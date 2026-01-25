import 'package:flutter/material.dart';
import '../../models/internship_model.dart';
import '../constants/colors.dart';
import '../constants/app_constants.dart';


// Status Badge Widget
class StatusBadge extends StatelessWidget {
  final InternshipStatus status;
  
  const StatusBadge({Key? key, required this.status}) : super(key: key);

  @override
  Widget build(BuildContext context) {
    Color color;
    switch (status) {
      case InternshipStatus.applied:
        color = Colors.blue;
        break;
      case InternshipStatus.interviewing:
        color = Colors.orange;
        break;
      case InternshipStatus.offered:
        color = Colors.green;
        break;
      case InternshipStatus.accepted:
        color = AppColors.purplePrimary;
        break;
      case InternshipStatus.rejected:
        color = Colors.red;
        break;
      case InternshipStatus.archived:
        color = AppColors.mediumGray;
        break;
    }

    return Container(
      padding: EdgeInsets.symmetric(horizontal: 10, vertical: 4),
      decoration: BoxDecoration(
        color: color.withOpacity(0.2),
        borderRadius: BorderRadius.circular(8),
      ),
      child: Text(
        _getStatusLabel(status),
        style: TextStyle(
          fontSize: 12,
          fontWeight: FontWeight.w600,
          color: color,
        ),
      ),
    );
  }

  String _getStatusLabel(InternshipStatus status) {
    return status.toString().split('.').last.replaceAllMapped(
          RegExp(r'[A-Z]'),
          (match) => ' ${match.group(0)}',
        ).trim().split(' ').map((word) => word[0].toUpperCase() + word.substring(1)).join(' ');
  }
}

// Priority Badge Widget
class PriorityBadge extends StatelessWidget {
  final Priority priority;
  final bool showLabel;
  
  const PriorityBadge({
    Key? key, 
    required this.priority,
    this.showLabel = false,
  }) : super(key: key);

  @override
  Widget build(BuildContext context) {
    Color color;
    String label;
    switch (priority) {
      case Priority.high:
        color = Colors.red;
        label = 'High Priority';
        break;
      case Priority.medium:
        color = Colors.orange;
        label = 'Medium Priority';
        break;
      case Priority.low:
        color = Colors.green;
        label = 'Low Priority';
        break;
    }

    if (showLabel) {
      return Container(
        padding: EdgeInsets.symmetric(horizontal: 12, vertical: 6),
        decoration: BoxDecoration(
          color: color.withOpacity(0.2),
          borderRadius: BorderRadius.circular(8),
        ),
        child: Row(
          mainAxisSize: MainAxisSize.min,
          children: [
            Container(
              width: 8,
              height: 8,
              decoration: BoxDecoration(
                color: color,
                shape: BoxShape.circle,
              ),
            ),
            SizedBox(width: 6),
            Text(
              label,
              style: TextStyle(
                fontSize: 12,
                fontWeight: FontWeight.w600,
                color: color,
              ),
            ),
          ],
        ),
      );
    }

    return Container(
      width: 8,
      height: 8,
      decoration: BoxDecoration(
        color: color,
        shape: BoxShape.circle,
      ),
    );
  }
}

// Info Chip Widget
class InfoChip extends StatelessWidget {
  final IconData icon;
  final String text;
  
  const InfoChip({
    Key? key,
    required this.icon,
    required this.text,
  }) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: EdgeInsets.symmetric(horizontal: 12, vertical: 6),
      decoration: BoxDecoration(
        color: AppColors.mediumGray.withOpacity(0.2),
        borderRadius: BorderRadius.circular(8),
      ),
      child: Row(
        mainAxisSize: MainAxisSize.min,
        children: [
          Icon(icon, size: 14, color: AppColors.mediumGray),
          SizedBox(width: 6),
          Text(
            text,
            style: TextStyle(
              fontSize: 12,
              color: AppColors.mediumGray,
            ),
          ),
        ],
      ),
    );
  }
}

// Empty State Widget
class EmptyStateWidget extends StatelessWidget {
  final IconData icon;
  final String title;
  final String subtitle;
  final bool isDark;
  
  const EmptyStateWidget({
    Key? key,
    required this.icon,
    required this.title,
    required this.subtitle,
    required this.isDark,
  }) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return Center(
      child: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          Icon(
            icon,
            size: 80,
            color: AppColors.mediumGray.withOpacity(0.5),
          ),
          SizedBox(height: AppConstants.spaceL),
          Text(
            title,
            style: TextStyle(
              fontSize: 20,
              fontWeight: FontWeight.w600,
              color: isDark ? AppColors.pureWhite : AppColors.pureBlack,
            ),
          ),
          SizedBox(height: AppConstants.spaceS),
          Text(
            subtitle,
            style: TextStyle(
              fontSize: 15,
              color: AppColors.mediumGray,
            ),
          ),
        ],
      ),
    );
  }
}

// Helper functions
class InternshipHelpers {
  static String getStatusLabel(InternshipStatus status) {
    return status.toString().split('.').last.replaceAllMapped(
          RegExp(r'[A-Z]'),
          (match) => ' ${match.group(0)}',
        ).trim().split(' ').map((word) => word[0].toUpperCase() + word.substring(1)).join(' ');
  }

  static String getPriorityLabel(Priority priority) {
    return priority.toString().split('.').last[0].toUpperCase() +
        priority.toString().split('.').last.substring(1);
  }

  static String formatDate(DateTime date) {
    return '${date.day}/${date.month}/${date.year}';
  }
}