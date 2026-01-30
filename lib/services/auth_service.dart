// lib\services\auth_service.dart
import 'package:firebase_auth/firebase_auth.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import '../models/user_model.dart';
import 'mentor_service.dart';

class AuthService {
  final FirebaseAuth _auth = FirebaseAuth.instance;
  final FirebaseFirestore _firestore = FirebaseFirestore.instance;
  final MentorService _mentorService = MentorService();

  Stream<User?> get authStateChanges => _auth.authStateChanges();
  User? get currentUser => _auth.currentUser;

  // Sign up with automatic role detection
  Future<UserModel?> signUp({
    required String email,
    required String password,
    required String displayName,
  }) async {
    try {
      print('AuthService: Starting signup for: $email');
      
      final normalizedEmail = email.trim().toLowerCase();
      
      // Check if email has a mentor invitation
      final invitationSnapshot = await _firestore
          .collection('mentorInvites')
          .where('mentorEmail', isEqualTo: normalizedEmail)
          .where('status', isEqualTo: 'pending')
          .get();

      final bool hasMentorInvitation = invitationSnapshot.docs.isNotEmpty;
      final role = hasMentorInvitation ? 'mentor' : 'student';
      
      print('AuthService: Found ${invitationSnapshot.docs.length} pending invitations');
      print('AuthService: Role determined as: $role');

      // Create user in Firebase Auth
      final userCredential = await _auth.createUserWithEmailAndPassword(
        email: normalizedEmail,
        password: password.trim(),
      );

      final user = userCredential.user;
      if (user == null) {
        print('AuthService ERROR: User creation returned null');
        return null;
      }

      await user.updateDisplayName(displayName.trim());
      await user.reload();

      // Create user document with determined role
      final userModel = UserModel(
        uid: user.uid,
        email: normalizedEmail,
        displayName: displayName.trim(),
        role: role,
        createdAt: DateTime.now(),
        lastLoginAt: DateTime.now(),
      );

      print('AuthService: Creating user document with role: $role');
      await _firestore.collection('users').doc(user.uid).set(userModel.toMap());

      // If mentor, create mentor-student links for ALL pending invitations
      if (role == 'mentor' && hasMentorInvitation) {
        print('AuthService: Processing ${invitationSnapshot.docs.length} mentor invitations');
        
        for (var inviteDoc in invitationSnapshot.docs) {
          try {
            final inviteData = inviteDoc.data();
            
            print('AuthService: Creating link for student: ${inviteData['studentId']}');
            
            await _mentorService.createMentorLink(
              mentorId: user.uid,
              studentId: inviteData['studentId'] as String,
              studentName: inviteData['studentName'] as String,
              studentEmail: inviteData['studentEmail'] as String,
              inviteId: inviteDoc.id,
            );
            
            print('AuthService: Successfully created link for invitation ${inviteDoc.id}');
          } catch (e) {
            print('AuthService ERROR creating link for invitation ${inviteDoc.id}: $e');
            // Continue with other invitations even if one fails
          }
        }
        
        print('AuthService: Completed processing all mentor invitations');
      }

      print('AuthService: Signup completed successfully for ${userModel.role}');
      return userModel;
    } on FirebaseAuthException catch (e) {
      print('AuthService ERROR (FirebaseAuth): ${e.code} - ${e.message}');
      throw _handleAuthException(e);
    } catch (e) {
      print('AuthService ERROR (General): $e');
      throw 'An unexpected error occurred. Please try again.';
    }
  }

  // Sign in
  Future<UserModel?> signIn({
    required String email,
    required String password,
  }) async {
    try {
      final normalizedEmail = email.trim().toLowerCase();
      
      final userCredential = await _auth.signInWithEmailAndPassword(
        email: normalizedEmail,
        password: password.trim(),
      );

      final user = userCredential.user;
      if (user == null) return null;

      await _firestore.collection('users').doc(user.uid).update({
        'lastLoginAt': Timestamp.fromDate(DateTime.now()),
      });

      final userDoc = await _firestore.collection('users').doc(user.uid).get();
      
      if (!userDoc.exists) {
        final userModel = UserModel(
          uid: user.uid,
          email: normalizedEmail,
          displayName: user.displayName ?? 'User',
          role: 'student',
          createdAt: DateTime.now(),
          lastLoginAt: DateTime.now(),
        );
        await _firestore.collection('users').doc(user.uid).set(userModel.toMap());
        return userModel;
      }

      return UserModel.fromMap(userDoc.data()!);
    } on FirebaseAuthException catch (e) {
      throw _handleAuthException(e);
    } catch (e) {
      throw 'An unexpected error occurred. Please try again.';
    }
  }

  Future<void> signOut() async {
    try {
      await _auth.signOut();
    } catch (e) {
      throw 'Failed to sign out. Please try again.';
    }
  }

  Future<UserModel?> getUserData(String uid) async {
    try {
      final doc = await _firestore.collection('users').doc(uid).get();
      if (!doc.exists) return null;
      return UserModel.fromMap(doc.data()!);
    } catch (e) {
      throw 'Failed to fetch user data.';
    }
  }

  String _handleAuthException(FirebaseAuthException e) {
    switch (e.code) {
      case 'weak-password':
        return 'Password is too weak. Please use at least 6 characters.';
      case 'email-already-in-use':
        return 'An account already exists with this email.';
      case 'user-not-found':
        return 'No account found with this email.';
      case 'wrong-password':
        return 'Incorrect password. Please try again.';
      case 'invalid-email':
        return 'Invalid email address.';
      case 'user-disabled':
        return 'This account has been disabled.';
      case 'too-many-requests':
        return 'Too many attempts. Please try again later.';
      case 'operation-not-allowed':
        return 'Operation not allowed. Please contact support.';
      case 'network-request-failed':
        return 'Network error. Please check your connection.';
      default:
        return e.message ?? 'Authentication failed. Please try again.';
    }
  }
}