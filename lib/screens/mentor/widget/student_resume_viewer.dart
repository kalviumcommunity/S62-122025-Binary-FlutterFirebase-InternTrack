// lib/screens/mentor/widget/student_resume_viewer.dart
import 'package:flutter/material.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:url_launcher/url_launcher.dart';
import '../../../core/constants/colors.dart';
import '../../../core/constants/app_constants.dart';
import '../../../core/widgets/glass_container.dart';

class StudentResumeViewer extends StatelessWidget {
  final String studentId;
  final bool isDark;

  const StudentResumeViewer({
    Key? key,
    required this.studentId,
    required this.isDark,
  }) : super(key: key);

  Future<Map<String, dynamic>?> _getResumeData() async {
    try {
      final doc = await FirebaseFirestore.instance
          .collection('users')
          .doc(studentId)
          .get();

      if (!doc.exists) return null;

      final data = doc.data();
      final resumeUrl = data?['resumeUrl'] as String?;
      final resumeFileName = data?['resumeFileName'] as String?;
      final resumeUpdatedAt = data?['resumeUpdatedAt'] as Timestamp?;

      if (resumeUrl == null || resumeUrl.isEmpty) return null;

      return {
        'url': resumeUrl,
        'fileName': resumeFileName ?? 'resume.pdf',
        'updatedAt': resumeUpdatedAt?.toDate(),
      };
    } catch (e) {
      print('Error fetching resume: $e');
      return null;
    }
  }

  String _formatDate(DateTime? date) {
    if (date == null) return 'Unknown';
    
    final now = DateTime.now();
    final diff = now.difference(date);

    if (diff.inDays == 0) {
      if (diff.inHours == 0) {
        return 'Updated ${diff.inMinutes}m ago';
      }
      return 'Updated ${diff.inHours}h ago';
    } else if (diff.inDays == 1) {
      return 'Updated yesterday';
    } else if (diff.inDays < 7) {
      return 'Updated ${diff.inDays}d ago';
    } else {
      return 'Updated ${date.day}/${date.month}/${date.year}';
    }
  }

