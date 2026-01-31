// lib/screens/dashboard/mentor_dashboard.dart
import 'package:flutter/material.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:provider/provider.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'dart:ui';

import '../../core/constants/colors.dart';
import '../../core/constants/app_constants.dart';
import '../../core/widgets/glass_container.dart';
import '../../core/widgets/gradient_orb.dart';
import '../../core/widgets/theme_toggle.dart';
import '../../providers/mentor_provider.dart';
import '../../models/mentor_invitation_model.dart';
import '../../models/feedback_cycle_model.dart';
import '../mentor/mentor_students_screen.dart';
import '../profile/mentor_profile_screen.dart';
import '../mentor/mentor_requests_screen.dart';

// Import new widgets
import '../../core/widgets/action_required_panel.dart';
import '../../core/widgets/mentor_stat_card.dart';
import '../../core/widgets/student_preview_card.dart';
import '../../core/widgets/activity_feed_item.dart';
import '../../core/widgets/suggested_action_card.dart';

class MentorDashboard extends StatefulWidget {
  @override
  State<MentorDashboard> createState() => _MentorDashboardState();
}

class _MentorDashboardState extends State<MentorDashboard> {
  int _selectedIndex = 0;
  final FirebaseAuth _auth = FirebaseAuth.instance;
  final FirebaseFirestore _firestore = FirebaseFirestore.instance;
  bool _initialized = false;

  // Store student activity data
  Map<String, StudentActivityData> _studentActivities = {};

