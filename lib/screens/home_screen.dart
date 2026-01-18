import 'package:flutter/material.dart';
import 'package:firebase_auth/firebase_auth.dart';
import '../../widgets/theme_toggle_button.dart';
import '../../widgets/animated_background.dart';
import '../../widgets/floating_orbs.dart';
import '../../core/constants/app_constants.dart';
import 'auth/auth_screen.dart';

class HomeScreen extends StatefulWidget {
  @override
  State<HomeScreen> createState() => _HomeScreenState();
}

class _HomeScreenState extends State<HomeScreen> with SingleTickerProviderStateMixin {
  late AnimationController _backgroundController;
  final user = FirebaseAuth.instance.currentUser;

  @override
  void initState() {
    super.initState();
    _backgroundController = AnimationController(
      duration: Duration(milliseconds: AppConstants.backgroundAnimationDuration),
      vsync: this,
    )..repeat();
  }

  @override
  void dispose() {
    _backgroundController.dispose();
    super.dispose();
  }

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
      body: Stack(
        children: [
          AnimatedBackground(controller: _backgroundController, isDark: isDark),
          FloatingOrbs(controller: _backgroundController, isDark: isDark),

          SafeArea(
            child: SingleChildScrollView(
              physics: BouncingScrollPhysics(),
              child: Padding(
                padding: EdgeInsets.all(AppConstants.spacingLarge),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    // Header
                    Row(
                      mainAxisAlignment: MainAxisAlignment.spaceBetween,
                      children: [
                        Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            Text(
                              'Welcome Back,',
                              style: TextStyle(
                                fontSize: 16,
                                color: Color(0xFF6B6B6B),
                                fontWeight: FontWeight.w500,
                              ),
                            ),
                            SizedBox(height: AppConstants.spacingXSmall),
                            ShaderMask(
                              shaderCallback: (bounds) => LinearGradient(
                                colors: isDark
                                    ? [Colors.white, Color(0xFFB8B8B8)]
                                    : [Colors.black, Color(0xFF4A4A4A)],
                              ).createShader(bounds),
                              child: Text(
                                user?.displayName ?? 'User',
                                style: TextStyle(
                                  fontSize: 28,
                                  fontWeight: FontWeight.w900,
                                  color: Colors.white,
                                  letterSpacing: -0.5,
                                ),
                              ),
                            ),
                          ],
                        ),
                        Row(
                          children: [
                            ThemeToggleButton(),
                            SizedBox(width: AppConstants.spacingSmall + 4),
                            Container(
                              width: 56,
                              height: 56,
                              decoration: BoxDecoration(
                                gradient: LinearGradient(
                                  colors: isDark
                                      ? [Color(0xFF6B4FBB), Color(0xFF4A90E2)]
                                      : [Color(0xFF4A90E2), Color(0xFF6B4FBB)],
                                ),
                                borderRadius: BorderRadius.circular(AppConstants.borderRadiusMedium),
                                boxShadow: [
                                  BoxShadow(
                                    color: (isDark ? Color(0xFF6B4FBB) : Color(0xFF4A90E2))
                                        .withOpacity(0.3),
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
                          ],
                        ),
                      ],
                    ),

                    SizedBox(height: AppConstants.spacingXXLarge),

                    // Stats Cards
                    Row(
                      children: [
                        Expanded(
                          child: _buildStatCard(
                            isDark: isDark,
                            icon: Icons.work_outline_rounded,
                            title: 'Active',
                            value: '12',
                            gradient: [Color(0xFF6B4FBB), Color(0xFF4A90E2)],
                          ),
                        ),
                        SizedBox(width: AppConstants.spacingMedium),
                        Expanded(
                          child: _buildStatCard(
                            isDark: isDark,
                            icon: Icons.pending_outlined,
                            title: 'Pending',
                            value: '5',
                            gradient: [Color(0xFF4A90E2), Color(0xFFE94B8C)],
                          ),
                        ),
                      ],
                    ),

                    SizedBox(height: AppConstants.spacingMedium),

                    Row(
                      children: [
                        Expanded(
                          child: _buildStatCard(
                            isDark: isDark,
                            icon: Icons.check_circle_outline_rounded,
                            title: 'Completed',
                            value: '8',
                            gradient: [Color(0xFFE94B8C), Color(0xFFFF6B35)],
                          ),
                        ),
                        SizedBox(width: AppConstants.spacingMedium),
                        Expanded(
                          child: _buildStatCard(
                            isDark: isDark,
                            icon: Icons.people_outline_rounded,
                            title: 'Mentors',
                            value: '3',
                            gradient: [Color(0xFFFF6B35), Color(0xFF6B4FBB)],
                          ),
                        ),
                      ],
                    ),

                    SizedBox(height: AppConstants.spacingXXLarge),

                    // Recent Applications Section
                    Text(
                      'Recent Applications',
                      style: TextStyle(
                        fontSize: 22,
                        fontWeight: FontWeight.w900,
                        color: isDark ? Colors.white : Colors.black,
                        letterSpacing: -0.5,
                      ),
                    ),

                    SizedBox(height: 20),

                    // Application Cards
                    _buildApplicationCard(
                      isDark: isDark,
                      company: 'Google',
                      position: 'Software Engineer Intern',
                      status: 'Interview',
                      date: 'Applied 2 days ago',
                      statusColor: Color(0xFF4A90E2),
                    ),

                    SizedBox(height: AppConstants.spacingMedium),

                    _buildApplicationCard(
                      isDark: isDark,
                      company: 'Microsoft',
                      position: 'Product Manager Intern',
                      status: 'Pending',
                      date: 'Applied 5 days ago',
                      statusColor: Color(0xFFFF6B35),
                    ),

                    SizedBox(height: AppConstants.spacingMedium),

                    _buildApplicationCard(
                      isDark: isDark,
                      company: 'Meta',
                      position: 'Data Science Intern',
                      status: 'Applied',
                      date: 'Applied 1 week ago',
                      statusColor: Color(0xFF6B6B6B),
                    ),

                    SizedBox(height: AppConstants.spacingXXLarge),

                    // Quick Actions
                    Container(
                      width: double.infinity,
                      padding: EdgeInsets.all(28),
                      decoration: BoxDecoration(
                        gradient: LinearGradient(
                          colors: isDark
                              ? [Color(0xFF6B4FBB), Color(0xFF4A90E2)]
                              : [Color(0xFF4A90E2), Color(0xFF6B4FBB)],
                        ),
                        borderRadius: BorderRadius.circular(AppConstants.borderRadiusLarge),
                        boxShadow: [
                          BoxShadow(
                            color: (isDark ? Color(0xFF6B4FBB) : Color(0xFF4A90E2))
                                .withOpacity(0.4),
                            blurRadius: 30,
                            offset: Offset(0, 15),
                          ),
                        ],
                      ),
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Icon(
                            Icons.add_circle_outline_rounded,
                            color: Colors.white,
                            size: 40,
                          ),
                          SizedBox(height: AppConstants.spacingMedium),
                          Text(
                            'Add New Application',
                            style: TextStyle(
                              fontSize: 24,
                              fontWeight: FontWeight.w900,
                              color: Colors.white,
                              letterSpacing: -0.5,
                            ),
                          ),
                          SizedBox(height: AppConstants.spacingSmall),
                          Text(
                            'Track your latest internship opportunity',
                            style: TextStyle(
                              fontSize: 15,
                              color: Colors.white.withOpacity(0.8),
                            ),
                          ),
                        ],
                      ),
                    ),

                    SizedBox(height: AppConstants.spacingLarge),
                  ],
                ),
              ),
            ),
          ),
        ],
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
    return Container(
      padding: EdgeInsets.all(20),
      decoration: BoxDecoration(
        color: isDark
            ? Colors.white.withOpacity(0.05)
            : Colors.white.withOpacity(0.7),
        borderRadius: BorderRadius.circular(20),
        border: Border.all(
          color: isDark
              ? Colors.white.withOpacity(0.1)
              : Colors.black.withOpacity(0.08),
          width: 1.5,
        ),
        boxShadow: [
          BoxShadow(
            color: isDark
                ? Colors.black.withOpacity(0.2)
                : Colors.black.withOpacity(0.04),
            blurRadius: 15,
            offset: Offset(0, 5),
          ),
        ],
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Container(
            padding: EdgeInsets.all(10),
            decoration: BoxDecoration(
              gradient: LinearGradient(colors: gradient),
              borderRadius: BorderRadius.circular(AppConstants.borderRadiusSmall),
            ),
            child: Icon(icon, color: Colors.white, size: 24),
          ),
          SizedBox(height: AppConstants.spacingMedium),
          Text(
            value,
            style: TextStyle(
              fontSize: 28,
              fontWeight: FontWeight.w900,
              color: isDark ? Colors.white : Colors.black,
              letterSpacing: -0.5,
            ),
          ),
          SizedBox(height: AppConstants.spacingXSmall),
          Text(
            title,
            style: TextStyle(
              fontSize: 14,
              color: Color(0xFF6B6B6B),
              fontWeight: FontWeight.w600,
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
    required Color statusColor,
  }) {
    return Container(
      padding: EdgeInsets.all(20),
      decoration: BoxDecoration(
        color: isDark
            ? Colors.white.withOpacity(0.05)
            : Colors.white.withOpacity(0.7),
        borderRadius: BorderRadius.circular(20),
        border: Border.all(
          color: isDark
              ? Colors.white.withOpacity(0.1)
              : Colors.black.withOpacity(0.08),
          width: 1.5,
        ),
        boxShadow: [
          BoxShadow(
            color: isDark
                ? Colors.black.withOpacity(0.2)
                : Colors.black.withOpacity(0.04),
            blurRadius: 15,
            offset: Offset(0, 5),
          ),
        ],
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              Text(
                company,
                style: TextStyle(
                  fontSize: 20,
                  fontWeight: FontWeight.w900,
                  color: isDark ? Colors.white : Colors.black,
                  letterSpacing: -0.3,
                ),
              ),
              Container(
                padding: EdgeInsets.symmetric(horizontal: 12, vertical: 6),
                decoration: BoxDecoration(
                  color: statusColor.withOpacity(0.2),
                  borderRadius: BorderRadius.circular(AppConstants.spacingSmall),
                  border: Border.all(
                    color: statusColor,
                    width: 1.5,
                  ),
                ),
                child: Text(
                  status,
                  style: TextStyle(
                    fontSize: 12,
                    fontWeight: FontWeight.w700,
                    color: statusColor,
                  ),
                ),
              ),
            ],
          ),
          SizedBox(height: AppConstants.spacingSmall),
          Text(
            position,
            style: TextStyle(
              fontSize: 15,
              color: Color(0xFF6B6B6B),
              fontWeight: FontWeight.w600,
            ),
          ),
          SizedBox(height: AppConstants.spacingSmall + 4),
          Row(
            children: [
              Icon(
                Icons.schedule_rounded,
                size: 16,
                color: Color(0xFF6B6B6B),
              ),
              SizedBox(width: 6),
              Text(
                date,
                style: TextStyle(
                  fontSize: 13,
                  color: Color(0xFF6B6B6B),
                ),
              ),
            ],
          ),
        ],
      ),
    );
  }
}