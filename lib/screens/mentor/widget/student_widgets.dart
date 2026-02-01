// lib/screens/mentor/widgets/student_widgets.dart
import 'package:flutter/material.dart';
import '../../../core/constants/colors.dart';
import '../../../core/constants/app_constants.dart';
import '../../../core/widgets/glass_container.dart';
import '../../../models/student_health_model.dart';
import '../../../models/mentor_invitation_model.dart';

/// Health indicator badge for student status
class StudentHealthIndicator extends StatelessWidget {
  final StudentHealthStatus status;
  final bool isDark;

  const StudentHealthIndicator({
    Key? key,
    required this.status,
    required this.isDark,
  }) : super(key: key);

  @override
  Widget build(BuildContext context) {
    Color color;
    String label;
    
    switch (status) {
      case StudentHealthStatus.urgent:
        color = Colors.red;
        label = 'Urgent';
        break;
      case StudentHealthStatus.needsAttention:
        color = Colors.orange;
        label = 'Attention';
        break;
      case StudentHealthStatus.onTrack:
        color = Colors.green;
        label = 'On Track';
        break;
    }
    
    return Container(
      padding: EdgeInsets.symmetric(horizontal: 8, vertical: 4),
      decoration: BoxDecoration(
        color: color.withOpacity(0.15),
        borderRadius: BorderRadius.circular(6),
      ),
      child: Row(
        mainAxisSize: MainAxisSize.min,
        children: [
          Container(
            width: 6,
            height: 6,
            decoration: BoxDecoration(
              color: color,
              shape: BoxShape.circle,
            ),
          ),
          SizedBox(width: 4),
          Text(
            label,
            style: TextStyle(
              fontSize: 11,
              fontWeight: FontWeight.w600,
              color: color,
            ),
          ),
        ],
      ),
    );
  }
}

/// Student card showing student info and health data
class StudentCard extends StatelessWidget {
  final MentorStudentLink student;
  final StudentHealthData? healthData;
  final bool isDark;
  final VoidCallback onTap;

  const StudentCard({
    Key? key,
    required this.student,
    required this.healthData,
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
                  width: 56,
                  height: 56,
                  decoration: BoxDecoration(
                    gradient: LinearGradient(
                      colors: [AppColors.bluePrimary, AppColors.blueLight],
                    ),
                    borderRadius: BorderRadius.circular(14),
                  ),
                  child: Center(
                    child: Text(
                      student.studentName.isNotEmpty
                          ? student.studentName.substring(0, 1).toUpperCase()
                          : '?',
                      style: TextStyle(
                        fontSize: 22,
                        fontWeight: FontWeight.w700,
                        color: Colors.white,
                      ),
                    ),
                  ),
                ),
                SizedBox(width: AppConstants.spaceM),
                
                // Student info
                Expanded(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Row(
                        children: [
                          Expanded(
                            child: Text(
                              student.studentName,
                              style: TextStyle(
                                fontSize: 17,
                                fontWeight: FontWeight.w600,
                                color: isDark ? AppColors.pureWhite : AppColors.pureBlack,
                              ),
                            ),
                          ),
                          if (healthData != null)
                            StudentHealthIndicator(
                              status: healthData!.status,
                              isDark: isDark,
                            ),
                        ],
                      ),
                      SizedBox(height: 4),
                      Text(
                        student.studentEmail,
                        style: TextStyle(
                          fontSize: 13,
                          color: AppColors.mediumGray,
                        ),
                        overflow: TextOverflow.ellipsis,
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
            
            if (healthData != null) ...[
              SizedBox(height: AppConstants.spaceM),
              Divider(
                color: isDark
                    ? Colors.white.withOpacity(0.1)
                    : Colors.black.withOpacity(0.1),
                height: 1,
              ),
              SizedBox(height: AppConstants.spaceM),
              
              Row(
                children: [
                  Expanded(
                    child: StudentInfoItem(
                      icon: Icons.work_outline,
                      label: 'Applications',
                      value: healthData!.internshipCount.toString(),
                      isDark: isDark,
                    ),
                  ),
                  Container(
                    width: 1,
                    height: 30,
                    color: isDark
                        ? Colors.white.withOpacity(0.1)
                        : Colors.black.withOpacity(0.1),
                  ),
                  Expanded(
                    child: StudentInfoItem(
                      icon: Icons.access_time_rounded,
                      label: 'Last Active',
                      value: formatTimeAgo(healthData!.lastActivity),
                      isDark: isDark,
                    ),
                  ),
                ],
              ),
              
              if (healthData!.hasPendingRequest) ...[
                SizedBox(height: AppConstants.spaceM),
                Container(
                  padding: EdgeInsets.all(AppConstants.spaceS),
                  decoration: BoxDecoration(
                    color: Colors.red.withOpacity(0.1),
                    borderRadius: BorderRadius.circular(8),
                    border: Border.all(
                      color: Colors.red.withOpacity(0.3),
                    ),
                  ),
                  child: Row(
                    children: [
                      SizedBox(width: 8),
                      Expanded(
                        child: Text(
                          healthData!.activityDescription,
                          style: TextStyle(
                            fontSize: 12,
                            fontWeight: FontWeight.w500,
                            color: Colors.red,
                          ),
                        ),
                      ),
                    ],
                  ),
                ),
              ],
            ],
          ],
        ),
      ),
    );
  }
}

