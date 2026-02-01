// lib/screens/mentor/widget/student_snapshot_card.dart
import 'package:flutter/material.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import '../../../core/constants/colors.dart';
import '../../../core/constants/app_constants.dart';
import '../../../core/widgets/glass_container.dart';

class StudentSnapshotCard extends StatelessWidget {
  final String studentId;
  final bool isDark;

  const StudentSnapshotCard({
    Key? key,
    required this.studentId,
    required this.isDark,
  }) : super(key: key);

  Future<Map<String, dynamic>> _getSnapshot() async {
    final firestore = FirebaseFirestore.instance;

    // Get internship statistics
    final internships = await firestore
        .collection('internships')
        .where('studentId', isEqualTo: studentId)
        .where('isArchived', isEqualTo: false)
        .get();

    final total = internships.docs.length;
    final interviewing = internships.docs
        .where((doc) => doc.data()['status'] == 'interviewing')
        .length;

    // Get last feedback date
    final feedback = await firestore
        .collection('feedbackCycles')
        .where('studentId', isEqualTo: studentId)
        .where('status', isEqualTo: 'completed')
        .orderBy('respondedAt', descending: true)
        .limit(1)
        .get();

    DateTime? lastFeedback;
    if (feedback.docs.isNotEmpty) {
      lastFeedback = (feedback.docs.first.data()['respondedAt'] as Timestamp).toDate();
    }

    return {
      'total': total,
      'interviewing': interviewing,
      'lastFeedback': lastFeedback,
    };
  }

  String _formatDate(DateTime? date) {
    if (date == null) return 'Never';
    
    final now = DateTime.now();
    final diff = now.difference(date);

    if (diff.inDays == 0) {
      if (diff.inHours == 0) {
        return '${diff.inMinutes}m ago';
      }
      return '${diff.inHours}h ago';
    } else if (diff.inDays == 1) {
      return 'Yesterday';
    } else if (diff.inDays < 7) {
      return '${diff.inDays}d ago';
    } else {
      return '${date.day}/${date.month}/${date.year}';
    }
  }

  @override
  Widget build(BuildContext context) {
    return FutureBuilder<Map<String, dynamic>>(
      future: _getSnapshot(),
      builder: (context, snapshot) {
        if (!snapshot.hasData) {
          return GlassContainer(
            isDark: isDark,
            padding: EdgeInsets.all(AppConstants.spaceL),
            child: Center(
              child: CircularProgressIndicator(
                valueColor: AlwaysStoppedAnimation<Color>(AppColors.bluePrimary),
              ),
            ),
          );
        }

        final data = snapshot.data!;
        final total = data['total'] as int;
        final interviewing = data['interviewing'] as int;
        final lastFeedback = data['lastFeedback'] as DateTime?;

        return GlassContainer(
          isDark: isDark,
          padding: EdgeInsets.all(AppConstants.spaceL),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Row(
                children: [
                  Icon(
                    Icons.analytics_outlined,
                    color: AppColors.bluePrimary,
                    size: 20,
                  ),
                  SizedBox(width: 8),
                  Text(
                    'Student Snapshot',
                    style: TextStyle(
                      fontSize: 16,
                      fontWeight: FontWeight.w600,
                      color: isDark ? AppColors.pureWhite : AppColors.pureBlack,
                    ),
                  ),
                ],
              ),
              SizedBox(height: AppConstants.spaceL),
              
              // Stats row
              Row(
                children: [
                  Expanded(
                    child: _buildStat(
                      icon: Icons.work_outline,
                      label: 'Total Apps',
                      value: total.toString(),
                    ),
                  ),
                  SizedBox(width: AppConstants.spaceM),
                  Expanded(
                    child: _buildStat(
                      icon: Icons.chat_bubble_outline,
                      label: 'Interviewing',
                      value: interviewing.toString(),
                      highlight: interviewing > 0,
                    ),
                  ),
                ],
              ),
              
              SizedBox(height: AppConstants.spaceM),
              Divider(color: AppColors.mediumGray.withOpacity(0.2)),
              SizedBox(height: AppConstants.spaceM),
              
              // Last feedback
              Row(
                children: [
                  Icon(
                    Icons.feedback_outlined,
                    color: AppColors.mediumGray,
                    size: 16,
                  ),
                  SizedBox(width: 8),
                  Text(
                    'Last Feedback: ',
                    style: TextStyle(
                      fontSize: 14,
                      color: AppColors.mediumGray,
                    ),
                  ),
                  Text(
                    _formatDate(lastFeedback),
                    style: TextStyle(
                      fontSize: 14,
                      fontWeight: FontWeight.w600,
                      color: isDark ? AppColors.pureWhite : AppColors.pureBlack,
                    ),
                  ),
                ],
              ),
            ],
          ),
        );
      },
    );
  }

  Widget _buildStat({
    required IconData icon,
    required String label,
    required String value,
    bool highlight = false,
  }) {
    return Container(
      padding: EdgeInsets.all(AppConstants.spaceM),
      decoration: BoxDecoration(
        color: highlight
            ? AppColors.bluePrimary.withOpacity(0.1)
            : (isDark ? Colors.white.withOpacity(0.05) : Colors.black.withOpacity(0.03)),
        borderRadius: BorderRadius.circular(12),
        border: Border.all(
          color: highlight
              ? AppColors.bluePrimary.withOpacity(0.3)
              : (isDark ? Colors.white.withOpacity(0.1) : Colors.black.withOpacity(0.05)),
        ),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Icon(
            icon,
            color: highlight ? AppColors.bluePrimary : AppColors.mediumGray,
            size: 20,
          ),
          SizedBox(height: 8),
          Text(
            value,
            style: TextStyle(
              fontSize: 24,
              fontWeight: FontWeight.w700,
              color: highlight
                  ? AppColors.bluePrimary
                  : (isDark ? AppColors.pureWhite : AppColors.pureBlack),
            ),
          ),
          SizedBox(height: 4),
          Text(
            label,
            style: TextStyle(
              fontSize: 12,
              color: AppColors.mediumGray,
            ),
          ),
        ],
      ),
    );
  }
}