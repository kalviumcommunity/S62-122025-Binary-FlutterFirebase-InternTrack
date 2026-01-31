// lib/models/mentor_activity_model.dart
import 'package:cloud_firestore/cloud_firestore.dart';

enum MentorActivityType {
  feedbackGiven,
  studentAdded,
  requestReceived,
  internshipViewed,
}

class MentorActivity {
  final String id;
  final String mentorId;
  final MentorActivityType type;
  final String title;
  final String description;
  final DateTime timestamp;
  final Map<String, dynamic>? metadata;

  MentorActivity({
    required this.id,
    required this.mentorId,
    required this.type,
    required this.title,
    required this.description,
    required this.timestamp,
    this.metadata,
  });

  factory MentorActivity.fromFirestore(DocumentSnapshot doc) {
    final data = doc.data() as Map<String, dynamic>;
    return MentorActivity(
      id: doc.id,
      mentorId: data['mentorId'] ?? '',
      type: MentorActivityType.values.firstWhere(
        (e) => e.toString() == 'MentorActivityType.${data['type']}',
        orElse: () => MentorActivityType.internshipViewed,
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
      'type': type.toString().split('.').last,
      'title': title,
      'description': description,
      'timestamp': Timestamp.fromDate(timestamp),
      'metadata': metadata,
    };
  }
}