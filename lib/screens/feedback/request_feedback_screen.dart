import 'package:flutter/material.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import '../../../core/constants/colors.dart';
import '../../../core/constants/app_constants.dart';
import '../../../core/widgets/gradient_orb.dart';
import '../../../services/feedback_service.dart';

class RequestFeedbackScreen extends StatefulWidget {
  final String internshipId;
  final String internshipCompany;
  final bool isDark;

  const RequestFeedbackScreen({
    Key? key,
    required this.internshipId,
    required this.internshipCompany,
    required this.isDark,
  }) : super(key: key);

  @override
  State<RequestFeedbackScreen> createState() => _RequestFeedbackScreenState();
}

class _RequestFeedbackScreenState extends State<RequestFeedbackScreen> {
  final _formKey = GlobalKey<FormState>();
  final _requestController = TextEditingController();
  final _mentorEmailController = TextEditingController();
  final FeedbackService _feedbackService = FeedbackService();
  final FirebaseAuth _auth = FirebaseAuth.instance;
  bool _isLoading = false;

  @override
  void dispose() {
    _requestController.dispose();
    _mentorEmailController.dispose();
    super.dispose();
  }

  Future<void> _submitRequest() async {
    if (!_formKey.currentState!.validate()) return;

    setState(() => _isLoading = true);

    try {
      // Get mentor ID by email
      final mentorSnapshot = await FirebaseFirestore.instance
          .collection('users')
          .where('email', isEqualTo: _mentorEmailController.text.trim())
          .where('role', isEqualTo: 'mentor')
          .limit(1)
          .get();

      if (mentorSnapshot.docs.isEmpty) {
        throw 'Mentor not found with this email';
      }

      final mentorId = mentorSnapshot.docs.first.id;
      final studentId = _auth.currentUser!.uid;

      await _feedbackService.createFeedbackRequest(
        internshipId: widget.internshipId,
        studentId: studentId,
        mentorId: mentorId,
        studentRequest: _requestController.text.trim(),
      );

      if (mounted) {
        // Show success dialog
        showDialog(
          context: context,
          barrierDismissible: false,
          builder: (_) => AlertDialog(
            backgroundColor: AppColors.purplePrimary,
            shape: RoundedRectangleBorder(
              borderRadius: BorderRadius.circular(18),
            ),
            content: Column(
              mainAxisSize: MainAxisSize.min,
              children: [
                Icon(
                  Icons.check_circle_outline,
                  size: 48,
                  color: Colors.white,
                ),
                SizedBox(height: 12),
                Text(
                  'Request Sent!',
                  style: TextStyle(
                    color: Colors.white,
                    fontSize: 18,
                    fontWeight: FontWeight.w600,
                  ),
                ),
                SizedBox(height: 8),
                Text(
                  'Your mentor will be notified',
                  style: TextStyle(
                    color: Colors.white.withOpacity(0.9),
                    fontSize: 14,
                  ),
                  textAlign: TextAlign.center,
                ),
              ],
            ),
          ),
        );

        Future.delayed(Duration(seconds: 2), () {
          if (mounted) {
            Navigator.pop(context); // Close dialog
            Navigator.pop(context, true); // Close screen with success
          }
        });
      }
    } catch (e) {
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text(e.toString()),
            backgroundColor: Colors.red,
          ),
        );
      }
    } finally {
      if (mounted) {
        setState(() => _isLoading = false);
      }
    }
  }

  @override
  Widget build(BuildContext context) {
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
                          backgroundColor: widget.isDark
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
                              'Request Feedback',
                              style: Theme.of(context)
                                  .textTheme
                                  .displayMedium
                                  ?.copyWith(fontSize: 24),
                            ),
                            SizedBox(height: 4),
                            Text(
                              widget.internshipCompany,
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

                Expanded(
                  child: SingleChildScrollView(
                    padding: EdgeInsets.all(AppConstants.spaceL),
                    child: Form(
                      key: _formKey,
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          // Info box
                          Container(
                            padding: EdgeInsets.all(AppConstants.spaceM),
                            decoration: BoxDecoration(
                              color: AppColors.purplePrimary.withOpacity(0.1),
                              borderRadius: BorderRadius.circular(12),
                              border: Border.all(
                                color: AppColors.purplePrimary.withOpacity(0.3),
                              ),
                            ),
                            child: Row(
                              children: [
                                Icon(
                                  Icons.info_outline,
                                  color: AppColors.purplePrimary,
                                  size: 20,
                                ),
                                SizedBox(width: AppConstants.spaceM),
                                Expanded(
                                  child: Text(
                                    'Your mentor will receive a notification and can respond with structured feedback',
                                    style: TextStyle(
                                      fontSize: 13,
                                      color: widget.isDark
                                          ? AppColors.pureWhite
                                          : AppColors.pureBlack,
                                    ),
                                  ),
                                ),
                              ],
                            ),
                          ),

                          SizedBox(height: AppConstants.spaceXL),

                          // Mentor email field
                          Text(
                            'Mentor Email',
                            style: TextStyle(
                              fontSize: 14,
                              fontWeight: FontWeight.w600,
                              color: widget.isDark
                                  ? AppColors.pureWhite
                                  : AppColors.pureBlack,
                            ),
                          ),
                          SizedBox(height: AppConstants.spaceS),
                          TextFormField(
                            controller: _mentorEmailController,
                            keyboardType: TextInputType.emailAddress,
                            style: TextStyle(
                              color: widget.isDark
                                  ? AppColors.pureWhite
                                  : AppColors.pureBlack,
                            ),
                            decoration: InputDecoration(
                              hintText: 'mentor@example.com',
                              hintStyle: TextStyle(color: AppColors.mediumGray),
                              prefixIcon: Icon(
                                Icons.email_outlined,
                                color: AppColors.mediumGray,
                              ),
                              filled: true,
                              fillColor: widget.isDark
                                  ? Colors.white.withOpacity(0.1)
                                  : Colors.black.withOpacity(0.05),
                              border: OutlineInputBorder(
                                borderRadius:
                                    BorderRadius.circular(AppConstants.radiusMedium),
                                borderSide: BorderSide.none,
                              ),
                              enabledBorder: OutlineInputBorder(
                                borderRadius:
                                    BorderRadius.circular(AppConstants.radiusMedium),
                                borderSide: BorderSide(
                                  color: widget.isDark
                                      ? Colors.white.withOpacity(0.2)
                                      : Colors.black.withOpacity(0.1),
                                ),
                              ),
                              focusedBorder: OutlineInputBorder(
                                borderRadius:
                                    BorderRadius.circular(AppConstants.radiusMedium),
                                borderSide: BorderSide(
                                  color: AppColors.purplePrimary,
                                  width: 2,
                                ),
                              ),
                            ),
                            validator: (value) {
                              if (value == null || value.trim().isEmpty) {
                                return 'Please enter mentor email';
                              }
                              if (!value.contains('@') || !value.contains('.')) {
                                return 'Please enter a valid email';
                              }
                              return null;
                            },
                          ),

                          SizedBox(height: AppConstants.spaceL),

                          // Request message field
                          Text(
                            'Your Request',
                            style: TextStyle(
                              fontSize: 14,
                              fontWeight: FontWeight.w600,
                              color: widget.isDark
                                  ? AppColors.pureWhite
                                  : AppColors.pureBlack,
                            ),
                          ),
                          SizedBox(height: AppConstants.spaceS),
                          TextFormField(
                            controller: _requestController,
                            maxLines: 8,
                            style: TextStyle(
                              color: widget.isDark
                                  ? AppColors.pureWhite
                                  : AppColors.pureBlack,
                            ),
                            decoration: InputDecoration(
                              hintText:
                                  'What would you like feedback on?\n\nExamples:\n• How can I improve my resume?\n• Advice for the upcoming interview?\n• Should I accept this offer?',
                              hintStyle: TextStyle(color: AppColors.mediumGray),
                              filled: true,
                              fillColor: widget.isDark
                                  ? Colors.white.withOpacity(0.1)
                                  : Colors.black.withOpacity(0.05),
                              border: OutlineInputBorder(
                                borderRadius:
                                    BorderRadius.circular(AppConstants.radiusMedium),
                                borderSide: BorderSide.none,
                              ),
                              enabledBorder: OutlineInputBorder(
                                borderRadius:
                                    BorderRadius.circular(AppConstants.radiusMedium),
                                borderSide: BorderSide(
                                  color: widget.isDark
                                      ? Colors.white.withOpacity(0.2)
                                      : Colors.black.withOpacity(0.1),
                                ),
                              ),
                              focusedBorder: OutlineInputBorder(
                                borderRadius:
                                    BorderRadius.circular(AppConstants.radiusMedium),
                                borderSide: BorderSide(
                                  color: AppColors.purplePrimary,
                                  width: 2,
                                ),
                              ),
                            ),
                            validator: (value) {
                              if (value == null || value.trim().isEmpty) {
                                return 'Please describe what you need feedback on';
                              }
                              if (value.trim().length < 10) {
                                return 'Please provide more details (at least 10 characters)';
                              }
                              return null;
                            },
                          ),

                          SizedBox(height: AppConstants.spaceXL),

                          // Submit button
                          SizedBox(
                            width: double.infinity,
                            child: ElevatedButton.icon(
                              onPressed: _isLoading ? null : _submitRequest,
                              icon: _isLoading
                                  ? SizedBox(
                                      width: 18,
                                      height: 18,
                                      child: CircularProgressIndicator(
                                        strokeWidth: 2,
                                        valueColor:
                                            AlwaysStoppedAnimation<Color>(Colors.white),
                                      ),
                                    )
                                  : Icon(Icons.send, size: 18),
                              label: Text(_isLoading ? 'Sending...' : 'Send Request'),
                              style: ElevatedButton.styleFrom(
                                backgroundColor: AppColors.purplePrimary,
                                foregroundColor: Colors.white,
                                padding: EdgeInsets.symmetric(vertical: 16),
                                shape: RoundedRectangleBorder(
                                  borderRadius: BorderRadius.circular(14),
                                ),
                              ),
                            ),
                          ),
                        ],
                      ),
                    ),
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