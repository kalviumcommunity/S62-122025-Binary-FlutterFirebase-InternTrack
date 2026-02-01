// lib/services/mentor_notes_service.dart
import 'package:cloud_firestore/cloud_firestore.dart';
import '../models/mentor_notes_model.dart';

class MentorNotesService {
  final FirebaseFirestore _firestore = FirebaseFirestore.instance;

  /// Get student-level note for a mentor
  Stream<MentorNote?> getStudentNote({
    required String mentorId,
    required String studentId,
  }) {
    return _firestore
        .collection('mentorNotes')
        .where('mentorId', isEqualTo: mentorId)
        .where('studentId', isEqualTo: studentId)
        .where('type', isEqualTo: 'student')
        .limit(1)
        .snapshots()
        .map((snapshot) {
          if (snapshot.docs.isEmpty) return null;
          return MentorNote.fromFirestore(snapshot.docs.first);
        });
  }

  /// Get internship-level note for a mentor
  Stream<MentorNote?> getInternshipNote({
    required String mentorId,
    required String internshipId,
  }) {
    return _firestore
        .collection('mentorNotes')
        .where('mentorId', isEqualTo: mentorId)
        .where('internshipId', isEqualTo: internshipId)
        .where('type', isEqualTo: 'internship')
        .limit(1)
        .snapshots()
        .map((snapshot) {
          if (snapshot.docs.isEmpty) return null;
          return MentorNote.fromFirestore(snapshot.docs.first);
        });
  }

  /// Save or update student note
  Future<void> saveStudentNote({
    required String mentorId,
    required String studentId,
    required String content,
  }) async {
    try {
      // Check if note exists
      final existing = await _firestore
          .collection('mentorNotes')
          .where('mentorId', isEqualTo: mentorId)
          .where('studentId', isEqualTo: studentId)
          .where('type', isEqualTo: 'student')
          .limit(1)
          .get();

      final now = DateTime.now();

      if (existing.docs.isEmpty) {
        // Create new note
        await _firestore.collection('mentorNotes').add({
          'mentorId': mentorId,
          'studentId': studentId,
          'internshipId': null,
          'type': 'student',
          'content': content,
          'createdAt': Timestamp.fromDate(now),
          'lastModified': Timestamp.fromDate(now),
        });
      } else {
        // Update existing note
        await _firestore.collection('mentorNotes').doc(existing.docs.first.id).update({
          'content': content,
          'lastModified': Timestamp.fromDate(now),
        });
      }
    } catch (e) {
      print('MentorNotesService ERROR saving student note: $e');
      throw 'Failed to save note: $e';
    }
  }

  /// Save or update internship note
  Future<void> saveInternshipNote({
    required String mentorId,
    required String studentId,
    required String internshipId,
    required String content,
  }) async {
    try {
      // Check if note exists
      final existing = await _firestore
          .collection('mentorNotes')
          .where('mentorId', isEqualTo: mentorId)
          .where('internshipId', isEqualTo: internshipId)
          .where('type', isEqualTo: 'internship')
          .limit(1)
          .get();

      final now = DateTime.now();

      if (existing.docs.isEmpty) {
        // Create new note
        await _firestore.collection('mentorNotes').add({
          'mentorId': mentorId,
          'studentId': studentId,
          'internshipId': internshipId,
          'type': 'internship',
          'content': content,
          'createdAt': Timestamp.fromDate(now),
          'lastModified': Timestamp.fromDate(now),
        });
      } else {
        // Update existing note
        await _firestore.collection('mentorNotes').doc(existing.docs.first.id).update({
          'content': content,
          'lastModified': Timestamp.fromDate(now),
        });
      }
    } catch (e) {
      print('MentorNotesService ERROR saving internship note: $e');
      throw 'Failed to save note: $e';
    }
  }

  /// Delete note
  Future<void> deleteNote(String noteId) async {
    try {
      await _firestore.collection('mentorNotes').doc(noteId).delete();
    } catch (e) {
      print('MentorNotesService ERROR deleting note: $e');
      throw 'Failed to delete note: $e';
    }
  }
}