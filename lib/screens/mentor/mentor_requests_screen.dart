import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:cloud_firestore/cloud_firestore.dart';

import '../../providers/mentor_provider.dart';
import '../../core/widgets/glass_container.dart';
import '../../core/constants/colors.dart';
import '../../core/constants/app_constants.dart';
import '../../models/internship_model.dart';
import 'mentor_internship_detail_screen.dart';

class MentorRequestsScreen extends StatelessWidget {
  MentorRequestsScreen({super.key});

  final TextEditingController _feedbackCtrl = TextEditingController();

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

  void _openFeedbackDialog(BuildContext context, req, bool isDark) {
    showDialog(
      context: context,
      builder: (_) => AlertDialog(
        title: Text(
          "${req.studentName} requested feedback",
          style: const TextStyle(fontSize: 20, fontWeight: FontWeight.w700),
        ),
        content: SingleChildScrollView(
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text(
                "Company: ${req.company}",
                style: const TextStyle(fontSize: 16, fontWeight: FontWeight.w500),
              ),
              const SizedBox(height: 12),
              const Text(
                "Student message",
                style: TextStyle(fontSize: 16, fontWeight: FontWeight.w600),
              ),
              const SizedBox(height: 6),
              Text(req.message, style: const TextStyle(fontSize: 16)),
              const SizedBox(height: 20),
              TextField(
                controller: _feedbackCtrl,
                maxLines: 4,
                decoration: InputDecoration(
                  hintText: "Write mentor feedback...",
                  filled: true,
                  fillColor: isDark
                      ? Colors.white.withOpacity(.05)
                      : Colors.black.withOpacity(.05),
                  border: OutlineInputBorder(
                    borderRadius: BorderRadius.circular(12),
                    borderSide: BorderSide.none,
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
              Navigator.pop(context);
            },
            child: Text("Cancel", style: TextStyle(color: AppColors.mediumGray)),
          ),
          ElevatedButton(
            style: ElevatedButton.styleFrom(
              backgroundColor: AppColors.bluePrimary,
              foregroundColor: Colors.white,
            ),
            onPressed: () async {
                 if (_feedbackCtrl.text.trim().isEmpty) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text("Feedback cannot be empty")),
      );
      return;
    }
              await FirebaseFirestore.instance
                  .collection('feedbackRequests')
                  .doc(req.id)
                  .update({
                'mentorFeedback': _feedbackCtrl.text.trim(),
                'status': 'completed',
                'reviewedAt': Timestamp.now(),
                'seenByStudent': false, 
              });

              _feedbackCtrl.clear();
              Navigator.pop(context);
             Future.microtask(() => _showSuccess(context));
            },
            child: const Text("Send Feedback"),
          ),
        ],
      ),
    );
  }

  // ================= ACTION SHEET =================

  void _openActions(BuildContext context, req, bool isDark) {
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
              leading:
                  Icon(Icons.visibility_outlined, color: AppColors.bluePrimary),
              title: const Text("View Internship"),
              onTap: () {
                Navigator.pop(context);
                _openInternship(context, req.internshipId);
              },
            ),
            ListTile(
              leading: Icon(Icons.edit_outlined, color: AppColors.bluePrimary),
              title: const Text("Add Review"),
              onTap: () {
                Navigator.pop(context);
                _openFeedbackDialog(context, req, isDark);
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
                children: const [
                  Icon(Icons.mark_chat_unread_outlined,
                      size: 80, color: Colors.grey),
                  SizedBox(height: 16),
                  Text(
                    "No feedback requests",
                    style: TextStyle(fontSize: 18, fontWeight: FontWeight.w500),
                  ),
                ],
              ),
            );
          }

          return ListView.builder(
            padding: EdgeInsets.all(AppConstants.spaceL),
            itemCount: requests.length,
            itemBuilder: (context, index) {
              final req = requests[index];

              return Padding(
                padding: EdgeInsets.only(bottom: AppConstants.spaceM),
                child: GestureDetector(
                  onTap: () => _openActions(context, req, isDark),
                  child: GlassContainer(
                    isDark: isDark,
                    padding: EdgeInsets.all(AppConstants.spaceM),
                    child: Row(
                      children: [
                        Container(
                          width: 50,
                          height: 50,
                          decoration: BoxDecoration(
                            gradient: LinearGradient(
                              colors: [
                                AppColors.bluePrimary,
                                AppColors.blueLight
                              ],
                            ),
                            borderRadius: BorderRadius.circular(12),
                          ),
                          child: Center(
                            child: Text(
                              req.studentName.isNotEmpty
                                  ? req.studentName[0].toUpperCase()
                                  : "?",
                              style: const TextStyle(
                                color: Colors.white,
                                fontSize: 22,
                                fontWeight: FontWeight.bold,
                              ),
                            ),
                          ),
                        ),
                        const SizedBox(width: 12),
                        Expanded(
                          child: Column(
                            crossAxisAlignment: CrossAxisAlignment.start,
                            children: [
                              Text(
                                req.studentName,
                                style: const TextStyle(
                                  fontSize: 17,
                                  fontWeight: FontWeight.w600,
                                ),
                              ),
                              const SizedBox(height: 4),
                              Text(
                                "Company: ${req.company}",
                                style: TextStyle(
                                  fontSize: 15,
                                  color: AppColors.mediumGray,
                                ),
                              ),
                            ],
                          ),
                        ),
                        const Icon(Icons.more_horiz),
                      ],
                    ),
                  ),
                ),
              );
            },
          );
        },
      ),
    );
  }
}
