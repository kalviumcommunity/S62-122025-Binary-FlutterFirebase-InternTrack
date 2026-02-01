// lib/core/widgets/action_required_panel.dart
import 'package:flutter/material.dart';
import '../../../core/constants/colors.dart';
import '../../../core/constants/app_constants.dart';
import '../../../core/widgets/glass_container.dart';

class ActionRequiredPanel extends StatelessWidget {
  final int pendingRequestsCount;
  final int highPriorityCount;
  final DateTime? lastRequestTime;
  final VoidCallback onTap;
  final bool isDark;

  const ActionRequiredPanel({
    Key? key,
    required this.pendingRequestsCount,
    required this.highPriorityCount,
    this.lastRequestTime,
    required this.onTap,
    required this.isDark,
  }) : super(key: key);

  String _getTimeAgo(DateTime dateTime) {
    final now = DateTime.now();
    final difference = now.difference(dateTime);

    if (difference.inMinutes < 60) {
      return '${difference.inMinutes}m ago';
    } else if (difference.inHours < 24) {
      return '${difference.inHours}h ago';
    } else if (difference.inDays < 7) {
      return '${difference.inDays}d ago';
    } else {
      return '${dateTime.day}/${dateTime.month}/${dateTime.year}';
    }
  }

  @override
  Widget build(BuildContext context) {
    final hasActions = pendingRequestsCount > 0 || highPriorityCount > 0;

    if (!hasActions) return SizedBox.shrink();

    return GestureDetector(
      onTap: onTap,
      child: GlassContainer(
        isDark: isDark,
        borderRadius: AppConstants.radiusMedium,
        padding: EdgeInsets.all(AppConstants.spaceL),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Row(
              children: [
                Container(
                  padding: EdgeInsets.all(12),
                  decoration: BoxDecoration(
                    color: Colors.red.withOpacity(0.2),
                    borderRadius: BorderRadius.circular(12),
                  ),
                  child: Icon(
                    Icons.priority_high_rounded,
                    color: Colors.red,
                    size: 24,
                  ),
                ),
                SizedBox(width: AppConstants.spaceM),
                Expanded(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(
                        'Action Required',
                        style: TextStyle(
                          fontSize: 18,
                          fontWeight: FontWeight.w700,
                          color: isDark ? AppColors.pureWhite : AppColors.pureBlack,
                        ),
                      ),
                      SizedBox(height: 4),
                      if (lastRequestTime != null)
                        Text(
                          'Last request ${_getTimeAgo(lastRequestTime!)}',
                          style: TextStyle(
                            fontSize: 13,
                            color: AppColors.mediumGray,
                          ),
                        ),
                    ],
                  ),
                ),
                Icon(
                  Icons.arrow_forward_ios_rounded,
                  size: 16,
                  color: AppColors.mediumGray,
                ),
              ],
            ),
            SizedBox(height: AppConstants.spaceM),
            Divider(color: AppColors.mediumGray.withOpacity(0.2)),
            SizedBox(height: AppConstants.spaceM),
            Row(
              children: [
                if (pendingRequestsCount > 0) ...[
                  Expanded(
                    child: _buildActionItem(
                      icon: Icons.mark_chat_unread_outlined,
                      label: 'Pending Feedback',
                      count: pendingRequestsCount,
                    ),
                  ),
                ],
                if (pendingRequestsCount > 0 && highPriorityCount > 0)
                  SizedBox(width: AppConstants.spaceM),
                if (highPriorityCount > 0) ...[
                  Expanded(
                    child: _buildActionItem(
                      icon: Icons.warning_amber_rounded,
                      label: 'High Priority',
                      count: highPriorityCount,
                    ),
                  ),
                ],
              ],
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildActionItem({
    required IconData icon,
    required String label,
    required int count,
  }) {
    return Row(
      children: [
        Container(
          padding: EdgeInsets.all(6),
          decoration: BoxDecoration(
            gradient: LinearGradient(
              colors: [AppColors.bluePrimary, AppColors.blueLight],
            ),
            borderRadius: BorderRadius.circular(8),
          ),
          child: Icon(icon, color: Colors.white, size: 16),
        ),
        SizedBox(width: 8),
        Expanded(
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text(
                count.toString(),
                style: TextStyle(
                  fontSize: 20,
                  fontWeight: FontWeight.w700,
                  color: isDark ? AppColors.pureWhite : AppColors.pureBlack,
                ),
              ),
              Text(
                label,
                style: TextStyle(
                  fontSize: 11,
                  color: AppColors.mediumGray,
                ),
                maxLines: 1,
                overflow: TextOverflow.ellipsis,
              ),
            ],
          ),
        ),
      ],
    );
  }
}