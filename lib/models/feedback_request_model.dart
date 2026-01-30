// lib\models\feedback_request_model.dart
import 'package:cloud_firestore/cloud_firestore.dart';

class FeedbackRequest {
  final String id;
  final String internshipId;
  final String studentId;
  final String studentName;
  final String mentorId;
  final String message;
  final String status;
  final DateTime createdAt;
  final String company;

  FeedbackRequest({
    required this.id,
    required this.internshipId,
    required this.studentId,
    required this.studentName,
    required this.mentorId,
    required this.message,
    required this.company,
    required this.status,
    required this.createdAt,
  });

  factory FeedbackRequest.fromFirestore(DocumentSnapshot doc) {
    final data = doc.data() as Map<String, dynamic>;

    return FeedbackRequest(
      id: doc.id,
      internshipId: data['internshipId'] ?? '',
      studentId: data['studentId'] ?? '',
      studentName: data['studentName'] ?? 'Student',
      mentorId: data['mentorId'] ?? '',
      message: data['message'] ?? '',
      company: data['company'] ?? 'Unknown Company',
      status: data['status'] ?? 'pending',
      createdAt: (data['createdAt'] as Timestamp?)?.toDate() ?? DateTime.now(),
    );
  }

  Map<String, dynamic> toMap() => {
        'internshipId': internshipId,
        'studentId': studentId,
        'studentName': studentName,
        'mentorId': mentorId,
        'message': message,
        'company': company,
        'status': status,
        'createdAt': Timestamp.now(),
      };
}
