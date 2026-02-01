// lib/services/mentorship_timeline_service.dart
import 'package:cloud_firestore/cloud_firestore.dart';
import '../models/mentorship_timeline_model.dart';

class MentorshipTimelineService {
  final FirebaseFirestore _firestore = FirebaseFirestore.instance;

  /// Get timeline for a specific student-mentor relationship
  Stream<List<MentorshipTimelineEvent>> getTimeline({
    required String mentorId,
    required String studentId,
  }) {
    print('📊 MentorshipTimelineService: Getting timeline for mentorId=$mentorId, studentId=$studentId');
    
    return _firestore
        .collection('mentorshipTimeline')
        .where('mentorId', isEqualTo: mentorId)
        .where('studentId', isEqualTo: studentId)
        .snapshots()
        .handleError((error) {
          print('📊 MentorshipTimelineService ERROR in timeline stream: $error');
        })
        .map((snapshot) {
          print('📊 MentorshipTimelineService: Received ${snapshot.docs.length} events');
          
          if (snapshot.docs.isEmpty) {
            print('📊 MentorshipTimelineService: No events found in database');
            return [];
          }
          
          final events = snapshot.docs.map((doc) {
            print('📊 Event data: ${doc.data()}');
            return MentorshipTimelineEvent.fromFirestore(doc);
          }).toList();
          
          // Sort in memory
          events.sort((a, b) => b.timestamp.compareTo(a.timestamp));
          
          // Take only last 50
          final limitedEvents = events.take(50).toList();
          print('📊 MentorshipTimelineService: Returning ${limitedEvents.length} events');
          
          return limitedEvents;
        });
  }

  /// Add timeline event
  Future<void> addEvent({
    required String mentorId,
    required String studentId,
    String? internshipId,
    required TimelineEventType type,
    required String title,
    required String description,
    Map<String, dynamic>? metadata,
  }) async {
    try {
      print('📊 MentorshipTimelineService: Adding event...');
      print('📊   mentorId: $mentorId');
      print('📊   studentId: $studentId');
      print('📊   internshipId: $internshipId');
      print('📊   type: $type');
      print('📊   title: $title');
      print('📊   description: $description');
      
      final eventData = {
        'mentorId': mentorId,
        'studentId': studentId,
        'internshipId': internshipId,
        'type': type.toString().split('.').last,
        'title': title,
        'description': description,
        'timestamp': Timestamp.now(),
        'metadata': metadata,
      };
      
      print('📊 Event data to save: $eventData');
      
      final docRef = await _firestore.collection('mentorshipTimeline').add(eventData);
      
      print('📊 MentorshipTimelineService: Successfully added event with ID: ${docRef.id}');
    } catch (e) {
      print('📊 MentorshipTimelineService ERROR adding event: $e');
      print('📊 Stack trace: ${StackTrace.current}');
      // Don't throw - timeline is not critical
    }
  }

  /// Add feedback given event
  Future<void> addFeedbackGiven({
    required String mentorId,
    required String studentId,
    required String internshipId,
    required String company,
  }) async {
    print('📊 MentorshipTimelineService: addFeedbackGiven called');
    await addEvent(
      mentorId: mentorId,
      studentId: studentId,
      internshipId: internshipId,
      type: TimelineEventType.feedbackGiven,
      title: 'Feedback Given',
      description: 'Provided feedback on $company application',
      metadata: {'company': company},
    );
  }

  /// Add request answered event
  Future<void> addRequestAnswered({
    required String mentorId,
    required String studentId,
    required String internshipId,
    required String company,
  }) async {
    print('📊 MentorshipTimelineService: addRequestAnswered called');
    await addEvent(
      mentorId: mentorId,
      studentId: studentId,
      internshipId: internshipId,
      type: TimelineEventType.requestAnswered,
      title: 'Request Answered',
      description: 'Responded to feedback request for $company',
      metadata: {'company': company},
    );
  }

  /// Add status change event
  Future<void> addStatusChange({
    required String mentorId,
    required String studentId,
    required String internshipId,
    required String company,
    required String oldStatus,
    required String newStatus,
  }) async {
    print('📊 MentorshipTimelineService: addStatusChange called');
    await addEvent(
      mentorId: mentorId,
      studentId: studentId,
      internshipId: internshipId,
      type: TimelineEventType.statusChanged,
      title: 'Status Updated',
      description: '$company: $oldStatus → $newStatus',
      metadata: {
        'company': company,
        'oldStatus': oldStatus,
        'newStatus': newStatus,
      },
    );
  }

  /// Add student linked event
  Future<void> addStudentLinked({
    required String mentorId,
    required String studentId,
    required String studentName,
  }) async {
    print('📊 MentorshipTimelineService: addStudentLinked called');
    await addEvent(
      mentorId: mentorId,
      studentId: studentId,
      type: TimelineEventType.studentLinked,
      title: 'Student Linked',
      description: '$studentName joined your mentorship',
      metadata: {'studentName': studentName},
    );
  }

  /// Add reviewed event
  Future<void> addReviewed({
    required String mentorId,
    required String studentId,
    required String internshipId,
    required String company,
  }) async {
    print('📊 MentorshipTimelineService: addReviewed called');
    await addEvent(
      mentorId: mentorId,
      studentId: studentId,
      internshipId: internshipId,
      type: TimelineEventType.reviewed,
      title: 'Reviewed',
      description: 'Marked $company application as reviewed',
      metadata: {'company': company},
    );
  }
}