import 'package:flutter/material.dart';
import 'dart:ui';
import 'package:firebase_auth/firebase_auth.dart';
import '../widgets/theme_toggle.dart';
import '../widgets/gradient_orb.dart';
import '../widgets/glass_container.dart';
import '../core/constants/app_constants.dart';
import '../core/theme/app_theme.dart';
import 'auth/auth_screen.dart';

class HomeScreen extends StatefulWidget {
  @override
  State<HomeScreen> createState() => _HomeScreenState();
}

class _HomeScreenState extends State<HomeScreen> {
  final user = FirebaseAuth.instance.currentUser;

  Future<void> _signOut() async {
    await FirebaseAuth.instance.signOut();
    if (mounted) {
      Navigator.of(context).pushReplacement(
        MaterialPageRoute(builder: (_) => AuthScreen()),
      );
    }
  }

  @override
  Widget build(BuildContext context) {
    final isDark = Theme.of(context).brightness == Brightness.dark;

    return Scaffold(
      body: Container(
        decoration: BoxDecoration(
          gradient: LinearGradient(
            begin: Alignment.topLeft,
            end: Alignment.bottomRight,
            colors: isDark
                ? [AppTheme.pureBlack, AppTheme.darkGray, AppTheme.pureBlack]
                : [AppTheme.pureWhite, AppTheme.lightGray, AppTheme.pureWhite],
          ),
        ),
        child: Stack(
          children: [
            // Gradient orbs
            GradientOrb(
              size: 400,
              alignment: Alignment.topRight,
              colors: [AppTheme.purplePrimary, Colors.transparent],
              opacity: 0.3,
            ),
            GradientOrb(
              size: 350,
              alignment: Alignment.bottomLeft,
              colors: [AppTheme.purpleLight, Colors.transparent],
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
                                  color: AppTheme.mediumGray,
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
                                      colors: [AppTheme.purplePrimary, AppTheme.purpleLight],
                                    ),
                                    borderRadius: BorderRadius.circular(AppConstants.radiusSmall),
                                    boxShadow: [
                                      BoxShadow(
                                        color: AppTheme.purplePrimary.withOpacity(0.4),
                                        blurRadius: 15,
                                        offset: Offset(0, 5),
                                      ),
                                    ],
                                  ),
                                  child: IconButton(
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
                            _buildStatCard(
                              isDark: isDark,
                              icon: Icons.work_outline_rounded,
                              title: 'Active',
                              value: '12',
                              gradient: [AppTheme.purplePrimary, AppTheme.purpleLight],
                            ),
                            _buildStatCard(
                              isDark: isDark,
                              icon: Icons.pending_outlined,
                              title: 'Pending',
                              value: '5',
                              gradient: [AppTheme.purpleLight, AppTheme.purpleDark],
                            ),
                            _buildStatCard(
                              isDark: isDark,
                              icon: Icons.check_circle_outline_rounded,
                              title: 'Completed',
                              value: '8',
                              gradient: [AppTheme.purpleDark, AppTheme.purplePrimary],
                            ),
                            _buildStatCard(
                              isDark: isDark,
                              icon: Icons.people_outline_rounded,
                              title: 'Mentors',
                              value: '3',
                              gradient: [AppTheme.purplePrimary, AppTheme.purpleDark],
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
                    _buildApplicationCard(
                      isDark: isDark,
                      company: 'Google',
                      position: 'Software Engineer Intern',
                      status: 'Interview',
                      date: 'Applied 2 days ago',
                    ),

                    SizedBox(height: AppConstants.spaceM),

                    _buildApplicationCard(
                      isDark: isDark,
                      company: 'Microsoft',
                      position: 'Product Manager Intern',
                      status: 'Pending',
                      date: 'Applied 5 days ago',
                    ),

                    SizedBox(height: AppConstants.spaceM),

                    _buildApplicationCard(
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
  }

  Widget _buildStatCard({
    required bool isDark,
    required IconData icon,
    required String title,
    required String value,
    required List<Color> gradient,
  }) {
    return GlassContainer(
      isDark: isDark,
      padding: EdgeInsets.all(AppConstants.spaceM),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        mainAxisAlignment: MainAxisAlignment.spaceBetween,
        children: [
          Container(
            padding: EdgeInsets.all(10),
            decoration: BoxDecoration(
              gradient: LinearGradient(colors: gradient),
              borderRadius: BorderRadius.circular(12),
            ),
            child: Icon(icon, color: Colors.white, size: 20),
          ),
          SizedBox(height: 4),
          Flexible(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              mainAxisSize: MainAxisSize.min,
              children: [
                FittedBox(
                  fit: BoxFit.scaleDown,
                  child: Text(
                    value,
                    style: TextStyle(
                      fontSize: 28,
                      fontWeight: FontWeight.w700,
                      color: isDark ? AppTheme.pureWhite : AppTheme.pureBlack,
                      letterSpacing: -0.5,
                    ),
                  ),
                ),
                SizedBox(height: 2),
                FittedBox(
                  fit: BoxFit.scaleDown,
                  child: Text(
                    title,
                    style: TextStyle(
                      fontSize: 13,
                      color: AppTheme.mediumGray,
                      fontWeight: FontWeight.w600,
                    ),
                  ),
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildApplicationCard({
    required bool isDark,
    required String company,
    required String position,
    required String status,
    required String date,
  }) {
    return GlassContainer(
      isDark: isDark,
      padding: EdgeInsets.all(AppConstants.spaceL),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              Flexible(
                child: Row(
                  children: [
                    Container(
                      width: 48,
                      height: 48,
                      decoration: BoxDecoration(
                        gradient: LinearGradient(
                          colors: [AppTheme.purplePrimary, AppTheme.purpleLight],
                        ),
                        borderRadius: BorderRadius.circular(AppConstants.radiusSmall),
                      ),
                      child: Icon(
                        Icons.work_outline_rounded,
                        color: Colors.white,
                        size: 24,
                      ),
                    ),
                    SizedBox(width: AppConstants.spaceM),
                    Flexible(
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Text(
                            company,
                            style: TextStyle(
                              fontSize: 18,
                              fontWeight: FontWeight.w700,
                              color: isDark ? AppTheme.pureWhite : AppTheme.pureBlack,
                            ),
                            overflow: TextOverflow.ellipsis,
                          ),
                          SizedBox(height: 2),
                          Text(
                            position,
                            style: TextStyle(
                              fontSize: 14,
                              color: AppTheme.mediumGray,
                            ),
                            overflow: TextOverflow.ellipsis,
                            maxLines: 1,
                          ),
                        ],
                      ),
                    ),
                  ],
                ),
              ),
              SizedBox(width: 8),
              Container(
                padding: EdgeInsets.symmetric(
                  horizontal: 12,
                  vertical: 6,
                ),
                decoration: BoxDecoration(
                  color: AppTheme.purplePrimary.withOpacity(0.2),
                  borderRadius: BorderRadius.circular(10),
                  border: Border.all(
                    color: AppTheme.purplePrimary.withOpacity(0.5),
                    width: 1.5,
                  ),
                ),
                child: Text(
                  status,
                  style: TextStyle(
                    fontSize: 11,
                    fontWeight: FontWeight.w700,
                    color: AppTheme.purplePrimary,
                  ),
                ),
              ),
            ],
          ),
          SizedBox(height: AppConstants.spaceM),
          Row(
            children: [
              Icon(
                Icons.schedule_rounded,
                size: 16,
                color: AppTheme.mediumGray,
              ),
              SizedBox(width: 6),
              Text(
                date,
                style: TextStyle(
                  fontSize: 13,
                  color: AppTheme.mediumGray,
                ),
              ),
            ],
          ),
        ],
      ),
    );
  }
}