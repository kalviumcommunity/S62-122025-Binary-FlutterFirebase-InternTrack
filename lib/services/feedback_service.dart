// lib\services\feedback_service.dart
import 'package:cloud_firestore/cloud_firestore.dart';
import '../models/feedback_cycle_model.dart';

class FeedbackService {
  final FirebaseFirestore _firestore = FirebaseFirestore.instance;

  // Get latest feedback cycle for an internship
  Future<FeedbackCycle?> getLatestFeedback(String internshipId) async {
    try {
      print('FeedbackService: Getting latest feedback for internship: $internshipId');
      
      final snapshot = await _firestore
          .collection('feedbackCycles')
          .where('internshipId', isEqualTo: internshipId)
          .orderBy('requestedAt', descending: true)
          .limit(1)
          .get();

      if (snapshot.docs.isEmpty) {
        print('FeedbackService: No feedback found for internship: $internshipId');
        return null;
      }
      
      print('FeedbackService: Found ${snapshot.docs.length} feedback cycle(s)');
      return FeedbackCycle.fromFirestore(snapshot.docs.first);
    } catch (e) {
      print('FeedbackService ERROR getting latest feedback: $e');
      // Don't throw, return null to show "no feedback" state
      return null;
    }
  }

  // Get all feedback history for an internship
  Stream<List<FeedbackCycle>> getFeedbackHistory(String internshipId) {
    print('FeedbackService: Streaming feedback history for internship: $internshipId');
    
    return _firestore
        .collection('feedbackCycles')
        .where('internshipId', isEqualTo: internshipId)
        .orderBy('requestedAt', descending: true)
        .snapshots()
        .handleError((error) {
          print('FeedbackService ERROR in history stream: $error');
        })
        .map((snapshot) {
          print('FeedbackService: Received ${snapshot.docs.length} feedback cycles in history');
          return snapshot.docs
              .map((doc) => FeedbackCycle.fromFirestore(doc))
              .toList();
        });
  }

  // Create a new feedback request
  Future<void> createFeedbackRequest({
    required String internshipId,
    required String studentId,
    required String mentorId,
    required String studentRequest,
  }) async {
    try {
      print('FeedbackService: Creating feedback request...');
      print('  internshipId: $internshipId');
      print('  studentId: $studentId');
      print('  mentorId: $mentorId');
      
      final cycle = FeedbackCycle(
        id: '',
        internshipId: internshipId,
        studentId: studentId,
        mentorId: mentorId,
        studentRequest: studentRequest,
        status: 'pending',
        requestedAt: DateTime.now(),
      );

      final docRef = await _firestore
          .collection('feedbackCycles')
          .add(cycle.toFirestore());
      
      print('FeedbackService: Successfully created feedback request with ID: ${docRef.id}');
    } catch (e) {
      print('FeedbackService ERROR creating feedback request: $e');
      throw 'Failed to create feedback request: $e';
    }
  }

  // Mark feedback as seen by student
  Future<void> markFeedbackAsSeen(String cycleId) async {
    try {
      print('FeedbackService: Marking feedback as seen: $cycleId');
      
      await _firestore.collection('feedbackCycles').doc(cycleId).update({
        'seenByStudent': true,
      });
      
      print('FeedbackService: Successfully marked as seen');
    } catch (e) {
      print('FeedbackService ERROR marking feedback as seen: $e');
      // Don't throw - this is not critical
    }
  }

  // Update feedback with mentor response
  Future<void> submitMentorFeedback({
    required String cycleId,
    required String feedback,
    String? nextStep,
  }) async {
    try {
      print('FeedbackService: Submitting mentor feedback for cycle: $cycleId');
      
      await _firestore.collection('feedbackCycles').doc(cycleId).update({
        'mentorFeedback': feedback,
        'suggestedNextStep': nextStep,
        'status': 'completed',
        'respondedAt': Timestamp.now(),
        'seenByStudent': false,
      });
      
      print('FeedbackService: Successfully submitted mentor feedback');
    } catch (e) {
      print('FeedbackService ERROR submitting mentor feedback: $e');
      throw 'Failed to submit feedback: $e';
    }
  }

  // Get pending feedback cycles for a mentor
  Stream<List<FeedbackCycle>> getMentorPendingRequests(String mentorId) {
    print('FeedbackService: Streaming pending requests for mentor: $mentorId');
    
    return _firestore
        .collection('feedbackCycles')
        .where('mentorId', isEqualTo: mentorId)
        .where('status', isEqualTo: 'pending')
        .orderBy('requestedAt', descending: true)
        .snapshots()
        .handleError((error) {
          print('FeedbackService ERROR in mentor requests stream: $error');
        })
        .map((snapshot) {
          print('FeedbackService: Received ${snapshot.docs.length} pending requests for mentor');
          return snapshot.docs
              .map((doc) => FeedbackCycle.fromFirestore(doc))
              .toList();
        });
  }
}