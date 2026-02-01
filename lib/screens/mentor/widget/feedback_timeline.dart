// lib/screens/mentor/widgets/feedback_timeline.dart
import 'package:flutter/material.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import '../../../core/constants/colors.dart';
import '../../../core/constants/app_constants.dart';
import '../../../core/widgets/glass_container.dart';
import '../../../models/feedback_cycle_model.dart';

class FeedbackTimeline extends StatefulWidget {
  final String internshipId;
  final bool isDark;

  const FeedbackTimeline({
    Key? key,
    required this.internshipId,
    required this.isDark,
  }) : super(key: key);

  @override
  State<FeedbackTimeline> createState() => _FeedbackTimelineState();
}

class _FeedbackTimelineState extends State<FeedbackTimeline> {
  bool _isExpanded = false;

  @override
  Widget build(BuildContext context) {
    return StreamBuilder<QuerySnapshot>(
      stream: FirebaseFirestore.instance
          .collection('feedbackCycles')
          .where('internshipId', isEqualTo: widget.internshipId)
          .where('status', isEqualTo: 'completed')
          .orderBy('respondedAt', descending: true)
          .snapshots(),
      builder: (context, snapshot) {
        if (snapshot.connectionState == ConnectionState.waiting) {
          return GlassContainer(
            isDark: widget.isDark,
            padding: EdgeInsets.all(AppConstants.spaceM),
            child: Center(
              child: CircularProgressIndicator(
                valueColor: AlwaysStoppedAnimation(AppColors.bluePrimary),
              ),
            ),
          );
        }

        if (!snapshot.hasData || snapshot.data!.docs.isEmpty) {
          return SizedBox.shrink();
        }

        final feedbackCycles = snapshot.data!.docs
            .map((doc) => FeedbackCycle.fromFirestore(doc))
            .toList();

        final latestFeedback = feedbackCycles.first;
        final hasMultiple = feedbackCycles.length > 1;

        return Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            // Section header
            Row(
              children: [
                Text(
                  'Mentor Feedback',
                  style: Theme.of(context).textTheme.headlineSmall,
                ),
                SizedBox(width: 8),
                Container(
                  padding: EdgeInsets.symmetric(horizontal: 8, vertical: 4),
                  decoration: BoxDecoration(
                    color: AppColors.bluePrimary.withOpacity(0.2),
                    borderRadius: BorderRadius.circular(12),
                  ),
                  child: Text(
                    '${feedbackCycles.length}',
                    style: TextStyle(
                      fontSize: 12,
                      fontWeight: FontWeight.w700,
                      color: AppColors.bluePrimary,
                    ),
                  ),
                ),
              ],
            ),
            SizedBox(height: AppConstants.spaceM),

            // Latest feedback (always shown)
            _buildFeedbackCard(latestFeedback, true),

            // Expand/collapse button
            if (hasMultiple) ...[
              SizedBox(height: AppConstants.spaceM),
              GestureDetector(
                onTap: () {
                  setState(() {
                    _isExpanded = !_isExpanded;
                  });
                },
                child: GlassContainer(
                  isDark: widget.isDark,
                  padding: EdgeInsets.symmetric(
                    horizontal: AppConstants.spaceM,
                    vertical: AppConstants.spaceS,
                  ),
                  child: Row(
                    mainAxisAlignment: MainAxisAlignment.center,
                    children: [
                      Text(
                        _isExpanded
                            ? 'Hide ${feedbackCycles.length - 1} earlier feedback'
                            : 'View ${feedbackCycles.length - 1} earlier feedback',
                        style: TextStyle(
                          fontSize: 14,
                          fontWeight: FontWeight.w600,
                          color: AppColors.bluePrimary,
                        ),
                      ),
                      SizedBox(width: 8),
                      Icon(
                        _isExpanded
                            ? Icons.keyboard_arrow_up_rounded
                            : Icons.keyboard_arrow_down_rounded,
                        color: AppColors.bluePrimary,
                        size: 20,
                      ),
                    ],
                  ),
                ),
              ),
            ],

            // Expanded feedback list
            if (_isExpanded && hasMultiple) ...[
              SizedBox(height: AppConstants.spaceM),
              ...feedbackCycles
                  .skip(1)
                  .map((cycle) => Padding(
                        padding: EdgeInsets.only(bottom: AppConstants.spaceM),
                        child: _buildFeedbackCard(cycle, false),
                      ))
                  .toList(),
            ],
          ],
        );
      },
    );
  }

  Widget _buildFeedbackCard(FeedbackCycle cycle, bool isLatest) {
    return FutureBuilder<String>(
      future: _getMentorName(cycle.mentorId),
      builder: (context, snapshot) {
        final mentorName = snapshot.data ?? 'Mentor';

        return GlassContainer(
          isDark: widget.isDark,
          padding: EdgeInsets.all(AppConstants.spaceM),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              // Header
              Row(
                children: [
                  Container(
                    width: 40,
                    height: 40,
                    decoration: BoxDecoration(
                      gradient: LinearGradient(
                        colors: [AppColors.bluePrimary, AppColors.blueLight],
                      ),
                      borderRadius: BorderRadius.circular(10),
                    ),
                    child: Center(
                      child: Text(
                        mentorName[0].toUpperCase(),
                        style: TextStyle(
                          color: Colors.white,
                          fontSize: 18,
                          fontWeight: FontWeight.w700,
                        ),
                      ),
                    ),
                  ),
                  SizedBox(width: AppConstants.spaceM),
                  Expanded(
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Row(
                          children: [
                            Text(
                              mentorName,
                              style: TextStyle(
                                fontSize: 16,
                                fontWeight: FontWeight.w600,
                                color: widget.isDark
                                    ? AppColors.pureWhite
                                    : AppColors.pureBlack,
                              ),
                            ),
                            if (isLatest) ...[
                              SizedBox(width: 8),
                              Container(
                                padding: EdgeInsets.symmetric(
                                  horizontal: 6,
                                  vertical: 2,
                                ),
                                decoration: BoxDecoration(
                                  color: Colors.green.withOpacity(0.2),
                                  borderRadius: BorderRadius.circular(4),
                                ),
                                child: Text(
                                  'Latest',
                                  style: TextStyle(
                                    fontSize: 10,
                                    fontWeight: FontWeight.w700,
                                    color: Colors.green,
                                  ),
                                ),
                              ),
                            ],
                          ],
                        ),
                        SizedBox(height: 2),
                        Text(
                          _formatDate(cycle.respondedAt!),
                          style: TextStyle(
                            fontSize: 12,
                            color: AppColors.mediumGray,
                          ),
                        ),
                      ],
                    ),
                  ),
                ],
              ),

              SizedBox(height: AppConstants.spaceM),

              // Student question
              Container(
                padding: EdgeInsets.all(AppConstants.spaceS),
                decoration: BoxDecoration(
                  color: widget.isDark
                      ? Colors.white.withOpacity(0.05)
                      : Colors.black.withOpacity(0.03),
                  borderRadius: BorderRadius.circular(8),
                ),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      'Question:',
                      style: TextStyle(
                        fontSize: 12,
                        fontWeight: FontWeight.w600,
                        color: AppColors.mediumGray,
                      ),
                    ),
                    SizedBox(height: 4),
                    Text(
                      cycle.studentRequest,
                      style: TextStyle(
                        fontSize: 14,
                        color: widget.isDark
                            ? AppColors.pureWhite
                            : AppColors.pureBlack,
                        height: 1.3,
                      ),
                    ),
                  ],
                ),
              ),

              SizedBox(height: AppConstants.spaceM),

              // Mentor feedback
              Container(
                padding: EdgeInsets.all(AppConstants.spaceM),
                decoration: BoxDecoration(
                  color: AppColors.bluePrimary.withOpacity(0.1),
                  borderRadius: BorderRadius.circular(12),
                  border: Border.all(
                    color: AppColors.bluePrimary.withOpacity(0.3),
                  ),
                ),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Row(
                      children: [
                        Icon(
                          Icons.feedback_outlined,
                          size: 16,
                          color: AppColors.bluePrimary,
                        ),
                        SizedBox(width: 6),
                        Text(
                          'Feedback:',
                          style: TextStyle(
                            fontSize: 12,
                            fontWeight: FontWeight.w600,
                            color: AppColors.bluePrimary,
                          ),
                        ),
                      ],
                    ),
                    SizedBox(height: 8),
                    Text(
                      cycle.mentorFeedback ?? 'No feedback provided',
                      style: TextStyle(
                        fontSize: 14,
                        color: widget.isDark
                            ? AppColors.pureWhite
                            : AppColors.pureBlack,
                        height: 1.4,
                      ),
                    ),
                  ],
                ),
              ),

              // Next step (if provided)
              if (cycle.suggestedNextStep != null &&
                  cycle.suggestedNextStep!.isNotEmpty) ...[
                SizedBox(height: AppConstants.spaceM),
                Container(
                  padding: EdgeInsets.all(AppConstants.spaceM),
                  decoration: BoxDecoration(
                    color: Colors.orange.withOpacity(0.1),
                    borderRadius: BorderRadius.circular(12),
                    border: Border.all(
                      color: Colors.orange.withOpacity(0.3),
                    ),
                  ),
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Row(
                        children: [
                          Icon(
                            Icons.lightbulb_outline,
                            size: 16,
                            color: Colors.orange,
                          ),
                          SizedBox(width: 6),
                          Text(
                            'Suggested Next Step:',
                            style: TextStyle(
                              fontSize: 12,
                              fontWeight: FontWeight.w600,
                              color: Colors.orange,
                            ),
                          ),
                        ],
                      ),
                      SizedBox(height: 8),
                      Text(
                        cycle.suggestedNextStep!,
                        style: TextStyle(
                          fontSize: 14,
                          color: widget.isDark
                              ? AppColors.pureWhite
                              : AppColors.pureBlack,
                          height: 1.4,
                        ),
                      ),
                    ],
                  ),
                ),
              ],
            ],
          ),
        );
      },
    );
  }

  Future<String> _getMentorName(String mentorId) async {
    try {
      final doc = await FirebaseFirestore.instance
          .collection('users')
          .doc(mentorId)
          .get();
      return doc.data()?['displayName'] ?? 'Mentor';
    } catch (e) {
      return 'Mentor';
    }
  }

  String _formatDate(DateTime date) {
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
}