// lib\services\mentor_service.dart
import 'package:cloud_firestore/cloud_firestore.dart';
import '../models/mentor_invitation_model.dart';
import '../models/internship_model.dart';
import '../models/feedback_cycle_model.dart';
import 'mentorship_timeline_service.dart';

class MentorService {
  final FirebaseFirestore _firestore = FirebaseFirestore.instance;

  // FEEDBACK CYCLES
  
  /// Get pending feedback cycles for a mentor
  Stream<List<FeedbackCycle>> getMentorPendingCycles(String mentorId) {
    print('MentorService: Streaming pending cycles for mentor: $mentorId');
    
    return _firestore
        .collection('feedbackCycles')
        .where('mentorId', isEqualTo: mentorId)
        .where('status', isEqualTo: 'pending')
        .orderBy('requestedAt', descending: true)
        .snapshots()
        .handleError((error) {
          print('MentorService ERROR in pending cycles stream: $error');
        })
        .map((snapshot) {
          print('MentorService: Received ${snapshot.docs.length} pending cycles');
          return snapshot.docs
              .map((doc) => FeedbackCycle.fromFirestore(doc))
              .toList();
        });
  }

  /// Submit mentor feedback for a cycle
  Future<void> submitFeedback({
    required String cycleId,
    required String feedback,
    String? nextStep,
    String? mentorId,
    String? studentId,
    String? internshipId,
    String? company,
  }) async {
    try {
      print('MentorService: Submitting feedback for cycle: $cycleId');
      
      // Get cycle data to extract needed info
      final cycleDoc = await _firestore
          .collection('feedbackCycles')
          .doc(cycleId)
          .get();
      
      if (!cycleDoc.exists) {
        throw 'Feedback cycle not found';
      }
      
      final cycleData = cycleDoc.data()!;
      final actualMentorId = mentorId ?? cycleData['mentorId'];
      final actualStudentId = studentId ?? cycleData['studentId'];
      final actualInternshipId = internshipId ?? cycleData['internshipId'];
      
      // Get company name if not provided
      String actualCompany = company ?? 'Unknown';
      if (company == null && actualInternshipId != null) {
        final internshipDoc = await _firestore
            .collection('internships')
            .doc(actualInternshipId)
            .get();
        
        if (internshipDoc.exists) {
          actualCompany = internshipDoc.data()?['company'] ?? 'Unknown';
        }
      }
      
      // Update feedback cycle
      await _firestore.collection('feedbackCycles').doc(cycleId).update({
        'mentorFeedback': feedback,
        'suggestedNextStep': nextStep,
        'status': 'completed',
        'respondedAt': Timestamp.now(),
        'seenByStudent': false,
      });
      
      print('MentorService: Feedback updated, now adding to timeline...');
      
      // Add to mentorship timeline
      try {
        final timelineService = MentorshipTimelineService();
        await timelineService.addRequestAnswered(
          mentorId: actualMentorId,
          studentId: actualStudentId,
          internshipId: actualInternshipId,
          company: actualCompany,
        );
        print('MentorService: Successfully added to timeline');
      } catch (timelineError) {
        // Don't fail the whole operation if timeline fails
        print('MentorService WARNING: Timeline update failed: $timelineError');
      }
      
      print('MentorService: Successfully submitted feedback');
    } catch (e) {
      print('MentorService ERROR submitting feedback: $e');
      throw 'Failed to submit feedback: $e';
    }
  }

  // STUDENTS MANAGEMENT

  /// Get stream of mentor's students
  Stream<List<MentorStudentLink>> getStudentsStream(String mentorId) {
    return _firestore
        .collection('mentorStudentLinks')
        .where('mentorId', isEqualTo: mentorId)
        .snapshots()
        .map((snapshot) {
      return snapshot.docs
          .map((doc) => MentorStudentLink.fromFirestore(doc))
          .toList();
    });
  }

  /// Get stream of a specific student's internships
  Stream<List<Internship>> getStudentInternshipsStream(String studentId) {
    return _firestore
        .collection('internships')
        .where('studentId', isEqualTo: studentId)
        .where('isArchived', isEqualTo: false)
        .orderBy('appliedDate', descending: true)
        .snapshots()
        .map((snapshot) {
      return snapshot.docs
          .map((doc) => Internship.fromFirestore(doc))
          .toList();
    });
  }

  // INVITATIONS 

  /// Check if there's a pending invitation for the given email
  Future<Map<String, dynamic>?> checkInvitation(String email) async {
    try {
      print('MentorService: Checking invitation for email: $email');
      
      final normalizedEmail = email.trim().toLowerCase();
      
      final snapshot = await _firestore
          .collection('mentorInvites')
          .where('mentorEmail', isEqualTo: normalizedEmail)
          .where('status', isEqualTo: 'pending')
          .limit(1)
          .get();

      if (snapshot.docs.isEmpty) {
        print('MentorService: No pending invitation found');
        return null;
      }

      print('MentorService: Found pending invitation');
      return snapshot.docs.first.data();
    } catch (e) {
      print('MentorService ERROR checking invitation: $e');
      return null;
    }
  }

