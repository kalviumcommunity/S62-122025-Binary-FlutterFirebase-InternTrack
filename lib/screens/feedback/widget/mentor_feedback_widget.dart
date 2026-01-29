import 'package:flutter/material.dart';
import '../../../core/constants/colors.dart';
import '../../../core/constants/app_constants.dart';
import '../../../core/widgets/glass_container.dart';
import '../../../models/feedback_cycle_model.dart';
import '../../../services/feedback_service.dart';
import '../feedback_history_screen.dart';
import '../request_feedback_screen.dart';

class MentorFeedbackWidget extends StatefulWidget {
  final String internshipId;
  final String internshipCompany;
  final bool isDark;

  const MentorFeedbackWidget({
    Key? key,
    required this.internshipId,
    required this.internshipCompany,
    required this.isDark,
  }) : super(key: key);

  @override
  State<MentorFeedbackWidget> createState() => _MentorFeedbackWidgetState();
}

class _MentorFeedbackWidgetState extends State<MentorFeedbackWidget> {
  final FeedbackService _feedbackService = FeedbackService();
  FeedbackCycle? _latestFeedback;
  bool _isLoading = true;

  @override
  void initState() {
    super.initState();
    _loadLatestFeedback();
  }

  Future<void> _loadLatestFeedback() async {
    setState(() => _isLoading = true);
    final feedback = await _feedbackService.getLatestFeedback(widget.internshipId);
    if (mounted) {
      setState(() {
        _latestFeedback = feedback;
        _isLoading = false;
      });

      // Mark as seen if completed and not seen yet
      if (feedback != null && 
          feedback.status == 'completed' && 
          !feedback.seenByStudent) {
        _feedbackService.markFeedbackAsSeen(feedback.id);
      }
    }
  }

  void _requestFeedback() async {
    final result = await Navigator.push(
      context,
      MaterialPageRoute(
        builder: (context) => RequestFeedbackScreen(
          internshipId: widget.internshipId,
          internshipCompany: widget.internshipCompany,
          isDark: widget.isDark,
        ),
      ),
    );

    if (result == true) {
      _loadLatestFeedback();
    }
  }

  void _viewHistory() {
    Navigator.push(
      context,
      MaterialPageRoute(
        builder: (context) => FeedbackHistoryScreen(
          internshipId: widget.internshipId,
          internshipCompany: widget.internshipCompany,
          isDark: widget.isDark,
        ),
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Row(
          mainAxisAlignment: MainAxisAlignment.spaceBetween,
          children: [
            Text(
              'Mentor Feedback',
              style: Theme.of(context).textTheme.headlineSmall,
            ),
            if (_latestFeedback != null)
              TextButton.icon(
                onPressed: _viewHistory,
                icon: Icon(Icons.history, size: 18),
                label: Text('View History'),
                style: TextButton.styleFrom(
                  foregroundColor: AppColors.purplePrimary,
                ),
              ),
          ],
        ),
        SizedBox(height: AppConstants.spaceM),

        if (_isLoading)
          Center(
            child: Padding(
              padding: EdgeInsets.all(AppConstants.spaceXL),
              child: CircularProgressIndicator(),
            ),
          )
        else if (_latestFeedback == null)
          _buildNoFeedbackState()
        else if (_latestFeedback!.status == 'pending')
          _buildPendingState()
        else
          _buildCompletedFeedback(),
      ],
    );
  }

