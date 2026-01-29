// lib/screens/mentor/mentor_requests_screen.dart
// FIXED: Works with FeedbackCycle and fetches student/internship info
import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:cloud_firestore/cloud_firestore.dart';

import '../../providers/mentor_provider.dart';
import '../../core/widgets/glass_container.dart';
import '../../core/constants/colors.dart';
import '../../core/constants/app_constants.dart';
import '../../models/internship_model.dart';
import '../../models/feedback_cycle_model.dart';
import 'mentor_internship_detail_screen.dart';

class MentorRequestsScreen extends StatelessWidget {
  MentorRequestsScreen({super.key});

  final TextEditingController _feedbackCtrl = TextEditingController();
  final TextEditingController _nextStepCtrl = TextEditingController();

  // ================= FETCH STUDENT NAME & INTERNSHIP DATA =================

  Future<Map<String, dynamic>> _fetchRequestData(FeedbackCycle cycle) async {
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

      return {
        'studentName': studentDoc.data()?['displayName'] ?? 'Student',
        'studentEmail': studentDoc.data()?['email'] ?? '',
        'company': internshipDoc.data()?['company'] ?? 'Unknown Company',
        'role': internshipDoc.data()?['role'] ?? '',
      };
    } catch (e) {
      print('Error fetching request data: $e');
      return {
        'studentName': 'Student',
        'studentEmail': '',
        'company': 'Unknown Company',
        'role': '',
      };
    }
  }

  // ================= VIEW INTERNSHIP =================

  Future<void> _openInternship(BuildContext context, String internshipId) async {
    try {
      final snap = await FirebaseFirestore.instance
          .collection('internships')
          .doc(internshipId)
          .get();

      if (!snap.exists) return;

      final internship = Internship.fromFirestore(snap);

      Navigator.push(
        context,
        MaterialPageRoute(
          builder: (_) => MentorInternshipDetailScreen(internship: internship),
        ),
      );
    } catch (e) {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: const Text("Unable to load internship"),
          backgroundColor: AppColors.bluePrimary,
        ),
      );
    }
  }

  // ================= BLUE SUCCESS POPUP =================

  void _showSuccess(BuildContext context) {
    showDialog(
      context: context,
      builder: (_) => AlertDialog(
        backgroundColor: AppColors.bluePrimary,
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(16)),
        content: Column(
          mainAxisSize: MainAxisSize.min,
          children: const [
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

    Future.delayed(const Duration(seconds: 2), () {
      Navigator.pop(context);
    });
  }

  // ================= FEEDBACK DIALOG =================

  void _openFeedbackDialog(
    BuildContext context,
    FeedbackCycle cycle,
    Map<String, dynamic> requestData,
    bool isDark,
  ) {
    final studentName = requestData['studentName'];
    final company = requestData['company'];

    showDialog(
      context: context,
      builder: (_) => AlertDialog(
        backgroundColor: isDark
            ? AppColors.darkGray
            : AppColors.pureWhite,
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(20)),
        title: Text(
          "$studentName requested feedback",
          style: TextStyle(
            fontSize: 20,
            fontWeight: FontWeight.w700,
            color: isDark ? AppColors.pureWhite : AppColors.pureBlack,
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
                      company,
                      style: TextStyle(
                        fontSize: 16,
                        fontWeight: FontWeight.w600,
                        color: isDark ? AppColors.pureWhite : AppColors.pureBlack,
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
                  cycle.studentRequest,
                  style: TextStyle(
                    fontSize: 14,
                    color: isDark ? AppColors.pureWhite : AppColors.pureBlack,
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
                  color: isDark ? AppColors.pureWhite : AppColors.pureBlack,
                ),
                decoration: InputDecoration(
                  hintText: "Share your detailed feedback...",
                  hintStyle: TextStyle(color: AppColors.mediumGray),
                  filled: true,
                  fillColor: isDark
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
                  color: isDark ? AppColors.pureWhite : AppColors.pureBlack,
                ),
                decoration: InputDecoration(
                  hintText: "Suggest an action item...",
                  hintStyle: TextStyle(color: AppColors.mediumGray),
                  filled: true,
                  fillColor: isDark
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
                  const SnackBar(content: Text("Feedback cannot be empty")),
                );
                return;
              }

              try {
                // Submit feedback
                await context.read<MentorProvider>().submitFeedback(
                      cycleId: cycle.id,
                      feedback: _feedbackCtrl.text.trim(),
                      nextStep: _nextStepCtrl.text.trim().isNotEmpty
                          ? _nextStepCtrl.text.trim()
                          : null,
                    );

                _feedbackCtrl.clear();
                _nextStepCtrl.clear();
                Navigator.pop(context);
                Future.microtask(() => _showSuccess(context));
              } catch (e) {
                ScaffoldMessenger.of(context).showSnackBar(
                  SnackBar(
                    content: Text("Error: $e"),
                    backgroundColor: Colors.red,
                  ),
                );
              }
            },
            child: const Text("Send Feedback"),
          ),
        ],
      ),
    );
  }

  // ================= ACTION SHEET =================

  void _openActions(
    BuildContext context,
    FeedbackCycle cycle,
    Map<String, dynamic> requestData,
    bool isDark,
  ) {
    showModalBottomSheet(
      context: context,
      backgroundColor: Colors.transparent,
      builder: (_) => GlassContainer(
        isDark: isDark,
        padding: EdgeInsets.all(AppConstants.spaceL),
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            ListTile(
              leading: Icon(Icons.visibility_outlined, color: AppColors.bluePrimary),
              title: const Text("View Internship"),
              onTap: () {
                Navigator.pop(context);
                _openInternship(context, cycle.internshipId);
              },
            ),
            ListTile(
              leading: Icon(Icons.edit_outlined, color: AppColors.bluePrimary),
              title: const Text("Add Feedback"),
              onTap: () {
                Navigator.pop(context);
                _openFeedbackDialog(context, cycle, requestData, isDark);
              },
            ),
          ],
        ),
      ),
    );
  }

  // ================= MAIN UI =================

  @override
  Widget build(BuildContext context) {
    final isDark = Theme.of(context).brightness == Brightness.dark;

    return Scaffold(
      body: Consumer<MentorProvider>(
        builder: (context, provider, _) {
          final requests = provider.requests;

          if (requests.isEmpty) {
            return Center(
              child: Column(
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  Icon(
                    Icons.mark_chat_unread_outlined,
                    size: 80,
                    color: AppColors.mediumGray.withOpacity(0.5),
                  ),
                  SizedBox(height: 16),
                  Text(
                    "No feedback requests",
                    style: TextStyle(
                      fontSize: 20,
                      fontWeight: FontWeight.w600,
                      color: isDark ? AppColors.pureWhite : AppColors.pureBlack,
                    ),
                  ),
                  SizedBox(height: 8),
                  Text(
                    "Requests from your students will appear here",
                    style: TextStyle(
                      fontSize: 14,
                      color: AppColors.mediumGray,
                    ),
                  ),
                ],
              ),
            );
          }

          return ListView.builder(
            padding: EdgeInsets.all(AppConstants.spaceL),
            itemCount: requests.length,
            itemBuilder: (context, index) {
              final cycle = requests[index];

              return FutureBuilder<Map<String, dynamic>>(
                future: _fetchRequestData(cycle),
                builder: (context, snapshot) {
                  if (!snapshot.hasData) {
                    return Padding(
                      padding: EdgeInsets.only(bottom: AppConstants.spaceM),
                      child: GlassContainer(
                        isDark: isDark,
                        padding: EdgeInsets.all(AppConstants.spaceM),
                        child: Center(child: CircularProgressIndicator()),
                      ),
                    );
                  }

                  final requestData = snapshot.data!;
                  final studentName = requestData['studentName'];
                  final company = requestData['company'];

                  return Padding(
                    padding: EdgeInsets.only(bottom: AppConstants.spaceM),
                    child: GestureDetector(
                      onTap: () => _openActions(context, cycle, requestData, isDark),
                      child: GlassContainer(
                        isDark: isDark,
                        padding: EdgeInsets.all(AppConstants.spaceM),
                        child: Row(
                          children: [
                            // Avatar
                            Container(
                              width: 50,
                              height: 50,
                              decoration: BoxDecoration(
                                gradient: LinearGradient(
                                  colors: [AppColors.bluePrimary, AppColors.blueLight],
                                ),
                                borderRadius: BorderRadius.circular(12),
                              ),
                              child: Center(
                                child: Text(
                                  studentName.isNotEmpty ? studentName[0].toUpperCase() : "?",
                                  style: const TextStyle(
                                    color: Colors.white,
                                    fontSize: 22,
                                    fontWeight: FontWeight.bold,
                                  ),
                                ),
                              ),
                            ),
                            const SizedBox(width: 12),
                            
                            // Info
                            Expanded(
                              child: Column(
                                crossAxisAlignment: CrossAxisAlignment.start,
                                children: [
                                  Text(
                                    studentName,
                                    style: TextStyle(
                                      fontSize: 17,
                                      fontWeight: FontWeight.w600,
                                      color: isDark ? AppColors.pureWhite : AppColors.pureBlack,
                                    ),
                                  ),
                                  SizedBox(height: 4),
                                  Row(
                                    children: [
                                      Icon(
                                        Icons.business,
                                        size: 14,
                                        color: AppColors.mediumGray,
                                      ),
                                      SizedBox(width: 4),
                                      Expanded(
                                        child: Text(
                                          company,
                                          style: TextStyle(
                                            fontSize: 15,
                                            color: AppColors.mediumGray,
                                          ),
                                        ),
                                      ),
                                    ],
                                  ),
                                  SizedBox(height: 4),
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
                            
                            const Icon(Icons.more_horiz, color: AppColors.bluePrimary),
                          ],
                        ),
                      ),
                    ),
                  );
                },
              );
            },
          );
        },
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