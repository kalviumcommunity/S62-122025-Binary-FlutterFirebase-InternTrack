// lib/screens/mentor/mentor_requests_screen.dart
import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:cloud_firestore/cloud_firestore.dart';

import '../../providers/mentor_provider.dart';
import '../../core/widgets/glass_container.dart';
import '../../core/widgets/gradient_orb.dart';
import '../../core/constants/colors.dart';
import '../../core/constants/app_constants.dart';
import '../../models/internship_model.dart';
import '../../models/feedback_cycle_model.dart';
import 'mentor_internship_detail_screen.dart';
import 'widget/request_card.dart';
import 'widget/feedback_dialog.dart';

enum RequestStatus { pending, responded, closed }
enum SortOption { newestFirst, oldestFirst, urgentFirst }

class MentorRequestsScreen extends StatefulWidget {
  const MentorRequestsScreen({super.key});

  @override
  State<MentorRequestsScreen> createState() => _MentorRequestsScreenState();
}

class _MentorRequestsScreenState extends State<MentorRequestsScreen> {
  RequestStatus _currentStatus = RequestStatus.pending;
  SortOption _currentSort = SortOption.newestFirst;

  @override
  Widget build(BuildContext context) {
    final isDark = Theme.of(context).brightness == Brightness.dark;

    return Scaffold(
      body: Stack(
        children: [
          // Background gradient orb
          GradientOrb(
            size: 300,
            alignment: Alignment.topRight,
            colors: [AppColors.bluePrimary, AppColors.blueLight],
            opacity: 0.15,
          ),

          SafeArea(
            child: Consumer<MentorProvider>(
              builder: (context, provider, _) {
                final allRequests = provider.requests;

                // Filter by status
                final filteredRequests = _filterByStatus(allRequests);

                // Sort requests
                final sortedRequests = _sortRequests(filteredRequests);

                return Column(
                  children: [
                    // HEADER
                    Padding(
                      padding: EdgeInsets.all(AppConstants.spaceL),
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Text(
                            'Feedback Requests',
                            style: Theme.of(context).textTheme.displayMedium?.copyWith(
                              fontSize: 28,
                            ),
                          ),
                          SizedBox(height: 4),
                          Text(
                            'Manage student feedback requests',
                            style: TextStyle(
                              fontSize: 15,
                              color: AppColors.mediumGray,
                            ),
                          ),
                        ],
                      ),
                    ),

                    // Status tabs
                    _buildStatusTabs(isDark, allRequests),

                    // Sort dropdown
                    _buildSortDropdown(isDark),

                    // Requests list
                    Expanded(
                      child: sortedRequests.isEmpty
                          ? _buildEmptyState(isDark)
                          : ListView.builder(
                              padding: EdgeInsets.all(AppConstants.spaceL),
                              itemCount: sortedRequests.length,
                              itemBuilder: (context, index) {
                                final cycle = sortedRequests[index];
                                return FutureBuilder<RequestCardData>(
                                  future: _fetchRequestData(cycle),
                                  builder: (context, snapshot) {
                                    if (!snapshot.hasData) {
                                      return _buildLoadingCard(isDark);
                                    }

                                    final data = snapshot.data!;
                                    final isUrgent = _isUrgent(cycle, data.internship);

                                    return Padding(
                                      padding: EdgeInsets.only(bottom: AppConstants.spaceM),
                                      child: RequestCard(
                                        cycle: cycle,
                                        data: data,
                                        isUrgent: isUrgent,
                                        isDark: isDark,
                                        onTap: () => _handleRequestTap(
                                          context,
                                          cycle,
                                          data,
                                          isDark,
                                        ),
                                      ),
                                    );
                                  },
                                );
                              },
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

  // ================= STATUS TABS =================

  Widget _buildStatusTabs(bool isDark, List<FeedbackCycle> allRequests) {
    // Debug: Print all requests
    print('📊 TOTAL REQUESTS: ${allRequests.length}');
    for (var req in allRequests) {
      print('  - ID: ${req.id}, Status: ${req.status}, seenByStudent: ${req.seenByStudent}');
    }
    
    final pendingCount = allRequests.where((r) => r.status == 'pending').length;
    
    // CRITICAL FIX: Handle both false AND null for responded
    final respondedCount = allRequests
        .where((r) => r.status == 'completed' && (r.seenByStudent == false || r.seenByStudent == null))
        .length;
    
    // Closed = explicitly marked as seen
    final closedCount = allRequests
        .where((r) => r.status == 'completed' && r.seenByStudent == true)
        .length;

    print('📈 COUNTS: Pending=$pendingCount, Responded=$respondedCount, Closed=$closedCount');

    return Container(
      padding: EdgeInsets.symmetric(
        horizontal: AppConstants.spaceL,
        vertical: AppConstants.spaceM,
      ),
      child: Row(
        children: [
          _buildTabButton(
            'Pending',
            pendingCount,
            _currentStatus == RequestStatus.pending,
            isDark,
            () => setState(() => _currentStatus = RequestStatus.pending),
          ),
          SizedBox(width: AppConstants.spaceM),
          _buildTabButton(
            'Responded',
            respondedCount,
            _currentStatus == RequestStatus.responded,
            isDark,
            () => setState(() => _currentStatus = RequestStatus.responded),
          ),
          SizedBox(width: AppConstants.spaceM),
          _buildTabButton(
            'Closed',
            closedCount,
            _currentStatus == RequestStatus.closed,
            isDark,
            () => setState(() => _currentStatus = RequestStatus.closed),
          ),
        ],
      ),
    );
  }

  Widget _buildTabButton(
    String label,
    int count,
    bool isSelected,
    bool isDark,
    VoidCallback onTap,
  ) {
    return Expanded(
      child: GestureDetector(
        onTap: onTap,
        child: Container(
          padding: EdgeInsets.symmetric(vertical: AppConstants.spaceM),
          decoration: BoxDecoration(
            gradient: isSelected
                ? LinearGradient(
                    colors: [AppColors.bluePrimary, AppColors.blueLight],
                  )
                : null,
            color: isSelected
                ? null
                : isDark
                    ? Colors.white.withOpacity(0.1)
                    : Colors.black.withOpacity(0.05),
            borderRadius: BorderRadius.circular(AppConstants.radiusMedium),
            border: Border.all(
              color: isSelected
                  ? Colors.transparent
                  : isDark
                      ? Colors.white.withOpacity(0.2)
                      : Colors.black.withOpacity(0.1),
            ),
          ),
          child: Column(
            children: [
              Text(
                count.toString(),
                style: TextStyle(
                  fontSize: 20,
                  fontWeight: FontWeight.w700,
                  color: isSelected
                      ? Colors.white
                      : isDark
                          ? AppColors.pureWhite
                          : AppColors.pureBlack,
                ),
              ),
              SizedBox(height: 4),
              Text(
                label,
                style: TextStyle(
                  fontSize: 12,
                  fontWeight: FontWeight.w600,
                  color: isSelected
                      ? Colors.white.withOpacity(0.9)
                      : AppColors.mediumGray,
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }

  // ================= SORT DROPDOWN =================

  Widget _buildSortDropdown(bool isDark) {
    return Padding(
      padding: EdgeInsets.symmetric(horizontal: AppConstants.spaceL),
      child: Row(
        children: [
          Icon(
            Icons.sort_rounded,
            size: 20,
            color: AppColors.mediumGray,
          ),
          SizedBox(width: 8),
          Text(
            'Sort by:',
            style: TextStyle(
              fontSize: 14,
              fontWeight: FontWeight.w500,
              color: AppColors.mediumGray,
            ),
          ),
          SizedBox(width: AppConstants.spaceS),
          Expanded(
            child: GlassContainer(
              isDark: isDark,
              padding: EdgeInsets.symmetric(
                horizontal: AppConstants.spaceM,
                vertical: AppConstants.spaceS,
              ),
              borderRadius: AppConstants.radiusMedium,
              child: DropdownButton<SortOption>(
                value: _currentSort,
                isExpanded: true,
                underline: SizedBox.shrink(),
                icon: Icon(
                  Icons.keyboard_arrow_down_rounded,
                  color: AppColors.bluePrimary,
                ),
                dropdownColor: isDark ? AppColors.darkGray : AppColors.pureWhite,
                style: TextStyle(
                  fontSize: 14,
                  fontWeight: FontWeight.w600,
                  color: isDark ? AppColors.pureWhite : AppColors.pureBlack,
                ),
                items: [
                  DropdownMenuItem(
                    value: SortOption.newestFirst,
                    child: Text('Newest First'),
                  ),
                  DropdownMenuItem(
                    value: SortOption.oldestFirst,
                    child: Text('Oldest First'),
                  ),
                  DropdownMenuItem(
                    value: SortOption.urgentFirst,
                    child: Text('Urgent First'),
                  ),
                ],
                onChanged: (value) {
                  if (value != null) {
                    setState(() => _currentSort = value);
                  }
                },
              ),
            ),
          ),
        ],
      ),
    );
  }

  // ================= FILTERING & SORTING =================

  List<FeedbackCycle> _filterByStatus(List<FeedbackCycle> requests) {
    print('\n🔍 FILTERING: Current status = $_currentStatus');
    print('Total requests to filter: ${requests.length}');
    
    List<FeedbackCycle> filtered;
    
    switch (_currentStatus) {
      case RequestStatus.pending:
        filtered = requests.where((r) {
          final match = r.status == 'pending';
          if (match) print('  ✓ Pending: ${r.id}');
          return match;
        }).toList();
        break;
        
      case RequestStatus.responded:
        // CRITICAL FIX: Handle both false AND null for seenByStudent
        filtered = requests.where((r) {
          final match = r.status == 'completed' && (r.seenByStudent == false || r.seenByStudent == null);
          if (match) print('  ✓ Responded: ${r.id} (seenByStudent=${r.seenByStudent})');
          return match;
        }).toList();
        break;
        
      case RequestStatus.closed:
        filtered = requests.where((r) {
          final match = r.status == 'completed' && r.seenByStudent == true;
          if (match) print('  ✓ Closed: ${r.id}');
          return match;
        }).toList();
        break;
    }
    
    print('Filtered count: ${filtered.length}\n');
    return filtered;
  }

  List<FeedbackCycle> _sortRequests(List<FeedbackCycle> requests) {
    final sorted = List<FeedbackCycle>.from(requests);

    switch (_currentSort) {
      case SortOption.newestFirst:
        sorted.sort((a, b) => b.requestedAt.compareTo(a.requestedAt));
        break;
      case SortOption.oldestFirst:
        sorted.sort((a, b) => a.requestedAt.compareTo(b.requestedAt));
        break;
      case SortOption.urgentFirst:
        // First, separate urgent from non-urgent
        final urgent = <FeedbackCycle>[];
        final normal = <FeedbackCycle>[];

        for (final request in sorted) {
          // We'll determine urgency in a future builder, but for now
          // use time-based urgency (48+ hours pending)
          final hoursPending =
              DateTime.now().difference(request.requestedAt).inHours;
          if (hoursPending >= 48) {
            urgent.add(request);
          } else {
            normal.add(request);
          }
        }

        // Sort each group by newest first
        urgent.sort((a, b) => b.requestedAt.compareTo(a.requestedAt));
        normal.sort((a, b) => b.requestedAt.compareTo(a.requestedAt));

        return [...urgent, ...normal];
    }

    return sorted;
  }

  /// Calculate urgency score for a request (higher = more urgent)
  /// Based on reusable logic from StudentHealthCalculator
  int _getUrgencyScore(FeedbackCycle cycle) {
    final now = DateTime.now();
    final hoursPending = now.difference(cycle.requestedAt).inHours;
    
    // CRITICAL: 72+ hours pending = highest urgency (score 3)
    if (hoursPending >= 72) return 3;
    
    // HIGH: 48+ hours pending = high urgency (score 2)
    if (hoursPending >= 48) return 2;
    
    // MEDIUM: 24+ hours pending = medium urgency (score 1)
    if (hoursPending >= 24) return 1;
    
    // LOW: Less than 24 hours = low urgency (score 0)
    return 0;
  }

  // ================= URGENCY DETECTION =================

  bool _isUrgent(FeedbackCycle cycle, Internship? internship) {
    // Use the same scoring logic as sorting for consistency
    final urgencyScore = _getUrgencyScore(cycle);
    
    // Consider anything with score 2+ as urgent (48+ hours pending)
    if (urgencyScore >= 2) return true;

    if (internship != null) {
      final now = DateTime.now();
      
      // 1. Deadline < 7 days
      if (internship.deadline != null) {
        final daysUntilDeadline = internship.deadline!.difference(now).inDays;
        if (daysUntilDeadline < 7 && daysUntilDeadline >= 0) return true;
      }

      // 2. High priority internship
      if (internship.priority == Priority.high) return true;
    }

    return false;
  }

  // ================= DATA FETCHING =================

  Future<RequestCardData> _fetchRequestData(FeedbackCycle cycle) async {
    try {
      // Fetch student data
      final studentDoc = await FirebaseFirestore.instance
          .collection('users')
          .doc(cycle.studentId)
          .get();

      // Fetch internship data
      final internshipDoc = await FirebaseFirestore.instance
          .collection('internships')
          .doc(cycle.internshipId)
          .get();

      Internship? internship;
      if (internshipDoc.exists) {
        internship = Internship.fromFirestore(internshipDoc);
      }

      return RequestCardData(
        studentName: studentDoc.data()?['displayName'] ?? 'Student',
        studentEmail: studentDoc.data()?['email'] ?? '',
        company: internship?.company ?? 'Unknown Company',
        role: internship?.role ?? '',
        status: internship?.status,
        internship: internship,
      );
    } catch (e) {
      print('Error fetching request data: $e');
      return RequestCardData(
        studentName: 'Student',
        studentEmail: '',
        company: 'Unknown Company',
        role: '',
        status: null,
        internship: null,
      );
    }
  }

  // ================= INTERACTION HANDLERS =================

  void _handleRequestTap(
    BuildContext context,
    FeedbackCycle cycle,
    RequestCardData data,
    bool isDark,
  ) {
    showModalBottomSheet(
      context: context,
      backgroundColor: Colors.transparent,
      isScrollControlled: true,
      builder: (_) => GlassContainer(
        isDark: isDark,
        padding: EdgeInsets.all(AppConstants.spaceL),
        borderRadius: 24,
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            ListTile(
              leading: Icon(Icons.visibility_outlined, color: AppColors.bluePrimary),
              title: Text('View Internship'),
              onTap: () {
                Navigator.pop(context);
                if (data.internship != null) {
                  _openInternship(context, data.internship!);
                }
              },
            ),
            if (cycle.status == 'pending')
              ListTile(
                leading: Icon(Icons.edit_outlined, color: AppColors.bluePrimary),
                title: Text('Add Feedback'),
                onTap: () {
                  Navigator.pop(context);
                  _openFeedbackDialog(context, cycle, data, isDark);
                },
              ),
            if (cycle.status == 'completed' && !cycle.seenByStudent)
              ListTile(
                leading: Icon(Icons.check_circle_outline, color: Colors.green),
                title: Text('Mark as Closed'),
                onTap: () async {
                  Navigator.pop(context);
                  await FirebaseFirestore.instance
                      .collection('feedbackCycles')
                      .doc(cycle.id)
                      .update({'seenByStudent': true});
                },
              ),
          ],
        ),
      ),
    );
  }

  void _openInternship(BuildContext context, Internship internship) {
    Navigator.push(
      context,
      MaterialPageRoute(
        builder: (_) => MentorInternshipDetailScreen(internship: internship),
      ),
    );
  }

  void _openFeedbackDialog(
    BuildContext context,
    FeedbackCycle cycle,
    RequestCardData data,
    bool isDark,
  ) {
    showDialog(
      context: context,
      builder: (_) => FeedbackDialog(
        cycle: cycle,
        data: data,
        isDark: isDark,
      ),
    );
  }

  // ================= UI HELPERS =================

  Widget _buildLoadingCard(bool isDark) {
    return Padding(
      padding: EdgeInsets.only(bottom: AppConstants.spaceM),
      child: GlassContainer(
        isDark: isDark,
        padding: EdgeInsets.all(AppConstants.spaceM),
        child: Center(
          child: SizedBox(
            height: 80,
            child: Center(
              child: CircularProgressIndicator(
                valueColor: AlwaysStoppedAnimation(AppColors.bluePrimary),
              ),
            ),
          ),
        ),
      ),
    );
  }

  Widget _buildEmptyState(bool isDark) {
    String message;
    IconData icon;

    switch (_currentStatus) {
      case RequestStatus.pending:
        message = 'No pending requests';
        icon = Icons.mark_chat_unread_outlined;
        break;
      case RequestStatus.responded:
        message = 'No responded requests';
        icon = Icons.chat_bubble_outline;
        break;
      case RequestStatus.closed:
        message = 'No closed requests';
        icon = Icons.check_circle_outline;
        break;
    }

    return Center(
      child: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          Icon(
            icon,
            size: 80,
            color: AppColors.mediumGray.withOpacity(0.5),
          ),
          SizedBox(height: 16),
          Text(
            message,
            style: TextStyle(
              fontSize: 20,
              fontWeight: FontWeight.w600,
              color: isDark ? AppColors.pureWhite : AppColors.pureBlack,
            ),
          ),
          SizedBox(height: 8),
          Text(
            'Check other tabs for more requests',
            style: TextStyle(
              fontSize: 14,
              color: AppColors.mediumGray,
            ),
          ),
        ],
      ),
    );
  }
}

// ================= DATA CLASS =================

class RequestCardData {
  final String studentName;
  final String studentEmail;
  final String company;
  final String role;
  final InternshipStatus? status;
  final Internship? internship;

  RequestCardData({
    required this.studentName,
    required this.studentEmail,
    required this.company,
    required this.role,
    required this.status,
    required this.internship,
  });
}