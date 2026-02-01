// lib/screens/mentor/widgets/students_statistics.dart
import 'package:flutter/material.dart';
import '../../../core/constants/colors.dart';
import '../../../core/constants/app_constants.dart';
import '../../../core/widgets/glass_container.dart';
import '../../../models/student_health_model.dart';
import '../../../models/mentor_invitation_model.dart';
import 'student_widgets.dart';

class StudentsStatisticsOverview extends StatelessWidget {
  final List<MentorStudentLink> students;
  final Map<String, StudentHealthData> healthData;
  final bool isDark;

  const StudentsStatisticsOverview({
    Key? key,
    required this.students,
    required this.healthData,
    required this.isDark,
  }) : super(key: key);

  @override
  Widget build(BuildContext context) {
    int urgentCount = 0;
    int needsAttentionCount = 0;
    int onTrackCount = 0;
    int totalInternships = 0;

    debugPrint('\n=== STATISTICS CALCULATION ===');
    debugPrint('Total students: ${students.length}');
    debugPrint('Health data entries: ${healthData.length}');

    // Calculate statistics from health data
    for (var student in students) {
      final data = healthData[student.studentId];
      
      if (data != null) {
        debugPrint('\n${student.studentName}:');
        debugPrint('  Status: ${data.status}');
        debugPrint('  Pending: ${data.hasPendingRequest}');
        debugPrint('  Internships: ${data.internshipCount}');
        
        // Count by status
        switch (data.status) {
          case StudentHealthStatus.urgent:
            urgentCount++;
            break;
          case StudentHealthStatus.needsAttention:
            needsAttentionCount++;
            break;
          case StudentHealthStatus.onTrack:
            onTrackCount++;
            break;
        }
        
        // Sum total internships
        totalInternships += data.internshipCount;
      } else {
        debugPrint('\n${student.studentName}: NO HEALTH DATA');
      }
    }

    debugPrint('\n--- FINAL COUNTS ---');
    debugPrint('Urgent: $urgentCount');
    debugPrint('Needs Attention: $needsAttentionCount');
    debugPrint('On Track: $onTrackCount');
    debugPrint('Total Applications: $totalInternships');
    debugPrint('=== END STATISTICS ===\n');

    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(
          'Overview',
          style: TextStyle(
            fontSize: 18,
            fontWeight: FontWeight.w600,
            color: isDark ? AppColors.pureWhite : AppColors.pureBlack,
          ),
        ),
        SizedBox(height: AppConstants.spaceM),
        Row(
          children: [
            Expanded(
              child: StudentStatCard(
                title: 'Urgent',
                value: urgentCount.toString(),
                color: Colors.red,
                isDark: isDark,
              ),
            ),
            SizedBox(width: AppConstants.spaceM),
            Expanded(
              child: StudentStatCard(
                title: 'Attention',
                value: needsAttentionCount.toString(),
                color: Colors.orange,
                isDark: isDark,
              ),
            ),
            SizedBox(width: AppConstants.spaceM),
            Expanded(
              child: StudentStatCard(
                title: 'On Track',
                value: onTrackCount.toString(),
                color: Colors.green,
                isDark: isDark,
              ),
            ),
          ],
        ),
        SizedBox(height: AppConstants.spaceM),
        GlassContainer(
          isDark: isDark,
          padding: EdgeInsets.all(AppConstants.spaceM),
          child: Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    'Total Applications',
                    style: TextStyle(
                      fontSize: 13,
                      color: AppColors.mediumGray,
                    ),
                  ),
                  SizedBox(height: 4),
                  Text(
                    totalInternships.toString(),
                    style: TextStyle(
                      fontSize: 24,
                      fontWeight: FontWeight.w700,
                      color: isDark ? AppColors.pureWhite : AppColors.pureBlack,
                    ),
                  ),
                ],
              ),
              Container(
                padding: EdgeInsets.all(12),
                decoration: BoxDecoration(
                  gradient: LinearGradient(
                    colors: [AppColors.bluePrimary, AppColors.blueLight],
                  ),
                  borderRadius: BorderRadius.circular(12),
                ),
                child: Icon(
                  Icons.work_outline,
                  color: Colors.white,
                  size: 24,
                ),
              ),
            ],
          ),
        ),
      ],
    );
  }
}