  /// Create mentor-student link from an invitation
  Future<void> createMentorLink({
    required String mentorId,
    required String studentId,
    required String studentName,
    required String studentEmail,
    required String inviteId,
  }) async {
    try {
      print('MentorService: Creating mentor link...');
      print('  mentorId: $mentorId');
      print('  studentId: $studentId');
      print('  inviteId: $inviteId');

      // Get mentor data
      final mentorDoc = await _firestore.collection('users').doc(mentorId).get();
      if (!mentorDoc.exists) {
        throw 'Mentor user document not found';
      }
      
      final mentorData = mentorDoc.data();
      final mentorEmail = mentorData?['email'] ?? '';
      final mentorName = mentorData?['displayName'] ?? 'Mentor';

      print('  mentorEmail: $mentorEmail');
      print('  mentorName: $mentorName');

      // Check if link already exists
      final existingLink = await _firestore
          .collection('mentorStudentLinks')
          .where('mentorId', isEqualTo: mentorId)
          .where('studentId', isEqualTo: studentId)
          .limit(1)
          .get();

      if (existingLink.docs.isNotEmpty) {
        print('MentorService: Link already exists, updating invitation status only');
        
        // Just update the invitation status
        await _firestore.collection('mentorInvites').doc(inviteId).update({
          'status': 'accepted',
          'mentorId': mentorId,
          'acceptedAt': Timestamp.now(),
        });
        
        return;
      }

      // Create the mentor-student link
      await _firestore.collection('mentorStudentLinks').add({
        'mentorId': mentorId,
        'mentorEmail': mentorEmail,
        'studentId': studentId,
        'studentName': studentName,
        'studentEmail': studentEmail,
        'linkedAt': Timestamp.now(),
      });

      print('MentorService: Mentor-student link created');

      // Update invitation status
      await _firestore.collection('mentorInvites').doc(inviteId).update({
        'status': 'accepted',
        'mentorId': mentorId,
        'acceptedAt': Timestamp.now(),
      });

      // Add to mentorship timeline
      try {
        final timelineService = MentorshipTimelineService();
        await timelineService.addStudentLinked(
          mentorId: mentorId,
          studentId: studentId,
          studentName: studentName,
        );
        print('MentorService: Successfully added student linked event to timeline');
      } catch (timelineError) {
        // Don't fail the whole operation if timeline fails
        print('MentorService WARNING: Timeline update failed: $timelineError');
      }

      print('MentorService: Successfully created mentor link and updated invitation');
    } catch (e) {
      print('MentorService ERROR creating mentor link: $e');
      throw 'Failed to create mentor link: $e';
    }
  }

  /// Send mentor invitation - handles both existing and new mentors
  Future<void> sendInvitation({
    required String studentId,
    required String studentName,
    required String studentEmail,
    required String mentorEmail,
  }) async {
    try {
      print('MentorService: Sending invitation to: $mentorEmail');
      
      final normalizedEmail = mentorEmail.trim().toLowerCase();

      // Check if there's already a pending invitation from THIS student
      final existingInvite = await _firestore
          .collection('mentorInvites')
          .where('studentId', isEqualTo: studentId)
          .where('mentorEmail', isEqualTo: normalizedEmail)
          .where('status', isEqualTo: 'pending')
          .limit(1)
          .get();

      if (existingInvite.docs.isNotEmpty) {
        throw 'An invitation has already been sent to this email';
      }

      // Check if mentor already exists
      final mentorSnapshot = await _firestore
          .collection('users')
          .where('email', isEqualTo: normalizedEmail)
          .where('role', isEqualTo: 'mentor')
          .limit(1)
          .get();

      if (mentorSnapshot.docs.isNotEmpty) {
        // CASE 1: Mentor already exists - link them immediately
        final mentorId = mentorSnapshot.docs.first.id;
        
        // Check if already linked
        final existingLink = await _firestore
            .collection('mentorStudentLinks')
            .where('studentId', isEqualTo: studentId)
            .where('mentorId', isEqualTo: mentorId)
            .limit(1)
            .get();

        if (existingLink.docs.isNotEmpty) {
          throw 'Already linked with this mentor';
        }

        // Create the link immediately
        await _firestore.collection('mentorStudentLinks').add({
          'studentId': studentId,
          'studentName': studentName,
          'studentEmail': studentEmail,
          'mentorId': mentorId,
          'mentorEmail': normalizedEmail,
          'linkedAt': Timestamp.now(),
        });

        // Create accepted invitation record for tracking
        await _firestore.collection('mentorInvites').add({
          'studentId': studentId,
          'studentName': studentName,
          'studentEmail': studentEmail,
          'mentorEmail': normalizedEmail,
          'mentorId': mentorId,
          'status': 'accepted',
          'sentAt': Timestamp.now(),
          'acceptedAt': Timestamp.now(),
        });

        // Add to mentorship timeline
        try {
          final timelineService = MentorshipTimelineService();
          await timelineService.addStudentLinked(
            mentorId: mentorId,
            studentId: studentId,
            studentName: studentName,
          );
          print('MentorService: Successfully added student linked event to timeline');
        } catch (timelineError) {
          // Don't fail the whole operation if timeline fails
          print('MentorService WARNING: Timeline update failed: $timelineError');
        }

        print('MentorService: Successfully linked with existing mentor');
      } else {
        // CASE 2: Mentor doesn't exist - create pending invitation
        await _firestore.collection('mentorInvites').add({
          'studentId': studentId,
          'studentName': studentName,
          'studentEmail': studentEmail,
          'mentorEmail': normalizedEmail,
          'status': 'pending',
          'sentAt': Timestamp.now(),
        });

        print('MentorService: Successfully created pending invitation');
      }
    } catch (e) {
      print('MentorService ERROR sending invitation: $e');
      throw e;
    }
  }

  /// Remove mentor-student link
  Future<void> removeMentorLink(String linkId) async {
    try {
      await _firestore.collection('mentorStudentLinks').doc(linkId).delete();
    } catch (e) {
      print('MentorService ERROR removing link: $e');
      throw 'Failed to remove mentor link: $e';
    }
  }
}