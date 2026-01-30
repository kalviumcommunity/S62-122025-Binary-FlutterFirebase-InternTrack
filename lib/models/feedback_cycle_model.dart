// lib\models\feedback_cycle_model.dart
import 'package:cloud_firestore/cloud_firestore.dart';

class FeedbackCycle {
  final String id;
  final String internshipId;
  final String studentId;
  final String mentorId;
  final String studentRequest;
  final String? mentorFeedback;
  final String? suggestedNextStep;
  final String status; // 'pending', 'completed'
  final DateTime requestedAt;
  final DateTime? respondedAt;
  final bool seenByStudent;

  FeedbackCycle({
    required this.id,
    required this.internshipId,
    required this.studentId,
    required this.mentorId,
    required this.studentRequest,
    this.mentorFeedback,
    this.suggestedNextStep,
    required this.status,
    required this.requestedAt,
    this.respondedAt,
    this.seenByStudent = false,
  });

  factory FeedbackCycle.fromFirestore(DocumentSnapshot doc) {
    final data = doc.data() as Map<String, dynamic>;
    return FeedbackCycle(
      id: doc.id,
      internshipId: data['internshipId'] ?? '',
      studentId: data['studentId'] ?? '',
      mentorId: data['mentorId'] ?? '',
      studentRequest: data['studentRequest'] ?? '',
      mentorFeedback: data['mentorFeedback'],
      suggestedNextStep: data['suggestedNextStep'],
      status: data['status'] ?? 'pending',
      requestedAt: (data['requestedAt'] as Timestamp).toDate(),
      respondedAt: data['respondedAt'] != null 
          ? (data['respondedAt'] as Timestamp).toDate() 
          : null,
      seenByStudent: data['seenByStudent'] ?? false,
    );
  }

  Map<String, dynamic> toFirestore() {
    return {
      'internshipId': internshipId,
      'studentId': studentId,
      'mentorId': mentorId,
      'studentRequest': studentRequest,
      'mentorFeedback': mentorFeedback,
      'suggestedNextStep': suggestedNextStep,
      'status': status,
      'requestedAt': Timestamp.fromDate(requestedAt),
      'respondedAt': respondedAt != null ? Timestamp.fromDate(respondedAt!) : null,
      'seenByStudent': seenByStudent,
    };
  }
}