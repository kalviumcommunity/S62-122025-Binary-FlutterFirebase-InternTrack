// lib/services/mentor_service.dart
import 'package:cloud_firestore/cloud_firestore.dart';
import '../models/mentor_invitation_model.dart';
import '../models/internship_model.dart';

class MentorService {
  final FirebaseFirestore _firestore = FirebaseFirestore.instance;

  // Send mentor invitation
  Future<void> sendInvitation({
    required String studentId,
    required String studentName,
    required String studentEmail,
    required String mentorEmail,
  }) async {
    try {
      final invitation = MentorInvitation(
        id: '',
        studentId: studentId,
        studentName: studentName,
        studentEmail: studentEmail,
        mentorEmail: mentorEmail,
        status: InvitationStatus.pending,
        createdAt: DateTime.now(),
      );

      await _firestore.collection('mentorInvites').add(invitation.toFirestore());
    } catch (e) {
      throw 'Failed to send invitation: ${e.toString()}';
    }
  }

  // Check if email has pending invitation
  Future<MentorInvitation?> checkInvitation(String email) async {
    try {
      final snapshot = await _firestore
          .collection('mentorInvites')
          .where('mentorEmail', isEqualTo: email)
          .where('status', isEqualTo: 'pending')
          .limit(1)
          .get();

      if (snapshot.docs.isEmpty) return null;
      return MentorInvitation.fromFirestore(snapshot.docs.first);
    } catch (e) {
      throw 'Failed to check invitation: ${e.toString()}';
    }
  }

  // Create mentor-student link after signup
  Future<void> createMentorLink({
    required String mentorId,
    required String studentId,
    required String studentName,
    required String studentEmail,
    required String inviteId,
  }) async {
    try {
      final link = MentorStudentLink(
        id: '',
        mentorId: mentorId,
        studentId: studentId,
        studentName: studentName,
        studentEmail: studentEmail,
        linkedAt: DateTime.now(),
      );

      // Create link
      await _firestore.collection('mentorStudentLinks').add(link.toFirestore());

      // Update invitation status
      await _firestore.collection('mentorInvites').doc(inviteId).update({
        'status': 'accepted',
        'respondedAt': Timestamp.now(),
      });
    } catch (e) {
      throw 'Failed to create mentor link: ${e.toString()}';
    }
  }

  // Get mentor's students
  Stream<List<MentorStudentLink>> getStudentsStream(String mentorId) {
    return _firestore
        .collection('mentorStudentLinks')
        .where('mentorId', isEqualTo: mentorId)
        .orderBy('linkedAt', descending: true)
        .snapshots()
        .map((snapshot) => snapshot.docs
            .map((doc) => MentorStudentLink.fromFirestore(doc))
            .toList());
  }

  // Get student's internships (for mentor to view)
  Stream<List<Internship>> getStudentInternshipsStream(String studentId) {
    return _firestore
        .collection('internships')
        .where('studentId', isEqualTo: studentId)
        .where('isArchived', isEqualTo: false)
        .orderBy('appliedDate', descending: true)
        .snapshots()
        .map((snapshot) => snapshot.docs
            .map((doc) => Internship.fromFirestore(doc))
            .toList());
  }

  // Check if mentor is linked to student
  Future<bool> isMentorLinkedToStudent(String mentorId, String studentId) async {
    try {
      final snapshot = await _firestore
          .collection('mentorStudentLinks')
          .where('mentorId', isEqualTo: mentorId)
          .where('studentId', isEqualTo: studentId)
          .limit(1)
          .get();

      return snapshot.docs.isNotEmpty;
    } catch (e) {
      return false;
    }
  }
}