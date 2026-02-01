// lib/screens/mentor/widgets/feedback_dialog.dart
import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import '../../../core/constants/colors.dart';
import '../../../core/constants/app_constants.dart';
import '../../../models/feedback_cycle_model.dart';
import '../../../providers/mentor_provider.dart';
import '../mentor_requests_screen.dart';

class FeedbackDialog extends StatefulWidget {
  final FeedbackCycle cycle;
  final RequestCardData data;
  final bool isDark;

  const FeedbackDialog({
    Key? key,
    required this.cycle,
    required this.data,
    required this.isDark,
  }) : super(key: key);

  @override
  State<FeedbackDialog> createState() => _FeedbackDialogState();
}

class _FeedbackDialogState extends State<FeedbackDialog> {
  final TextEditingController _feedbackCtrl = TextEditingController();
  final TextEditingController _nextStepCtrl = TextEditingController();

  @override
  void dispose() {
    _feedbackCtrl.dispose();
    _nextStepCtrl.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return AlertDialog(
      backgroundColor: widget.isDark ? AppColors.darkGray : AppColors.pureWhite,
      shape: RoundedRectangleBorder(
        borderRadius: BorderRadius.circular(20),
      ),
      title: Text(
        "${widget.data.studentName} requested feedback",
        style: TextStyle(
          fontSize: 20,
          fontWeight: FontWeight.w700,
          color: widget.isDark ? AppColors.pureWhite : AppColors.pureBlack,
        ),
      ),
      content: SingleChildScrollView(
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          mainAxisSize: MainAxisSize.min,
          children: [
            // Company info
            Row(
              children: [
                Icon(Icons.business, size: 16, color: AppColors.mediumGray),
                SizedBox(width: 8),
                Expanded(
                  child: Text(
                    widget.data.company,
                    style: TextStyle(
                      fontSize: 16,
                      fontWeight: FontWeight.w600,
                      color: widget.isDark
                          ? AppColors.pureWhite
                          : AppColors.pureBlack,
                    ),
                  ),
                ),
              ],
            ),
            SizedBox(height: AppConstants.spaceM),

            // Student's request
            Text(
              "Student's Question:",
              style: TextStyle(
                fontSize: 14,
                fontWeight: FontWeight.w600,
                color: AppColors.mediumGray,
              ),
            ),
            SizedBox(height: 6),
            Container(
              padding: EdgeInsets.all(AppConstants.spaceM),
              decoration: BoxDecoration(
                color: AppColors.bluePrimary.withOpacity(0.1),
                borderRadius: BorderRadius.circular(12),
                border: Border.all(
                  color: AppColors.bluePrimary.withOpacity(0.3),
                ),
              ),
              child: Text(
                widget.cycle.studentRequest,
                style: TextStyle(
                  fontSize: 14,
                  color: widget.isDark ? AppColors.pureWhite : AppColors.pureBlack,
                  height: 1.4,
                ),
              ),
            ),

            SizedBox(height: AppConstants.spaceL),

            // Feedback input
            Text(
              "Your Feedback:",
              style: TextStyle(
                fontSize: 14,
                fontWeight: FontWeight.w600,
                color: AppColors.mediumGray,
              ),
            ),
            SizedBox(height: 6),
            TextField(
              controller: _feedbackCtrl,
              maxLines: 5,
              style: TextStyle(
                color: widget.isDark ? AppColors.pureWhite : AppColors.pureBlack,
              ),
              decoration: InputDecoration(
                hintText: "Share your detailed feedback...",
                hintStyle: TextStyle(color: AppColors.mediumGray),
                filled: true,
                fillColor: widget.isDark
                    ? Colors.white.withOpacity(.05)
                    : Colors.black.withOpacity(.05),
                border: OutlineInputBorder(
                  borderRadius: BorderRadius.circular(12),
                  borderSide: BorderSide.none,
                ),
                enabledBorder: OutlineInputBorder(
                  borderRadius: BorderRadius.circular(12),
                  borderSide: BorderSide(
                    color: AppColors.mediumGray.withOpacity(0.2),
                  ),
                ),
                focusedBorder: OutlineInputBorder(
                  borderRadius: BorderRadius.circular(12),
                  borderSide: BorderSide(
                    color: AppColors.bluePrimary,
                    width: 2,
                  ),
                ),
              ),
            ),

            SizedBox(height: AppConstants.spaceM),

            // Next step input (optional)
            Text(
              "Suggested Next Step (Optional):",
              style: TextStyle(
                fontSize: 14,
                fontWeight: FontWeight.w600,
                color: AppColors.mediumGray,
              ),
            ),
            SizedBox(height: 6),
            TextField(
              controller: _nextStepCtrl,
              maxLines: 2,
              style: TextStyle(
                color: widget.isDark ? AppColors.pureWhite : AppColors.pureBlack,
              ),
              decoration: InputDecoration(
                hintText: "Suggest an action item...",
                hintStyle: TextStyle(color: AppColors.mediumGray),
                filled: true,
                fillColor: widget.isDark
                    ? Colors.white.withOpacity(.05)
                    : Colors.black.withOpacity(.05),
                border: OutlineInputBorder(
                  borderRadius: BorderRadius.circular(12),
                  borderSide: BorderSide.none,
                ),
                enabledBorder: OutlineInputBorder(
                  borderRadius: BorderRadius.circular(12),
                  borderSide: BorderSide(
                    color: AppColors.mediumGray.withOpacity(0.2),
                  ),
                ),
                focusedBorder: OutlineInputBorder(
                  borderRadius: BorderRadius.circular(12),
                  borderSide: BorderSide(
                    color: AppColors.bluePrimary,
                    width: 2,
                  ),
                ),
              ),
            ),
          ],
        ),
      ),
      actions: [
        TextButton(
          onPressed: () {
            _feedbackCtrl.clear();
            _nextStepCtrl.clear();
            Navigator.pop(context);
          },
          child: Text(
            "Cancel",
            style: TextStyle(color: AppColors.mediumGray),
          ),
        ),
        ElevatedButton(
          style: ElevatedButton.styleFrom(
            backgroundColor: AppColors.bluePrimary,
            foregroundColor: Colors.white,
            padding: EdgeInsets.symmetric(horizontal: 24, vertical: 12),
            shape: RoundedRectangleBorder(
              borderRadius: BorderRadius.circular(12),
            ),
          ),
          onPressed: () async {
            if (_feedbackCtrl.text.trim().isEmpty) {
              ScaffoldMessenger.of(context).showSnackBar(
                SnackBar(content: Text("Feedback cannot be empty")),
              );
              return;
            }

            try {
              // Submit feedback
              await context.read<MentorProvider>().submitFeedback(
                    cycleId: widget.cycle.id,
                    feedback: _feedbackCtrl.text.trim(),
                    nextStep: _nextStepCtrl.text.trim().isNotEmpty
                        ? _nextStepCtrl.text.trim()
                        : null,
                  );

              _feedbackCtrl.clear();
              _nextStepCtrl.clear();
              Navigator.pop(context);
              _showSuccess(context);
            } catch (e) {
              ScaffoldMessenger.of(context).showSnackBar(
                SnackBar(
                  content: Text("Error: $e"),
                  backgroundColor: Colors.red,
                ),
              );
            }
          },
          child: Text("Send Feedback"),
        ),
      ],
    );
  }

  void _showSuccess(BuildContext context) {
    showDialog(
      context: context,
      builder: (_) => AlertDialog(
        backgroundColor: AppColors.bluePrimary,
        shape: RoundedRectangleBorder(
          borderRadius: BorderRadius.circular(16),
        ),
        content: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            Icon(Icons.check_circle_outline, size: 50, color: Colors.white),
            SizedBox(height: 12),
            Text(
              "Feedback sent successfully",
              style: TextStyle(
                color: Colors.white,
                fontSize: 16,
                fontWeight: FontWeight.w600,
              ),
            ),
          ],
        ),
      ),
    );

    Future.delayed(Duration(seconds: 2), () {
      Navigator.pop(context);
    });
  }
}