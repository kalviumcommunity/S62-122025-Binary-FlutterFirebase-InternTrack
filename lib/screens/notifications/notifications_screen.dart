// lib/screens/notifications/notifications_screen.dart - COMPLETELY REWRITTEN
import 'package:flutter/material.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import '../../core/constants/colors.dart';
import '../../core/constants/app_constants.dart';
import '../../core/widgets/glass_container.dart';
import '../../core/widgets/gradient_orb.dart';
import '../../services/notification_service.dart';
import '../../models/notification_model.dart';
import '../../models/internship_model.dart';
import '../../app/app_routes.dart';

class NotificationsScreen extends StatefulWidget {
  const NotificationsScreen({Key? key}) : super(key: key);

  @override
  State<NotificationsScreen> createState() => _NotificationsScreenState();
}

class _NotificationsScreenState extends State<NotificationsScreen> {
  final NotificationService _notificationService = NotificationService();
  final FirebaseAuth _auth = FirebaseAuth.instance;

  @override
  Widget build(BuildContext context) {
    final isDark = Theme.of(context).brightness == Brightness.dark;
    final userId = _auth.currentUser?.uid;

    if (userId == null) {
      return Scaffold(
        body: Center(
          child: Text('Not logged in'),
        ),
      );
    }

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
                              'Notifications',
                              style: Theme.of(context)
                                  .textTheme
                                  .displayMedium
                                  ?.copyWith(fontSize: 24),
                            ),
                            SizedBox(height: 4),
                            Text(
                              'Mentor feedback updates',
                              style: TextStyle(
                                fontSize: 14,
                                color: AppColors.mediumGray,
                              ),
                            ),
                          ],
                        ),
                      ),
                      TextButton(
                        onPressed: () {
                          _notificationService.markAllAsSeen(userId);
                        },
                        child: Text(
                          'Mark all read',
                          style: TextStyle(
                            color: AppColors.purplePrimary,
                            fontSize: 13,
                            fontWeight: FontWeight.w600,
                          ),
                        ),
                      ),
                    ],
                  ),
                ),

                // Notifications list
                Expanded(
                  child: StreamBuilder<List<NotificationModel>>(
                    stream: _notificationService.getNotifications(userId),
                    builder: (context, snapshot) {
                    
                      
                      if (snapshot.connectionState == ConnectionState.waiting) {
                        return Center(child: CircularProgressIndicator());
                      }

                      if (snapshot.hasError) {
                        
                        return Center(
                          child: Column(
                            mainAxisAlignment: MainAxisAlignment.center,
                            children: [
                              Icon(
                                Icons.error_outline,
                                size: 80,
                                color: Colors.red.withOpacity(0.5),
                              ),
                              SizedBox(height: AppConstants.spaceL),
                              Text(
                                'Error loading notifications',
                                style: TextStyle(
                                  fontSize: 18,
                                  fontWeight: FontWeight.w600,
                                  color: isDark ? AppColors.pureWhite : AppColors.pureBlack,
                                ),
                              ),
                              SizedBox(height: AppConstants.spaceS),
                              Text(
                                snapshot.error.toString(),
                                style: TextStyle(
                                  fontSize: 14,
                                  color: AppColors.mediumGray,
                                ),
                                textAlign: TextAlign.center,
                              ),
                            ],
                          ),
                        );
                      }

                      if (!snapshot.hasData || snapshot.data!.isEmpty) {
                        return Center(
                          child: Column(
                            mainAxisAlignment: MainAxisAlignment.center,
                            children: [
                              Icon(
                                Icons.notifications_none_outlined,
                                size: 80,
                                color: AppColors.mediumGray.withOpacity(0.5),
                              ),
                              SizedBox(height: AppConstants.spaceL),
                              Text(
                                'No notifications',
                                style: TextStyle(
                                  fontSize: 20,
                                  fontWeight: FontWeight.w600,
                                  color: isDark
                                      ? AppColors.pureWhite
                                      : AppColors.pureBlack,
                                ),
                              ),
                              SizedBox(height: AppConstants.spaceS),
                              Text(
                                'Mentor feedback will appear here',
                                style: TextStyle(
                                  fontSize: 14,
                                  color: AppColors.mediumGray,
                                ),
                              ),
                            ],
                          ),
                        );
                      }

                      final notifications = snapshot.data!;
                      

                      return ListView.builder(
                        padding: EdgeInsets.symmetric(
                          horizontal: AppConstants.spaceL,
                          vertical: AppConstants.spaceS,
                        ),
                        itemCount: notifications.length,
                        itemBuilder: (context, index) {
                          final notification = notifications[index];
                          return _buildNotificationCard(notification, isDark);
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

  Widget _buildNotificationCard(
    NotificationModel notification,
    bool isDark,
  ) {
    return FutureBuilder<Map<String, String>>(
      future: _fetchNotificationData(notification),
      builder: (context, snapshot) {
        if (!snapshot.hasData) {
          return Padding(
            padding: EdgeInsets.only(bottom: AppConstants.spaceM),
            child: GlassContainer(
              isDark: isDark,
              padding: EdgeInsets.all(AppConstants.spaceM),
              child: Row(
                children: [
                  Container(
                    width: 42,
                    height: 42,
                    decoration: BoxDecoration(
                      color: AppColors.mediumGray.withOpacity(0.2),
                      borderRadius: BorderRadius.circular(12),
                    ),
                  ),
                  SizedBox(width: AppConstants.spaceM),
                  Expanded(
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Container(
                          height: 16,
                          width: double.infinity,
                          decoration: BoxDecoration(
                            color: AppColors.mediumGray.withOpacity(0.2),
                            borderRadius: BorderRadius.circular(4),
                          ),
                        ),
                        SizedBox(height: 8),
                        Container(
                          height: 12,
                          width: 100,
                          decoration: BoxDecoration(
                            color: AppColors.mediumGray.withOpacity(0.2),
                            borderRadius: BorderRadius.circular(4),
                          ),
                        ),
                      ],
                    ),
                  ),
                ],
              ),
            ),
          );
        }

        final data = snapshot.data!;
        final mentorName = data['mentorName'] ?? 'Your mentor';
        final companyName = data['companyName'] ?? 'Unknown Company';
        final isUnread = !notification.seenByStudent;

        return Padding(
          padding: EdgeInsets.only(bottom: AppConstants.spaceM),
          child: GestureDetector(
            onTap: () async {
              // Mark as seen
              if (isUnread) {
                await _notificationService.markAsSeen(notification.id);
              }

              // Get internship and navigate
              try {
                final internshipDoc = await FirebaseFirestore.instance
                    .collection('internships')
                    .doc(notification.internshipId)
                    .get();

                if (!internshipDoc.exists) {
                  if (mounted) {
                    ScaffoldMessenger.of(context).showSnackBar(
                      SnackBar(
                        content: Text('Internship not found'),
                        backgroundColor: Colors.red,
                      ),
                    );
                  }
                  return;
                }

                final internship = Internship.fromFirestore(internshipDoc);

                if (mounted) {
                  Navigator.pushNamed(
                    context,
                    AppRoutes.internshipDetail,
                    arguments: {'internship': internship},
                  );
                }
              } catch (e) {
                print('Error navigating: $e');
                if (mounted) {
                  ScaffoldMessenger.of(context).showSnackBar(
                    SnackBar(
                      content: Text('Error loading internship'),
                      backgroundColor: Colors.red,
                    ),
                  );
                }
              }
            },
            child: Container(
              decoration: BoxDecoration(
                gradient: isUnread
                    ? LinearGradient(
                        colors: [
                          AppColors.purplePrimary.withOpacity(0.05),
                          AppColors.purpleLight.withOpacity(0.05),
                        ],
                      )
                    : null,
                borderRadius: BorderRadius.circular(AppConstants.radiusMedium),
              ),
              child: GlassContainer(
                isDark: isDark,
                padding: EdgeInsets.all(AppConstants.spaceM),
                child: Row(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    // Icon
                    Container(
                      padding: EdgeInsets.all(10),
                      decoration: BoxDecoration(
                        gradient: isUnread
                            ? LinearGradient(
                                colors: [
                                  AppColors.purplePrimary,
                                  AppColors.purpleLight
                                ],
                              )
                            : null,
                        color: isUnread
                            ? null
                            : AppColors.mediumGray.withOpacity(0.2),
                        borderRadius: BorderRadius.circular(12),
                      ),
                      child: Icon(
                        Icons.feedback_outlined,
                        color: isUnread ? Colors.white : AppColors.mediumGray,
                        size: 20,
                      ),
                    ),

                    SizedBox(width: AppConstants.spaceM),

                    // Content
                    Expanded(
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Row(
                            children: [
                              Expanded(
                                child: RichText(
                                  text: TextSpan(
                                    style: TextStyle(
                                      fontSize: 15,
                                      fontWeight: isUnread
                                          ? FontWeight.w600
                                          : FontWeight.w500,
                                      color: isDark
                                          ? AppColors.pureWhite
                                          : AppColors.pureBlack,
                                      height: 1.3,
                                    ),
                                    children: [
                                      TextSpan(
                                        text: mentorName,
                                        style: TextStyle(
                                          fontWeight: FontWeight.w700,
                                          color: AppColors.purplePrimary,
                                        ),
                                      ),
                                      TextSpan(text: ' has reviewed your '),
                                      TextSpan(
                                        text: companyName,
                                        style: TextStyle(
                                          fontWeight: FontWeight.w700,
                                        ),
                                      ),
                                      TextSpan(text: ' application'),
                                    ],
                                  ),
                                ),
                              ),
                              if (isUnread) ...[
                                SizedBox(width: 8),
                                Container(
                                  width: 8,
                                  height: 8,
                                  decoration: BoxDecoration(
                                    color: AppColors.purplePrimary,
                                    shape: BoxShape.circle,
                                  ),
                                ),
                              ],
                            ],
                          ),
                          SizedBox(height: 6),
                          Text(
                            _formatDate(notification.respondedAt),
                            style: TextStyle(
                              fontSize: 12,
                              color: AppColors.mediumGray,
                            ),
                          ),
                        ],
                      ),
                    ),

                    // Arrow
                    Icon(
                      Icons.arrow_forward_ios_rounded,
                      size: 16,
                      color: AppColors.mediumGray,
                    ),
                  ],
                ),
              ),
            ),
          ),
        );
      },
    );
  }

  Future<Map<String, String>> _fetchNotificationData(
      NotificationModel notification) async {
    final mentorName =
        await _notificationService.getMentorName(notification.mentorId);
    final companyName =
        await _notificationService.getCompanyName(notification.internshipId);

    return {
      'mentorName': mentorName,
      'companyName': companyName,
    };
  }

  String _formatDate(DateTime date) {
    final now = DateTime.now();
    final diff = now.difference(date);

    if (diff.inDays == 0) {
      if (diff.inHours == 0) {
        if (diff.inMinutes == 0) {
          return 'Just now';
        }
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