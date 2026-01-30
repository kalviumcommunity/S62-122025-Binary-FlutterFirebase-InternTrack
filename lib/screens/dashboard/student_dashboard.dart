// lib\screens\dashboard\student_dashboard.dart
import 'package:flutter/material.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:provider/provider.dart';
import '../../core/constants/colors.dart';
import '../../core/constants/app_constants.dart';
import '../../core/widgets/glass_container.dart';
import '../../core/widgets/gradient_orb.dart';
import '../../core/widgets/theme_toggle.dart';
import '../../models/internship_model.dart';
import '../../providers/internship_provider.dart';
import '../../app/app_routes.dart';
import '../../core/widgets/internship_widgets.dart';
import '../internships/internship_list_screen.dart';
import '../profile/profile_screen.dart';
import 'dart:ui';

class StudentDashboard extends StatefulWidget {
  @override
  State<StudentDashboard> createState() => _StudentDashboardState();
}

class _StudentDashboardState extends State<StudentDashboard> {
  int _selectedIndex = 0;
  final FirebaseAuth _auth = FirebaseAuth.instance;

  @override
  void initState() {
    super.initState();
    // Initialize internships stream when dashboard loads
    WidgetsBinding.instance.addPostFrameCallback((_) {
      final user = _auth.currentUser;
      if (user != null) {
        context.read<InternshipProvider>().initializeInternshipsStream(user.uid);
        context.read<InternshipProvider>().initializeArchivedStream(user.uid);
      }
    });
  }

  @override
  Widget build(BuildContext context) {
    final isDark = Theme.of(context).brightness == Brightness.dark;

    return Scaffold(
      body: IndexedStack(
        index: _selectedIndex,
        children: [
          _buildDashboardHome(isDark),
          _buildInternshipsView(),
          _buildProfileView(),
        ],
      ),
      bottomNavigationBar: _buildBottomNav(isDark),
    );
  }

