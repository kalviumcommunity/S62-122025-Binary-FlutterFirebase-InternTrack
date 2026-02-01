// lib/screens/mentor/widgets/request_card.dart
import 'package:flutter/material.dart';
import '../../../core/constants/colors.dart';
import '../../../core/constants/app_constants.dart';
import '../../../core/widgets/glass_container.dart';
import '../../../models/feedback_cycle_model.dart';
import '../../../models/internship_model.dart';
import '../mentor_requests_screen.dart';

class RequestCard extends StatelessWidget {
  final FeedbackCycle cycle;
  final RequestCardData data;
  final bool isUrgent;
  final bool isDark;
  final VoidCallback onTap;

  const RequestCard({
    Key? key,
    required this.cycle,
    required this.data,
    required this.isUrgent,
    required this.isDark,
    required this.onTap,
  }) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return GestureDetector(
      onTap: onTap,
      child: GlassContainer(
        isDark: isDark,
        padding: EdgeInsets.all(AppConstants.spaceM),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Row(
              children: [
                // Avatar
                Container(
                  width: 50,
                  height: 50,
                  decoration: BoxDecoration(
                    gradient: LinearGradient(
                      colors: [AppColors.bluePrimary, AppColors.blueLight],
                    ),
                    borderRadius: BorderRadius.circular(12),
                  ),
                  child: Center(
                    child: Text(
                      data.studentName.isNotEmpty
                          ? data.studentName[0].toUpperCase()
                          : "?",
                      style: TextStyle(
                        color: Colors.white,
                        fontSize: 22,
                        fontWeight: FontWeight.bold,
                      ),
                    ),
                  ),
                ),
                SizedBox(width: AppConstants.spaceM),

                // Info
                Expanded(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Row(
                        children: [
                          Expanded(
                            child: Text(
                              data.studentName,
                              style: TextStyle(
                                fontSize: 17,
                                fontWeight: FontWeight.w600,
                                color: isDark
                                    ? AppColors.pureWhite
                                    : AppColors.pureBlack,
                              ),
                            ),
                          ),
                          if (isUrgent)
                            Container(
                              padding: EdgeInsets.symmetric(
                                horizontal: 8,
                                vertical: 4,
                              ),
                              decoration: BoxDecoration(
                                color: Colors.red.withOpacity(0.15),
                                borderRadius: BorderRadius.circular(6),
                                border: Border.all(
                                  color: Colors.red.withOpacity(0.3),
                                ),
                              ),
                              child: Row(
                                mainAxisSize: MainAxisSize.min,
                                children: [
                                  Icon(
                                    Icons.priority_high,
                                    size: 14,
                                    color: Colors.red,
                                  ),
                                  SizedBox(width: 4),
                                  Text(
                                    'URGENT',
                                    style: TextStyle(
                                      fontSize: 11,
                                      fontWeight: FontWeight.w700,
                                      color: Colors.red,
                                    ),
                                  ),
                                ],
                              ),
                            ),
                        ],
                      ),
                      SizedBox(height: 4),
                      Row(
                        children: [
                          Icon(
                            Icons.business,
                            size: 14,
                            color: AppColors.mediumGray,
                          ),
                          SizedBox(width: 4),
                          Expanded(
                            child: Text(
                              data.company,
                              style: TextStyle(
                                fontSize: 15,
                                color: AppColors.mediumGray,
                              ),
                            ),
                          ),
                        ],
                      ),
                    ],
                  ),
                ),

                Icon(Icons.more_horiz, color: AppColors.bluePrimary),
              ],
            ),

            SizedBox(height: AppConstants.spaceM),

            // Status badge and time
            Row(
              children: [
                if (data.status != null)
                  _buildStatusBadge(data.status!),
                Spacer(),
                Text(
                  _formatDate(cycle.requestedAt),
                  style: TextStyle(
                    fontSize: 12,
                    color: AppColors.mediumGray,
                  ),
                ),
              ],
            ),

            // Show response status if completed
            if (cycle.status == 'completed') ...[
              SizedBox(height: AppConstants.spaceS),
              Container(
                padding: EdgeInsets.all(AppConstants.spaceS),
                decoration: BoxDecoration(
                  color: Colors.green.withOpacity(0.1),
                  borderRadius: BorderRadius.circular(8),
                  border: Border.all(
                    color: Colors.green.withOpacity(0.3),
                  ),
                ),
                child: Row(
                  children: [
                    Icon(
                      cycle.seenByStudent
                          ? Icons.check_circle
                          : Icons.check_circle_outline,
                      size: 16,
                      color: Colors.green,
                    ),
                    SizedBox(width: 8),
                    Expanded(
                      child: Text(
                        cycle.seenByStudent
                            ? 'Feedback seen by student'
                            : 'Feedback sent - awaiting student view',
                        style: TextStyle(
                          fontSize: 12,
                          fontWeight: FontWeight.w500,
                          color: Colors.green,
                        ),
                      ),
                    ),
                  ],
                ),
              ),
            ],
          ],
        ),
      ),
    );
  }

  Widget _buildStatusBadge(InternshipStatus status) {
    Color color;
    String label;

    switch (status) {
      case InternshipStatus.applied:
        color = Colors.blue;
        label = 'Applied';
        break;
      case InternshipStatus.interviewing:
        color = Colors.orange;
        label = 'Interviewing';
        break;
      case InternshipStatus.offered:
        color = Colors.green;
        label = 'Offered';
        break;
      case InternshipStatus.accepted:
        color = AppColors.bluePrimary;
        label = 'Accepted';
        break;
      case InternshipStatus.rejected:
        color = Colors.red;
        label = 'Rejected';
        break;
      case InternshipStatus.archived:
        color = AppColors.mediumGray;
        label = 'Archived';
        break;
    }

    return Container(
      padding: EdgeInsets.symmetric(horizontal: 10, vertical: 4),
      decoration: BoxDecoration(
        color: color.withOpacity(0.15),
        borderRadius: BorderRadius.circular(6),
      ),
      child: Text(
        label,
        style: TextStyle(
          fontSize: 12,
          fontWeight: FontWeight.w600,
          color: color,
        ),
      ),
    );
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
}