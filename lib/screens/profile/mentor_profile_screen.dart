// lib/screens/profile/mentor_profile_screen.dart - STREAMLINED VERSION
import 'package:flutter/material.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import '../../core/constants/colors.dart';
import '../../core/constants/app_constants.dart';
import '../../core/widgets/glass_container.dart';
import '../../core/widgets/gradient_orb.dart';
import '../../core/widgets/theme_toggle.dart';
import '../../app/app_routes.dart';

class MentorProfileScreen extends StatelessWidget {
  final FirebaseAuth _auth = FirebaseAuth.instance;
  final FirebaseFirestore _firestore = FirebaseFirestore.instance;

  @override
  Widget build(BuildContext context) {
    final isDark = Theme.of(context).brightness == Brightness.dark;
    final user = _auth.currentUser;

    return Scaffold(
      body: Stack(
        children: [
          GradientOrb(
            size: 300,
            alignment: Alignment.topRight,
            colors: [AppColors.bluePrimary, AppColors.blueLight],
            opacity: 0.15,
          ),
          GradientOrb(
            size: 250,
            alignment: Alignment.bottomLeft,
            colors: [AppColors.blueLight, AppColors.bluePrimary],
            opacity: 0.1,
          ),

          SafeArea(
            child: StreamBuilder<Map<String, dynamic>>(
              stream: _getMentorStatsStream(user?.uid),
              builder: (context, snapshot) {
                if (!snapshot.hasData) {
                  return Center(child: CircularProgressIndicator());
                }

                final data = snapshot.data!;
                final completedFeedback = data['completedFeedback'] as int;
                final responseRate = data['responseRate'] as double;
                final avgResponseTime = data['avgResponseTime'] as String;

                return CustomScrollView(
                  slivers: [
                    SliverToBoxAdapter(
                      child: Padding(
                        padding: EdgeInsets.all(AppConstants.spaceL),
                        child: Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            // Header
                            Row(
                              mainAxisAlignment: MainAxisAlignment.spaceBetween,
                              children: [
                                Text(
                                  'Profile',
                                  style: Theme.of(context).textTheme.displayMedium,
                                ),
                                Row(
                                  children: [
                                    IconButton(
                                      onPressed: () => _signOut(context),
                                      icon: Icon(Icons.logout_rounded),
                                      tooltip: 'Sign Out',
                                    ),
                                    SizedBox(width: AppConstants.spaceS),
                                    ThemeToggle(),
                                  ],
                                ),
                              ],
                            ),

                            SizedBox(height: AppConstants.spaceXL),

                            // Identity Section
                            _buildIdentitySection(user, isDark),

                            SizedBox(height: AppConstants.spaceXL),

                            // Performance Metrics (UNIQUE TO MENTOR)
                            Text(
                              'Performance Metrics',
                              style: TextStyle(
                                fontSize: 20,
                                fontWeight: FontWeight.w600,
                                color: isDark ? AppColors.pureWhite : AppColors.pureBlack,
                              ),
                            ),
                            SizedBox(height: AppConstants.spaceM),
                            _buildPerformanceMetrics(
                              completedFeedback,
                              responseRate,
                              avgResponseTime,
                              isDark,
                            ),

                            SizedBox(height: AppConstants.spaceXL),

                            // Impact Statement (UNIQUE TO MENTOR)
                            _buildImpactStatement(completedFeedback, isDark),

                            SizedBox(height: AppConstants.spaceXL),

                            // Settings
                            Text(
                              'Settings',
                              style: TextStyle(
                                fontSize: 20,
                                fontWeight: FontWeight.w600,
                                color: isDark ? AppColors.pureWhite : AppColors.pureBlack,
                              ),
                            ),
                            SizedBox(height: AppConstants.spaceM),
                            _buildSettingsOptions(context, isDark),

                            SizedBox(height: AppConstants.spaceXL),
                          ],
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

  Stream<Map<String, dynamic>> _getMentorStatsStream(String? uid) async* {
    if (uid == null) {
      yield {
        'completedFeedback': 0,
        'responseRate': 0.0,
        'avgResponseTime': 'N/A',
      };
      return;
    }

    await for (var _ in _firestore.collection('users').doc(uid).snapshots()) {
      // Get all feedback cycles
      final allFeedbackSnapshot = await _firestore
          .collection('feedbackCycles')
          .where('mentorId', isEqualTo: uid)
          .get();

      final completed = allFeedbackSnapshot.docs
          .where((doc) => doc.data()['status'] == 'completed')
          .toList();
      
      final completedFeedback = completed.length;
      final totalRequests = allFeedbackSnapshot.docs.length;
      
      // Calculate response rate
      final responseRate = totalRequests > 0 
          ? (completed.length / totalRequests * 100) 
          : 0.0;

      // Calculate average response time
      String avgResponseTime = 'N/A';
      if (completed.isNotEmpty) {
        int totalHours = 0;
        for (var doc in completed) {
          final data = doc.data();
          if (data['requestedAt'] != null && data['respondedAt'] != null) {
            final requested = (data['requestedAt'] as Timestamp).toDate();
            final responded = (data['respondedAt'] as Timestamp).toDate();
            totalHours += responded.difference(requested).inHours;
          }
        }
        final avgHours = totalHours / completed.length;
        if (avgHours < 24) {
          avgResponseTime = '${avgHours.round()}h';
        } else {
          avgResponseTime = '${(avgHours / 24).round()}d';
        }
      }

      yield {
        'completedFeedback': completedFeedback,
        'responseRate': responseRate,
        'avgResponseTime': avgResponseTime,
      };
    }
  }

  Widget _buildIdentitySection(User? user, bool isDark) {
    return StreamBuilder<DocumentSnapshot>(
      stream: _firestore.collection('users').doc(user?.uid).snapshots(),
      builder: (context, snapshot) {
        final userName = snapshot.data?.data() != null 
            ? (snapshot.data!.data() as Map<String, dynamic>)['displayName'] ?? user?.email?.split('@')[0] ?? 'Mentor'
            : user?.email?.split('@')[0] ?? 'Mentor';

        return GlassContainer(
          isDark: isDark,
          padding: EdgeInsets.all(AppConstants.spaceL),
          child: Column(
            children: [
              Container(
                width: 90,
                height: 90,
                decoration: BoxDecoration(
                  gradient: LinearGradient(
                    colors: [AppColors.bluePrimary, AppColors.blueLight],
                  ),
                  shape: BoxShape.circle,
                  boxShadow: [
                    BoxShadow(
                      color: AppColors.bluePrimary.withOpacity(0.3),
                      blurRadius: 20,
                      spreadRadius: 5,
                    ),
                  ],
                ),
                child: Center(
                  child: Text(
                    userName.substring(0, 1).toUpperCase(),
                    style: TextStyle(
                      fontSize: 40,
                      fontWeight: FontWeight.w700,
                      color: Colors.white,
                    ),
                  ),
                ),
              ),
              SizedBox(height: AppConstants.spaceM),
              Text(
                userName,
                style: TextStyle(
                  fontSize: 24,
                  fontWeight: FontWeight.w700,
                  color: isDark ? AppColors.pureWhite : AppColors.pureBlack,
                ),
              ),
              SizedBox(height: 6),
              Text(
                user?.email ?? '',
                style: TextStyle(
                  fontSize: 15,
                  color: AppColors.mediumGray,
                ),
              ),
              SizedBox(height: AppConstants.spaceM),
              Container(
                padding: EdgeInsets.symmetric(horizontal: 16, vertical: 8),
                decoration: BoxDecoration(
                  gradient: LinearGradient(
                    colors: [AppColors.bluePrimary, AppColors.blueLight],
                  ),
                  borderRadius: BorderRadius.circular(20),
                  boxShadow: [
                    BoxShadow(
                      color: AppColors.bluePrimary.withOpacity(0.3),
                      blurRadius: 8,
                      spreadRadius: 2,
                    ),
                  ],
                ),
                child: Row(
                  mainAxisSize: MainAxisSize.min,
                  children: [
                    Icon(Icons.verified, size: 16, color: Colors.white),
                    SizedBox(width: 6),
                    Text(
                      'Mentor',
                      style: TextStyle(
                        fontSize: 14,
                        fontWeight: FontWeight.w700,
                        color: Colors.white,
                        letterSpacing: 0.5,
                      ),
                    ),
                  ],
                ),
              ),
            ],
          ),
        );
      },
    );
  }

  Widget _buildPerformanceMetrics(
    int completedFeedback,
    double responseRate,
    String avgResponseTime,
    bool isDark,
  ) {
    return Column(
      children: [
        Row(
          children: [
            Expanded(
              child: _buildMetricCard(
                title: 'Total Feedback',
                value: completedFeedback.toString(),
                icon: Icons.feedback,
                isDark: isDark,
              ),
            ),
            SizedBox(width: AppConstants.spaceM),
            Expanded(
              child: _buildMetricCard(
                title: 'Response Rate',
                value: '${responseRate.round()}%',
                icon: Icons.trending_up,
                isDark: isDark,
              ),
            ),
          ],
        ),
        SizedBox(height: AppConstants.spaceM),
        _buildMetricCard(
          title: 'Average Response Time',
          value: avgResponseTime,
          subtitle: 'How quickly you respond to requests',
          icon: Icons.schedule,
          isDark: isDark,
          fullWidth: true,
        ),
      ],
    );
  }

  Widget _buildMetricCard({
    required String title,
    required String value,
    String? subtitle,
    required IconData icon,
    required bool isDark,
    bool fullWidth = false,
  }) {
    return GlassContainer(
      isDark: isDark,
      padding: EdgeInsets.all(AppConstants.spaceM),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            children: [
              Container(
                padding: EdgeInsets.all(8),
                decoration: BoxDecoration(
                  gradient: LinearGradient(
                    colors: [AppColors.bluePrimary, AppColors.blueLight],
                  ),
                  borderRadius: BorderRadius.circular(10),
                ),
                child: Icon(icon, color: Colors.white, size: 18),
              ),
              if (fullWidth) ...[
                SizedBox(width: AppConstants.spaceM),
                Expanded(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(
                        title,
                        style: TextStyle(
                          fontSize: 14,
                          fontWeight: FontWeight.w600,
                          color: AppColors.mediumGray,
                        ),
                      ),
                      if (subtitle != null) ...[
                        SizedBox(height: 2),
                        Text(
                          subtitle,
                          style: TextStyle(
                            fontSize: 12,
                            color: AppColors.mediumGray.withOpacity(0.7),
                          ),
                        ),
                      ],
                    ],
                  ),
                ),
                Text(
                  value,
                  style: TextStyle(
                    fontSize: 24,
                    fontWeight: FontWeight.w700,
                    color: AppColors.bluePrimary,
                  ),
                ),
              ],
            ],
          ),
          if (!fullWidth) ...[
            SizedBox(height: AppConstants.spaceM),
            Text(
              value,
              style: TextStyle(
                fontSize: 28,
                fontWeight: FontWeight.w700,
                color: isDark ? AppColors.pureWhite : AppColors.pureBlack,
              ),
            ),
            SizedBox(height: 4),
            Text(
              title,
              style: TextStyle(
                fontSize: 13,
                color: AppColors.mediumGray,
              ),
            ),
          ],
        ],
      ),
    );
  }

  Widget _buildImpactStatement(int completedFeedback, bool isDark) {
    if (completedFeedback == 0) return SizedBox.shrink();

    return GlassContainer(
      isDark: isDark,
      padding: EdgeInsets.all(AppConstants.spaceL),
      child: Row(
        children: [
          Container(
            padding: EdgeInsets.all(12),
            decoration: BoxDecoration(
              gradient: LinearGradient(
                colors: [AppColors.bluePrimary, AppColors.blueLight],
              ),
              shape: BoxShape.circle,
            ),
            child: Icon(
              Icons.auto_awesome,
              color: Colors.white,
              size: 28,
            ),
          ),
          SizedBox(width: AppConstants.spaceL),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  'Making an Impact',
                  style: TextStyle(
                    fontSize: 18,
                    fontWeight: FontWeight.w700,
                    color: isDark ? AppColors.pureWhite : AppColors.pureBlack,
                  ),
                ),
                SizedBox(height: 4),
                Text(
                  'You\'ve provided $completedFeedback feedback session${completedFeedback != 1 ? 's' : ''}, helping students grow in their careers.',
                  style: TextStyle(
                    fontSize: 14,
                    color: AppColors.mediumGray,
                    height: 1.4,
                  ),
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildSettingsOptions(BuildContext context, bool isDark) {
    return Column(
      children: [
        _buildSettingTile(
          icon: Icons.help_outline,
          title: 'Help & Support',
          onTap: () {
            ScaffoldMessenger.of(context).showSnackBar(
              SnackBar(
                content: Text('Coming soon!'),
                backgroundColor: AppColors.bluePrimary,
              ),
            );
          },
          isDark: isDark,
        ),
        SizedBox(height: AppConstants.spaceM),
        _buildSettingTile(
          icon: Icons.logout_rounded,
          title: 'Sign Out',
          onTap: () => _signOut(context),
          isDark: isDark,
          isDestructive: true,
        ),
      ],
    );
  }

  Widget _buildSettingTile({
    required IconData icon,
    required String title,
    required VoidCallback onTap,
    required bool isDark,
    bool isDestructive = false,
  }) {
    return GestureDetector(
      onTap: onTap,
      child: GlassContainer(
        isDark: isDark,
        padding: EdgeInsets.all(AppConstants.spaceM),
        child: Row(
          children: [
            Container(
              padding: EdgeInsets.all(10),
              decoration: BoxDecoration(
                gradient: isDestructive
                    ? null
                    : LinearGradient(
                        colors: [AppColors.bluePrimary, AppColors.blueLight],
                      ),
                color: isDestructive ? Colors.red.withOpacity(0.2) : null,
                borderRadius: BorderRadius.circular(10),
              ),
              child: Icon(
                icon,
                color: isDestructive ? Colors.red : Colors.white,
                size: 20,
              ),
            ),
            SizedBox(width: AppConstants.spaceM),
            Expanded(
              child: Text(
                title,
                style: TextStyle(
                  fontSize: 16,
                  fontWeight: FontWeight.w600,
                  color: isDestructive
                      ? Colors.red
                      : isDark
                          ? AppColors.pureWhite
                          : AppColors.pureBlack,
                ),
              ),
            ),
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

  Future<void> _signOut(BuildContext context) async {
    final confirmed = await showDialog<bool>(
      context: context,
      builder: (context) => AlertDialog(
        title: Text('Sign Out'),
        content: Text('Are you sure you want to sign out?'),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(context, false),
            child: Text('Cancel'),
          ),
          TextButton(
            onPressed: () => Navigator.pop(context, true),
            child: Text('Sign Out', style: TextStyle(color: Colors.red)),
          ),
        ],
      ),
    );

    if (confirmed == true) {
      await _auth.signOut();
      if (context.mounted) {
        Navigator.of(context, rootNavigator: true)
            .pushNamedAndRemoveUntil(AppRoutes.auth, (route) => false);
      }
    }
  }
}