/// Info item showing icon, label and value
class StudentInfoItem extends StatelessWidget {
  final IconData icon;
  final String label;
  final String value;
  final bool isDark;

  const StudentInfoItem({
    Key? key,
    required this.icon,
    required this.label,
    required this.value,
    required this.isDark,
  }) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return Column(
      children: [
        Icon(
          icon,
          size: 18,
          color: AppColors.bluePrimary,
        ),
        SizedBox(height: 4),
        Text(
          value,
          style: TextStyle(
            fontSize: 15,
            fontWeight: FontWeight.w600,
            color: isDark ? AppColors.pureWhite : AppColors.pureBlack,
          ),
        ),
        Text(
          label,
          style: TextStyle(
            fontSize: 11,
            color: AppColors.mediumGray,
          ),
        ),
      ],
    );
  }
}

/// Statistics card for overview section
class StudentStatCard extends StatelessWidget {
  final String title;
  final String value;
  final Color color;
  final bool isDark;

  const StudentStatCard({
    Key? key,
    required this.title,
    required this.value,
    required this.color,
    required this.isDark,
  }) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return GlassContainer(
      isDark: isDark,
      padding: EdgeInsets.all(AppConstants.spaceM),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Container(
            width: 8,
            height: 8,
            decoration: BoxDecoration(
              color: color,
              shape: BoxShape.circle,
            ),
          ),
          SizedBox(height: AppConstants.spaceS),
          Text(
            value,
            style: TextStyle(
              fontSize: 24,
              fontWeight: FontWeight.w700,
              color: isDark ? AppColors.pureWhite : AppColors.pureBlack,
            ),
          ),
          SizedBox(height: 2),
          Text(
            title,
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

/// Filter chip for student filtering
class StudentFilterChip extends StatelessWidget {
  final String label;
  final bool isSelected;
  final VoidCallback onTap;
  final bool isDark;
  final bool showBadge;

  const StudentFilterChip({
    Key? key,
    required this.label,
    required this.isSelected,
    required this.onTap,
    required this.isDark,
    this.showBadge = false,
  }) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return GestureDetector(
      onTap: onTap,
      child: Container(
        padding: EdgeInsets.symmetric(horizontal: 16, vertical: 8),
        decoration: BoxDecoration(
          gradient: isSelected
              ? LinearGradient(
                  colors: [AppColors.bluePrimary, AppColors.blueLight],
                )
              : null,
          color: isSelected
              ? null
              : isDark
                  ? Colors.white.withOpacity(0.1)
                  : Colors.black.withOpacity(0.05),
          borderRadius: BorderRadius.circular(12),
          border: Border.all(
            color: isSelected
                ? Colors.transparent
                : isDark
                    ? Colors.white.withOpacity(0.2)
                    : Colors.black.withOpacity(0.1),
          ),
        ),
        child: Row(
          mainAxisSize: MainAxisSize.min,
          children: [
            Text(
              label,
              style: TextStyle(
                fontSize: 13,
                fontWeight: FontWeight.w600,
                color: isSelected
                    ? Colors.white
                    : isDark
                        ? AppColors.pureWhite
                        : AppColors.pureBlack,
              ),
            ),
            if (showBadge && !isSelected) ...[
              SizedBox(width: 6),
              Container(
                width: 6,
                height: 6,
                decoration: BoxDecoration(
                  color: Colors.red,
                  shape: BoxShape.circle,
                ),
              ),
            ],
          ],
        ),
      ),
    );
  }
}

/// Sort option chip
class SortOptionChip extends StatelessWidget {
  final String label;
  final bool isSelected;
  final VoidCallback onTap;
  final bool isDark;

  const SortOptionChip({
    Key? key,
    required this.label,
    required this.isSelected,
    required this.onTap,
    required this.isDark,
  }) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return GestureDetector(
      onTap: onTap,
      child: Container(
        padding: EdgeInsets.symmetric(horizontal: 12, vertical: 6),
        decoration: BoxDecoration(
          color: isSelected
              ? AppColors.bluePrimary.withOpacity(0.2)
              : isDark
                  ? Colors.white.withOpacity(0.05)
                  : Colors.black.withOpacity(0.03),
          borderRadius: BorderRadius.circular(8),
          border: Border.all(
            color: isSelected
                ? AppColors.bluePrimary
                : Colors.transparent,
          ),
        ),
        child: Text(
          label,
          style: TextStyle(
            fontSize: 12,
            fontWeight: isSelected ? FontWeight.w600 : FontWeight.w500,
            color: isSelected
                ? AppColors.bluePrimary
                : AppColors.mediumGray,
          ),
        ),
      ),
    );
  }
}

/// Empty state widget
class StudentsEmptyState extends StatelessWidget {
  final bool isDark;

