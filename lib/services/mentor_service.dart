// lib/services/mentor_service.dart
// FIXED: Now uses feedbackCycles collection instead of feedbackRequests
import 'package:cloud_firestore/cloud_firestore.dart';
import '../models/mentor_invitation_model.dart';
import '../models/internship_model.dart';
import '../models/feedback_cycle_model.dart';

class MentorService {
  final FirebaseFirestore _firestore = FirebaseFirestore.instance;

  // ==================== FEEDBACK CYCLES (NEW) ====================
  
  /// Get pending feedback cycles for a mentor
  /// This replaces the old getMentorRequests that used feedbackRequests collection
  Stream<List<FeedbackCycle>> getMentorPendingCycles(String mentorId) {
    print('MentorService: Streaming pending cycles for mentor: $mentorId');
    
    return _firestore
        .collection('feedbackCycles')
        .where('mentorId', isEqualTo: mentorId)
        .where('status', isEqualTo: 'pending')
        .orderBy('requestedAt', descending: true)
        .snapshots()
        .handleError((error) {
          print('MentorService ERROR in pending cycles stream: $error');
        })
        .map((snapshot) {
          print('MentorService: Received ${snapshot.docs.length} pending cycles');
          return snapshot.docs
              .map((doc) => FeedbackCycle.fromFirestore(doc))
              .toList();
        });
  }

  /// Submit mentor feedback for a cycle
  Future<void> submitFeedback({
    required String cycleId,
    required String feedback,
    String? nextStep,
  }) async {
    try {
      print('MentorService: Submitting feedback for cycle: $cycleId');
      
      await _firestore.collection('feedbackCycles').doc(cycleId).update({
        'mentorFeedback': feedback,
        'suggestedNextStep': nextStep,
        'status': 'completed',
        'respondedAt': Timestamp.now(),
        'seenByStudent': false,
      });
      
      print('MentorService: Successfully submitted feedback');
    } catch (e) {
      print('MentorService ERROR submitting feedback: $e');
      throw 'Failed to submit feedback: $e';
    }
  }

  // ==================== STUDENTS MANAGEMENT ====================

  /// Get stream of mentor's students
  Stream<List<MentorStudentLink>> getStudentsStream(String mentorId) {
    return _firestore
        .collection('mentorStudentLinks')
        .where('mentorId', isEqualTo: mentorId)
        .snapshots()
        .map((snapshot) {
      return snapshot.docs
          .map((doc) => MentorStudentLink.fromFirestore(doc))
          .toList();
    });
  }

  /// Get stream of a specific student's internships
  Stream<List<Internship>> getStudentInternshipsStream(String studentId) {
    return _firestore
        .collection('internships')
        .where('studentId', isEqualTo: studentId)
        .where('isArchived', isEqualTo: false)
        .orderBy('appliedDate', descending: true)
        .snapshots()
        .map((snapshot) {
      return snapshot.docs
          .map((doc) => Internship.fromFirestore(doc))
          .toList();
    });
  }

  // ==================== INVITATIONS ====================

  /// Check if there's a pending invitation for the given email
  /// Returns the invitation data if found, null otherwise
  Future<Map<String, dynamic>?> checkInvitation(String email) async {
    try {
      print('MentorService: Checking invitation for email: $email');
      
      final snapshot = await _firestore
          .collection('mentorInvites')
          .where('mentorEmail', isEqualTo: email.trim().toLowerCase())
          .where('status', isEqualTo: 'pending')
          .limit(1)
          .get();

      if (snapshot.docs.isEmpty) {
        print('MentorService: No pending invitation found');
        return null;
      }

      print('MentorService: Found pending invitation');
      return snapshot.docs.first.data();
    } catch (e) {
      print('MentorService ERROR checking invitation: $e');
      return null;
    }
  }

  /// Create mentor-student link from an invitation
  Future<void> createMentorLink({
    required String mentorId,
    required String studentId,
    required String studentName,
    required String studentEmail,
    required String inviteId,
  }) async {
    try {
      print('MentorService: Creating mentor link...');
      print('  mentorId: $mentorId');
      print('  studentId: $studentId');

      // Get mentor email
      final mentorDoc = await _firestore.collection('users').doc(mentorId).get();
      if (!mentorDoc.exists) {
        throw 'Mentor user not found';
      }
      final mentorEmail = mentorDoc.data()?['email'] ?? '';

      // Create the mentor-student link
      await _firestore.collection('mentorStudentLinks').add({
        'mentorId': mentorId,
        'mentorEmail': mentorEmail,
        'studentId': studentId,
        'studentName': studentName,
        'studentEmail': studentEmail,
        'linkedAt': Timestamp.now(),
      });

      // Update invitation status
      await _firestore.collection('mentorInvites').doc(inviteId).update({
        'status': 'accepted',
        'mentorId': mentorId,
        'acceptedAt': Timestamp.now(),
      });

      print('MentorService: Successfully created mentor link');
    } catch (e) {
      print('MentorService ERROR creating mentor link: $e');
      throw 'Failed to create mentor link: $e';
    }
  }

  /// Send mentor invitation
  Future<void> sendInvitation({
    required String studentId,
    required String studentName,
    required String studentEmail,
    required String mentorEmail,
  }) async {
    try {
      // Check if mentor exists
      final mentorSnapshot = await _firestore
          .collection('users')
          .where('email', isEqualTo: mentorEmail)
          .where('role', isEqualTo: 'mentor')
          .limit(1)
          .get();

      if (mentorSnapshot.docs.isEmpty) {
        throw 'No mentor found with email: $mentorEmail';
      }

      final mentorId = mentorSnapshot.docs.first.id;

      // Check if link already exists
      final existingLink = await _firestore
          .collection('mentorStudentLinks')
          .where('studentId', isEqualTo: studentId)
          .where('mentorId', isEqualTo: mentorId)
          .limit(1)
          .get();

      if (existingLink.docs.isNotEmpty) {
        throw 'Already linked with this mentor';
      }

      // Create the link
      await _firestore.collection('mentorStudentLinks').add({
        'studentId': studentId,
        'studentName': studentName,
        'studentEmail': studentEmail,
        'mentorId': mentorId,
        'mentorEmail': mentorEmail,
        'linkedAt': Timestamp.now(),
      });

      // Create notification/invitation record (optional)
      await _firestore.collection('mentorInvites').add({
        'studentId': studentId,
        'studentName': studentName,
        'studentEmail': studentEmail,
        'mentorEmail': mentorEmail,
        'mentorId': mentorId,
        'status': 'accepted',
        'sentAt': Timestamp.now(),
      });
    } catch (e) {
      print('MentorService ERROR sending invitation: $e');
      throw e;
    }
  }

  /// Remove mentor-student link
  Future<void> removeMentorLink(String linkId) async {
    try {
      await _firestore.collection('mentorStudentLinks').doc(linkId).delete();
    } catch (e) {
      print('MentorService ERROR removing link: $e');
      throw 'Failed to remove mentor link: $e';
    }
  }
}