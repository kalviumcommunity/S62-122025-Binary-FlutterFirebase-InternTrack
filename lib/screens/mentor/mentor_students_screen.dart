// lib/screens/mentor/mentor_students_screen.dart
import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import '../../core/constants/colors.dart';
import '../../core/constants/app_constants.dart';
import '../../core/widgets/gradient_orb.dart';
import '../../providers/mentor_provider.dart';
import '../../models/mentor_invitation_model.dart';
import '../../models/student_health_model.dart';
import '../../app/app_routes.dart';
import 'widget/student_widgets.dart';
import 'widget/students_statistics.dart';

enum StudentSortOption {
  urgency,
  name,
  lastActivity,
  internshipCount,
}

enum StudentFilterOption {
  all,
  pendingRequests,
  needsAttention,
  urgent,
  onTrack,
}

class MentorStudentsScreen extends StatefulWidget {
  @override
  State<MentorStudentsScreen> createState() => _MentorStudentsScreenState();
}

class _MentorStudentsScreenState extends State<MentorStudentsScreen> with AutomaticKeepAliveClientMixin {
  final StudentHealthCalculator _healthCalculator = StudentHealthCalculator();
  
  StudentSortOption _sortOption = StudentSortOption.urgency;
  StudentFilterOption _filterOption = StudentFilterOption.all;
  Map<String, StudentHealthData> _studentHealthData = {};
  bool _isLoadingHealth = false;
  bool _initialLoadDone = false;

  @override
  bool get wantKeepAlive => true;

  @override
  void initState() {
    super.initState();
    // Load immediately on init
    WidgetsBinding.instance.addPostFrameCallback((_) {
      _loadStudentHealthData();
    });
  }

  Future<void> _loadStudentHealthData() async {
    if (_isLoadingHealth) return;
    
    final students = context.read<MentorProvider>().students;
    
    debugPrint('=== LOADING HEALTH DATA ===');
    debugPrint('Total students: ${students.length}');
    
    if (students.isEmpty) {
      setState(() {
        _studentHealthData = {};
        _isLoadingHealth = false;
        _initialLoadDone = true;
      });
      return;
    }
    
    setState(() => _isLoadingHealth = true);
    
    final Map<String, StudentHealthData> newHealthData = {};
    
    for (var student in students) {
      try {
        debugPrint('\n--- Processing: ${student.studentName} ---');
        final healthData = await _healthCalculator.calculateHealth(
          studentId: student.studentId,
          mentorId: student.mentorId,
          linkedAt: student.linkedAt,
        );
        
        newHealthData[student.studentId] = healthData;
      } catch (e) {
        debugPrint('ERROR loading health for ${student.studentName}: $e');
      }
    }
    
    debugPrint('\n=== HEALTH DATA SUMMARY ===');
    debugPrint('Total loaded: ${newHealthData.length}');
    
    int urgent = 0, attention = 0, onTrack = 0, pending = 0;
    newHealthData.forEach((key, value) {
      if (value.status == StudentHealthStatus.urgent) urgent++;
      if (value.status == StudentHealthStatus.needsAttention) attention++;
      if (value.status == StudentHealthStatus.onTrack) onTrack++;
      if (value.hasPendingRequest) pending++;
    });
    
    debugPrint('Urgent: $urgent, Attention: $attention, On Track: $onTrack');
    debugPrint('With Pending Requests: $pending');
    debugPrint('=== END SUMMARY ===\n');
    
    if (mounted) {
      setState(() {
        _studentHealthData = newHealthData;
        _isLoadingHealth = false;
        _initialLoadDone = true;
      });
    }
  }

  List<MentorStudentLink> _getSortedAndFilteredStudents(
    List<MentorStudentLink> students,
  ) {
    var filteredStudents = List<MentorStudentLink>.from(students);

    debugPrint('\n--- FILTERING ---');
    debugPrint('Filter: $_filterOption');
    debugPrint('Before filter: ${filteredStudents.length} students');

    // Apply filters
    if (_filterOption != StudentFilterOption.all) {
      filteredStudents = filteredStudents.where((student) {
        final healthData = _studentHealthData[student.studentId];
        if (healthData == null) {
          debugPrint('No health data for ${student.studentName}');
          return false;
        }

        switch (_filterOption) {
          case StudentFilterOption.pendingRequests:
            final match = healthData.hasPendingRequest;
            if (match) {
              debugPrint('${student.studentName} has pending request');
            }
            return match;
          case StudentFilterOption.urgent:
            final match = healthData.status == StudentHealthStatus.urgent;
            if (match) {
              debugPrint('${student.studentName} is URGENT');
            }
            return match;
          case StudentFilterOption.needsAttention:
            final match = healthData.status == StudentHealthStatus.needsAttention;
            if (match) {
              debugPrint('${student.studentName} needs ATTENTION');
            }
            return match;
          case StudentFilterOption.onTrack:
            final match = healthData.status == StudentHealthStatus.onTrack;
            if (match) {
              debugPrint('${student.studentName} is ON TRACK');
            }
            return match;
          default:
            return true;
        }
      }).toList();
    }

    debugPrint('After filter: ${filteredStudents.length} students');

    // Apply sorting
    filteredStudents.sort((a, b) {
      final healthA = _studentHealthData[a.studentId];
      final healthB = _studentHealthData[b.studentId];

      if (healthA == null || healthB == null) return 0;

      switch (_sortOption) {
        case StudentSortOption.urgency:
          // Sort by status first (urgent first), then by last activity
          if (healthA.status != healthB.status) {
            return healthA.status.index.compareTo(healthB.status.index);
          }
          return healthB.lastActivity.compareTo(healthA.lastActivity);

        case StudentSortOption.name:
          return a.studentName.toLowerCase().compareTo(b.studentName.toLowerCase());

        case StudentSortOption.lastActivity:
          return healthB.lastActivity.compareTo(healthA.lastActivity);

        case StudentSortOption.internshipCount:
          if (healthA.internshipCount != healthB.internshipCount) {
            return healthB.internshipCount.compareTo(healthA.internshipCount);
          }
          return a.studentName.toLowerCase().compareTo(b.studentName.toLowerCase());
      }
    });

    return filteredStudents;
  }

