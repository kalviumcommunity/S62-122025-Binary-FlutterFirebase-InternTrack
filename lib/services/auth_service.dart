// lib/services/auth_service.dart (UPDATED)
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

  // UPDATED: Sign up with automatic role detection
  Future<UserModel?> signUp({
    required String email,
    required String password,
    required String displayName,
  }) async {
    try {
      // Check if email has a mentor invitation
      final invitation = await _mentorService.checkInvitation(email.trim());
      final role = invitation != null ? 'mentor' : 'student';

      // Create user in Firebase Auth
      final userCredential = await _auth.createUserWithEmailAndPassword(
        email: email.trim(),
        password: password.trim(),
      );

      final user = userCredential.user;
      if (user == null) return null;

      await user.updateDisplayName(displayName.trim());
      await user.reload();

      // Create user document with determined role
      final userModel = UserModel(
        uid: user.uid,
        email: email.trim(),
        displayName: displayName.trim(),
        role: role,
        createdAt: DateTime.now(),
        lastLoginAt: DateTime.now(),
      );

      await _firestore.collection('users').doc(user.uid).set(userModel.toMap());

      // If mentor, create the mentor-student link
      if (role == 'mentor' && invitation != null) {
        await _mentorService.createMentorLink(
          mentorId: user.uid,
          studentId: invitation['studentId'] as String,
          studentName: invitation['studentName'] as String,
          studentEmail: invitation['studentEmail'] as String,
          inviteId: invitation['id'] as String,
        );
      }

      return userModel;
    } on FirebaseAuthException catch (e) {
      throw _handleAuthException(e);
    } catch (e) {
      throw 'An unexpected error occurred. Please try again.';
    }
  }

  // Sign in (unchanged)
  Future<UserModel?> signIn({
    required String email,
    required String password,
  }) async {
    try {
      final userCredential = await _auth.signInWithEmailAndPassword(
        email: email.trim(),
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
          email: user.email ?? email.trim(),
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