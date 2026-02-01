// lib/screens/mentor/widget/mentorship_timeline_widget.dart
import 'package:flutter/material.dart';
import 'package:firebase_auth/firebase_auth.dart';
import '../../../core/constants/colors.dart';
import '../../../core/constants/app_constants.dart';
import '../../../core/widgets/glass_container.dart';
import '../../../services/mentorship_timeline_service.dart';
import '../../../models/mentorship_timeline_model.dart';

class MentorshipTimelineWidget extends StatelessWidget {
  final String studentId;
  final bool isDark;

  const MentorshipTimelineWidget({
    Key? key,
    required this.studentId,
    required this.isDark,
  }) : super(key: key);

  IconData _getIconForType(TimelineEventType type) {
    switch (type) {
      case TimelineEventType.feedbackGiven:
        return Icons.feedback;
      case TimelineEventType.requestAnswered:
        return Icons.check_circle_outline;
      case TimelineEventType.statusChanged:
        return Icons.swap_horiz;
      case TimelineEventType.noteAdded:
        return Icons.note_add_outlined;
      case TimelineEventType.resumeRequested:
        return Icons.description_outlined;
      case TimelineEventType.reflectionRequested:
        return Icons.psychology_outlined;
      case TimelineEventType.reviewed:
        return Icons.visibility_outlined;
      case TimelineEventType.studentLinked:
        return Icons.link;
      case TimelineEventType.internshipAdded:
        return Icons.add_circle_outline;
    }
  }

  Color _getColorForType(TimelineEventType type) {
    switch (type) {
      case TimelineEventType.feedbackGiven:
      case TimelineEventType.requestAnswered:
        return AppColors.bluePrimary;
      case TimelineEventType.statusChanged:
        return Colors.orange;
      case TimelineEventType.reviewed:
        return Colors.green;
      case TimelineEventType.studentLinked:
        return AppColors.purplePrimary;
      default:
        return AppColors.mediumGray;
    }
  }

  String _formatDate(DateTime date) {
    final now = DateTime.now();
    final diff = now.difference(date);

    if (diff.inDays == 0) {
      if (diff.inHours == 0) {
        return '${diff.inMinutes}m ago';
      }
      return '${diff.inHours}h ago';
    } else if (diff.inDays == 1) {
      return 'Yesterday';
    } else if (diff.inDays < 7) {
      return '${diff.inDays}d ago';
    } else {
      return '${date.day}/${date.month}/${date.year}';
    }
  }

  @override
  Widget build(BuildContext context) {
    final mentorId = FirebaseAuth.instance.currentUser!.uid;
    final timelineService = MentorshipTimelineService();

    return StreamBuilder<List<MentorshipTimelineEvent>>(
      stream: timelineService.getTimeline(
        mentorId: mentorId,
        studentId: studentId,
      ),
      builder: (context, snapshot) {
        if (snapshot.connectionState == ConnectionState.waiting) {
          return GlassContainer(
            isDark: isDark,
            padding: EdgeInsets.all(AppConstants.spaceL),
            child: Center(
              child: CircularProgressIndicator(
                valueColor: AlwaysStoppedAnimation<Color>(AppColors.bluePrimary),
              ),
            ),
          );
        }

        if (!snapshot.hasData || snapshot.data!.isEmpty) {
          return GlassContainer(
            isDark: isDark,
            padding: EdgeInsets.all(AppConstants.spaceL),
            child: Column(
              children: [
                Row(
                  children: [
                    Icon(
                      Icons.timeline,
                      color: AppColors.bluePrimary,
                      size: 20,
                    ),
                    SizedBox(width: 8),
                    Text(
                      'Mentorship Timeline',
                      style: TextStyle(
                        fontSize: 16,
                        fontWeight: FontWeight.w600,
                        color: isDark ? AppColors.pureWhite : AppColors.pureBlack,
                      ),
                    ),
                  ],
                ),
                SizedBox(height: AppConstants.spaceL),
                Center(
                  child: Text(
                    'No activity yet',
                    style: TextStyle(
                      fontSize: 14,
                      color: AppColors.mediumGray,
                    ),
                  ),
                ),
              ],
            ),
          );
        }

        final events = snapshot.data!;

        return GlassContainer(
          isDark: isDark,
          padding: EdgeInsets.all(AppConstants.spaceL),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Row(
                children: [
                  Icon(
                    Icons.timeline,
                    color: AppColors.bluePrimary,
                    size: 20,
                  ),
                  SizedBox(width: 8),
                  Text(
                    'Mentorship Timeline',
                    style: TextStyle(
                      fontSize: 16,
                      fontWeight: FontWeight.w600,
                      color: isDark ? AppColors.pureWhite : AppColors.pureBlack,
                    ),
                  ),
                  Spacer(),
                  Text(
                    '${events.length} events',
                    style: TextStyle(
                      fontSize: 12,
                      color: AppColors.mediumGray,
                    ),
                  ),
                ],
              ),
              SizedBox(height: AppConstants.spaceL),
              
              // Timeline events
              ...events.asMap().entries.map((entry) {
                final index = entry.key;
                final event = entry.value;
                final isLast = index == events.length - 1;

                return Row(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    // Timeline indicator
                    Column(
                      children: [
                        Container(
                          width: 32,
                          height: 32,
                          decoration: BoxDecoration(
                            color: _getColorForType(event.type).withOpacity(0.2),
                            borderRadius: BorderRadius.circular(8),
                          ),
                          child: Icon(
                            _getIconForType(event.type),
                            color: _getColorForType(event.type),
                            size: 16,
                          ),
                        ),
                        if (!isLast)
                          Container(
                            width: 2,
                            height: 40,
                            color: AppColors.mediumGray.withOpacity(0.2),
                          ),
                      ],
                    ),
                    SizedBox(width: 12),
                    
                    // Event content
                    Expanded(
                      child: Padding(
                        padding: EdgeInsets.only(bottom: isLast ? 0 : 16),
                        child: Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            Text(
                              event.title,
                              style: TextStyle(
                                fontSize: 14,
                                fontWeight: FontWeight.w600,
                                color: isDark ? AppColors.pureWhite : AppColors.pureBlack,
                              ),
                            ),
                            SizedBox(height: 4),
                            Text(
                              event.description,
                              style: TextStyle(
                                fontSize: 13,
                                color: AppColors.mediumGray,
                              ),
                            ),
                            SizedBox(height: 4),
                            Text(
                              _formatDate(event.timestamp),
                              style: TextStyle(
                                fontSize: 11,
                                color: AppColors.mediumGray,
                              ),
                            ),
                          ],
                        ),
                      ),
                    ),
                  ],
                );
              }).toList(),
            ],
          ),
        );
      },
    );
  }
}