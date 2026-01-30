import 'package:flutter/material.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:provider/provider.dart';
import 'package:file_picker/file_picker.dart';
import 'package:url_launcher/url_launcher.dart';
import 'package:flutter/services.dart';
import 'dart:io';
import '../../core/constants/colors.dart';
import '../../core/constants/app_constants.dart';
import '../../core/widgets/glass_container.dart';
import '../../core/widgets/gradient_orb.dart';
import '../../core/widgets/purple_button.dart';
import '../../providers/resume_provider.dart';

class ResumeUploadScreen extends StatelessWidget {
  final FirebaseAuth _auth = FirebaseAuth.instance;

  @override
  Widget build(BuildContext context) {
    final isDark = Theme.of(context).brightness == Brightness.dark;
    final user = _auth.currentUser;

    if (user == null) {
      return Scaffold(
        body: Center(child: Text('Please log in')),
      );
    }

    return ChangeNotifierProvider(
      create: (_) => ResumeProvider()..initializeResumeStream(user.uid),
      child: Scaffold(
        body: Stack(
          children: [
            GradientOrb(
              size: 300,
              alignment: Alignment.topRight,
              colors: [AppColors.purplePrimary, AppColors.purpleLight],
              opacity: 0.15,
            ),
            SafeArea(
              child: Consumer<ResumeProvider>(
                builder: (context, resumeProvider, child) {
                  return CustomScrollView(
                    slivers: [
                      SliverToBoxAdapter(
                        child: Padding(
                          padding: EdgeInsets.all(AppConstants.spaceL),
                          child: Column(
                            crossAxisAlignment: CrossAxisAlignment.start,
                            children: [
                              // Header
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
                                  Text(
                                    'Resume',
                                    style: Theme.of(context)
                                        .textTheme
                                        .displayMedium
                                        ?.copyWith(fontSize: 28),
                                  ),
                                ],
                              ),

                              SizedBox(height: AppConstants.spaceXL),

                              // Error message
                              if (resumeProvider.error != null) ...[
                                GlassContainer(
                                  isDark: isDark,
                                  padding: EdgeInsets.all(AppConstants.spaceM),
                                  child: Row(
                                    children: [
                                      Icon(Icons.error_outline,
                                          color: Colors.red, size: 20),
                                      SizedBox(width: AppConstants.spaceM),
                                      Expanded(
                                        child: Text(
                                          resumeProvider.error!,
                                          style: TextStyle(
                                            fontSize: 14,
                                            color: Colors.red,
                                          ),
                                        ),
                                      ),
                                      IconButton(
                                        onPressed: () =>
                                            resumeProvider.clearError(),
                                        icon: Icon(Icons.close, size: 18),
                                        color: Colors.red,
                                      ),
                                    ],
                                  ),
                                ),
                                SizedBox(height: AppConstants.spaceL),
                              ],

                              // Current Resume Section
                              if (resumeProvider.resumeUrl != null) ...[
                                _buildCurrentResumeSection(
                                  context,
                                  resumeProvider,
                                  isDark,
                                  user.uid,
                                ),
                                SizedBox(height: AppConstants.spaceXL),
                              ],

                              // Upload Section
                              if (resumeProvider.isUploading)
                                _buildUploadingSection(
                                    context, resumeProvider, isDark)
                              else
                                _buildUploadButton(
                                    context, resumeProvider, isDark, user.uid),

                              SizedBox(height: AppConstants.spaceXL),

                              // Info Section
                              _buildInfoSection(isDark),
                            ],
                          ),
                        ),
                      ),
                    ],
                  );
                },
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildCurrentResumeSection(
    BuildContext context,
    ResumeProvider provider,
    bool isDark,
    String userId,
  ) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(
          'Current Resume',
          style: TextStyle(
            fontSize: 20,
            fontWeight: FontWeight.w600,
            color: isDark ? AppColors.pureWhite : AppColors.pureBlack,
          ),
        ),
        SizedBox(height: AppConstants.spaceM),
        GlassContainer(
          isDark: isDark,
          padding: EdgeInsets.all(AppConstants.spaceL),
          child: Column(
            children: [
              Row(
                children: [
                  Container(
                    padding: EdgeInsets.all(12),
                    decoration: BoxDecoration(
                      gradient: LinearGradient(
                        colors: [AppColors.purplePrimary, AppColors.purpleLight],
                      ),
                      borderRadius: BorderRadius.circular(12),
                    ),
                    child: Icon(
                      Icons.description_rounded,
                      color: Colors.white,
                      size: 28,
                    ),
                  ),
                  SizedBox(width: AppConstants.spaceM),
                  Expanded(
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Text(
                          provider.getFileNameFromUrl(provider.resumeUrl!),
                          style: TextStyle(
                            fontSize: 16,
                            fontWeight: FontWeight.w600,
                            color:
                                isDark ? AppColors.pureWhite : AppColors.pureBlack,
                          ),
                          maxLines: 1,
                          overflow: TextOverflow.ellipsis,
                        ),
                        SizedBox(height: 4),
                        Text(
                          'PDF Document',
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
              SizedBox(height: AppConstants.spaceL),
              Row(
                children: [
                  Expanded(
                    child: OutlinedButton.icon(
                      onPressed: () => _viewResume(context, provider.resumeUrl!),
                      icon: Icon(Icons.visibility_outlined, size: 18),
                      label: Text('View'),
                      style: OutlinedButton.styleFrom(
                        foregroundColor: AppColors.purplePrimary,
                        side: BorderSide(color: AppColors.purplePrimary),
                        padding: EdgeInsets.symmetric(vertical: 12),
                        shape: RoundedRectangleBorder(
                          borderRadius: BorderRadius.circular(12),
                        ),
                      ),
                    ),
                  ),
                  SizedBox(width: AppConstants.spaceM),
                  Expanded(
                    child: OutlinedButton.icon(
                      onPressed: () => _copyLink(context, provider.resumeUrl!),
                      icon: Icon(Icons.link, size: 18),
                      label: Text('Copy Link'),
                      style: OutlinedButton.styleFrom(
                        foregroundColor: AppColors.purplePrimary,
                        side: BorderSide(color: AppColors.purplePrimary),
                        padding: EdgeInsets.symmetric(vertical: 12),
                        shape: RoundedRectangleBorder(
                          borderRadius: BorderRadius.circular(12),
                        ),
                      ),
                    ),
                  ),
                ],
              ),
              SizedBox(height: AppConstants.spaceM),
              SizedBox(
                width: double.infinity,
                child: OutlinedButton.icon(
                  onPressed: () => _confirmDelete(context, provider, userId),
                  icon: Icon(Icons.delete_outline, size: 18),
                  label: Text('Delete Resume'),
                  style: OutlinedButton.styleFrom(
                    foregroundColor: Colors.red,
                    side: BorderSide(color: Colors.red),
                    padding: EdgeInsets.symmetric(vertical: 12),
                    shape: RoundedRectangleBorder(
                      borderRadius: BorderRadius.circular(12),
                    ),
                  ),
                ),
              ),
            ],
          ),
        ),
      ],
    );
  }

  Future<void> _confirmDelete(
    BuildContext context,
    ResumeProvider provider,
    String userId,
  ) async {
    final confirmed = await showDialog<bool>(
      context: context,
      builder: (context) => AlertDialog(
        title: Text('Delete Resume'),
        content: Text('Are you sure you want to delete your resume?'),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(context, false),
            child: Text('Cancel'),
          ),
          TextButton(
            onPressed: () => Navigator.pop(context, true),
            child: Text('Delete', style: TextStyle(color: Colors.red)),
          ),
        ],
      ),
    );

    if (confirmed == true) {
      final success = await provider.deleteResume(userId);
      if (success && context.mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text('Resume deleted successfully'),
            backgroundColor: Colors.green,
          ),
        );
      }
    }
  }

  Future<void> _viewResume(BuildContext context, String url) async {
    try {
      print('🔍 Attempting to open: $url');
      final uri = Uri.parse(url);
      
      // Try external application first (Chrome, Drive, etc.)
      bool launched = await launchUrl(
        uri,
        mode: LaunchMode.externalApplication,
      );
      
      if (launched) {
        print('✅ Opened successfully');
        return;
      }
      
      // If external app didn't work, show helpful message
      if (context.mounted) {
        showDialog(
          context: context,
          builder: (context) => AlertDialog(
            title: Row(
              children: [
                Icon(Icons.info_outline, color: AppColors.purplePrimary),
                SizedBox(width: 8),
                Text('Open Resume'),
              ],
            ),
            content: Column(
              mainAxisSize: MainAxisSize.min,
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  'To view your resume:',
                  style: TextStyle(fontWeight: FontWeight.w600),
                ),
                SizedBox(height: 12),
                Text('1. Copy the link below'),
                Text('2. Paste it in Chrome or any browser'),
                Text('3. The PDF will open automatically'),
                SizedBox(height: 16),
                Container(
                  padding: EdgeInsets.all(12),
                  decoration: BoxDecoration(
                    color: Colors.grey[200],
                    borderRadius: BorderRadius.circular(8),
                  ),
                  child: SelectableText(
                    url,
                    style: TextStyle(fontSize: 11, color: Colors.blue),
                  ),
                ),
              ],
            ),
            actions: [
              TextButton(
                onPressed: () async {
                  await Clipboard.setData(ClipboardData(text: url));
                  Navigator.pop(context);
                  ScaffoldMessenger.of(context).showSnackBar(
                    SnackBar(
                      content: Text('Link copied! Now paste it in Chrome'),
                      backgroundColor: Colors.green,
                      duration: Duration(seconds: 3),
                    ),
                  );
                },
                child: Text('Copy Link'),
              ),
              TextButton(
                onPressed: () => Navigator.pop(context),
                child: Text('Close'),
              ),
            ],
          ),
        );
      }
    } catch (e) {
      print('❌ Error: $e');
      if (context.mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text('Please copy the link and open it in Chrome'),
            backgroundColor: Colors.orange,
            action: SnackBarAction(
              label: 'Copy',
              textColor: Colors.white,
              onPressed: () => _copyLink(context, url),
            ),
          ),
        );
      }
    }
  }

  Future<void> _copyLink(BuildContext context, String url) async {
    await Clipboard.setData(ClipboardData(text: url));
    if (context.mounted) {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Text('Link copied! Paste it in Chrome to open'),
          backgroundColor: Colors.green,
          duration: Duration(seconds: 3),
        ),
      );
    }
  }

  Widget _buildUploadingSection(
    BuildContext context,
    ResumeProvider provider,
    bool isDark,
  ) {
    return GlassContainer(
      isDark: isDark,
      padding: EdgeInsets.all(AppConstants.spaceL),
      child: Column(
        children: [
          Row(
            children: [
              SizedBox(
                width: 24,
                height: 24,
                child: CircularProgressIndicator(
                  strokeWidth: 2.5,
                  valueColor:
                      AlwaysStoppedAnimation<Color>(AppColors.purplePrimary),
                ),
              ),
              SizedBox(width: AppConstants.spaceM),
              Expanded(
                child: Text(
                  'Uploading resume...',
                  style: TextStyle(
                    fontSize: 16,
                    fontWeight: FontWeight.w600,
                    color: isDark ? AppColors.pureWhite : AppColors.pureBlack,
                  ),
                ),
              ),
            ],
          ),
          SizedBox(height: AppConstants.spaceL),
          LinearProgressIndicator(
            value: provider.uploadProgress,
            backgroundColor: AppColors.mediumGray.withOpacity(0.2),
            valueColor:
                AlwaysStoppedAnimation<Color>(AppColors.purplePrimary),
            minHeight: 6,
            borderRadius: BorderRadius.circular(3),
          ),
          SizedBox(height: AppConstants.spaceS),
          Text(
            '${(provider.uploadProgress * 100).toInt()}%',
            style: TextStyle(
              fontSize: 13,
              color: AppColors.mediumGray,
              fontWeight: FontWeight.w500,
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildUploadButton(
    BuildContext context,
    ResumeProvider provider,
    bool isDark,
    String userId,
  ) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(
          provider.resumeUrl != null ? 'Replace Resume' : 'Upload Resume',
          style: TextStyle(
            fontSize: 20,
            fontWeight: FontWeight.w600,
            color: isDark ? AppColors.pureWhite : AppColors.pureBlack,
          ),
        ),
        SizedBox(height: AppConstants.spaceM),
        SizedBox(
          width: double.infinity,
          child: PurpleButton(
            text: provider.resumeUrl != null
                ? 'Choose New Resume'
                : 'Choose File',
            icon: Icons.upload_file,
            onPressed: () => _pickAndUploadFile(context, provider, userId),
          ),
        ),
      ],
    );
  }

  Widget _buildInfoSection(bool isDark) {
    return GlassContainer(
      isDark: isDark,
      padding: EdgeInsets.all(AppConstants.spaceL),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            children: [
              Icon(Icons.info_outline,
                  color: AppColors.purplePrimary, size: 20),
              SizedBox(width: AppConstants.spaceM),
              Text(
                'Resume Guidelines',
                style: TextStyle(
                  fontSize: 16,
                  fontWeight: FontWeight.w600,
                  color: isDark ? AppColors.pureWhite : AppColors.pureBlack,
                ),
              ),
            ],
          ),
          SizedBox(height: AppConstants.spaceM),
          _buildInfoItem('PDF format only', isDark),
          _buildInfoItem('Maximum file size: 10MB', isDark),
          _buildInfoItem('Include your contact information', isDark),
          _buildInfoItem('Highlight relevant skills and experience', isDark),
        ],
      ),
    );
  }

  Widget _buildInfoItem(String text, bool isDark) {
    return Padding(
      padding: EdgeInsets.only(bottom: AppConstants.spaceS),
      child: Row(
        children: [
          Container(
            width: 6,
            height: 6,
            decoration: BoxDecoration(
              color: AppColors.purplePrimary,
              shape: BoxShape.circle,
            ),
          ),
          SizedBox(width: AppConstants.spaceM),
          Expanded(
            child: Text(
              text,
              style: TextStyle(
                fontSize: 14,
                color: AppColors.mediumGray,
              ),
            ),
          ),
        ],
      ),
    );
  }

  Future<void> _pickAndUploadFile(
    BuildContext context,
    ResumeProvider provider,
    String userId,
  ) async {
    try {
      final result = await FilePicker.platform.pickFiles(
        type: FileType.custom,
        allowedExtensions: ['pdf'],
      );

      if (result != null && result.files.single.path != null) {
        final file = File(result.files.single.path!);
        final success = await provider.uploadResume(file, userId);

        if (success && context.mounted) {
          ScaffoldMessenger.of(context).showSnackBar(
            SnackBar(
              content: Text('Resume uploaded successfully'),
              backgroundColor: Colors.green,
            ),
          );
        }
      }
    } catch (e) {
      if (context.mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text('Failed to pick file: ${e.toString()}'),
            backgroundColor: Colors.red,
          ),
        );
      }
    }
  }
}