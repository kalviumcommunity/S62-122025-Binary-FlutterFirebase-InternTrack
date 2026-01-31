// lib/core/widgets/activity_feed_item.dart
import 'package:flutter/material.dart';
import '../constants/colors.dart';
import '../constants/app_constants.dart';

enum ActivityType { mentorFeedback, studentRequest, internshipUpdate, studentAdded }

class ActivityFeedItem extends StatelessWidget {
  final ActivityType type;
  final String title;
  final String subtitle;
  final DateTime timestamp;
  final bool isDark;

  const ActivityFeedItem({
    Key? key,
    required this.type,
    required this.title,
    required this.subtitle,
    required this.timestamp,
    required this.isDark,
  }) : super(key: key);

  IconData _getIcon() {
    switch (type) {
      case ActivityType.mentorFeedback:
        return Icons.rate_review_outlined;
      case ActivityType.studentRequest:
        return Icons.help_outline_rounded;
      case ActivityType.internshipUpdate:
        return Icons.update_rounded;
      case ActivityType.studentAdded:
        return Icons.person_add_outlined;
    }
  }

  Color _getIconColor() {
    switch (type) {
      case ActivityType.mentorFeedback:
        return AppColors.bluePrimary;
      case ActivityType.studentRequest:
        return Colors.orange;
      case ActivityType.internshipUpdate:
        return Colors.green;
      case ActivityType.studentAdded:
        return AppColors.blueLight;
    }
  }

  String _getTimeAgo() {
    final now = DateTime.now();
    final difference = now.difference(timestamp);

    if (difference.inMinutes < 60) {
      return '${difference.inMinutes}m ago';
    } else if (difference.inHours < 24) {
      return '${difference.inHours}h ago';
    } else if (difference.inDays < 7) {
      return '${difference.inDays}d ago';
    } else {
      return '${timestamp.day}/${timestamp.month}/${timestamp.year}';
    }
  }

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: EdgeInsets.only(bottom: AppConstants.spaceM),
      child: Row(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Container(
            width: 40,
            height: 40,
            decoration: BoxDecoration(
              color: _getIconColor().withOpacity(0.2),
              borderRadius: BorderRadius.circular(10),
            ),
            child: Icon(
              _getIcon(),
              color: _getIconColor(),
              size: 20,
            ),
          ),
          SizedBox(width: AppConstants.spaceM),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  title,
                  style: TextStyle(
                    fontSize: 14,
                    fontWeight: FontWeight.w600,
                    color: isDark ? AppColors.pureWhite : AppColors.pureBlack,
                  ),
                ),
                SizedBox(height: 4),
                Text(
                  subtitle,
                  style: TextStyle(
                    fontSize: 13,
                    color: AppColors.mediumGray,
                  ),
                  maxLines: 2,
                  overflow: TextOverflow.ellipsis,
                ),
                SizedBox(height: 4),
                Text(
                  _getTimeAgo(),
                  style: TextStyle(
                    fontSize: 11,
                    color: AppColors.mediumGray,
                  ),
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }
}