  @override
  void initState() {
    super.initState();
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
        _loadStudentActivities(user.uid);
        setState(() => _initialized = true);
      }
    }
  }

  // Load actual activity data for each student
  void _loadStudentActivities(String mentorId) async {
    final students = context.read<MentorProvider>().students;
    
    for (var student in students) {
      // Get latest feedback request from this student
      final requestSnapshot = await _firestore
          .collection('feedbackCycles')
          .where('studentId', isEqualTo: student.studentId)
          .where('mentorId', isEqualTo: mentorId)
          .orderBy('requestedAt', descending: true)
          .limit(1)
          .get();

      // Get student's internship count and latest update
      final internshipSnapshot = await _firestore
          .collection('internships')
          .where('studentId', isEqualTo: student.studentId)
          .where('isArchived', isEqualTo: false)
          .get();

      DateTime? lastActivity;
      String activityDescription = '';
      bool hasPendingRequest = false;

      if (requestSnapshot.docs.isNotEmpty) {
        final request = FeedbackCycle.fromFirestore(requestSnapshot.docs.first);
        lastActivity = request.requestedAt;
        
        if (request.status == 'pending') {
          hasPendingRequest = true;
          activityDescription = 'Requested feedback ${_getTimeAgo(request.requestedAt)}';
        } else {
          activityDescription = 'Last feedback ${_getTimeAgo(request.requestedAt)}';
        }
      } else if (internshipSnapshot.docs.isNotEmpty) {
        // Find most recent internship
        DateTime? latestDate;
        for (var doc in internshipSnapshot.docs) {
          final appliedDate = (doc.data()['appliedDate'] as Timestamp).toDate();
          if (latestDate == null || appliedDate.isAfter(latestDate)) {
            latestDate = appliedDate;
          }
        }
        if (latestDate != null) {
          lastActivity = latestDate;
          activityDescription = 'Added internship ${_getTimeAgo(latestDate)}';
        }
      }

      // If still no activity, use linked date
      if (lastActivity == null) {
        lastActivity = student.linkedAt;
        activityDescription = 'Joined ${_getTimeAgo(student.linkedAt)}';
      }

      if (mounted) {
        setState(() {
          _studentActivities[student.studentId] = StudentActivityData(
            lastActivity: lastActivity!,
            description: activityDescription,
            hasPendingRequest: hasPendingRequest,
            internshipCount: internshipSnapshot.docs.length,
            pendingRequestTime: hasPendingRequest && requestSnapshot.docs.isNotEmpty 
              ? FeedbackCycle.fromFirestore(requestSnapshot.docs.first).requestedAt 
              : null,
          );
        });
      }
    }
  }

  String _getTimeAgo(DateTime dateTime) {
    final now = DateTime.now();
    final difference = now.difference(dateTime);

    if (difference.inMinutes < 1) {
      return 'just now';
    } else if (difference.inMinutes < 60) {
      return '${difference.inMinutes}m ago';
    } else if (difference.inHours < 24) {
      return '${difference.inHours}h ago';
    } else if (difference.inDays == 1) {
      return 'yesterday';
    } else if (difference.inDays < 7) {
      return '${difference.inDays}d ago';
    } else if (difference.inDays < 30) {
      final weeks = (difference.inDays / 7).floor();
      return '$weeks week${weeks > 1 ? 's' : ''} ago';
    } else {
      return '${dateTime.day}/${dateTime.month}/${dateTime.year}';
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
              if (provider.isLoading && !_initialized) {
                return Center(child: CircularProgressIndicator());
              }

              final students = provider.students;
              final pendingRequests = provider.pendingRequestsCount;
              final highPriority = provider.highPriorityInternshipsCount;

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

                          // Action Required Panel
                          ActionRequiredPanel(
                            pendingRequestsCount: pendingRequests,
                            highPriorityCount: highPriority,
                            lastRequestTime: provider.lastRequestTime,
                            onTap: () => setState(() => _selectedIndex = 2),
                            isDark: isDark,
                          ),

                          if (pendingRequests > 0 || highPriority > 0)
                            SizedBox(height: AppConstants.spaceL),

                          // Stats Row
                          _buildStatsRow(provider, isDark),

                          SizedBox(height: AppConstants.spaceXL),

                          // Suggested Action (if applicable)
                          if (_getSuggestedAction(provider) != null)
                            ...[
                              _getSuggestedAction(provider)!,
                              SizedBox(height: AppConstants.spaceXL),
                            ],

                          // Students Section
                          Text(
                            'Your Students',
                            style: Theme.of(context).textTheme.headlineSmall,
                          ),
                          SizedBox(height: AppConstants.spaceM),

                          if (students.isEmpty)
                            _buildEmptyStudents(isDark)
                          else
                            ..._buildStudentsList(students, isDark, provider),

                          SizedBox(height: AppConstants.spaceXL),

                          // Recent Activity Feed
                          Text(
                            'Recent Activity',
                            style: Theme.of(context).textTheme.headlineSmall,
                          ),
                          SizedBox(height: AppConstants.spaceM),

                          GlassContainer(
                            isDark: isDark,
                            padding: EdgeInsets.all(AppConstants.spaceM),
                            child: Column(
                              children: _buildActivityFeed(provider, students, isDark),
                            ),
                          ),

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
    );
  }

  Widget _buildStatsRow(MentorProvider provider, bool isDark) {
    return Row(
      children: [
        Expanded(
          child: MentorStatCard(
            title: 'Students',
            value: provider.totalStudents.toString(),
            icon: Icons.supervisor_account_rounded,
            isDark: isDark,
            onTap: () => setState(() => _selectedIndex = 1),
          ),
        ),
        SizedBox(width: AppConstants.spaceM),
        Expanded(
          child: MentorStatCard(
            title: 'Pending Requests',
            value: provider.pendingRequestsCount.toString(),
            icon: Icons.mark_chat_unread_outlined,
            isDark: isDark,
            onTap: () => setState(() => _selectedIndex = 2),
          ),
        ),
        SizedBox(width: AppConstants.spaceM),
        Expanded(
          child: MentorStatCard(
            title: 'Feedback Given',
            value: provider.totalFeedbackGiven.toString(),
            icon: Icons.rate_review_rounded,
            isDark: isDark,
          ),
        ),
      ],
    );
  }

  Widget? _getSuggestedAction(MentorProvider provider) {
    // Priority 1: Pending requests
    if (provider.pendingRequestsCount > 0) {
      return SuggestedActionCard(
        title: 'Review Pending Feedback',
        description: '${provider.pendingRequestsCount} student${provider.pendingRequestsCount > 1 ? 's' : ''} waiting for your guidance',
        icon: Icons.rate_review_outlined,
        onTap: () => setState(() => _selectedIndex = 2),
        isDark: Theme.of(context).brightness == Brightness.dark,
      );
    }

    // Priority 2: Check on students who haven't been active
    if (provider.students.isNotEmpty) {
      return SuggestedActionCard(
        title: 'Check Student Progress',
        description: 'Review your students\' recent internship applications',
        icon: Icons.trending_up_rounded,
        onTap: () => setState(() => _selectedIndex = 1),
        isDark: Theme.of(context).brightness == Brightness.dark,
      );
    }

    return null;
  }

  List<Widget> _buildStudentsList(
    List<MentorStudentLink> students,
    bool isDark,
    MentorProvider provider,
  ) {
    // Sort students by urgency based on REAL data
    final sortedStudents = List<MentorStudentLink>.from(students);
    sortedStudents.sort((a, b) {
      final statusA = _getStudentStatus(a, provider);
      final statusB = _getStudentStatus(b, provider);
      
      // Urgent > Needs Attention > On Track
      if (statusA == StudentStatus.urgent && statusB != StudentStatus.urgent) return -1;
      if (statusB == StudentStatus.urgent && statusA != StudentStatus.urgent) return 1;
      if (statusA == StudentStatus.needsAttention && statusB == StudentStatus.onTrack) return -1;
      if (statusB == StudentStatus.needsAttention && statusA == StudentStatus.onTrack) return 1;
      
      // If same status, sort by most recent activity
      final activityA = _studentActivities[a.studentId]?.lastActivity;
      final activityB = _studentActivities[b.studentId]?.lastActivity;
      if (activityA != null && activityB != null) {
        return activityB.compareTo(activityA); // Most recent first
      }
      
      return 0;
    });
    
    return sortedStudents.take(5).map((student) {
      final status = _getStudentStatus(student, provider);
      final lastActivity = _getStudentLastActivity(student);
      
      return Padding(
        padding: EdgeInsets.only(bottom: AppConstants.spaceM),
        child: StudentPreviewCard(
          studentName: student.studentName,
          studentEmail: student.studentEmail,
          status: status,
          lastActivity: lastActivity,
          onTap: () {
            provider.selectStudent(student);
            setState(() => _selectedIndex = 1);
          },
          isDark: isDark,
        ),
      );
    }).toList();
  }

  StudentStatus _getStudentStatus(MentorStudentLink student, MentorProvider provider) {
    final activityData = _studentActivities[student.studentId];
    
    // Check pending feedback with TIME-BASED escalation
    if (activityData?.hasPendingRequest == true && activityData?.pendingRequestTime != null) {
      final hoursPending = DateTime.now().difference(activityData!.pendingRequestTime!).inHours;
      
      // URGENT: Feedback pending 3+ days (72 hours)
      if (hoursPending >= 72) {
        return StudentStatus.urgent;
      }
      // NEEDS ATTENTION: Feedback pending 6+ hours
      else if (hoursPending >= 6) {
        return StudentStatus.needsAttention;
      }
      // ON TRACK: Just pending (less than 6 hours)
      else {
        return StudentStatus.onTrack;
      }
    }
    
    // NEEDS ATTENTION: No activity in 7+ days OR no internships
    if (activityData != null) {
      final daysSinceActivity = DateTime.now().difference(activityData.lastActivity).inDays;
      if (daysSinceActivity > 7 || activityData.internshipCount == 0) {
        return StudentStatus.needsAttention;
      }
    }
    
    // ON TRACK: Regular activity
    return StudentStatus.onTrack;
  }

  String _getStudentLastActivity(MentorStudentLink student) {
    final activityData = _studentActivities[student.studentId];
    
    if (activityData != null) {
      return activityData.description;
    }
    
    // Fallback
    return 'Joined ${_getTimeAgo(student.linkedAt)}';
  }

  List<Widget> _buildActivityFeed(MentorProvider provider, List<MentorStudentLink> students, bool isDark) {
    final activities = <Widget>[];

    // Get student name lookup
    final studentNames = <String, String>{};
    for (var student in students) {
      studentNames[student.studentId] = student.studentName;
    }

    // Add recent feedback requests with ACTUAL student names
    final recentRequests = provider.requests.take(3).toList();
    for (var request in recentRequests) {
      final studentName = studentNames[request.studentId] ?? 'Student';
      
      activities.add(
        ActivityFeedItem(
          type: ActivityType.studentRequest,
          title: '$studentName requested feedback',
          subtitle: 'Feedback request for internship application',
          timestamp: request.requestedAt,
          isDark: isDark,
        ),
      );
    }

    // Add student additions if we need more activities
    if (activities.length < 3) {
      final recentStudents = students.take(3 - activities.length);
      for (var student in recentStudents) {
        activities.add(
          ActivityFeedItem(
            type: ActivityType.studentAdded,
            title: '${student.studentName} joined',
            subtitle: 'New student linked to your mentorship',
            timestamp: student.linkedAt,
            isDark: isDark,
          ),
        );
      }
    }

    if (activities.isEmpty) {
      return [
        Center(
          child: Padding(
            padding: EdgeInsets.all(AppConstants.spaceL),
            child: Text(
              'No recent activity',
              style: TextStyle(
                color: AppColors.mediumGray,
                fontSize: 14,
              ),
            ),
          ),
        ),
      ];
    }

    return activities;
  }

  Widget _buildEmptyStudents(bool isDark) {
    return Center(
      child: Padding(
        padding: EdgeInsets.symmetric(vertical: AppConstants.spaceXL),
        child: Column(
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
              'Wait for student invitations',
              style: TextStyle(
                fontSize: 15,
                color: AppColors.mediumGray,
              ),
            ),
          ],
        ),
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
      onTap: () => setState(() => _selectedIndex = index),
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

// Helper class to store student activity data
class StudentActivityData {
  final DateTime lastActivity;
  final String description;
  final bool hasPendingRequest;
  final int internshipCount;
  final DateTime? pendingRequestTime; // Track when feedback was requested

  StudentActivityData({
    required this.lastActivity,
    required this.description,
    required this.hasPendingRequest,
    required this.internshipCount,
    this.pendingRequestTime,
  });
}