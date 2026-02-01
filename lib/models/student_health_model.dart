// lib/models/student_health_model.dart
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:flutter/material.dart';
import './feedback_cycle_model.dart';

enum StudentHealthStatus {
  urgent,
  needsAttention,
  onTrack,
}

class StudentHealthData {
  final StudentHealthStatus status;
  final DateTime lastActivity;
  final String activityDescription;
  final bool hasPendingRequest;
  final int internshipCount;
  final DateTime? pendingRequestTime;

  StudentHealthData({
    required this.status,
    required this.lastActivity,
    required this.activityDescription,
    required this.hasPendingRequest,
    required this.internshipCount,
    this.pendingRequestTime,
  });
}

class StudentHealthCalculator {
  final FirebaseFirestore _firestore = FirebaseFirestore.instance;

  Future<StudentHealthData> calculateHealth({
    required String studentId,
    required String mentorId,
    required DateTime linkedAt,
  }) async {
    try {
      debugPrint('=== CALCULATING HEALTH ===');
      debugPrint('Student: $studentId, Mentor: $mentorId');
      
      // Get latest feedback request for THIS specific mentor
      List<QueryDocumentSnapshot> requestDocs = [];
      try {
        final requestSnapshot = await _firestore
            .collection('feedbackCycles')
            .where('studentId', isEqualTo: studentId)
            .where('mentorId', isEqualTo: mentorId)
            .where('status', isEqualTo: 'pending')
            .orderBy('requestedAt', descending: true)
            .limit(1)
            .get();
        
        requestDocs = requestSnapshot.docs;
        debugPrint('Found ${requestDocs.length} pending requests');
      } catch (e) {
        debugPrint('ERROR querying feedback cycles: $e');
      }

      // Get internship count (non-archived only)
      final internshipSnapshot = await _firestore
          .collection('internships')
          .where('studentId', isEqualTo: studentId)
          .where('isArchived', isEqualTo: false)
          .get();

      final internshipCount = internshipSnapshot.docs.length;
      debugPrint('Found $internshipCount non-archived internships');

      DateTime lastActivity = linkedAt;
      String activityDescription = 'Joined ${_getTimeAgo(linkedAt)}';
      bool hasPendingRequest = false;
      DateTime? pendingRequestTime;

      // Check for pending requests
      if (requestDocs.isNotEmpty) {
        final request = FeedbackCycle.fromFirestore(requestDocs.first);
        hasPendingRequest = true;
        pendingRequestTime = request.requestedAt;
        lastActivity = request.requestedAt;
        activityDescription = 'Requested feedback ${_getTimeAgo(request.requestedAt)}';
        debugPrint('Pending request from: ${_getTimeAgo(request.requestedAt)}');
      } else if (internshipSnapshot.docs.isNotEmpty) {
        // Find most recent internship activity
        DateTime? latestDate;
        for (var doc in internshipSnapshot.docs) {
          final appliedDate = (doc.data()['appliedDate'] as Timestamp).toDate();
          if (latestDate == null || appliedDate.isAfter(latestDate)) {
            latestDate = appliedDate;
          }
        }
        if (latestDate != null) {
          lastActivity = latestDate;
          activityDescription = 'Added internship ${_getTimeAgo(latestDate)}';
        }
      }

      // Calculate health status
      StudentHealthStatus status = _determineHealthStatus(
        hasPendingRequest: hasPendingRequest,
        pendingRequestTime: pendingRequestTime,
        lastActivity: lastActivity,
        internshipCount: internshipCount,
      );

      debugPrint('Final Status: $status');
      debugPrint('Has Pending: $hasPendingRequest');
      debugPrint('Internship Count: $internshipCount');
      debugPrint('Last Activity: $lastActivity');
      debugPrint('=== END CALCULATION ===\n');

      return StudentHealthData(
        status: status,
        lastActivity: lastActivity,
        activityDescription: activityDescription,
        hasPendingRequest: hasPendingRequest,
        internshipCount: internshipCount,
        pendingRequestTime: pendingRequestTime,
      );
    } catch (e) {
      debugPrint('ERROR calculating student health: $e');
      return StudentHealthData(
        status: StudentHealthStatus.onTrack,
        lastActivity: linkedAt,
        activityDescription: 'Joined ${_getTimeAgo(linkedAt)}',
        hasPendingRequest: false,
        internshipCount: 0,
      );
    }
  }