  Widget _buildNoFeedbackState() {
    return GlassContainer(
      isDark: widget.isDark,
      padding: EdgeInsets.all(AppConstants.spaceL),
      child: Column(
        children: [
          Icon(
            Icons.forum_outlined,
            size: 48,
            color: AppColors.mediumGray.withOpacity(0.5),
          ),
          SizedBox(height: AppConstants.spaceM),
          Text(
            'No feedback yet',
            style: TextStyle(
              fontSize: 16,
              fontWeight: FontWeight.w600,
              color: widget.isDark ? AppColors.pureWhite : AppColors.pureBlack,
            ),
          ),
          SizedBox(height: AppConstants.spaceS),
          Text(
            'Request feedback from your mentor to get started',
            style: TextStyle(
              fontSize: 14,
              color: AppColors.mediumGray,
            ),
            textAlign: TextAlign.center,
          ),
          SizedBox(height: AppConstants.spaceL),
          SizedBox(
            width: double.infinity,
            child: ElevatedButton.icon(
              onPressed: _requestFeedback,
              icon: Icon(Icons.send_outlined, size: 18),
              label: Text('Request Mentor Feedback'),
              style: ElevatedButton.styleFrom(
                backgroundColor: AppColors.purplePrimary,
                foregroundColor: Colors.white,
                padding: EdgeInsets.symmetric(vertical: 14),
                shape: RoundedRectangleBorder(
                  borderRadius: BorderRadius.circular(12),
                ),
              ),
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildPendingState() {
    return GlassContainer(
      isDark: widget.isDark,
      padding: EdgeInsets.all(AppConstants.spaceL),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            children: [
              Container(
                padding: EdgeInsets.all(8),
                decoration: BoxDecoration(
                  color: Colors.orange.withOpacity(0.2),
                  borderRadius: BorderRadius.circular(8),
                ),
                child: Icon(
                  Icons.access_time,
                  color: Colors.orange,
                  size: 20,
                ),
              ),
              SizedBox(width: AppConstants.spaceM),
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      'Feedback Pending',
                      style: TextStyle(
                        fontSize: 16,
                        fontWeight: FontWeight.w600,
                        color: widget.isDark ? AppColors.pureWhite : AppColors.pureBlack,
                      ),
                    ),
                    SizedBox(height: 4),
                    Text(
                      'Waiting for mentor response',
                      style: TextStyle(
                        fontSize: 13,
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
          Text(
            'Your Request:',
            style: TextStyle(
              fontSize: 13,
              fontWeight: FontWeight.w600,
              color: AppColors.mediumGray,
            ),
          ),
          SizedBox(height: AppConstants.spaceS),
          Text(
            _latestFeedback!.studentRequest,
            style: TextStyle(
              fontSize: 14,
              color: widget.isDark ? AppColors.pureWhite : AppColors.pureBlack,
            ),
          ),
          SizedBox(height: AppConstants.spaceM),
          Text(
            'Requested ${_formatDate(_latestFeedback!.requestedAt)}',
            style: TextStyle(
              fontSize: 12,
              color: AppColors.mediumGray,
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildCompletedFeedback() {
    final hasNewFeedback = !_latestFeedback!.seenByStudent;

    return Column(
      children: [
        GlassContainer(
          isDark: widget.isDark,
          padding: EdgeInsets.all(AppConstants.spaceL),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Row(
                children: [
                  Container(
                    padding: EdgeInsets.all(8),
                    decoration: BoxDecoration(
                      gradient: LinearGradient(
                        colors: [AppColors.purplePrimary, AppColors.purpleLight],
                      ),
                      borderRadius: BorderRadius.circular(8),
                    ),
                    child: Icon(
                      Icons.psychology_outlined,
                      color: Colors.white,
                      size: 20,
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
                              'Latest Feedback',
                              style: TextStyle(
                                fontSize: 16,
                                fontWeight: FontWeight.w600,
                                color: widget.isDark ? AppColors.pureWhite : AppColors.pureBlack,
                              ),
                            ),
                            if (hasNewFeedback) ...[
                              SizedBox(width: 8),
                              Container(
                                padding: EdgeInsets.symmetric(horizontal: 8, vertical: 2),
                                decoration: BoxDecoration(
                                  color: Colors.green,
                                  borderRadius: BorderRadius.circular(10),
                                ),
                                child: Text(
                                  'NEW',
                                  style: TextStyle(
                                    fontSize: 10,
                                    fontWeight: FontWeight.w700,
                                    color: Colors.white,
                                  ),
                                ),
                              ),
                            ],
                          ],
                        ),
                        SizedBox(height: 4),
                        Text(
                          'From your mentor • ${_formatDate(_latestFeedback!.respondedAt!)}',
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
              
              SizedBox(height: AppConstants.spaceL),
              
              // Mentor's feedback
              Container(
                padding: EdgeInsets.all(AppConstants.spaceM),
                decoration: BoxDecoration(
                  color: AppColors.purplePrimary.withOpacity(0.1),
                  borderRadius: BorderRadius.circular(12),
                  border: Border.all(
                    color: AppColors.purplePrimary.withOpacity(0.3),
                    width: 1,
                  ),
                ),
                child: Text(
                  _latestFeedback!.mentorFeedback ?? '',
                  style: TextStyle(
                    fontSize: 14,
                    height: 1.5,
                    color: widget.isDark ? AppColors.pureWhite : AppColors.pureBlack,
                  ),
                ),
              ),
              
              // Suggested next step
              if (_latestFeedback!.suggestedNextStep != null &&
                  _latestFeedback!.suggestedNextStep!.isNotEmpty) ...[
                SizedBox(height: AppConstants.spaceM),
                Container(
                  padding: EdgeInsets.all(AppConstants.spaceM),
                  decoration: BoxDecoration(
                    color: Colors.green.withOpacity(0.1),
                    borderRadius: BorderRadius.circular(12),
                    border: Border.all(
                      color: Colors.green.withOpacity(0.3),
                      width: 1,
                    ),
                  ),
                  child: Row(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Icon(
                        Icons.arrow_forward,
                        color: Colors.green,
                        size: 18,
                      ),
                      SizedBox(width: AppConstants.spaceS),
                      Expanded(
                        child: Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            Text(
                              'Suggested Next Step',
                              style: TextStyle(
                                fontSize: 12,
                                fontWeight: FontWeight.w600,
                                color: Colors.green,
                              ),
                            ),
                            SizedBox(height: 4),
                            Text(
                              _latestFeedback!.suggestedNextStep!,
                              style: TextStyle(
                                fontSize: 13,
                                color: widget.isDark ? AppColors.pureWhite : AppColors.pureBlack,
                              ),
                            ),
                          ],
                        ),
                      ),
                    ],
                  ),
                ),
              ],
            ],
          ),
        ),

        SizedBox(height: AppConstants.spaceM),

        // Action button
        SizedBox(
          width: double.infinity,
          child: OutlinedButton.icon(
            onPressed: _requestFeedback,
            icon: Icon(Icons.refresh, size: 18),
            label: Text('Request Follow-up Feedback'),
            style: OutlinedButton.styleFrom(
              foregroundColor: AppColors.purplePrimary,
              side: BorderSide(color: AppColors.purplePrimary),
              padding: EdgeInsets.symmetric(vertical: 14),
              shape: RoundedRectangleBorder(
                borderRadius: BorderRadius.circular(12),
              ),
            ),
          ),
        ),
      ],
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