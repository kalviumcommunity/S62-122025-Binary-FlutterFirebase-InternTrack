// lib\screens\dashboard\mentor_dashboard.dart
import 'package:flutter/material.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:provider/provider.dart';
import '../../core/constants/colors.dart';
import '../../core/constants/app_constants.dart';
import '../../core/widgets/glass_container.dart';
import '../../core/widgets/gradient_orb.dart';
import '../../core/widgets/theme_toggle.dart';
import '../../providers/mentor_provider.dart';
import '../mentor/mentor_students_screen.dart';
import '../profile/profile_screen.dart';
import 'dart:ui';
import '../profile/mentor_profile_screen.dart';
import '../mentor/mentor_requests_screen.dart';

class MentorDashboard extends StatefulWidget {
  @override
  State<MentorDashboard> createState() => _MentorDashboardState();
}

class _MentorDashboardState extends State<MentorDashboard> {
  int _selectedIndex = 0;
  final FirebaseAuth _auth = FirebaseAuth.instance;
  bool _initialized = false;

  @override
  void initState() {
    super.initState();
    // Initialize in initState instead of didChangeDependencies
    WidgetsBinding.instance.addPostFrameCallback((_) {
      _initializeData();
    });
  }

  void _initializeData() {
    if (!_initialized && mounted) {
      final user = _auth.currentUser;
      if (user != null) {
        context.read<MentorProvider>().initializeStudentsStream(user.uid);
        context.read<MentorProvider>().initializeRequests(user.uid);
        setState(() => _initialized = true);
      }
    }
  }

  @override
  Widget build(BuildContext context) {
    final isDark = Theme.of(context).brightness == Brightness.dark;

    return Scaffold(
      body: IndexedStack(
        index: _selectedIndex,
        children: [
          _buildDashboardHome(isDark),
          _buildStudentsView(),
          MentorRequestsScreen(),
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
          child: Consumer<MentorProvider>(
            builder: (context, provider, child) {
              if (provider.isLoading) {
                return Center(child: CircularProgressIndicator());
              }

              final students = provider.students;

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
                                    'Mentor Dashboard',
                                    style: Theme.of(context).textTheme.displayMedium,
                                  ),
                                  SizedBox(height: 4),
                                  Text(
                                    'Guide your students',
                                    style: Theme.of(context).textTheme.bodyMedium,
                                  ),
                                ],
                              ),
                              ThemeToggle(),
                            ],
                          ),

                          SizedBox(height: AppConstants.spaceXL),

                          _buildStatsCard(students.length, isDark),

                          SizedBox(height: AppConstants.spaceXL),

                          Text(
                            'Your Students',
                            style: Theme.of(context).textTheme.headlineSmall,
                          ),
                          SizedBox(height: AppConstants.spaceM),

                          if (students.isEmpty)
                            Center(
                              child: Column(
                                children: [
                                  SizedBox(height: 40),
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
                                    'Wait for student invitations',
                                    style: TextStyle(
                                      fontSize: 15,
                                      color: AppColors.mediumGray,
                                    ),
                                  ),
                                ],
                              ),
                            )
                          else
                            ...students.take(5).map((student) {
                              return Padding(
                                padding: EdgeInsets.only(bottom: AppConstants.spaceM),
                                child: GestureDetector(
                                  onTap: () {
                                    provider.selectStudent(student);
                                    setState(() => _selectedIndex = 1);
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
                                              colors: [AppColors.bluePrimary, AppColors.blueLight],
                                            ),
                                            borderRadius: BorderRadius.circular(12),
                                          ),
                                          child: Center(
                                            child: Text(
                                              student.studentName.substring(0, 1).toUpperCase(),
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
                                                student.studentName,
                                                style: TextStyle(
                                                  fontSize: 16,
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

  Widget _buildStatsCard(int studentCount, bool isDark) {
    return GlassContainer(
      isDark: isDark,
      borderRadius: AppConstants.radiusMedium,
      padding: EdgeInsets.all(AppConstants.spaceL),
      child: Row(
        children: [
          Container(
            padding: EdgeInsets.all(12),
            decoration: BoxDecoration(
              gradient: LinearGradient(
                colors: [AppColors.bluePrimary, AppColors.blueLight],
              ),
              borderRadius: BorderRadius.circular(12),
            ),
            child: Icon(Icons.supervisor_account_rounded, color: Colors.white, size: 28),
          ),
          SizedBox(width: AppConstants.spaceL),
          Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text(
                studentCount.toString(),
                style: TextStyle(
                  fontSize: 32,
                  fontWeight: FontWeight.w700,
                  color: isDark ? AppColors.pureWhite : AppColors.pureBlack,
                ),
              ),
              Text(
                studentCount == 1 ? 'Student' : 'Students',
                style: TextStyle(
                  fontSize: 15,
                  color: AppColors.mediumGray,
                ),
              ),
            ],
          ),
        ],
      ),
    );
  }

  Widget _buildStudentsView() {
    return Navigator(
      onGenerateRoute: (settings) {
        return MaterialPageRoute(
          builder: (context) => MentorStudentsScreen(),
        );
      },
    );
  }

  Widget _buildProfileView() {
    return Navigator(
      onGenerateRoute: (settings) {
        return MaterialPageRoute(
          builder: (context) => MentorProfileScreen(),
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
                icon: Icons.supervisor_account_outlined,
                label: 'Students',
                index: 1,
                isDark: isDark,
              ),
              Consumer<MentorProvider>(
                builder: (context, provider, _) {
                  final count = provider.requests.length;

                  return Stack(
                    children: [
                      _buildNavItem(
                        icon: Icons.mark_chat_unread_outlined,
                        label: 'Requests',
                        index: 2,
                        isDark: isDark,
                      ),

                      if (count > 0)
                        Positioned(
                          right: 6,
                          top: 2,
                          child: Container(
                            padding: EdgeInsets.all(6),
                            decoration: BoxDecoration(
                              color: Colors.red,
                              shape: BoxShape.circle,
                            ),
                            child: Text(
                              count.toString(),
                              style: TextStyle(
                                color: Colors.white,
                                fontSize: 11,
                                fontWeight: FontWeight.bold,
                              ),
                            ),
                          ),
                        ),
                    ],
                  );
                },
              ),
              _buildNavItem(
                icon: Icons.person_outline_rounded,
                label: 'Profile',
                index: 3,
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
      onTap: () {
        setState(() => _selectedIndex = index);

        // Refresh requests when switching to requests tab
        if (index == 2 && !_initialized) {
          final user = FirebaseAuth.instance.currentUser;
          if (user != null) {
            WidgetsBinding.instance.addPostFrameCallback((_) {
              context.read<MentorProvider>().initializeRequests(user.uid);
            });
          }
        }
      },
      child: Container(
        padding: EdgeInsets.symmetric(horizontal: 20, vertical: 8),
        decoration: BoxDecoration(
          gradient: isSelected
              ? LinearGradient(
                  colors: [AppColors.bluePrimary, AppColors.blueLight],
                )
              : null,
          borderRadius: BorderRadius.circular(16),
        ),
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            Icon(
              icon,
              color: isSelected ? Colors.white : AppColors.mediumGray,
              size: 24,
            ),
            SizedBox(height: 4),
            Text(
              label,
              style: TextStyle(
                fontSize: 12,
                fontWeight: isSelected ? FontWeight.w600 : FontWeight.w500,
                color: isSelected ? Colors.white : AppColors.mediumGray,
              ),
            ),
          ],
        ),
      ),
    );
  }
}