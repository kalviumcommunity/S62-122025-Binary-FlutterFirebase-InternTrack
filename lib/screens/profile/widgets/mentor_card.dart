// lib/core/widgets/mentor_card.dart
import 'package:flutter/material.dart';
import '../../../core/constants/colors.dart';
import '../../../core/constants/app_constants.dart';
import '../../../core/widgets/glass_container.dart';

class MentorCard extends StatelessWidget {
  final String name;
  final String email;
  final String? role; // 'primary' or 'secondary'
  final String? scope;
  final bool isDark;
  final VoidCallback? onTap;

  const MentorCard({
    Key? key,
    required this.name,
    required this.email,
    this.role,
    this.scope,
    required this.isDark,
    this.onTap,
  }) : super(key: key);

  @override
  Widget build(BuildContext context) {
    final isPrimary = role == 'primary';
    
    return GestureDetector(
      onTap: onTap,
      child: GlassContainer(
        isDark: isDark,
        padding: EdgeInsets.all(AppConstants.spaceM),
        child: Row(
          children: [
            Container(
              width: 50,
              height: 50,
              decoration: BoxDecoration(
                gradient: isPrimary
                    ? LinearGradient(
                        colors: [AppColors.purplePrimary, AppColors.purpleLight],
                      )
                    : null,
                color: isPrimary ? null : AppColors.purplePrimary.withOpacity(0.2),
                borderRadius: BorderRadius.circular(12),
              ),
              child: Center(
                child: Text(
                  name.substring(0, 1).toUpperCase(),
                  style: TextStyle(
                    fontSize: 20,
                    fontWeight: FontWeight.w700,
                    color: isPrimary ? Colors.white : AppColors.purplePrimary,
                  ),
                ),
              ),
            ),
            SizedBox(width: AppConstants.spaceM),
            Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Row(
                    children: [
                      Expanded(
                        child: Text(
                          name,
                          style: TextStyle(
                            fontSize: 16,
                            fontWeight: FontWeight.w600,
                            color: isDark ? AppColors.pureWhite : AppColors.pureBlack,
                          ),
                        ),
                      ),
                      if (isPrimary)
                        Container(
                          padding: EdgeInsets.symmetric(horizontal: 8, vertical: 4),
                          decoration: BoxDecoration(
                            gradient: LinearGradient(
                              colors: [AppColors.purplePrimary, AppColors.purpleLight],
                            ),
                            borderRadius: BorderRadius.circular(6),
                          ),
                          child: Text(
                            'PRIMARY',
                            style: TextStyle(
                              fontSize: 10,
                              fontWeight: FontWeight.w700,
                              color: Colors.white,
                              letterSpacing: 0.5,
                            ),
                          ),
                        ),
                    ],
                  ),
                  SizedBox(height: 4),
                  Text(
                    email,
                    style: TextStyle(
                      fontSize: 13,
                      color: AppColors.mediumGray,
                    ),
                  ),
                  if (scope != null && scope != 'general') ...[
                    SizedBox(height: 4),
                    Text(
                      scope!,
                      style: TextStyle(
                        fontSize: 12,
                        color: AppColors.purplePrimary,
                        fontWeight: FontWeight.w500,
                      ),
                    ),
                  ],
                ],
              ),
            ),
            if (onTap != null)
              Icon(
                Icons.arrow_forward_ios_rounded,
                size: 16,
                color: AppColors.mediumGray,
              ),
          ],
        ),
      ),
    );
  }
}

class InviteStatusCard extends StatelessWidget {
  final String mentorEmail;
  final String status; // 'pending', 'accepted', 'declined', 'expired'
  final DateTime createdAt;
  final bool isDark;
  final VoidCallback? onCancel;

  const InviteStatusCard({
    Key? key,
    required this.mentorEmail,
    required this.status,
    required this.createdAt,
    required this.isDark,
    this.onCancel,
  }) : super(key: key);

  @override
  Widget build(BuildContext context) {
    final statusConfig = _getStatusConfig(status);
    
    return GlassContainer(
      isDark: isDark,
      padding: EdgeInsets.all(AppConstants.spaceM),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            children: [
              Container(
                padding: EdgeInsets.all(8),
                decoration: BoxDecoration(
                  color: statusConfig['color'].withOpacity(0.2),
                  borderRadius: BorderRadius.circular(8),
                ),
                child: Icon(
                  statusConfig['icon'],
                  size: 18,
                  color: statusConfig['color'],
                ),
              ),
              SizedBox(width: AppConstants.spaceM),
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      mentorEmail,
                      style: TextStyle(
                        fontSize: 15,
                        fontWeight: FontWeight.w600,
                        color: isDark ? AppColors.pureWhite : AppColors.pureBlack,
                      ),
                    ),
                    SizedBox(height: 4),
                    Row(
                      children: [
                        Text(
                          statusConfig['label'],
                          style: TextStyle(
                            fontSize: 12,
                            fontWeight: FontWeight.w600,
                            color: statusConfig['color'],
                          ),
                        ),
                        SizedBox(width: 8),
                        Text(
                          '• ${_formatDate(createdAt)}',
                          style: TextStyle(
                            fontSize: 12,
                            color: AppColors.mediumGray,
                          ),
                        ),
                      ],
                    ),
                  ],
                ),
              ),
            ],
          ),
          if (status == 'pending' && onCancel != null) ...[
            SizedBox(height: AppConstants.spaceM),
            SizedBox(
              width: double.infinity,
              child: OutlinedButton(
                onPressed: onCancel,
                style: OutlinedButton.styleFrom(
                  foregroundColor: Colors.red,
                  side: BorderSide(color: Colors.red),
                  padding: EdgeInsets.symmetric(vertical: 10),
                  shape: RoundedRectangleBorder(
                    borderRadius: BorderRadius.circular(10),
                  ),
                ),
                child: Text('Cancel Invite', style: TextStyle(fontSize: 13)),
              ),
            ),
          ],
        ],
      ),
    );
  }

  Map<String, dynamic> _getStatusConfig(String status) {
    switch (status) {
      case 'pending':
        return {
          'label': 'Pending',
          'color': Colors.orange,
          'icon': Icons.access_time_rounded,
        };
      case 'accepted':
        return {
          'label': 'Accepted',
          'color': Colors.green,
          'icon': Icons.check_circle_outline,
        };
      case 'declined':
        return {
          'label': 'Declined',
          'color': Colors.red,
          'icon': Icons.cancel_outlined,
        };
      case 'expired':
        return {
          'label': 'Expired',
          'color': Colors.grey,
          'icon': Icons.warning_amber_rounded,
        };
      default:
        return {
          'label': 'Unknown',
          'color': AppColors.mediumGray,
          'icon': Icons.help_outline,
        };
    }
  }

  String _formatDate(DateTime date) {
    final now = DateTime.now();
    final diff = now.difference(date);
    
    if (diff.inDays == 0) {
      return 'Today';
    } else if (diff.inDays == 1) {
      return 'Yesterday';
    } else if (diff.inDays < 7) {
      return '${diff.inDays}d ago';
    } else {
      return '${date.day}/${date.month}/${date.year}';
    }
  }
}