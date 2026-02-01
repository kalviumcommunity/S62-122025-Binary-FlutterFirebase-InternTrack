// lib/core/widgets/student_preview_card.dart
import 'package:flutter/material.dart';
import '../../../core/constants/colors.dart';
import '../../../core/constants/app_constants.dart';
import '../../../core/widgets/glass_container.dart';

enum StudentStatus { onTrack, needsAttention, urgent }

class StudentPreviewCard extends StatelessWidget {
  final String studentName;
  final String studentEmail;
  final StudentStatus status;
  final String lastActivity;
  final VoidCallback onTap;
  final bool isDark;

  const StudentPreviewCard({
    Key? key,
    required this.studentName,
    required this.studentEmail,
    required this.status,
    required this.lastActivity,
    required this.onTap,
    required this.isDark,
  }) : super(key: key);

  Color _getStatusColor() {
    switch (status) {
      case StudentStatus.onTrack:
        return Colors.green;
      case StudentStatus.needsAttention:
        return Colors.orange;
      case StudentStatus.urgent:
        return Colors.red;
    }
  }

  String _getStatusLabel() {
    switch (status) {
      case StudentStatus.onTrack:
        return 'On Track';
      case StudentStatus.needsAttention:
        return 'Needs Attention';
      case StudentStatus.urgent:
        return 'Urgent';
    }
  }

  @override
  Widget build(BuildContext context) {
    return GestureDetector(
      onTap: onTap,
      child: GlassContainer(
        isDark: isDark,
        padding: EdgeInsets.all(AppConstants.spaceM),
        child: Row(
          children: [
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
                  studentName.substring(0, 1).toUpperCase(),
                  style: TextStyle(
                    fontSize: 20,
                    fontWeight: FontWeight.w700,
                    color: Colors.white,
                  ),
                ),
              ),
            ),
            SizedBox(width: AppConstants.spaceM),
            Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Row(
                    children: [
                      Expanded(
                        child: Text(
                          studentName,
                          style: TextStyle(
                            fontSize: 16,
                            fontWeight: FontWeight.w600,
                            color: isDark ? AppColors.pureWhite : AppColors.pureBlack,
                          ),
                        ),
                      ),
                      Container(
                        padding: EdgeInsets.symmetric(horizontal: 8, vertical: 4),
                        decoration: BoxDecoration(
                          color: _getStatusColor().withOpacity(0.2),
                          borderRadius: BorderRadius.circular(6),
                          border: Border.all(
                            color: _getStatusColor().withOpacity(0.5),
                            width: 1,
                          ),
                        ),
                        child: Text(
                          _getStatusLabel(),
                          style: TextStyle(
                            fontSize: 10,
                            fontWeight: FontWeight.w600,
                            color: _getStatusColor(),
                          ),
                        ),
                      ),
                    ],
                  ),
                  SizedBox(height: 4),
                  Text(
                    studentEmail,
                    style: TextStyle(
                      fontSize: 13,
                      color: AppColors.mediumGray,
                    ),
                    maxLines: 1,
                    overflow: TextOverflow.ellipsis,
                  ),
                  SizedBox(height: 6),
                  Row(
                    children: [
                      Icon(
                        Icons.access_time_rounded,
                        size: 12,
                        color: AppColors.mediumGray,
                      ),
                      SizedBox(width: 4),
                      Expanded(
                        child: Text(
                          lastActivity,
                          style: TextStyle(
                            fontSize: 12,
                            color: AppColors.mediumGray,
                          ),
                          maxLines: 1,
                          overflow: TextOverflow.ellipsis,
                        ),
                      ),
                    ],
                  ),
                ],
              ),
            ),
            SizedBox(width: 8),
            Icon(
              Icons.arrow_forward_ios_rounded,
              size: 16,
              color: AppColors.mediumGray,
            ),
          ],
        ),
      ),
    );
  }
}