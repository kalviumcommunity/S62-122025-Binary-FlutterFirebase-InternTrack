import 'package:cloud_firestore/cloud_firestore.dart';
import '../models/resume_model.dart';

class ResumeService {
  final FirebaseFirestore _firestore = FirebaseFirestore.instance;

  // Save resume with full metadata
  Future<void> saveResume(ResumeModel resume) async {
    try {
      // Save to user document for quick access
      await _firestore.collection('users').doc(resume.userId).update({
        'resumeUrl': resume.cloudinaryUrl,
        'resumeFileName': resume.fileName,
        'resumeUpdatedAt': Timestamp.now(),
      });

      // Also save full metadata in resumes collection
      await _firestore
          .collection('resumes')
          .doc(resume.id)
          .set(resume.toMap());
    } catch (e) {
      throw 'Failed to save resume: ${e.toString()}';
    }
  }

  // Get resume by user ID
  Future<ResumeModel?> getResumeByUserId(String userId) async {
    try {
      final snapshot = await _firestore
          .collection('resumes')
          .where('userId', isEqualTo: userId)
          .limit(1)
          .get();

      if (snapshot.docs.isEmpty) return null;
      
      return ResumeModel.fromFirestore(snapshot.docs.first);
    } catch (e) {
      throw 'Failed to fetch resume: ${e.toString()}';
    }
  }

  // Get resume URL (legacy support)
  Future<String?> getResumeUrl(String userId) async {
    try {
      final doc = await _firestore.collection('users').doc(userId).get();
      if (doc.exists) {
        return doc.data()?['resumeUrl'] as String?;
      }
      return null;
    } catch (e) {
      throw 'Failed to fetch resume URL: ${e.toString()}';
    }
  }

  // Get resume filename
  Future<String?> getResumeFileName(String userId) async {
    try {
      final doc = await _firestore.collection('users').doc(userId).get();
      if (doc.exists) {
        return doc.data()?['resumeFileName'] as String?;
      }
      return null;
    } catch (e) {
      throw 'Failed to fetch resume filename: ${e.toString()}';
    }
  }

  // Delete resume
  Future<void> deleteResume(String userId, String resumeId) async {
    try {
      // Delete from user document
      await _firestore.collection('users').doc(userId).update({
        'resumeUrl': FieldValue.delete(),
        'resumeFileName': FieldValue.delete(),
        'resumeUpdatedAt': FieldValue.delete(),
      });

      // Delete from resumes collection
      await _firestore.collection('resumes').doc(resumeId).delete();
    } catch (e) {
      throw 'Failed to delete resume: ${e.toString()}';
    }
  }

  // Stream resume
  Stream<ResumeModel?> streamResume(String userId) {
    return _firestore
        .collection('resumes')
        .where('userId', isEqualTo: userId)
        .limit(1)
        .snapshots()
        .map((snapshot) {
          if (snapshot.docs.isEmpty) return null;
          return ResumeModel.fromFirestore(snapshot.docs.first);
        });
  }

  // Stream resume URL (legacy support)
  Stream<String?> streamResumeUrl(String userId) {
    return _firestore
        .collection('users')
        .doc(userId)
        .snapshots()
        .map((doc) => doc.data()?['resumeUrl'] as String?);
  }

  // Stream resume filename
  Stream<String?> streamResumeFileName(String userId) {
    return _firestore
        .collection('users')
        .doc(userId)
        .snapshots()
        .map((doc) => doc.data()?['resumeFileName'] as String?);
  }
}