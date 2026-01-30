// lib\screens\profile\profile_screen.dart
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
              stream: _getProfileDataStream(user?.uid),
              builder: (context, snapshot) {
                if (!snapshot.hasData) {
                  return Center(child: CircularProgressIndicator());
                }

                final data = snapshot.data!;
                final userRole = data['role'] as String;
                final internships = data['internships'] as List<Internship>;
                final mentorCount = data['mentorCount'] as int;
                final pendingInvitesCount = data['pendingInvitesCount'] as int;

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

                            // Resume Section
                            _buildResumeSection(isDark),

                            SizedBox(height: AppConstants.spaceXL),

                            // Mentorship Summary Section
                            _buildMentorshipSummary(context, mentorCount, pendingInvitesCount, isDark),

                            SizedBox(height: AppConstants.spaceXL),

                            // Skills Section
                            _buildSkillsSummary(internships, isDark),

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

  Stream<Map<String, dynamic>> _getProfileDataStream(String? uid) async* {
    if (uid == null) {
      yield {
        'role': 'student',
        'internships': <Internship>[],
        'mentorCount': 0,
        'pendingInvitesCount': 0,
      };
      return;
    }

    await for (var _ in _firestore.collection('users').doc(uid).snapshots()) {
      final userDoc = await _firestore.collection('users').doc(uid).get();
      final userRole = userDoc.data()?['role'] ?? 'student';
      
      // Get internships for skills
      final internshipSnapshot = await _firestore
          .collection('internships')
          .where('studentId', isEqualTo: uid)
          .where('isArchived', isEqualTo: false)
          .get();
      final internships = internshipSnapshot.docs
          .map((doc) => Internship.fromFirestore(doc))
          .toList();

      // Get mentor count
      final mentorLinksSnapshot = await _firestore
          .collection('mentorStudentLinks')
          .where('studentId', isEqualTo: uid)
          .get();
      final mentorCount = mentorLinksSnapshot.docs.length;

      // Get pending invites count
      final pendingInvitesSnapshot = await _firestore
          .collection('mentorInvites')
          .where('studentId', isEqualTo: uid)
          .where('status', isEqualTo: 'pending')
          .get();
      final pendingInvitesCount = pendingInvitesSnapshot.docs.length;

      yield {
        'role': userRole,
        'internships': internships,
        'mentorCount': mentorCount,
        'pendingInvitesCount': pendingInvitesCount,
      };
    }
  }

  Widget _buildIdentitySection(User? user, bool isDark) {
    return GlassContainer(
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
          Container(
            padding: EdgeInsets.symmetric(horizontal: 12, vertical: 6),
            decoration: BoxDecoration(
              gradient: LinearGradient(
                colors: [AppColors.purplePrimary, AppColors.purpleLight],
              ),
              borderRadius: BorderRadius.circular(8),
            ),
            child: Text(
              'Student',
              style: TextStyle(
                fontSize: 13,
                fontWeight: FontWeight.w600,
                color: Colors.white,
              ),
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildResumeSection(bool isDark) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(
          'Resume',
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
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Row(
                children: [
                  Icon(
                    Icons.description_outlined,
                    color: AppColors.mediumGray,
                    size: 20,
                  ),
                  SizedBox(width: AppConstants.spaceS),
                  Expanded(
                    child: Text(
                      'No resume uploaded',
                      style: TextStyle(
                        fontSize: 14,
                        color: AppColors.mediumGray,
                        fontStyle: FontStyle.italic,
                      ),
                    ),
                  ),
                ],
              ),
              SizedBox(height: AppConstants.spaceM),
              SizedBox(
                width: double.infinity,
                child: OutlinedButton.icon(
                  onPressed: () {
                    // TODO: Implement resume upload
                  },
                  icon: Icon(Icons.upload_file, size: 18),
                  label: Text('Upload Resume'),
                  style: OutlinedButton.styleFrom(
                    foregroundColor: AppColors.purplePrimary,
                    side: BorderSide(color: AppColors.purplePrimary),
                    padding: EdgeInsets.symmetric(vertical: 12),
                    shape: RoundedRectangleBorder(
                      borderRadius: BorderRadius.circular(12),
                    ),
                  ),
                ),
              ),
            ],
          ),
        ),
      ],
    );
  }

  Widget _buildMentorshipSummary(BuildContext context, int mentorCount, int pendingInvitesCount, bool isDark) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(
          'Mentorship',
          style: TextStyle(
            fontSize: 20,
            fontWeight: FontWeight.w600,
            color: isDark ? AppColors.pureWhite : AppColors.pureBlack,
          ),
        ),
        SizedBox(height: AppConstants.spaceM),
        GestureDetector(
          onTap: () {
            Navigator.of(context, rootNavigator: true).pushNamed(AppRoutes.mentorshipManagement);
          },
          child: GlassContainer(
            isDark: isDark,
            padding: EdgeInsets.all(AppConstants.spaceL),
            child: Column(
              children: [
                Row(
                  children: [
                    Container(
                      padding: EdgeInsets.all(12),
                      decoration: BoxDecoration(
                        gradient: LinearGradient(
                          colors: [AppColors.purplePrimary, AppColors.purpleLight],
                        ),
                        borderRadius: BorderRadius.circular(12),
                      ),
                      child: Icon(
                        Icons.supervisor_account_rounded,
                        color: Colors.white,
                        size: 24,
                      ),
                    ),
                    SizedBox(width: AppConstants.spaceM),
                    Expanded(
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Text(
                            '$mentorCount Active Mentor${mentorCount != 1 ? 's' : ''}',
                            style: TextStyle(
                              fontSize: 18,
                              fontWeight: FontWeight.w600,
                              color: isDark ? AppColors.pureWhite : AppColors.pureBlack,
                            ),
                          ),
                          if (pendingInvitesCount > 0) ...[
                            SizedBox(height: 4),
                            Text(
                              '$pendingInvitesCount pending invite${pendingInvitesCount != 1 ? 's' : ''}',
                              style: TextStyle(
                                fontSize: 13,
                                color: Colors.orange,
                                fontWeight: FontWeight.w500,
                              ),
                            ),
                          ],
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
                SizedBox(height: AppConstants.spaceL),
                SizedBox(
                  width: double.infinity,
                  child: ElevatedButton.icon(
                    onPressed: mentorCount >= 3 ? null : () {
                      Navigator.of(context, rootNavigator: true).pushNamed(AppRoutes.inviteMentor);
                    },
                    icon: Icon(Icons.person_add_outlined, size: 18),
                    label: Text(mentorCount >= 3 ? 'Maximum reached (3/3)' : 'Invite a Mentor'),
                    style: ElevatedButton.styleFrom(
                      backgroundColor: AppColors.purplePrimary,
                      foregroundColor: Colors.white,
                      disabledBackgroundColor: AppColors.mediumGray.withOpacity(0.3),
                      disabledForegroundColor: AppColors.mediumGray,
                      padding: EdgeInsets.symmetric(vertical: 14),
                      shape: RoundedRectangleBorder(
                        borderRadius: BorderRadius.circular(12),
                      ),
                    ),
                  ),
                ),
              ],
            ),
          ),
        ),
      ],
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