  @override
  Widget build(BuildContext context) {
    super.build(context);
    final isDark = Theme.of(context).brightness == Brightness.dark;

    return Scaffold(
      body: Stack(
        children: [
          GradientOrb(
            size: 300,
            alignment: Alignment.topLeft,
            colors: [AppColors.bluePrimary, AppColors.blueLight],
            opacity: 0.15,
          ),

          SafeArea(
            child: Consumer<MentorProvider>(
              builder: (context, provider, child) {
                final students = _getSortedAndFilteredStudents(provider.students);

                // Show loading only on first load
                if (!_initialLoadDone && _isLoadingHealth) {
                  return Center(
                    child: Column(
                      mainAxisAlignment: MainAxisAlignment.center,
                      children: [
                        CircularProgressIndicator(
                          valueColor: AlwaysStoppedAnimation<Color>(AppColors.bluePrimary),
                        ),
                        SizedBox(height: 16),
                        Text(
                          'Loading student data...',
                          style: TextStyle(
                            color: isDark ? AppColors.pureWhite : AppColors.pureBlack,
                            fontSize: 16,
                          ),
                        ),
                      ],
                    ),
                  );
                }

                return RefreshIndicator(
                  onRefresh: _loadStudentHealthData,
                  color: AppColors.bluePrimary,
                  child: CustomScrollView(
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
                                  Expanded(
                                    child: Column(
                                      crossAxisAlignment: CrossAxisAlignment.start,
                                      children: [
                                        Text(
                                          'My Students',
                                          style: Theme.of(context).textTheme.displayMedium,
                                        ),
                                        SizedBox(height: 4),
                                        Text(
                                          '${provider.students.length} ${provider.students.length == 1 ? "student" : "students"} under mentorship',
                                          style: Theme.of(context).textTheme.bodyMedium,
                                        ),
                                      ],
                                    ),
                                  ),
                                  if (provider.students.isNotEmpty)
                                    IconButton(
                                      onPressed: _isLoadingHealth ? null : _loadStudentHealthData,
                                      icon: _isLoadingHealth
                                          ? SizedBox(
                                              width: 20,
                                              height: 20,
                                              child: CircularProgressIndicator(
                                                strokeWidth: 2,
                                                valueColor: AlwaysStoppedAnimation<Color>(
                                                  AppColors.bluePrimary,
                                                ),
                                              ),
                                            )
                                          : Icon(Icons.refresh_rounded),
                                      style: IconButton.styleFrom(
                                        backgroundColor: isDark
                                            ? Colors.white.withOpacity(0.1)
                                            : Colors.black.withOpacity(0.05),
                                      ),
                                    ),
                                ],
                              ),

                              SizedBox(height: AppConstants.spaceXL),

                              // Statistics
                              if (provider.students.isNotEmpty && _studentHealthData.isNotEmpty)
                                StudentsStatisticsOverview(
                                  students: provider.students,
                                  healthData: _studentHealthData,
                                  isDark: isDark,
                                ),

                              if (provider.students.isNotEmpty)
                                SizedBox(height: AppConstants.spaceXL),

                              // Filters
                              if (provider.students.isNotEmpty)
                                _buildFilterChips(isDark),

                              if (provider.students.isNotEmpty)
                                SizedBox(height: AppConstants.spaceM),

                              // Sort
                              if (provider.students.isNotEmpty)
                                _buildSortOptions(isDark),

                              if (provider.students.isNotEmpty)
                                SizedBox(height: AppConstants.spaceL),
                            ],
                          ),
                        ),
                      ),

                      if (provider.students.isEmpty)
                        SliverFillRemaining(
                          child: StudentsEmptyState(isDark: isDark),
                        )
                      else if (students.isEmpty)
                        SliverFillRemaining(
                          child: NoStudentsFoundState(isDark: isDark),
                        )
                      else
                        SliverPadding(
                          padding: EdgeInsets.symmetric(horizontal: AppConstants.spaceL),
                          sliver: SliverList(
                            delegate: SliverChildBuilderDelegate(
                              (context, index) {
                                final student = students[index];
                                final healthData = _studentHealthData[student.studentId];
                                
                                return Padding(
                                  padding: EdgeInsets.only(bottom: AppConstants.spaceM),
                                  child: StudentCard(
                                    student: student,
                                    healthData: healthData,
                                    isDark: isDark,
                                    onTap: () {
                                      context.read<MentorProvider>().selectStudent(student);
                                      Navigator.of(context, rootNavigator: true).pushNamed(
                                        AppRoutes.mentorStudentDetail,
                                        arguments: {'student': student},
                                      );
                                    },
                                  ),
                                );
                              },
                              childCount: students.length,
                            ),
                          ),
                        ),
                        
                      SliverPadding(padding: EdgeInsets.only(bottom: AppConstants.spaceXL)),
                    ],
                  ),
                );
              },
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildFilterChips(bool isDark) {
    // Count students in each category
    int pendingCount = 0;
    int urgentCount = 0;
    int attentionCount = 0;
    int onTrackCount = 0;
    
    _studentHealthData.forEach((key, value) {
      if (value.hasPendingRequest) pendingCount++;
      if (value.status == StudentHealthStatus.urgent) urgentCount++;
      if (value.status == StudentHealthStatus.needsAttention) attentionCount++;
      if (value.status == StudentHealthStatus.onTrack) onTrackCount++;
    });

    return SingleChildScrollView(
      scrollDirection: Axis.horizontal,
      child: Row(
        children: [
          StudentFilterChip(
            label: 'All Students',
            isSelected: _filterOption == StudentFilterOption.all,
            onTap: () => setState(() => _filterOption = StudentFilterOption.all),
            isDark: isDark,
          ),
          SizedBox(width: AppConstants.spaceS),
          StudentFilterChip(
            label: 'Pending Requests ($pendingCount)',
            isSelected: _filterOption == StudentFilterOption.pendingRequests,
            onTap: () => setState(() => _filterOption = StudentFilterOption.pendingRequests),
            isDark: isDark,
            showBadge: pendingCount > 0,
          ),
          SizedBox(width: AppConstants.spaceS),
          StudentFilterChip(
            label: 'Urgent ($urgentCount)',
            isSelected: _filterOption == StudentFilterOption.urgent,
            onTap: () => setState(() => _filterOption = StudentFilterOption.urgent),
            isDark: isDark,
          ),
          SizedBox(width: AppConstants.spaceS),
          StudentFilterChip(
            label: 'Needs Attention ($attentionCount)',
            isSelected: _filterOption == StudentFilterOption.needsAttention,
            onTap: () => setState(() => _filterOption = StudentFilterOption.needsAttention),
            isDark: isDark,
          ),
          SizedBox(width: AppConstants.spaceS),
          StudentFilterChip(
            label: 'On Track ($onTrackCount)',
            isSelected: _filterOption == StudentFilterOption.onTrack,
            onTap: () => setState(() => _filterOption = StudentFilterOption.onTrack),
            isDark: isDark,
          ),
        ],
      ),
    );
  }

  Widget _buildSortOptions(bool isDark) {
    return Row(
      children: [
        Icon(
          Icons.sort_rounded,
          size: 18,
          color: AppColors.mediumGray,
        ),
        SizedBox(width: 8),
        Text(
          'Sort by:',
          style: TextStyle(
            fontSize: 14,
            fontWeight: FontWeight.w600,
            color: AppColors.mediumGray,
          ),
        ),
        SizedBox(width: 12),
        Expanded(
          child: SingleChildScrollView(
            scrollDirection: Axis.horizontal,
            child: Row(
              children: [
                SortOptionChip(
                  label: 'Urgency',
                  isSelected: _sortOption == StudentSortOption.urgency,
                  onTap: () => setState(() => _sortOption = StudentSortOption.urgency),
                  isDark: isDark,
                ),
                SizedBox(width: 8),
                SortOptionChip(
                  label: 'Name',
                  isSelected: _sortOption == StudentSortOption.name,
                  onTap: () => setState(() => _sortOption = StudentSortOption.name),
                  isDark: isDark,
                ),
                SizedBox(width: 8),
                SortOptionChip(
                  label: 'Activity',
                  isSelected: _sortOption == StudentSortOption.lastActivity,
                  onTap: () => setState(() => _sortOption = StudentSortOption.lastActivity),
                  isDark: isDark,
                ),
                SizedBox(width: 8),
                SortOptionChip(
                  label: 'Applications',
                  isSelected: _sortOption == StudentSortOption.internshipCount,
                  onTap: () => setState(() => _sortOption = StudentSortOption.internshipCount),
                  isDark: isDark,
                ),
              ],
            ),
          ),
        ),
      ],
    );
  }
}