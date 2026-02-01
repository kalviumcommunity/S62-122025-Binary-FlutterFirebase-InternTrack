// lib/screens/mentor/widget/quick_mentor_actions.dart
import 'package:flutter/material.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';
import '../../../core/constants/colors.dart';
import '../../../core/constants/app_constants.dart';
import '../../../core/widgets/glass_container.dart';
import '../../../services/mentorship_timeline_service.dart';
import '../../../models/mentorship_timeline_model.dart';

class QuickMentorActions extends StatelessWidget {
  final String studentId;
  final String? internshipId;
  final String? company;
  final bool isDark;

  const QuickMentorActions({
    Key? key,
    required this.studentId,
    this.internshipId,
    this.company,
    required this.isDark,
  }) : super(key: key);

  Future<void> _requestResumeUpdate(BuildContext context) async {
    // Create a feedback request for resume update
    try {
      final mentorId = FirebaseAuth.instance.currentUser!.uid;
      
      if (internshipId == null) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(content: Text('Please select a specific internship')),
        );
        return;
      }

      await FirebaseFirestore.instance.collection('feedbackCycles').add({
        'internshipId': internshipId,
        'studentId': studentId,
        'mentorId': mentorId,
        'studentRequest': 'Mentor requested resume update',
        'mentorFeedback': 'Please update your resume and resubmit.',
        'suggestedNextStep': 'Update and upload your latest resume',
        'status': 'completed',
        'requestedAt': Timestamp.now(),
        'respondedAt': Timestamp.now(),
        'seenByStudent': false,
      });

      // Add to timeline
      final timelineService = MentorshipTimelineService();
      await timelineService.addEvent(
        mentorId: mentorId,
        studentId: studentId,
        internshipId: internshipId,
        type: TimelineEventType.resumeRequested,
        title: 'Resume Update Requested',
        description: 'Asked student to update resume${company != null ? " for $company" : ""}',
      );

      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Row(
            children: [
              Icon(Icons.check_circle, color: Colors.white, size: 18),
              SizedBox(width: 8),
              Text('Resume update requested'),
            ],
          ),
          backgroundColor: Colors.green,
        ),
      );
    } catch (e) {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Text('Failed to send request'),
          backgroundColor: Colors.red,
        ),
      );
    }
  }

  Future<void> _askForReflection(BuildContext context) async {
    try {
      final mentorId = FirebaseAuth.instance.currentUser!.uid;
      
      if (internshipId == null) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(content: Text('Please select a specific internship')),
        );
        return;
      }

      await FirebaseFirestore.instance.collection('feedbackCycles').add({
        'internshipId': internshipId,
        'studentId': studentId,
        'mentorId': mentorId,
        'studentRequest': 'Mentor requested reflection',
        'mentorFeedback': 'Please reflect on this application and update your learning notes.',
        'suggestedNextStep': 'Add reflections and learning outcomes to this internship',
        'status': 'completed',
        'requestedAt': Timestamp.now(),
        'respondedAt': Timestamp.now(),
        'seenByStudent': false,
      });

      // Add to timeline
      final timelineService = MentorshipTimelineService();
      await timelineService.addEvent(
        mentorId: mentorId,
        studentId: studentId,
        internshipId: internshipId,
        type: TimelineEventType.reflectionRequested,
        title: 'Reflection Requested',
        description: 'Asked student to reflect${company != null ? " on $company application" : ""}',
      );

      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Row(
            children: [
              Icon(Icons.check_circle, color: Colors.white, size: 18),
              SizedBox(width: 8),
              Text('Reflection requested'),
            ],
          ),
          backgroundColor: Colors.green,
        ),
      );
    } catch (e) {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Text('Failed to send request'),
          backgroundColor: Colors.red,
        ),
      );
    }
  }

  Future<void> _markAsReviewed(BuildContext context) async {
    try {
      final mentorId = FirebaseAuth.instance.currentUser!.uid;
      
      if (internshipId == null) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(content: Text('Please select a specific internship')),
        );
        return;
      }

      // Add to timeline
      final timelineService = MentorshipTimelineService();
      await timelineService.addReviewed(
        mentorId: mentorId,
        studentId: studentId,
        internshipId: internshipId!,
        company: company ?? 'this application',
      );

      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Row(
            children: [
              Icon(Icons.check_circle, color: Colors.white, size: 18),
              SizedBox(width: 8),
              Text('Marked as reviewed'),
            ],
          ),
          backgroundColor: Colors.green,
        ),
      );
    } catch (e) {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Text('Failed to mark as reviewed'),
          backgroundColor: Colors.red,
        ),
      );
    }
  }

  @override
  Widget build(BuildContext context) {
    return GlassContainer(
      isDark: isDark,
      padding: EdgeInsets.all(AppConstants.spaceL),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            children: [
              Icon(
                Icons.bolt,
                color: AppColors.bluePrimary,
                size: 20,
              ),
              SizedBox(width: 8),
              Text(
                'Quick Actions',
                style: TextStyle(
                  fontSize: 16,
                  fontWeight: FontWeight.w600,
                  color: isDark ? AppColors.pureWhite : AppColors.pureBlack,
                ),
              ),
            ],
          ),
          SizedBox(height: AppConstants.spaceM),
          
          // Action buttons
          Row(
            children: [
              Expanded(
                child: _ActionButton(
                  icon: Icons.description_outlined,
                  label: 'Request\nResume',
                  onTap: () => _requestResumeUpdate(context),
                  isDark: isDark,
                ),
              ),
              SizedBox(width: 8),
              Expanded(
                child: _ActionButton(
                  icon: Icons.psychology_outlined,
                  label: 'Ask for\nReflection',
                  onTap: () => _askForReflection(context),
                  isDark: isDark,
                ),
              ),
              SizedBox(width: 8),
              Expanded(
                child: _ActionButton(
                  icon: Icons.check_circle_outline,
                  label: 'Mark\nReviewed',
                  onTap: () => _markAsReviewed(context),
                  isDark: isDark,
                ),
              ),
            ],
          ),
        ],
      ),
    );
  }
}

class _ActionButton extends StatelessWidget {
  final IconData icon;
  final String label;
  final VoidCallback onTap;
  final bool isDark;

  const _ActionButton({
    Key? key,
    required this.icon,
    required this.label,
    required this.onTap,
    required this.isDark,
  }) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return GestureDetector(
      onTap: onTap,
      child: Container(
        padding: EdgeInsets.symmetric(vertical: 12),
        decoration: BoxDecoration(
          gradient: LinearGradient(
            colors: [AppColors.bluePrimary, AppColors.blueLight],
          ),
          borderRadius: BorderRadius.circular(12),
        ),
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            Icon(icon, color: Colors.white, size: 20),
            SizedBox(height: 6),
            Text(
              label,
              textAlign: TextAlign.center,
              style: TextStyle(
                fontSize: 11,
                fontWeight: FontWeight.w600,
                color: Colors.white,
                height: 1.2,
              ),
            ),
          ],
        ),
      ),
    );
  }
}