// lib/screens/student/invite_mentor_screen.dart
import 'package:flutter/material.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:provider/provider.dart';
import '../../core/constants/colors.dart';
import '../../core/constants/app_constants.dart';
import '../../core/widgets/glass_text_field.dart';
import '../../core/widgets/gradient_orb.dart';
import '../../core/widgets/purple_button.dart';
import '../../providers/mentor_provider.dart';

class InviteMentorScreen extends StatefulWidget {
  @override
  State<InviteMentorScreen> createState() => _InviteMentorScreenState();
}

class _InviteMentorScreenState extends State<InviteMentorScreen> {
  final _formKey = GlobalKey<FormState>();
  final _mentorEmailController = TextEditingController();
  final FirebaseAuth _auth = FirebaseAuth.instance;

  @override
  void dispose() {
    _mentorEmailController.dispose();
    super.dispose();
  }

  Future<void> _sendInvitation() async {
    if (!_formKey.currentState!.validate()) return;

    final user = _auth.currentUser;
    if (user == null) return;

    final mentorProvider = Provider.of<MentorProvider>(context, listen: false);

    final success = await mentorProvider.sendInvitation(
      studentId: user.uid,
      studentName: user.displayName ?? 'Student',
      studentEmail: user.email ?? '',
      mentorEmail: _mentorEmailController.text.trim(),
    );

    if (mounted) {
      if (success) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text('Invitation sent! Check your mentor\'s email.'),
            backgroundColor: Colors.green,
            behavior: SnackBarBehavior.floating,
            margin: EdgeInsets.all(AppConstants.spaceM),
            shape: RoundedRectangleBorder(
              borderRadius: BorderRadius.circular(AppConstants.radiusSmall),
            ),
          ),
        );
        Navigator.pop(context);
      } else {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text('Email sent to Firestore but couldn\'t send email notification. Invitation is still valid.'),
            backgroundColor: Colors.orange,
            behavior: SnackBarBehavior.floating,
            margin: EdgeInsets.all(AppConstants.spaceM),
            shape: RoundedRectangleBorder(
              borderRadius: BorderRadius.circular(AppConstants.radiusSmall),
            ),
          ),
        );
        Navigator.pop(context);
      }
    }
  }

  @override
  Widget build(BuildContext context) {
    final isDark = Theme.of(context).brightness == Brightness.dark;
    final isLoading = context.watch<MentorProvider>().isLoading;

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
            child: SingleChildScrollView(
              padding: EdgeInsets.all(AppConstants.spaceL),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Row(
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
                      Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Text(
                            'Invite Mentor',
                            style: Theme.of(context).textTheme.displayMedium?.copyWith(fontSize: 28),
                          ),
                          SizedBox(height: 4),
                          Text(
                            'Get guidance from an expert',
                            style: Theme.of(context).textTheme.bodyMedium,
                          ),
                        ],
                      ),
                    ],
                  ),

                  SizedBox(height: AppConstants.spaceXXL),

                  Icon(
                    Icons.supervisor_account_rounded,
                    size: 80,
                    color: AppColors.purplePrimary,
                  ),

                  SizedBox(height: AppConstants.spaceL),

                  Text(
                    'How it works',
                    style: TextStyle(
                      fontSize: 20,
                      fontWeight: FontWeight.w600,
                      color: isDark ? AppColors.pureWhite : AppColors.pureBlack,
                    ),
                  ),

                  SizedBox(height: AppConstants.spaceM),

                  _buildStep(
                    '1',
                    'Enter your mentor\'s email',
                    'We\'ll send them an invitation to join InternTrack',
                    isDark,
                  ),

                  _buildStep(
                    '2',
                    'Mentor downloads the app',
                    'They\'ll receive instructions via email',
                    isDark,
                  ),

                  _buildStep(
                    '3',
                    'Mentor signs up using that email',
                    'You\'ll be automatically connected',
                    isDark,
                  ),

                  SizedBox(height: AppConstants.spaceXL),

                  Form(
                    key: _formKey,
                    child: GlassTextField(
                      label: 'Mentor Email',
                      hint: 'mentor@example.com',
                      controller: _mentorEmailController,
                      isDark: isDark,
                      prefixIcon: Icons.email_outlined,
                      keyboardType: TextInputType.emailAddress,
                      validator: (value) {
                        if (value == null || value.trim().isEmpty) {
                          return 'Please enter mentor\'s email';
                        }
                        if (!value.contains('@') || !value.contains('.')) {
                          return 'Please enter a valid email';
                        }
                        return null;
                      },
                    ),
                  ),

                  SizedBox(height: AppConstants.spaceXL),

                  PurpleButton(
                    text: 'Send Invitation',
                    icon: Icons.send_rounded,
                    onPressed: _sendInvitation,
                    isLoading: isLoading,
                    width: double.infinity,
                  ),

                  SizedBox(height: AppConstants.spaceL),
                ],
              ),
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildStep(String number, String title, String description, bool isDark) {
    return Padding(
      padding: EdgeInsets.only(bottom: AppConstants.spaceM),
      child: Row(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Container(
            width: 32,
            height: 32,
            decoration: BoxDecoration(
              gradient: LinearGradient(
                colors: [AppColors.purplePrimary, AppColors.purpleLight],
              ),
              shape: BoxShape.circle,
            ),
            child: Center(
              child: Text(
                number,
                style: TextStyle(
                  fontSize: 16,
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
                  title,
                  style: TextStyle(
                    fontSize: 16,
                    fontWeight: FontWeight.w600,
                    color: isDark ? AppColors.pureWhite : AppColors.pureBlack,
                  ),
                ),
                SizedBox(height: 4),
                Text(
                  description,
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
    );
  }
}