// lib\screens\mentor\mentor_students_screen.dart
import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import '../../core/constants/colors.dart';
import '../../core/constants/app_constants.dart';
import '../../core/widgets/glass_container.dart';
import '../../core/widgets/gradient_orb.dart';
import '../../providers/mentor_provider.dart';
import '../../app/app_routes.dart';

class MentorStudentsScreen extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    final isDark = Theme.of(context).brightness == Brightness.dark;

    return Scaffold(
      body: Stack(
        children: [
          GradientOrb(
            size: 300,
            alignment: Alignment.topLeft,
            colors: [AppColors.bluePrimary, AppColors.blueLight],
            opacity: 0.15,
          ),

          SafeArea(
            child: Consumer<MentorProvider>(
              builder: (context, provider, child) {
                final students = provider.students;

                return CustomScrollView(
                  slivers: [
                    SliverToBoxAdapter(
                      child: Padding(
                        padding: EdgeInsets.all(AppConstants.spaceL),
                        child: Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            Text(
                              'My Students',
                              style: Theme.of(context).textTheme.displayMedium,
                            ),
                            SizedBox(height: 4),
                            Text(
                              '${students.length} ${students.length == 1 ? "student" : "students"}',
                              style: Theme.of(context).textTheme.bodyMedium,
                            ),
                          ],
                        ),
                      ),
                    ),

                    if (students.isEmpty)
                      SliverFillRemaining(
                        child: Center(
                          child: Column(
                            mainAxisAlignment: MainAxisAlignment.center,
                            children: [
                              Icon(
                                Icons.supervisor_account_outlined,
                                size: 80,
                                color: AppColors.mediumGray.withOpacity(0.5),
                              ),
                              SizedBox(height: AppConstants.spaceL),
                              Text(
                                'No students yet',
                                style: TextStyle(
                                  fontSize: 20,
                                  fontWeight: FontWeight.w600,
                                  color: isDark ? AppColors.pureWhite : AppColors.pureBlack,
                                ),
                              ),
                              SizedBox(height: AppConstants.spaceS),
                              Text(
                                'Students will appear here when they invite you',
                                style: TextStyle(
                                  fontSize: 15,
                                  color: AppColors.mediumGray,
                                ),
                                textAlign: TextAlign.center,
                              ),
                            ],
                          ),
                        ),
                      )
                    else
                      SliverPadding(
                        padding: EdgeInsets.all(AppConstants.spaceL),
                        sliver: SliverList(
                          delegate: SliverChildBuilderDelegate(
                            (context, index) {
                              final student = students[index];
                              return Padding(
                                padding: EdgeInsets.only(bottom: AppConstants.spaceM),
                                child: GestureDetector(
                                  onTap: () {
                                    provider.selectStudent(student);
                                    Navigator.of(context, rootNavigator: true).pushNamed(
                                      AppRoutes.mentorStudentDetail,
                                      arguments: {'student': student},
                                    );
                                  },
                                  child: GlassContainer(
                                    isDark: isDark,
                                    padding: EdgeInsets.all(AppConstants.spaceL),
                                    child: Row(
                                      children: [
                                        Container(
                                          width: 60,
                                          height: 60,
                                          decoration: BoxDecoration(
                                            gradient: LinearGradient(
                                              colors: [AppColors.bluePrimary, AppColors.blueLight],
                                            ),
                                            borderRadius: BorderRadius.circular(16),
                                          ),
                                          child: Center(
                                            child: Text(
                                              student.studentName.substring(0, 1).toUpperCase(),
                                              style: TextStyle(
                                                fontSize: 24,
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
                                              Text(
                                                student.studentName,
                                                style: TextStyle(
                                                  fontSize: 18,
                                                  fontWeight: FontWeight.w600,
                                                  color: isDark ? AppColors.pureWhite : AppColors.pureBlack,
                                                ),
                                              ),
                                              SizedBox(height: 4),
                                              Text(
                                                student.studentEmail,
                                                style: TextStyle(
                                                  fontSize: 14,
                                                  color: AppColors.mediumGray,
                                                ),
                                              ),
                                              SizedBox(height: 8),
                                              Text(
                                                'Linked since ${_formatDate(student.linkedAt)}',
                                                style: TextStyle(
                                                  fontSize: 12,
                                                  color: AppColors.mediumGray,
                                                ),
                                              ),
                                            ],
                                          ),
                                        ),
                                        Icon(
                                          Icons.arrow_forward_ios_rounded,
                                          size: 18,
                                          color: AppColors.mediumGray,
                                        ),
                                      ],
                                    ),
                                  ),
                                ),
                              );
                            },
                            childCount: students.length,
                          ),
                        ),
                      ),
                  ],
                );
              },
            ),
          ),
        ],
      ),
    );
  }

  String _formatDate(DateTime date) {
    return '${date.day}/${date.month}/${date.year}';
  }
}