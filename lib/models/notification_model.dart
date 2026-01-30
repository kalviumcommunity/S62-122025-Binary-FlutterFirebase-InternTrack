// lib/models/notification_model.dart - UPDATED
class NotificationModel {
  final String id;
  final String mentorId;  // ADDED
  final String mentorName;
  final String companyName;
  final String internshipId;
  final DateTime respondedAt;
  final bool seenByStudent;
  final String message;

  NotificationModel({
    required this.id,
    required this.mentorId,  // ADDED
    required this.mentorName,
    required this.companyName,
    required this.internshipId,
    required this.respondedAt,
    required this.seenByStudent,
    required this.message,
  });
}