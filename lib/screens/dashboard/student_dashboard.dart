import 'package:flutter/material.dart';
import 'dart:ui';
import 'package:provider/provider.dart';
import '../../core/widgets/theme_toggle.dart';
import '../../core/widgets/gradient_orb.dart';
import '../../core/constants/app_constants.dart';
import '../../core/constants/colors.dart';
import '../../providers/auth_provider.dart';
import 'widgets/stats_card.dart';
import 'widgets/application_card.dart';

class StudentDashboard extends StatefulWidget {
  @override
  State<StudentDashboard> createState() => _StudentDashboardState();
}

class _StudentDashboardState extends State<StudentDashboard> {
  Future<void> _signOut() async {
    final authProvider = Provider.of<AuthProvider>(context, listen: false);
    
    final success = await authProvider.signOut();
    
    if (!success && authProvider.error != null) {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Text(authProvider.error!),
          backgroundColor: Colors.red.shade400,
          behavior: SnackBarBehavior.floating,
          margin: EdgeInsets.all(AppConstants.spaceM),
          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(AppConstants.radiusSmall),
          ),
        ),
      );
      authProvider.clearError();
    }
  }

  @override
  Widget build(BuildContext context) {
    final isDark = Theme.of(context).brightness == Brightness.dark;

    return Consumer<AuthProvider>(
      builder: (context, authProvider, child) {
        final user = authProvider.currentUser;

        return Scaffold(
          body: Container(
            decoration: BoxDecoration(
              gradient: LinearGradient(
                begin: Alignment.topLeft,
                end: Alignment.bottomRight,
                colors: isDark
                    ? [AppColors.pureBlack, AppColors.darkGray, AppColors.pureBlack]
                    : [AppColors.pureWhite, AppColors.lightGray, AppColors.pureWhite],
              ),
            ),
            child: Stack(
              children: [
                // Gradient orbs
                GradientOrb(
                  size: 400,
                  alignment: Alignment.topRight,
                  colors: [AppColors.purplePrimary, Colors.transparent],
                  opacity: 0.3,
                ),
                GradientOrb(
                  size: 350,
                  alignment: Alignment.bottomLeft,
                  colors: [AppColors.purpleLight, Colors.transparent],
                  opacity: 0.25,
                ),

                SafeArea(
                  child: SingleChildScrollView(
                    physics: BouncingScrollPhysics(),
                    padding: EdgeInsets.all(AppConstants.spaceL),
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        // Header
                        Row(
                          mainAxisAlignment: MainAxisAlignment.spaceBetween,
                          children: [
                            Flexible(
                              child: Column(
                                crossAxisAlignment: CrossAxisAlignment.start,
                                children: [
                                  Text(
                                    'Welcome back,',
                                    style: TextStyle(
                                      fontSize: 16,
                                      color: AppColors.mediumGray,
                                      fontWeight: FontWeight.w500,
                                    ),
                                  ),
                                  SizedBox(height: AppConstants.spaceXS),
                                  Text(
                                    user?.displayName ?? 'User',
                                    style: Theme.of(context).textTheme.displayMedium,
                                    overflow: TextOverflow.ellipsis,
                                  ),
                                ],
                              ),
                            ),
                            Row(
                              children: [
                                ThemeToggle(),
                                SizedBox(width: AppConstants.spaceS),
                                ClipRRect(
                                  borderRadius: BorderRadius.circular(AppConstants.radiusSmall),
                                  child: BackdropFilter(
                                    filter: ImageFilter.blur(sigmaX: 10, sigmaY: 10),
                                    child: Container(
                                      width: 56,
                                      height: 56,
                                      decoration: BoxDecoration(
                                        gradient: LinearGradient(
                                          colors: [AppColors.purplePrimary, AppColors.purpleLight],
                                        ),
                                        borderRadius: BorderRadius.circular(AppConstants.radiusSmall),
                                        boxShadow: [
                                          BoxShadow(
                                            color: AppColors.purplePrimary.withOpacity(0.4),
                                            blurRadius: 15,
                                            offset: Offset(0, 5),
                                          ),
                                        ],
                                      ),
                                      child: authProvider.isLoading
                                          ? Center(
                                              child: SizedBox(
                                                width: 24,
                                                height: 24,
                                                child: CircularProgressIndicator(
                                                  strokeWidth: 2,
                                                  valueColor: AlwaysStoppedAnimation<Color>(Colors.white),
                                                ),
                                              ),
                                            )
                                          : IconButton(
                                              icon: Icon(Icons.logout_rounded, color: Colors.white),
                                              onPressed: _signOut,
                                            ),
                                    ),
                                  ),
                                ),
                              ],
                            ),
                          ],
                        ),

                        SizedBox(height: AppConstants.spaceXXL),

                        // Stats Grid
                        LayoutBuilder(
                          builder: (context, constraints) {
                            return GridView.count(
                              shrinkWrap: true,
                              physics: NeverScrollableScrollPhysics(),
                              crossAxisCount: 2,
                              mainAxisSpacing: AppConstants.spaceM,
                              crossAxisSpacing: AppConstants.spaceM,
                              childAspectRatio: 1.1,
                              children: [
                                StatsCard(
                                  isDark: isDark,
                                  icon: Icons.work_outline_rounded,
                                  title: 'Active',
                                  value: '12',
                                  gradient: [AppColors.purplePrimary, AppColors.purpleLight],
                                ),
                                StatsCard(
                                  isDark: isDark,
                                  icon: Icons.pending_outlined,
                                  title: 'Pending',
                                  value: '5',
                                  gradient: [AppColors.purpleLight, AppColors.purpleDark],
                                ),
                                StatsCard(
                                  isDark: isDark,
                                  icon: Icons.check_circle_outline_rounded,
                                  title: 'Completed',
                                  value: '8',
                                  gradient: [AppColors.purpleDark, AppColors.purplePrimary],
                                ),
                                StatsCard(
                                  isDark: isDark,
                                  icon: Icons.people_outline_rounded,
                                  title: 'Mentors',
                                  value: '3',
                                  gradient: [AppColors.purplePrimary, AppColors.purpleDark],
                                ),
                              ],
                            );
                          },
                        ),

                        SizedBox(height: AppConstants.spaceXXL),

                        // Section title
                        Text(
                          'Recent Applications',
                          style: Theme.of(context).textTheme.headlineSmall,
                        ),

                        SizedBox(height: AppConstants.spaceL),

                        // Applications
                        ApplicationCard(
                          isDark: isDark,
                          company: 'Google',
                          position: 'Software Engineer Intern',
                          status: 'Interview',
                          date: 'Applied 2 days ago',
                        ),

                        SizedBox(height: AppConstants.spaceM),

                        ApplicationCard(
                          isDark: isDark,
                          company: 'Microsoft',
                          position: 'Product Manager Intern',
                          status: 'Pending',
                          date: 'Applied 5 days ago',
                        ),

                        SizedBox(height: AppConstants.spaceM),

                        ApplicationCard(
                          isDark: isDark,
                          company: 'Meta',
                          position: 'Data Science Intern',
                          status: 'Applied',
                          date: 'Applied 1 week ago',
                        ),
                      ],
                    ),
                  ),
                ),
              ],
            ),
          ),
        );
      },
    );
  }
}