  StudentHealthStatus _determineHealthStatus({
    required bool hasPendingRequest,
    DateTime? pendingRequestTime,
    required DateTime lastActivity,
    required int internshipCount,
  }) {
    final now = DateTime.now();
    
    // URGENT: Pending feedback request for 72+ hours (3 days)
    if (hasPendingRequest && pendingRequestTime != null) {
      final hoursPending = now.difference(pendingRequestTime).inHours;
      debugPrint('Hours pending: $hoursPending');
      if (hoursPending >= 72) {
        debugPrint('→ URGENT: Request pending 72+ hours');
        return StudentHealthStatus.urgent;
      }
    }

    // NEEDS ATTENTION: Multiple criteria
    final daysSinceActivity = now.difference(lastActivity).inDays;
    debugPrint('Days since last activity: $daysSinceActivity');
    
    // 1. Pending request for 6+ hours but less than 72
    if (hasPendingRequest && pendingRequestTime != null) {
      final hoursPending = now.difference(pendingRequestTime).inHours;
      if (hoursPending >= 6) {
        debugPrint('→ NEEDS ATTENTION: Request pending 6+ hours');
        return StudentHealthStatus.needsAttention;
      }
    }
    
    // 2. No activity in 7+ days
    if (daysSinceActivity > 7) {
      debugPrint('→ NEEDS ATTENTION: Inactive for 7+ days');
      return StudentHealthStatus.needsAttention;
    }
    
    // 3. No internships added
    if (internshipCount == 0) {
      debugPrint('→ NEEDS ATTENTION: No internships');
      return StudentHealthStatus.needsAttention;
    }

    // ON TRACK: Everything looks good
    debugPrint('→ ON TRACK');
    return StudentHealthStatus.onTrack;
  }

  String _getTimeAgo(DateTime dateTime) {
    final now = DateTime.now();
    final difference = now.difference(dateTime);

    if (difference.inMinutes < 1) {
      return 'just now';
    } else if (difference.inMinutes < 60) {
      return '${difference.inMinutes}m ago';
    } else if (difference.inHours < 24) {
      return '${difference.inHours}h ago';
    } else if (difference.inDays == 1) {
      return 'yesterday';
    } else if (difference.inDays < 7) {
      return '${difference.inDays}d ago';
    } else if (difference.inDays < 30) {
      final weeks = (difference.inDays / 7).floor();
      return '$weeks week${weeks > 1 ? 's' : ''} ago';
    } else {
      return '${dateTime.day}/${dateTime.month}/${dateTime.year}';
    }
  }
}

// Utility function for time formatting
String formatTimeAgo(DateTime dateTime) {
  final now = DateTime.now();
  final difference = now.difference(dateTime);

  if (difference.inMinutes < 1) {
    return 'just now';
  } else if (difference.inMinutes < 60) {
    return '${difference.inMinutes}m ago';
  } else if (difference.inHours < 24) {
    return '${difference.inHours}h ago';
  } else if (difference.inDays == 1) {
    return 'yesterday';
  } else if (difference.inDays < 7) {
    return '${difference.inDays}d ago';
  } else if (difference.inDays < 30) {
    final weeks = (difference.inDays / 7).floor();
    return '$weeks week${weeks > 1 ? 's' : ''} ago';
  } else {
    return '${dateTime.day}/${dateTime.month}/${dateTime.year}';
  }
}