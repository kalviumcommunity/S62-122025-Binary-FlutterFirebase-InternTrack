// lib/models/mentorship_timeline_model.dart
import 'package:cloud_firestore/cloud_firestore.dart';

enum TimelineEventType {
  feedbackGiven,
  requestAnswered,
  statusChanged,
  noteAdded,
  resumeRequested,
  reflectionRequested,
  reviewed,
  studentLinked,
  internshipAdded,
}

class MentorshipTimelineEvent {
  final String id;
  final String mentorId;
  final String studentId;
  final String? internshipId;
  final TimelineEventType type;
  final String title;
  final String description;
  final DateTime timestamp;
  final Map<String, dynamic>? metadata;

  MentorshipTimelineEvent({
    required this.id,
    required this.mentorId,
    required this.studentId,
    this.internshipId,
    required this.type,
    required this.title,
    required this.description,
    required this.timestamp,
    this.metadata,
  });

  factory MentorshipTimelineEvent.fromFirestore(DocumentSnapshot doc) {
    final data = doc.data() as Map<String, dynamic>;
    return MentorshipTimelineEvent(
      id: doc.id,
      mentorId: data['mentorId'] ?? '',
      studentId: data['studentId'] ?? '',
      internshipId: data['internshipId'],
      type: TimelineEventType.values.firstWhere(
        (e) => e.toString() == 'TimelineEventType.${data['type']}',
        orElse: () => TimelineEventType.reviewed,
      ),
      title: data['title'] ?? '',
      description: data['description'] ?? '',
      timestamp: (data['timestamp'] as Timestamp).toDate(),
      metadata: data['metadata'] as Map<String, dynamic>?,
    );
  }

  Map<String, dynamic> toFirestore() {
    return {
      'mentorId': mentorId,
      'studentId': studentId,
      'internshipId': internshipId,
      'type': type.toString().split('.').last,
      'title': title,
      'description': description,
      'timestamp': Timestamp.fromDate(timestamp),
      'metadata': metadata,
    };
  }
}