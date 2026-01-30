// lib\screens\feedback\feedback_history_screen.dart
import 'package:flutter/material.dart';
import '../../../core/constants/colors.dart';
import '../../../core/constants/app_constants.dart';
import '../../../core/widgets/glass_container.dart';
import '../../../core/widgets/gradient_orb.dart';
import '../../../models/feedback_cycle_model.dart';
import '../../../services/feedback_service.dart';

class FeedbackHistoryScreen extends StatelessWidget {
  final String internshipId;
  final String internshipCompany;
  final bool isDark;

  const FeedbackHistoryScreen({
    Key? key,
    required this.internshipId,
    required this.internshipCompany,
    required this.isDark,
  }) : super(key: key);

  @override
  Widget build(BuildContext context) {
    final feedbackService = FeedbackService();

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
            child: Column(
              children: [
                // Header
                Padding(
                  padding: EdgeInsets.all(AppConstants.spaceL),
                  child: Row(
                    children: [
                      IconButton(
                        onPressed: () => Navigator.pop(context),
                        icon: Icon(Icons.arrow_back_rounded),
                        style: IconButton.styleFrom(
                          backgroundColor: isDark
                              ? Colors.white.withOpacity(0.1)
                              : Colors.black.withOpacity(0.05),
                        ),
                      ),
                      SizedBox(width: AppConstants.spaceM),
                      Expanded(
                        child: Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            Text(
                              'Feedback History',
                              style: Theme.of(context)
                                  .textTheme
                                  .displayMedium
                                  ?.copyWith(fontSize: 24),
                            ),
                            SizedBox(height: 4),
                            Text(
                              internshipCompany,
                              style: TextStyle(
                                fontSize: 14,
                                color: AppColors.mediumGray,
                              ),
                            ),
                          ],
                        ),
                      ),
                    ],
                  ),
                ),

                // History list
                Expanded(
                  child: StreamBuilder<List<FeedbackCycle>>(
                    stream: feedbackService.getFeedbackHistory(internshipId),
                    builder: (context, snapshot) {
                      if (snapshot.connectionState == ConnectionState.waiting) {
                        return Center(child: CircularProgressIndicator());
                      }

                      if (!snapshot.hasData || snapshot.data!.isEmpty) {
                        return Center(
                          child: Column(
                            mainAxisAlignment: MainAxisAlignment.center,
                            children: [
                              Icon(
                                Icons.history,
                                size: 64,
                                color: AppColors.mediumGray.withOpacity(0.5),
                              ),
                              SizedBox(height: AppConstants.spaceL),
                              Text(
                                'No feedback history',
                                style: TextStyle(
                                  fontSize: 18,
                                  fontWeight: FontWeight.w600,
                                  color: isDark
                                      ? AppColors.pureWhite
                                      : AppColors.pureBlack,
                                ),
                              ),
                              SizedBox(height: AppConstants.spaceS),
                              Text(
                                'Your feedback cycles will appear here',
                                style: TextStyle(
                                  fontSize: 14,
                                  color: AppColors.mediumGray,
                                ),
                              ),
                            ],
                          ),
                        );
                      }

                      final cycles = snapshot.data!;

                      return ListView.builder(
                        padding: EdgeInsets.all(AppConstants.spaceL),
                        itemCount: cycles.length,
                        itemBuilder: (context, index) {
                          final cycle = cycles[index];
                          final isLatest = index == 0;

                          return Padding(
                            padding: EdgeInsets.only(
                              bottom: AppConstants.spaceM,
                            ),
                            child: _FeedbackCycleCard(
                              cycle: cycle,
                              isDark: isDark,
                              isLatest: isLatest,
                            ),
                          );
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
    );
  }
}

class _FeedbackCycleCard extends StatelessWidget {
  final FeedbackCycle cycle;
  final bool isDark;
  final bool isLatest;

  const _FeedbackCycleCard({
    Key? key,
    required this.cycle,
    required this.isDark,
    required this.isLatest,
  }) : super(key: key);

  @override
  Widget build(BuildContext context) {
    final isCompleted = cycle.status == 'completed';

    return GlassContainer(
      isDark: isDark,
      padding: EdgeInsets.all(AppConstants.spaceL),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          // Header
          Row(
            children: [
              Container(
                padding: EdgeInsets.all(8),
                decoration: BoxDecoration(
                  color: isCompleted
                      ? AppColors.purplePrimary.withOpacity(0.2)
                      : Colors.orange.withOpacity(0.2),
                  borderRadius: BorderRadius.circular(8),
                ),
                child: Icon(
                  isCompleted ? Icons.check_circle : Icons.access_time,
                  color: isCompleted ? AppColors.purplePrimary : Colors.orange,
                  size: 18,
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
                          isCompleted ? 'Completed' : 'Pending',
                          style: TextStyle(
                            fontSize: 14,
                            fontWeight: FontWeight.w600,
                            color: isDark
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
                              gradient: LinearGradient(
                                colors: [
                                  AppColors.purplePrimary,
                                  AppColors.purpleLight
                                ],
                              ),
                              borderRadius: BorderRadius.circular(8),
                            ),
                            child: Text(
                              'LATEST',
                              style: TextStyle(
                                fontSize: 9,
                                fontWeight: FontWeight.w700,
                                color: Colors.white,
                                letterSpacing: 0.5,
                              ),
                            ),
                          ),
                        ],
                      ],
                    ),
                    SizedBox(height: 2),
                    Text(
                      _formatDate(cycle.requestedAt),
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
          Divider(color: AppColors.mediumGray.withOpacity(0.2)),
          SizedBox(height: AppConstants.spaceM),

          // Student request
          Text(
            'Your Request:',
            style: TextStyle(
              fontSize: 12,
              fontWeight: FontWeight.w600,
              color: AppColors.mediumGray,
            ),
          ),
          SizedBox(height: AppConstants.spaceS),
          Text(
            cycle.studentRequest,
            style: TextStyle(
              fontSize: 13,
              color: isDark ? AppColors.pureWhite : AppColors.pureBlack,
            ),
          ),

          // Mentor feedback (if completed)
          if (isCompleted && cycle.mentorFeedback != null) ...[
            SizedBox(height: AppConstants.spaceM),
            Text(
              'Mentor Response:',
              style: TextStyle(
                fontSize: 12,
                fontWeight: FontWeight.w600,
                color: AppColors.mediumGray,
              ),
            ),
            SizedBox(height: AppConstants.spaceS),
            Container(
              padding: EdgeInsets.all(AppConstants.spaceM),
              decoration: BoxDecoration(
                color: AppColors.purplePrimary.withOpacity(0.1),
                borderRadius: BorderRadius.circular(10),
                border: Border.all(
                  color: AppColors.purplePrimary.withOpacity(0.3),
                ),
              ),
              child: Text(
                cycle.mentorFeedback!,
                style: TextStyle(
                  fontSize: 13,
                  height: 1.4,
                  color: isDark ? AppColors.pureWhite : AppColors.pureBlack,
                ),
              ),
            ),

            if (cycle.suggestedNextStep != null &&
                cycle.suggestedNextStep!.isNotEmpty) ...[
              SizedBox(height: AppConstants.spaceM),
              Container(
                padding: EdgeInsets.all(AppConstants.spaceM),
                decoration: BoxDecoration(
                  color: Colors.green.withOpacity(0.1),
                  borderRadius: BorderRadius.circular(10),
                  border: Border.all(
                    color: Colors.green.withOpacity(0.3),
                  ),
                ),
                child: Row(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Icon(
                      Icons.arrow_forward,
                      color: Colors.green,
                      size: 16,
                    ),
                    SizedBox(width: AppConstants.spaceS),
                    Expanded(
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Text(
                            'Next Step',
                            style: TextStyle(
                              fontSize: 11,
                              fontWeight: FontWeight.w600,
                              color: Colors.green,
                            ),
                          ),
                          SizedBox(height: 2),
                          Text(
                            cycle.suggestedNextStep!,
                            style: TextStyle(
                              fontSize: 12,
                              color: isDark
                                  ? AppColors.pureWhite
                                  : AppColors.pureBlack,
                            ),
                          ),
                        ],
                      ),
                    ),
                  ],
                ),
              ),
            ],

            SizedBox(height: AppConstants.spaceS),
            Text(
              'Responded ${_formatDate(cycle.respondedAt!)}',
              style: TextStyle(
                fontSize: 11,
                color: AppColors.mediumGray,
              ),
            ),
          ],
        ],
      ),
    );
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