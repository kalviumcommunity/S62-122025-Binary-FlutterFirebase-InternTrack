// lib/services/notification_service.dart - FIXED VERSION
import 'package:cloud_firestore/cloud_firestore.dart';
import '../models/notification_model.dart';

class NotificationService {
  final FirebaseFirestore _firestore = FirebaseFirestore.instance;

  // Get all notifications for a student
  Stream<List<NotificationModel>> getNotifications(String studentId) {
    return _firestore
        .collection('feedbackCycles')
        .where('studentId', isEqualTo: studentId)
        .where('status', isEqualTo: 'completed')
        .orderBy('respondedAt', descending: true)
        .snapshots()
        .map((snapshot) {
      print('📬 NotificationService: Found ${snapshot.docs.length} feedback cycles');
      
      return snapshot.docs.map((doc) {
        final data = doc.data();
        
        // We'll fetch mentor/company names in the UI instead
        return NotificationModel(
          id: doc.id,
          mentorName: '', // Will be fetched in UI
          companyName: '', // Will be fetched in UI
          mentorId: data['mentorId'] as String,
          internshipId: data['internshipId'] as String,
          respondedAt: (data['respondedAt'] as Timestamp).toDate(),
          seenByStudent: data['seenByStudent'] as bool? ?? false,
          message: '', // Will be built in UI after fetching names
        );
      }).toList();
    });
  }

  // Get count of unseen notifications
  Stream<int> getUnseenCount(String studentId) {
    return _firestore
        .collection('feedbackCycles')
        .where('studentId', isEqualTo: studentId)
        .where('status', isEqualTo: 'completed')
        .where('seenByStudent', isEqualTo: false)
        .snapshots()
        .map((snapshot) {
          print(' Unseen count: ${snapshot.docs.length}');
          return snapshot.docs.length;
        });
  }

  // Mark notification as seen
  Future<void> markAsSeen(String cycleId) async {
    try {
      print(' Marking notification as seen: $cycleId');
      await _firestore.collection('feedbackCycles').doc(cycleId).update({
        'seenByStudent': true,
      });
    } catch (e) {
      print(' Error marking notification as seen: $e');
      rethrow;
    }
  }

  // Mark all notifications as seen
  Future<void> markAllAsSeen(String studentId) async {
    try {
      final batch = _firestore.batch();
      
      final snapshot = await _firestore
          .collection('feedbackCycles')
          .where('studentId', isEqualTo: studentId)
          .where('status', isEqualTo: 'completed')
          .where('seenByStudent', isEqualTo: false)
          .get();

      print('📝 Marking ${snapshot.docs.length} notifications as seen');

      for (var doc in snapshot.docs) {
        batch.update(doc.reference, {'seenByStudent': true});
      }

      await batch.commit();
      print('✅ All notifications marked as seen');
    } catch (e) {
      print('❌ Error marking all notifications as seen: $e');
      rethrow;
    }
  }

  // Fetch mentor name
  Future<String> getMentorName(String mentorId) async {
    try {
      final doc = await _firestore.collection('users').doc(mentorId).get();
      return doc.data()?['displayName'] ?? 'Your mentor';
    } catch (e) {
      print('Error fetching mentor name: $e');
      return 'Your mentor';
    }
  }

  // Fetch company name
  Future<String> getCompanyName(String internshipId) async {
    try {
      final doc = await _firestore.collection('internships').doc(internshipId).get();
      return doc.data()?['company'] ?? 'Unknown Company';
    } catch (e) {
      print('Error fetching company name: $e');
      return 'Unknown Company';
    }
  }
}