import 'package:flutter/material.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';
import '../../core/constants/colors.dart';
import '../../core/constants/app_constants.dart';
import '../../core/widgets/glass_container.dart';
import '../../core/widgets/gradient_orb.dart';
import '../../core/widgets/purple_button.dart';
import '../../models/internship_model.dart';
import '../../app/app_routes.dart';
import 'dart:ui';

class InternshipListScreen extends StatefulWidget {
  @override
  State<InternshipListScreen> createState() => _InternshipListScreenState();
}

class _InternshipListScreenState extends State<InternshipListScreen> {
  final FirebaseAuth _auth = FirebaseAuth.instance;
  final FirebaseFirestore _firestore = FirebaseFirestore.instance;
  
  InternshipStatus? _filterStatus;
  Priority? _filterPriority;
  String _sortBy = 'date'; // 'date', 'deadline', 'priority'

  @override
  Widget build(BuildContext context) {
    final isDark = Theme.of(context).brightness == Brightness.dark;

    return Scaffold(
      body: Stack(
        children: [
          GradientOrb(
            size: 300,
            alignment: Alignment.topLeft,
            colors: [AppColors.purplePrimary, AppColors.purpleLight],
            opacity: 0.15,
          ),

          SafeArea(
            child: Column(
              children: [
                // Header
                Padding(
                  padding: EdgeInsets.all(AppConstants.spaceL),
                  child: Row(
                    children: [
                      Expanded(
                        child: Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            Text(
                              'Internships',
                              style: Theme.of(context).textTheme.displayMedium,
                            ),
                            SizedBox(height: 4),
                            Text(
                              'Manage your applications',
                              style: Theme.of(context).textTheme.bodyMedium,
                            ),
                          ],
                        ),
                      ),
                      IconButton(
                        onPressed: () {
                          // FIXED: Use root navigator to avoid nested navigation issues
                          Navigator.of(context, rootNavigator: true).pushNamed(
                            AppRoutes.archivedInternships,
                          );
                        },
                        icon: Icon(Icons.archive_outlined),
                        style: IconButton.styleFrom(
                          backgroundColor: isDark
                              ? Colors.white.withOpacity(0.1)
                              : Colors.black.withOpacity(0.05),
                        ),
                      ),
                    ],
                  ),
                ),

                // Filters
                _buildFilters(isDark),

                // List
                Expanded(
                  child: StreamBuilder<QuerySnapshot>(
                    stream: _firestore
                        .collection('internships')
                        .where('studentId', isEqualTo: _auth.currentUser?.uid)
                        .where('isArchived', isEqualTo: false)
                        .snapshots(),
                    builder: (context, snapshot) {
                      if (!snapshot.hasData) {
                        return Center(child: CircularProgressIndicator());
                      }

                      var internships = snapshot.data!.docs
                          .map((doc) => Internship.fromFirestore(doc))
                          .toList();

                      // Apply filters
                      if (_filterStatus != null) {
                        internships = internships
                            .where((i) => i.status == _filterStatus)
                            .toList();
                      }
                      if (_filterPriority != null) {
                        internships = internships
                            .where((i) => i.priority == _filterPriority)
                            .toList();
                      }

                      // Apply sorting
                      if (_sortBy == 'date') {
                        internships.sort((a, b) => b.appliedDate.compareTo(a.appliedDate));
                      } else if (_sortBy == 'deadline') {
                        internships.sort((a, b) {
                          if (a.deadline == null) return 1;
                          if (b.deadline == null) return -1;
                          return a.deadline!.compareTo(b.deadline!);
                        });
                      } else if (_sortBy == 'priority') {
                        internships.sort((a, b) => a.priority.index.compareTo(b.priority.index));
                      }

                      if (internships.isEmpty) {
                        return _buildEmptyState(isDark);
                      }

                      return ListView.builder(
                        padding: EdgeInsets.all(AppConstants.spaceL),
                        itemCount: internships.length,
                        itemBuilder: (context, index) {
                          return _buildInternshipCard(internships[index], isDark);
                        },
                      );
                    },
                  ),
                ),
              ],
            ),
          ),
        ],
      ),
      floatingActionButton: FloatingActionButton.extended(
        onPressed: () {
          // FIXED: Use root navigator to properly navigate
          Navigator.of(context, rootNavigator: true).pushNamed(
            AppRoutes.addInternship,
          );
        },
        backgroundColor: AppColors.purplePrimary,
        icon: Icon(Icons.add, color: Colors.white),
        label: Text(
          'Add Internship',
          style: TextStyle(
            color: Colors.white,
            fontWeight: FontWeight.w600,
          ),
        ),
      ),
    );
  }

  Widget _buildFilters(bool isDark) {
    return SingleChildScrollView(
      scrollDirection: Axis.horizontal,
      padding: EdgeInsets.symmetric(horizontal: AppConstants.spaceL),
      child: Row(
        children: [
          _buildFilterChip(
            label: 'All Status',
            isSelected: _filterStatus == null,
            onTap: () => setState(() => _filterStatus = null),
            isDark: isDark,
          ),
          ...InternshipStatus.values.map((status) {
            return _buildFilterChip(
              label: _getStatusLabel(status),
              isSelected: _filterStatus == status,
              onTap: () => setState(() => _filterStatus = status),
              isDark: isDark,
            );
          }).toList(),
          SizedBox(width: AppConstants.spaceM),
          Container(width: 1, height: 30, color: AppColors.mediumGray.withOpacity(0.3)),
          SizedBox(width: AppConstants.spaceM),
          _buildFilterChip(
            label: 'All Priority',
            isSelected: _filterPriority == null,
            onTap: () => setState(() => _filterPriority = null),
            isDark: isDark,
          ),
          ...Priority.values.map((priority) {
            return _buildFilterChip(
              label: _getPriorityLabel(priority),
              isSelected: _filterPriority == priority,
              onTap: () => setState(() => _filterPriority = priority),
              isDark: isDark,
            );
          }).toList(),
        ],
      ),
    );
  }

  Widget _buildFilterChip({
    required String label,
    required bool isSelected,
    required VoidCallback onTap,
    required bool isDark,
  }) {
    return Padding(
      padding: EdgeInsets.only(right: AppConstants.spaceS),
      child: GestureDetector(
        onTap: onTap,
        child: Container(
          padding: EdgeInsets.symmetric(
            horizontal: 16,
            vertical: 8,
          ),
          decoration: BoxDecoration(
            gradient: isSelected
                ? LinearGradient(
                    colors: [AppColors.purplePrimary, AppColors.purpleLight],
                  )
                : null,
            color: isSelected
                ? null
                : isDark
                    ? Colors.white.withOpacity(0.1)
                    : Colors.black.withOpacity(0.05),
            borderRadius: BorderRadius.circular(12),
            border: Border.all(
              color: isSelected
                  ? Colors.transparent
                  : isDark
                      ? Colors.white.withOpacity(0.2)
                      : Colors.black.withOpacity(0.1),
            ),
          ),
          child: Text(
            label,
            style: TextStyle(
              fontSize: 13,
              fontWeight: FontWeight.w600,
              color: isSelected
                  ? Colors.white
                  : isDark
                      ? AppColors.pureWhite
                      : AppColors.pureBlack,
            ),
          ),
        ),
      ),
    );
  }

  Widget _buildInternshipCard(Internship internship, bool isDark) {
    return Padding(
      padding: EdgeInsets.only(bottom: AppConstants.spaceM),
      child: GestureDetector(
        onTap: () {
          Navigator.of(context, rootNavigator: true).pushNamed(
            AppRoutes.internshipDetail,
            arguments: {'internship': internship},
          );
        },
        child: GlassContainer(
          isDark: isDark,
          padding: EdgeInsets.all(AppConstants.spaceM),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Row(
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
                            fontSize: 18,
                            fontWeight: FontWeight.w600,
                            color: isDark
                                ? AppColors.pureWhite
                                : AppColors.pureBlack,
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

                  _buildPriorityBadge(internship.priority),
                ],
              ),

              SizedBox(height: AppConstants.spaceM),

              Row(
                children: [
                  _buildStatusBadge(internship.status),

                  if (internship.location != null) ...[
                    SizedBox(width: AppConstants.spaceS),
                    Icon(Icons.location_on_outlined,
                        size: 16, color: AppColors.mediumGray),
                    SizedBox(width: 4),
                    Text(
                      internship.location!,
                      style: TextStyle(
                        fontSize: 13,
                        color: AppColors.mediumGray,
                      ),
                    ),
                  ],

                  Spacer(),

                  if (internship.deadline != null)
                    Text(
                      'Due: ${_formatDate(internship.deadline!)}',
                      style: TextStyle(
                        fontSize: 13,
                        color: AppColors.mediumGray,
                      ),
                    ),
                ],
              ),
            ],
          ),
        ),
      ),
    );
  }

  Widget _buildStatusBadge(InternshipStatus status) {
    Color color;
    switch (status) {
      case InternshipStatus.applied:
        color = Colors.blue;
        break;
      case InternshipStatus.interviewing:
        color = Colors.orange;
        break;
      case InternshipStatus.offered:
        color = Colors.green;
        break;
      case InternshipStatus.accepted:
        color = AppColors.purplePrimary;
        break;
      case InternshipStatus.rejected:
        color = Colors.red;
        break;
      case InternshipStatus.archived:
        color = AppColors.mediumGray;
        break;
    }

    return Container(
      padding: EdgeInsets.symmetric(horizontal: 10, vertical: 4),
      decoration: BoxDecoration(
        color: color.withOpacity(0.2),
        borderRadius: BorderRadius.circular(8),
      ),
      child: Text(
        _getStatusLabel(status),
        style: TextStyle(
          fontSize: 12,
          fontWeight: FontWeight.w600,
          color: color,
        ),
      ),
    );
  }

  Widget _buildPriorityBadge(Priority priority) {
    Color color;
    switch (priority) {
      case Priority.high:
        color = Colors.red;
        break;
      case Priority.medium:
        color = Colors.orange;
        break;
      case Priority.low:
        color = Colors.green;
        break;
    }

    return Container(
      width: 8,
      height: 8,
      decoration: BoxDecoration(
        color: color,
        shape: BoxShape.circle,
      ),
    );
  }

  Widget _buildEmptyState(bool isDark) {
    return Center(
      child: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          Icon(
            Icons.work_outline_rounded,
            size: 80,
            color: AppColors.mediumGray.withOpacity(0.5),
          ),
          SizedBox(height: AppConstants.spaceL),
          Text(
            'No internships found',
            style: TextStyle(
              fontSize: 20,
              fontWeight: FontWeight.w600,
              color: isDark ? AppColors.pureWhite : AppColors.pureBlack,
            ),
          ),
          SizedBox(height: AppConstants.spaceS),
          Text(
            'Try adjusting your filters',
            style: TextStyle(
              fontSize: 15,
              color: AppColors.mediumGray,
            ),
          ),
        ],
      ),
    );
  }

  String _getStatusLabel(InternshipStatus status) {
    return status.toString().split('.').last.replaceAllMapped(
          RegExp(r'[A-Z]'),
          (match) => ' ${match.group(0)}',
        ).trim().split(' ').map((word) => word[0].toUpperCase() + word.substring(1)).join(' ');
  }

  String _getPriorityLabel(Priority priority) {
    return priority.toString().split('.').last[0].toUpperCase() +
        priority.toString().split('.').last.substring(1);
  }

  String _formatDate(DateTime date) {
    return '${date.day}/${date.month}/${date.year}';
  }
}