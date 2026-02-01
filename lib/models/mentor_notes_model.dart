// lib/models/mentor_notes_model.dart
import 'package:cloud_firestore/cloud_firestore.dart';

enum NoteType {
  student,     // Notes about a student overall
  internship,  // Notes about a specific internship
}

class MentorNote {
  final String id;
  final String mentorId;
  final String studentId;
  final String? internshipId;  // null for student-level notes
  final NoteType type;
  final String content;
  final DateTime createdAt;
  final DateTime lastModified;

  MentorNote({
    required this.id,
    required this.mentorId,
    required this.studentId,
    this.internshipId,
    required this.type,
    required this.content,
    required this.createdAt,
    required this.lastModified,
  });

  factory MentorNote.fromFirestore(DocumentSnapshot doc) {
    final data = doc.data() as Map<String, dynamic>;
    return MentorNote(
      id: doc.id,
      mentorId: data['mentorId'] ?? '',
      studentId: data['studentId'] ?? '',
      internshipId: data['internshipId'],
      type: NoteType.values.firstWhere(
        (e) => e.toString() == 'NoteType.${data['type']}',
        orElse: () => NoteType.student,
      ),
      content: data['content'] ?? '',
      createdAt: (data['createdAt'] as Timestamp).toDate(),
      lastModified: (data['lastModified'] as Timestamp).toDate(),
    );
  }

  Map<String, dynamic> toFirestore() {
    return {
      'mentorId': mentorId,
      'studentId': studentId,
      'internshipId': internshipId,
      'type': type.toString().split('.').last,
      'content': content,
      'createdAt': Timestamp.fromDate(createdAt),
      'lastModified': Timestamp.fromDate(lastModified),
    };
  }

  MentorNote copyWith({
    String? id,
    String? mentorId,
    String? studentId,
    String? internshipId,
    NoteType? type,
    String? content,
    DateTime? createdAt,
    DateTime? lastModified,
  }) {
    return MentorNote(
      id: id ?? this.id,
      mentorId: mentorId ?? this.mentorId,
      studentId: studentId ?? this.studentId,
      internshipId: internshipId ?? this.internshipId,
      type: type ?? this.type,
      content: content ?? this.content,
      createdAt: createdAt ?? this.createdAt,
      lastModified: lastModified ?? this.lastModified,
    );
  }
}