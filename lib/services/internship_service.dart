import 'package:cloud_firestore/cloud_firestore.dart';
import '../models/internship_model.dart';

class InternshipService {
  final FirebaseFirestore _firestore = FirebaseFirestore.instance;
  final String _collection = 'internships';

  // Get internships stream for a student
  Stream<List<Internship>> getInternshipsStream(String studentId, {bool includeArchived = false}) {
    Query query = _firestore
        .collection(_collection)
        .where('studentId', isEqualTo: studentId);
    
    if (!includeArchived) {
      query = query.where('isArchived', isEqualTo: false);
    }
    
    return query.snapshots().map((snapshot) {
      return snapshot.docs.map((doc) => Internship.fromFirestore(doc)).toList();
    });
  }

  // Get archived internships stream
  Stream<List<Internship>> getArchivedInternshipsStream(String studentId) {
    return _firestore
        .collection(_collection)
        .where('studentId', isEqualTo: studentId)
        .where('isArchived', isEqualTo: true)
        .orderBy('archivedDate', descending: true)
        .snapshots()
        .map((snapshot) {
      return snapshot.docs.map((doc) => Internship.fromFirestore(doc)).toList();
    });
  }

  // Add new internship
  Future<String> addInternship(Internship internship) async {
    try {
      final docRef = await _firestore.collection(_collection).add(internship.toFirestore());
      return docRef.id;
    } catch (e) {
      throw Exception('Failed to add internship: $e');
    }
  }

  // Update internship
  Future<void> updateInternship(String id, Map<String, dynamic> updates) async {
    try {
      await _firestore.collection(_collection).doc(id).update(updates);
    } catch (e) {
      throw Exception('Failed to update internship: $e');
    }
  }

  // Delete internship
  Future<void> deleteInternship(String id) async {
    try {
      await _firestore.collection(_collection).doc(id).delete();
    } catch (e) {
      throw Exception('Failed to delete internship: $e');
    }
  }

  // Archive internship
  Future<void> archiveInternship(String id) async {
    try {
      await _firestore.collection(_collection).doc(id).update({
        'isArchived': true,
        'archivedDate': Timestamp.now(),
      });
    } catch (e) {
      throw Exception('Failed to archive internship: $e');
    }
  }

  // Restore archived internship
  Future<void> restoreInternship(String id) async {
    try {
      await _firestore.collection(_collection).doc(id).update({
        'isArchived': false,
        'archivedDate': null,
      });
    } catch (e) {
      throw Exception('Failed to restore internship: $e');
    }
  }

  // Update reflection notes
  Future<void> updateReflectionNotes(String id, String notes) async {
    try {
      await _firestore.collection(_collection).doc(id).update({
        'reflectionNotes': notes,
      });
    } catch (e) {
      throw Exception('Failed to update reflection notes: $e');
    }
  }

  // Update learning outcomes and skills
  Future<void> updateLearningOutcomes(String id, String outcomes, List<String> skills) async {
    try {
      await _firestore.collection(_collection).doc(id).update({
        'learningOutcomes': outcomes,
        'skillsGained': skills,
      });
    } catch (e) {
      throw Exception('Failed to update learning outcomes: $e');
    }
  }

  // Add timeline event
  Future<void> addTimelineEvent(String id, TimelineEvent event, List<TimelineEvent> existingTimeline) async {
    try {
      final updatedTimeline = [...existingTimeline, event];
      await _firestore.collection(_collection).doc(id).update({
        'timeline': updatedTimeline.map((e) => e.toMap()).toList(),
      });
    } catch (e) {
      throw Exception('Failed to add timeline event: $e');
    }
  }
}