  Widget _buildDashboardHome(bool isDark) {
    return Stack(
      children: [
        GradientOrb(
          size: 300,
          alignment: Alignment.topRight,
          colors: [AppColors.purplePrimary, AppColors.purpleLight],
          opacity: 0.15,
        ),
        GradientOrb(
          size: 250,
          alignment: Alignment.bottomLeft,
          colors: [AppColors.purpleLight, AppColors.purplePrimary],
          opacity: 0.1,
        ),

        SafeArea(
          child: Consumer<InternshipProvider>(
            builder: (context, provider, child) {
              if (provider.isLoading) {
                return Center(child: CircularProgressIndicator());
              }

              final internships = provider.internships;

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
                              Column(
                                crossAxisAlignment: CrossAxisAlignment.start,
                                children: [
                                  Text(
                                    'Dashboard',
                                    style: Theme.of(context).textTheme.displayMedium,
                                  ),
                                  SizedBox(height: 4),
                                  Text(
                                    'Track your journey',
                                    style: Theme.of(context).textTheme.bodyMedium,
                                  ),
                                ],
                              ),
                              ThemeToggle(),
                            ],
                          ),

                          SizedBox(height: AppConstants.spaceXL),

                          _buildStatsCards(provider, isDark),

                          SizedBox(height: AppConstants.spaceXL),

                          _buildUpcomingDeadlines(provider, isDark),

                          SizedBox(height: AppConstants.spaceXL),

                          _buildRecentActivity(internships, isDark),
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
    );
  }

  Widget _buildStatsCards(InternshipProvider provider, bool isDark) {
    final totalApplied = provider.internships.length;
    final interviewing = provider.getCountByStatus(InternshipStatus.interviewing);
    final offered = provider.getCountByStatus(InternshipStatus.offered);

    return Row(
      children: [
        Expanded(
          child: _buildStatCard(
            title: 'Total Applied',
            value: totalApplied.toString(),
            icon: Icons.work_outline_rounded,
            isDark: isDark,
          ),
        ),
        SizedBox(width: AppConstants.spaceM),
        Expanded(
          child: _buildStatCard(
            title: 'Interviewing',
            value: interviewing.toString(),
            icon: Icons.psychology_outlined,
            isDark: isDark,
          ),
        ),
        SizedBox(width: AppConstants.spaceM),
        Expanded(
          child: _buildStatCard(
            title: 'Offers',
            value: offered.toString(),
            icon: Icons.emoji_events_outlined,
            isDark: isDark,
          ),
        ),
      ],
    );
  }

  Widget _buildStatCard({
    required String title,
    required String value,
    required IconData icon,
    required bool isDark,
  }) {
    return GlassContainer(
      isDark: isDark,
      borderRadius: AppConstants.radiusMedium,
      padding: EdgeInsets.all(AppConstants.spaceM),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Container(
            padding: EdgeInsets.all(8),
            decoration: BoxDecoration(
              gradient: LinearGradient(
                colors: [AppColors.purplePrimary, AppColors.purpleLight],
              ),
              borderRadius: BorderRadius.circular(12),
            ),
            child: Icon(icon, color: Colors.white, size: 20),
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
            title,
            style: TextStyle(
              fontSize: 13,
              color: AppColors.mediumGray,
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildUpcomingDeadlines(InternshipProvider provider, bool isDark) {
    final upcomingDeadlines = provider.getUpcomingDeadlines();

    if (upcomingDeadlines.isEmpty) {
      return SizedBox.shrink();
    }

    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(
          'Upcoming Deadlines',
          style: Theme.of(context).textTheme.headlineSmall,
        ),
        SizedBox(height: AppConstants.spaceM),
        ...upcomingDeadlines.take(3).map((internship) {
          final daysLeft = internship.deadline!.difference(DateTime.now()).inDays;
          return Padding(
            padding: EdgeInsets.only(bottom: AppConstants.spaceM),
            child: GlassContainer(
              isDark: isDark,
              padding: EdgeInsets.all(AppConstants.spaceM),
              child: Row(
                children: [
                  Container(
                    width: 4,
                    height: 50,
                    decoration: BoxDecoration(
                      gradient: LinearGradient(
                        colors: [AppColors.purplePrimary, AppColors.purpleLight],
                        begin: Alignment.topCenter,
                        end: Alignment.bottomCenter,
                      ),
                      borderRadius: BorderRadius.circular(2),
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
                            fontSize: 16,
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
                  Container(
                    padding: EdgeInsets.symmetric(horizontal: 12, vertical: 6),
                    decoration: BoxDecoration(
                      color: daysLeft <= 3
                          ? Colors.red.withOpacity(0.2)
                          : AppColors.purplePrimary.withOpacity(0.2),
                      borderRadius: BorderRadius.circular(8),
                    ),
                    child: Text(
                      '$daysLeft days',
                      style: TextStyle(
                        fontSize: 12,
                        fontWeight: FontWeight.w600,
                        color: daysLeft <= 3 ? Colors.red : AppColors.purplePrimary,
                      ),
                    ),
                  ),
                ],
              ),
            ),
          );
        }).toList(),
      ],
    );
  }

  Widget _buildRecentActivity(List<Internship> internships, bool isDark) {
    final recentInternships = internships.take(3).toList();

    if (recentInternships.isEmpty) {
      return EmptyStateWidget(
        icon: Icons.work_outline_rounded,
        title: 'No internships yet',
        subtitle: 'Start tracking your applications',
        isDark: isDark,
      );
    }

    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(
          'Recent Activity',
          style: Theme.of(context).textTheme.headlineSmall,
        ),
        SizedBox(height: AppConstants.spaceM),
        ...recentInternships.map((internship) {
          return Padding(
            padding: EdgeInsets.only(bottom: AppConstants.spaceM),
            child: GestureDetector(
              onTap: () {
                Navigator.pushNamed(
                  context,
                  AppRoutes.internshipDetail,
                  arguments: {'internship': internship},
                );
              },
              child: GlassContainer(
                isDark: isDark,
                padding: EdgeInsets.all(AppConstants.spaceM),
                child: Row(
                  children: [
                    Container(
                      width: 50,
                      height: 50,
                      decoration: BoxDecoration(
                        gradient: LinearGradient(
                          colors: [AppColors.purplePrimary, AppColors.purpleLight],
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
                              fontSize: 16,
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
              ),
            ),
          );
        }).toList(),
      ],
    );
  }

  Widget _buildInternshipsView() {
    return Navigator(
      onGenerateRoute: (settings) {
        return MaterialPageRoute(
          builder: (context) => InternshipListScreen(),
        );
      },
    );
  }

  Widget _buildProfileView() {
    return Navigator(
      onGenerateRoute: (settings) {
        return MaterialPageRoute(
          builder: (context) => ProfileScreen(),
        );
      },
    );
  }

  Widget _buildBottomNav(bool isDark) {
    return ClipRRect(
      borderRadius: BorderRadius.only(
        topLeft: Radius.circular(AppConstants.radiusLarge),
        topRight: Radius.circular(AppConstants.radiusLarge),
      ),
      child: BackdropFilter(
        filter: ImageFilter.blur(sigmaX: 10, sigmaY: 10),
        child: Container(
          height: 80,
          decoration: BoxDecoration(
            color: isDark
                ? Colors.white.withOpacity(0.1)
                : Colors.black.withOpacity(0.05),
            border: Border(
              top: BorderSide(
                color: isDark
                    ? Colors.white.withOpacity(0.2)
                    : Colors.black.withOpacity(0.1),
                width: 1,
              ),
            ),
          ),
          child: Row(
            mainAxisAlignment: MainAxisAlignment.spaceAround,
            children: [
              _buildNavItem(
                icon: Icons.dashboard_outlined,
                label: 'Home',
                index: 0,
                isDark: isDark,
              ),
              _buildNavItem(
                icon: Icons.work_outline_rounded,
                label: 'Internships',
                index: 1,
                isDark: isDark,
              ),
              _buildNavItem(
                icon: Icons.person_outline_rounded,
                label: 'Profile',
                index: 2,
                isDark: isDark,
              ),
            ],
          ),
        ),
      ),
    );
  }

  Widget _buildNavItem({
    required IconData icon,
    required String label,
    required int index,
    required bool isDark,
  }) {
    final isSelected = _selectedIndex == index;

    return GestureDetector(
      onTap: () => setState(() => _selectedIndex = index),
      child: Container(
        padding: EdgeInsets.symmetric(horizontal: 20, vertical: 8),
        decoration: BoxDecoration(
          gradient: isSelected
              ? LinearGradient(
                  colors: [AppColors.purplePrimary, AppColors.purpleLight],
                )
              : null,
          borderRadius: BorderRadius.circular(16),
        ),
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            Icon(
              icon,
              color: isSelected
                  ? Colors.white
                  : AppColors.mediumGray,
              size: 24,
            ),
            SizedBox(height: 4),
            Text(
              label,
              style: TextStyle(
                fontSize: 12,
                fontWeight: isSelected ? FontWeight.w600 : FontWeight.w500,
                color: isSelected
                    ? Colors.white
                    : AppColors.mediumGray,
              ),
            ),
          ],
        ),
      ),
    );
  }
}