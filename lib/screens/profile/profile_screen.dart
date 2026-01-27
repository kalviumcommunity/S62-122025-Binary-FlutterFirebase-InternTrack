// lib/screens/profile/profile_screen.dart
import 'package:flutter/material.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import '../../core/constants/colors.dart';
import '../../core/constants/app_constants.dart';
import '../../core/widgets/glass_container.dart';
import '../../core/widgets/gradient_orb.dart';
import '../../core/widgets/theme_toggle.dart';
import '../../models/internship_model.dart';
import '../../app/app_routes.dart';

class ProfileScreen extends StatelessWidget {
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
            colors: [AppColors.purplePrimary, AppColors.purpleLight],
            opacity: 0.15,
          ),

          SafeArea(
            child: StreamBuilder<Map<String, dynamic>>(
              stream: _firestore.collection('users').doc(user?.uid).snapshots().asyncMap((userDoc) async {
                final userRole = userDoc.data()?['role'] ?? 'student';
                final internshipSnapshot = await _firestore
                    .collection('internships')
                    .where('studentId', isEqualTo: user?.uid)
                    .where('isArchived', isEqualTo: false)
                    .get();
                final internships = internshipSnapshot.docs.map((doc) => Internship.fromFirestore(doc)).toList();
                return {
                  'role': userRole,
                  'internships': internships,
                };
              }),
              builder: (context, snapshot) {
                final userRole = snapshot.hasData ? snapshot.data!['role'] as String : 'student';
                final internships = snapshot.hasData 
                    ? List<Internship>.from(snapshot.data!['internships'] as List)
                    : <Internship>[];

                return CustomScrollView(
                  slivers: [
                    SliverToBoxAdapter(
                      child: Padding(
                        padding: EdgeInsets.all(AppConstants.spaceL),
                        child: Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            Row(
                              mainAxisAlignment: MainAxisAlignment.spaceBetween,
                              children: [
                                Text(
                                  'Profile',
                                  style: Theme.of(context).textTheme.displayMedium,
                                ),
                                ThemeToggle(),
                              ],
                            ),

                            SizedBox(height: AppConstants.spaceXL),

                            // Profile Card
                            GlassContainer(
                              isDark: isDark,
                              padding: EdgeInsets.all(AppConstants.spaceL),
                              child: Column(
                                children: [
                                  Container(
                                    width: 80,
                                    height: 80,
                                    decoration: BoxDecoration(
                                      gradient: LinearGradient(
                                        colors: [AppColors.purplePrimary, AppColors.purpleLight],
                                      ),
                                      shape: BoxShape.circle,
                                    ),
                                    child: Center(
                                      child: Text(
                                        user?.email?.substring(0, 1).toUpperCase() ?? 'U',
                                        style: TextStyle(
                                          fontSize: 36,
                                          fontWeight: FontWeight.w700,
                                          color: Colors.white,
                                        ),
                                      ),
                                    ),
                                  ),
                                  SizedBox(height: AppConstants.spaceM),
                                  Text(
                                    user?.email ?? 'User',
                                    style: TextStyle(
                                      fontSize: 20,
                                      fontWeight: FontWeight.w600,
                                      color: isDark ? AppColors.pureWhite : AppColors.pureBlack,
                                    ),
                                  ),
                                  SizedBox(height: 4),
                                  Text(
                                    'Student',
                                    style: TextStyle(
                                      fontSize: 15,
                                      color: AppColors.mediumGray,
                                    ),
                                  ),
                                ],
                              ),
                            ),

                            SizedBox(height: AppConstants.spaceXL),

                            // Stats
                            Text(
                              'Your Progress',
                              style: Theme.of(context).textTheme.headlineSmall,
                            ),
                            SizedBox(height: AppConstants.spaceM),
                            _buildStatsGrid(internships, isDark),

                            SizedBox(height: AppConstants.spaceXL),

                            // Skills Summary
                            _buildSkillsSummary(internships, isDark),

                            SizedBox(height: AppConstants.spaceXL),

                            // Settings
                            Text(
                              'Settings',
                              style: Theme.of(context).textTheme.headlineSmall,
                            ),
                            SizedBox(height: AppConstants.spaceM),
                            _buildSettingsOptions(context, isDark, userRole),

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

  Widget _buildStatsGrid(List<Internship> internships, bool isDark) {
    final totalApplied = internships.length;
    final totalAccepted = internships.where((i) => i.status == InternshipStatus.accepted).length;
    final totalOffered = internships.where((i) => i.status == InternshipStatus.offered).length;
    final totalRejected = internships.where((i) => i.status == InternshipStatus.rejected).length;

    return Column(
      children: [
        Row(
          children: [
            Expanded(
              child: _buildStatBox(
                'Total Applied',
                totalApplied.toString(),
                Icons.work_outline_rounded,
                Colors.blue,
                isDark,
              ),
            ),
            SizedBox(width: AppConstants.spaceM),
            Expanded(
              child: _buildStatBox(
                'Accepted',
                totalAccepted.toString(),
                Icons.check_circle_outline,
                Colors.green,
                isDark,
              ),
            ),
          ],
        ),
        SizedBox(height: AppConstants.spaceM),
        Row(
          children: [
            Expanded(
              child: _buildStatBox(
                'Offers',
                totalOffered.toString(),
                Icons.emoji_events_outlined,
                AppColors.purplePrimary,
                isDark,
              ),
            ),
            SizedBox(width: AppConstants.spaceM),
            Expanded(
              child: _buildStatBox(
                'Rejected',
                totalRejected.toString(),
                Icons.cancel_outlined,
                Colors.red,
                isDark,
              ),
            ),
          ],
        ),
      ],
    );
  }

  Widget _buildStatBox(String label, String value, IconData icon, Color color, bool isDark) {
    return GlassContainer(
      isDark: isDark,
      padding: EdgeInsets.all(AppConstants.spaceM),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Container(
            padding: EdgeInsets.all(8),
            decoration: BoxDecoration(
              color: color.withOpacity(0.2),
              borderRadius: BorderRadius.circular(10),
            ),
            child: Icon(icon, color: color, size: 20),
          ),
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
            label,
            style: TextStyle(
              fontSize: 13,
              color: AppColors.mediumGray,
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildSkillsSummary(List<Internship> internships, bool isDark) {
    final allSkills = <String>[];
    for (var internship in internships) {
      allSkills.addAll(internship.skillsGained);
    }
    final skillCounts = <String, int>{};
    for (var skill in allSkills) {
      skillCounts[skill] = (skillCounts[skill] ?? 0) + 1;
    }
    final topSkills = skillCounts.entries.toList()
      ..sort((a, b) => b.value.compareTo(a.value));

    if (topSkills.isEmpty) {
      return SizedBox.shrink();
    }

    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(
          'Skills Gained',
          style: TextStyle(
            fontSize: 20,
            fontWeight: FontWeight.w600,
            color: isDark ? AppColors.pureWhite : AppColors.pureBlack,
          ),
        ),
        SizedBox(height: AppConstants.spaceM),
        GlassContainer(
          isDark: isDark,
          padding: EdgeInsets.all(AppConstants.spaceM),
          child: Wrap(
            spacing: 8,
            runSpacing: 8,
            children: topSkills.take(10).map((entry) {
              return Container(
                padding: EdgeInsets.symmetric(horizontal: 12, vertical: 6),
                decoration: BoxDecoration(
                  gradient: LinearGradient(
                    colors: [AppColors.purplePrimary, AppColors.purpleLight],
                  ),
                  borderRadius: BorderRadius.circular(8),
                ),
                child: Row(
                  mainAxisSize: MainAxisSize.min,
                  children: [
                    Text(
                      entry.key,
                      style: TextStyle(
                        fontSize: 13,
                        fontWeight: FontWeight.w500,
                        color: Colors.white,
                      ),
                    ),
                    SizedBox(width: 6),
                    Container(
                      padding: EdgeInsets.symmetric(horizontal: 6, vertical: 2),
                      decoration: BoxDecoration(
                        color: Colors.white.withOpacity(0.3),
                        borderRadius: BorderRadius.circular(4),
                      ),
                      child: Text(
                        '${entry.value}',
                        style: TextStyle(
                          fontSize: 11,
                          fontWeight: FontWeight.w700,
                          color: Colors.white,
                        ),
                      ),
                    ),
                  ],
                ),
              );
            }).toList(),
          ),
        ),
      ],
    );
  }

  Widget _buildSettingsOptions(BuildContext context, bool isDark, String userRole) {
    return Column(
      children: [
        // Only show invite mentor for students
        if (userRole == 'student') ...[
          _buildSettingTile(
            icon: Icons.person_add_outlined,
            title: 'Invite Mentor',
            onTap: () => Navigator.of(context, rootNavigator: true).pushNamed(AppRoutes.inviteMentor),
            isDark: isDark,
          ),
          SizedBox(height: AppConstants.spaceM),
        ],
        
        _buildSettingTile(
          icon: Icons.archive_outlined,
          title: 'Archived Internships',
          onTap: () => Navigator.of(context, rootNavigator: true).pushNamed(AppRoutes.archivedInternships),
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
                color: (isDestructive ? Colors.red : AppColors.purplePrimary).withOpacity(0.2),
                borderRadius: BorderRadius.circular(10),
              ),
              child: Icon(
                icon,
                color: isDestructive ? Colors.red : AppColors.purplePrimary,
                size: 20,
              ),
            ),
            SizedBox(width: AppConstants.spaceM),
            Expanded(
              child: Text(
                title,
                style: TextStyle(
                  fontSize: 16,
                  fontWeight: FontWeight.w500,
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
        Navigator.of(context, rootNavigator: true).pushNamedAndRemoveUntil(AppRoutes.auth, (route) => false);
      }
    }
  }
}