  const StudentsEmptyState({
    Key? key,
    required this.isDark,
  }) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return Center(
      child: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          Container(
            padding: EdgeInsets.all(AppConstants.spaceXL),
            decoration: BoxDecoration(
              gradient: LinearGradient(
                colors: [
                  AppColors.bluePrimary.withOpacity(0.1),
                  AppColors.blueLight.withOpacity(0.1),
                ],
              ),
              shape: BoxShape.circle,
            ),
            child: Icon(
              Icons.supervisor_account_outlined,
              size: 80,
              color: AppColors.bluePrimary.withOpacity(0.5),
            ),
          ),
          SizedBox(height: AppConstants.spaceXL),
          Text(
            'No students yet',
            style: TextStyle(
              fontSize: 24,
              fontWeight: FontWeight.w600,
              color: isDark ? AppColors.pureWhite : AppColors.pureBlack,
            ),
          ),
          SizedBox(height: AppConstants.spaceS),
          Padding(
            padding: EdgeInsets.symmetric(horizontal: AppConstants.spaceXL),
            child: Text(
              'Students will appear here when they send you an invitation',
              style: TextStyle(
                fontSize: 15,
                color: AppColors.mediumGray,
              ),
              textAlign: TextAlign.center,
            ),
          ),
        ],
      ),
    );
  }
}

/// No results state widget
class NoStudentsFoundState extends StatelessWidget {
  final bool isDark;

  const NoStudentsFoundState({
    Key? key,
    required this.isDark,
  }) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return Center(
      child: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          Icon(
            Icons.search_off_rounded,
            size: 64,
            color: AppColors.mediumGray.withOpacity(0.5),
          ),
          SizedBox(height: AppConstants.spaceL),
          Text(
            'No students match your filters',
            style: TextStyle(
              fontSize: 18,
              fontWeight: FontWeight.w600,
              color: isDark ? AppColors.pureWhite : AppColors.pureBlack,
            ),
          ),
          SizedBox(height: AppConstants.spaceS),
          Text(
            'Try adjusting your search criteria',
            style: TextStyle(
              fontSize: 14,
              color: AppColors.mediumGray,
            ),
          ),
        ],
      ),
    );
  }
}