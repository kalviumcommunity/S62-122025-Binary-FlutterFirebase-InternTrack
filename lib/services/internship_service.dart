// lib\services\internship_service.dart
import 'package:cloud_firestore/cloud_firestore.dart';
import '../models/internship_model.dart';

class InternshipService {
  final FirebaseFirestore _firestore = FirebaseFirestore.instance;

  // Get internships stream for a student
  Stream<List<Internship>> getInternshipsStream(String studentId) {
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

  // Get archived internships stream
  Stream<List<Internship>> getArchivedInternshipsStream(String studentId) {
    return _firestore
        .collection('internships')
        .where('studentId', isEqualTo: studentId)
        .where('isArchived', isEqualTo: true)
        .orderBy('archivedDate', descending: true)
        .snapshots()
        .map((snapshot) => snapshot.docs
            .map((doc) => Internship.fromFirestore(doc))
            .toList());
  }

  // Add internship
  Future<void> addInternship(Internship internship) async {
    try {
      await _firestore.collection('internships').add(internship.toFirestore());
    } catch (e) {
      throw 'Failed to add internship: ${e.toString()}';
    }
  }

  // Update internship
  Future<void> updateInternship(String id, Map<String, dynamic> updates) async {
    try {
      await _firestore.collection('internships').doc(id).update(updates);
    } catch (e) {
      throw 'Failed to update internship: ${e.toString()}';
    }
  }

  // Delete internship
  Future<void> deleteInternship(String id) async {
    try {
      await _firestore.collection('internships').doc(id).delete();
    } catch (e) {
      throw 'Failed to delete internship: ${e.toString()}';
    }
  }

  // Archive internship
  Future<void> archiveInternship(String id) async {
    try {
      await _firestore.collection('internships').doc(id).update({
        'isArchived': true,
        'archivedDate': Timestamp.now(),
      });
    } catch (e) {
      throw 'Failed to archive internship: ${e.toString()}';
    }
  }

  // Restore internship
  Future<void> restoreInternship(String id) async {
    try {
      await _firestore.collection('internships').doc(id).update({
        'isArchived': false,
        'archivedDate': null,
      });
    } catch (e) {
      throw 'Failed to restore internship: ${e.toString()}';
    }
  }

  // Update reflection notes
  Future<void> updateReflectionNotes(String id, String notes) async {
    try {
      await _firestore.collection('internships').doc(id).update({
        'reflectionNotes': notes,
      });
    } catch (e) {
      throw 'Failed to update reflection: ${e.toString()}';
    }
  }

  // Update learning outcomes
  Future<void> updateLearningOutcomes(String id, String outcomes, List<String> skills) async {
    try {
      await _firestore.collection('internships').doc(id).update({
        'learningOutcomes': outcomes,
        'skillsGained': skills,
      });
    } catch (e) {
      throw 'Failed to update learning outcomes: ${e.toString()}';
    }
  }

  // Add timeline event
  Future<void> addTimelineEvent(String id, TimelineEvent event, List<TimelineEvent> existingTimeline) async {
    try {
      final updatedTimeline = [...existingTimeline, event];
      await _firestore.collection('internships').doc(id).update({
        'timeline': updatedTimeline.map((e) => e.toMap()).toList(),
      });
    } catch (e) {
      throw 'Failed to add timeline event: ${e.toString()}';
    }
  }
}