  Future<void> _openResume(BuildContext context, String url) async {
    try {
      final uri = Uri.parse(url);
      
      // Try to launch the URL directly
      final launched = await launchUrl(
        uri,
        mode: LaunchMode.externalApplication,
      );
      
      if (!launched) {
        if (context.mounted) {
          ScaffoldMessenger.of(context).showSnackBar(
            const SnackBar(
              content: Text('Could not open resume. Please check if you have a PDF viewer installed.'),
              backgroundColor: Colors.orange,
              duration: Duration(seconds: 4),
            ),
          );
        }
      }
    } catch (e) {
      print('Error opening resume: $e');
      if (context.mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text('Error opening resume: ${e.toString()}'),
            backgroundColor: Colors.red,
            duration: const Duration(seconds: 4),
          ),
        );
      }
    }
  }

  @override
  Widget build(BuildContext context) {
    return FutureBuilder<Map<String, dynamic>?>(
      future: _getResumeData(),
      builder: (context, snapshot) {
        if (snapshot.connectionState == ConnectionState.waiting) {
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

        if (!snapshot.hasData || snapshot.data == null) {
          return GlassContainer(
            isDark: isDark,
            padding: EdgeInsets.all(AppConstants.spaceL),
            child: Column(
              children: [
                Row(
                  children: [
                    Icon(
                      Icons.description_outlined,
                      color: AppColors.mediumGray,
                      size: 20,
                    ),
                    SizedBox(width: 8),
                    Text(
                      'Resume',
                      style: TextStyle(
                        fontSize: 16,
                        fontWeight: FontWeight.w600,
                        color: isDark ? AppColors.pureWhite : AppColors.pureBlack,
                      ),
                    ),
                  ],
                ),
                SizedBox(height: AppConstants.spaceL),
                Container(
                  padding: EdgeInsets.all(AppConstants.spaceL),
                  decoration: BoxDecoration(
                    color: AppColors.mediumGray.withOpacity(0.1),
                    borderRadius: BorderRadius.circular(12),
                    border: Border.all(
                      color: AppColors.mediumGray.withOpacity(0.2),
                    ),
                  ),
                  child: Row(
                    children: [
                      Icon(
                        Icons.info_outline,
                        color: AppColors.mediumGray,
                        size: 20,
                      ),
                      SizedBox(width: 12),
                      Expanded(
                        child: Text(
                          'Student hasn\'t uploaded a resume yet',
                          style: TextStyle(
                            fontSize: 14,
                            color: AppColors.mediumGray,
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

        final resumeData = snapshot.data!;
        final url = resumeData['url'] as String;
        final fileName = resumeData['fileName'] as String;
        final updatedAt = resumeData['updatedAt'] as DateTime?;

        return GlassContainer(
          isDark: isDark,
          padding: EdgeInsets.all(AppConstants.spaceL),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Row(
                children: [
                  Icon(
                    Icons.description_outlined,
                    color: AppColors.bluePrimary,
                    size: 20,
                  ),
                  SizedBox(width: 8),
                  Expanded(
                    child: Text(
                      'Resume',
                      style: TextStyle(
                        fontSize: 16,
                        fontWeight: FontWeight.w600,
                        color: isDark ? AppColors.pureWhite : AppColors.pureBlack,
                      ),
                    ),
                  ),
                  Container(
                    padding: EdgeInsets.symmetric(horizontal: 8, vertical: 4),
                    decoration: BoxDecoration(
                      color: Colors.green.withOpacity(0.2),
                      borderRadius: BorderRadius.circular(6),
                    ),
                    child: Row(
                      mainAxisSize: MainAxisSize.min,
                      children: [
                        Icon(Icons.check_circle, color: Colors.green, size: 12),
                        SizedBox(width: 4),
                        Text(
                          'Uploaded',
                          style: TextStyle(
                            fontSize: 10,
                            fontWeight: FontWeight.w600,
                            color: Colors.green,
                          ),
                        ),
                      ],
                    ),
                  ),
                ],
              ),
              SizedBox(height: AppConstants.spaceM),
              
              // Resume card
              GestureDetector(
                onTap: () => _openResume(context, url),
                child: Container(
                  padding: EdgeInsets.all(AppConstants.spaceM),
                  decoration: BoxDecoration(
                    gradient: LinearGradient(
                      colors: [
                        AppColors.bluePrimary.withOpacity(0.1),
                        AppColors.blueLight.withOpacity(0.1),
                      ],
                    ),
                    borderRadius: BorderRadius.circular(12),
                    border: Border.all(
                      color: AppColors.bluePrimary.withOpacity(0.3),
                    ),
                  ),
                  child: Row(
                    children: [
                      Container(
                        width: 48,
                        height: 48,
                        decoration: BoxDecoration(
                          gradient: LinearGradient(
                            colors: [AppColors.bluePrimary, AppColors.blueLight],
                          ),
                          borderRadius: BorderRadius.circular(10),
                        ),
                        child: Icon(
                          Icons.picture_as_pdf,
                          color: Colors.white,
                          size: 24,
                        ),
                      ),
                      SizedBox(width: 12),
                      Expanded(
                        child: Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            Text(
                              fileName,
                              style: TextStyle(
                                fontSize: 14,
                                fontWeight: FontWeight.w600,
                                color: isDark ? AppColors.pureWhite : AppColors.pureBlack,
                              ),
                              maxLines: 1,
                              overflow: TextOverflow.ellipsis,
                            ),
                            SizedBox(height: 4),
                            Text(
                              _formatDate(updatedAt),
                              style: TextStyle(
                                fontSize: 12,
                                color: AppColors.mediumGray,
                              ),
                            ),
                          ],
                        ),
                      ),
                      Icon(
                        Icons.open_in_new,
                        color: AppColors.bluePrimary,
                        size: 20,
                      ),
                    ],
                  ),
                ),
              ),
              
              SizedBox(height: AppConstants.spaceS),
              
              // Helper text
              Row(
                children: [
                  Icon(
                    Icons.info_outline,
                    color: AppColors.mediumGray,
                    size: 14,
                  ),
                  SizedBox(width: 6),
                  Expanded(
                    child: Text(
                      'Tap to view or download resume',
                      style: TextStyle(
                        fontSize: 12,
                        color: AppColors.mediumGray,
                      ),
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
}
