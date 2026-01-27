// lib/screens/mentor/mentor_student_detail_screen.dart
import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import '../../core/constants/colors.dart';
import '../../core/constants/app_constants.dart';
import '../../core/widgets/glass_container.dart';
import '../../core/widgets/gradient_orb.dart';
import '../../core/widgets/internship_widgets.dart';
import '../../models/mentor_invitation_model.dart';
import '../../providers/mentor_provider.dart';
import '../../app/app_routes.dart';

class MentorStudentDetailScreen extends StatelessWidget {
  final MentorStudentLink student;

  const MentorStudentDetailScreen({Key? key, required this.student}) : super(key: key);

  @override
  Widget build(BuildContext context) {
    final isDark = Theme.of(context).brightness == Brightness.dark;

    return Scaffold(
      body: Stack(
        children: [
          GradientOrb(
            size: 300,
            alignment: Alignment.topRight,
            colors: [AppColors.bluePrimary, AppColors.blueLight],
            opacity: 0.15,
          ),

          SafeArea(
            child: Consumer<MentorProvider>(
              builder: (context, provider, child) {
                final internships = provider.selectedStudentInternships;

                return CustomScrollView(
                  slivers: [
                    SliverToBoxAdapter(
                      child: Padding(
                        padding: EdgeInsets.all(AppConstants.spaceL),
                        child: Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            Row(
                              children: [
                                IconButton(
                                  onPressed: () => Navigator.pop(context),
                                  icon: Icon(Icons.arrow_back_rounded),
                                  style: IconButton.styleFrom(
                                    backgroundColor: isDark
                                        ? Colors.white.withOpacity(0.1)
                                        : Colors.black.withOpacity(0.05),
                                  ),
                                ),
                                SizedBox(width: AppConstants.spaceM),
                                Expanded(
                                  child: Column(
                                    crossAxisAlignment: CrossAxisAlignment.start,
                                    children: [
                                      Text(
                                        student.studentName,
                                        style: Theme.of(context).textTheme.displayMedium?.copyWith(fontSize: 28),
                                      ),
                                      SizedBox(height: 4),
                                      Text(
                                        student.studentEmail,
                                        style: Theme.of(context).textTheme.bodyMedium,
                                      ),
                                    ],
                                  ),
                                ),
                              ],
                            ),

                            SizedBox(height: AppConstants.spaceXL),

                            GlassContainer(
                              isDark: isDark,
                              padding: EdgeInsets.all(AppConstants.spaceL),
                              child: Row(
                                children: [
                                  Container(
                                    width: 70,
                                    height: 70,
                                    decoration: BoxDecoration(
                                      gradient: LinearGradient(
                                        colors: [AppColors.bluePrimary, AppColors.blueLight],
                                      ),
                                      borderRadius: BorderRadius.circular(20),
                                    ),
                                    child: Center(
                                      child: Text(
                                        student.studentName.substring(0, 1).toUpperCase(),
                                        style: TextStyle(
                                          fontSize: 32,
                                          fontWeight: FontWeight.w700,
                                          color: Colors.white,
                                        ),
                                      ),
                                    ),
                                  ),
                                  SizedBox(width: AppConstants.spaceL),
                                  Expanded(
                                    child: Column(
                                      crossAxisAlignment: CrossAxisAlignment.start,
                                      children: [
                                        Text(
                                          '${internships.length} Applications',
                                          style: TextStyle(
                                            fontSize: 24,
                                            fontWeight: FontWeight.w700,
                                            color: isDark ? AppColors.pureWhite : AppColors.pureBlack,
                                          ),
                                        ),
                                        SizedBox(height: 4),
                                        Text(
                                          'Total internship applications',
                                          style: TextStyle(
                                            fontSize: 14,
                                            color: AppColors.mediumGray,
                                          ),
                                        ),
                                      ],
                                    ),
                                  ),
                                ],
                              ),
                            ),

                            SizedBox(height: AppConstants.spaceXL),

                            Text(
                              'Internship Applications',
                              style: Theme.of(context).textTheme.headlineSmall,
                            ),
                            SizedBox(height: AppConstants.spaceM),
                          ],
                        ),
                      ),
                    ),

                    if (internships.isEmpty)
                      SliverFillRemaining(
                        child: Center(
                          child: Column(
                            mainAxisAlignment: MainAxisAlignment.center,
                            children: [
                              Icon(
                                Icons.work_outline_rounded,
                                size: 80,
                                color: AppColors.mediumGray.withOpacity(0.5),
                              ),
                              SizedBox(height: AppConstants.spaceL),
                              Text(
                                'No applications yet',
                                style: TextStyle(
                                  fontSize: 20,
                                  fontWeight: FontWeight.w600,
                                  color: isDark ? AppColors.pureWhite : AppColors.pureBlack,
                                ),
                              ),
                              SizedBox(height: AppConstants.spaceS),
                              Text(
                                'Student hasn\'t added any internships',
                                style: TextStyle(
                                  fontSize: 15,
                                  color: AppColors.mediumGray,
                                ),
                              ),
                            ],
                          ),
                        ),
                      )
                    else
                      SliverPadding(
                        padding: EdgeInsets.symmetric(horizontal: AppConstants.spaceL),
                        sliver: SliverList(
                          delegate: SliverChildBuilderDelegate(
                            (context, index) {
                              final internship = internships[index];
                              return Padding(
                                padding: EdgeInsets.only(bottom: AppConstants.spaceM),
                                child: GestureDetector(
                                  onTap: () {
                                    Navigator.of(context, rootNavigator: true).pushNamed(
                                      AppRoutes.mentorInternshipDetail,
                                      arguments: {'internship': internship},
                                    );
                                  },
                                  child: GlassContainer(
                                    isDark: isDark,
                                    padding: EdgeInsets.all(AppConstants.spaceM),
                                    child: Column(
                                      crossAxisAlignment: CrossAxisAlignment.start,
                                      children: [
                                        Row(
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
                                                  internship.company.substring(0, 1).toUpperCase(),
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
                                                  Text(
                                                    internship.company,
                                                    style: TextStyle(
                                                      fontSize: 18,
                                                      fontWeight: FontWeight.w600,
                                                      color: isDark ? AppColors.pureWhite : AppColors.pureBlack,
                                                    ),
                                                  ),
                                                  SizedBox(height: 4),
                                                  Text(
                                                    internship.role,
                                                    style: TextStyle(
                                                      fontSize: 14,
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
                                        Row(
                                          children: [
                                            StatusBadge(status: internship.status),
                                            SizedBox(width: 8),
                                            PriorityBadge(priority: internship.priority),
                                            if (internship.location != null) ...[
                                              SizedBox(width: 8),
                                              InfoChip(
                                                icon: Icons.location_on_outlined,
                                                text: internship.location!,
                                              ),
                                            ],
                                          ],
                                        ),
                                      ],
                                    ),
                                  ),
                                ),
                              );
                            },
                            childCount: internships.length,
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
}