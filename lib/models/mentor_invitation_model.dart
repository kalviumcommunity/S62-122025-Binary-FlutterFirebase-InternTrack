// lib/models/mentor_invitation_model.dart
import 'package:cloud_firestore/cloud_firestore.dart';

enum InvitationStatus {
  pending,
  accepted,
  rejected
}

class MentorInvitation {
  final String id;
  final String studentId;
  final String studentName;
  final String studentEmail;
  final String mentorEmail;
  final InvitationStatus status;
  final DateTime createdAt;
  final DateTime? respondedAt;

  MentorInvitation({
    required this.id,
    required this.studentId,
    required this.studentName,
    required this.studentEmail,
    required this.mentorEmail,
    required this.status,
    required this.createdAt,
    this.respondedAt,
  });

  factory MentorInvitation.fromFirestore(DocumentSnapshot doc) {
    Map<String, dynamic> data = doc.data() as Map<String, dynamic>;
    return MentorInvitation(
      id: doc.id,
      studentId: data['studentId'] ?? '',
      studentName: data['studentName'] ?? '',
      studentEmail: data['studentEmail'] ?? '',
      mentorEmail: data['mentorEmail'] ?? '',
      status: InvitationStatus.values.firstWhere(
        (e) => e.toString() == 'InvitationStatus.${data['status']}',
        orElse: () => InvitationStatus.pending,
      ),
      createdAt: (data['createdAt'] as Timestamp).toDate(),
      respondedAt: data['respondedAt'] != null 
          ? (data['respondedAt'] as Timestamp).toDate() 
          : null,
    );
  }

  Map<String, dynamic> toFirestore() {
    return {
      'studentId': studentId,
      'studentName': studentName,
      'studentEmail': studentEmail,
      'mentorEmail': mentorEmail,
      'status': status.toString().split('.').last,
      'createdAt': Timestamp.fromDate(createdAt),
      'respondedAt': respondedAt != null ? Timestamp.fromDate(respondedAt!) : null,
    };
  }
}

class MentorStudentLink {
  final String id;
  final String mentorId;
  final String studentId;
  final String studentName;
  final String studentEmail;
  final DateTime linkedAt;

  MentorStudentLink({
    required this.id,
    required this.mentorId,
    required this.studentId,
    required this.studentName,
    required this.studentEmail,
    required this.linkedAt,
  });

  factory MentorStudentLink.fromFirestore(DocumentSnapshot doc) {
    Map<String, dynamic> data = doc.data() as Map<String, dynamic>;
    return MentorStudentLink(
      id: doc.id,
      mentorId: data['mentorId'] ?? '',
      studentId: data['studentId'] ?? '',
      studentName: data['studentName'] ?? '',
      studentEmail: data['studentEmail'] ?? '',
      linkedAt: (data['linkedAt'] as Timestamp).toDate(),
    );
  }

  Map<String, dynamic> toFirestore() {
    return {
      'mentorId': mentorId,
      'studentId': studentId,
      'studentName': studentName,
      'studentEmail': studentEmail,
      'linkedAt': Timestamp.fromDate(linkedAt),
    };
  }
}