import 'package:cloud_firestore/cloud_firestore.dart';
import '../models/mentor_invitation_model.dart';
import '../models/internship_model.dart';
import '../models/feedback_request_model.dart';

class MentorService {
  final FirebaseFirestore _firestore = FirebaseFirestore.instance;

  // Send mentor invitation
  Future<void> sendInvitation({
    required String studentId,
    required String studentName,
    required String studentEmail,
    required String mentorEmail,
  }) async {
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
  }

  Future<MentorInvitation?> checkInvitation(String email) async {
    final snapshot = await _firestore
        .collection('mentorInvites')
        .where('mentorEmail', isEqualTo: email)
        .where('status', isEqualTo: 'pending')
        .limit(1)
        .get();

    if (snapshot.docs.isEmpty) return null;
    return MentorInvitation.fromFirestore(snapshot.docs.first);
  }

  Future<void> createMentorLink({
    required String mentorId,
    required String studentId,
    required String studentName,
    required String studentEmail,
    required String inviteId,
  }) async {
    final link = MentorStudentLink(
      id: '',
      mentorId: mentorId,
      studentId: studentId,
      studentName: studentName,
      studentEmail: studentEmail,
      linkedAt: DateTime.now(),
    );

    await _firestore.collection('mentorStudentLinks').add(link.toFirestore());

    await _firestore.collection('mentorInvites').doc(inviteId).update({
      'status': 'accepted',
      'respondedAt': Timestamp.now(),
    });
  }

  Stream<List<MentorStudentLink>> getStudentsStream(String mentorId) {
    return _firestore
        .collection('mentorStudentLinks')
        .where('mentorId', isEqualTo: mentorId)
        .orderBy('linkedAt', descending: true)
        .snapshots()
        .map((s) =>
            s.docs.map((d) => MentorStudentLink.fromFirestore(d)).toList());
  }

  // Feedback Requests

  Future<String?> getMentorIdByEmail(String email) async {
    final res = await _firestore
        .collection('users')
        .where('email', isEqualTo: email)
        .where('role', isEqualTo: 'mentor')
        .limit(1)
        .get();

    if (res.docs.isEmpty) return null;
    return res.docs.first.id;
  }

  Future<void> createFeedbackRequest(Map<String, dynamic> data) async {
    await _firestore.collection('feedbackRequests').add(data);
  }

  Stream<List<FeedbackRequest>> getMentorRequests(String mentorId) {
    return _firestore
        .collection('feedbackRequests')
        .where('mentorId', isEqualTo: mentorId)
        .where('status', isEqualTo: 'pending')
        .snapshots()
        .map((snap) =>
            snap.docs.map((d) => FeedbackRequest.fromFirestore(d)).toList());
  }

  // Internships

  Stream<List<Internship>> getStudentInternshipsStream(String studentId) {
    return _firestore
        .collection('internships')
        .where('studentId', isEqualTo: studentId)
        .where('isArchived', isEqualTo: false)
        .orderBy('appliedDate', descending: true)
        .snapshots()
        .map((s) => s.docs.map((d) => Internship.fromFirestore(d)).toList());
  }

  Future<bool> isMentorLinkedToStudent(String mentorId, String studentId) async {
    final snapshot = await _firestore
        .collection('mentorStudentLinks')
        .where('mentorId', isEqualTo: mentorId)
        .where('studentId', isEqualTo: studentId)
        .limit(1)
        .get();

    return snapshot.docs.isNotEmpty;
  }
}
