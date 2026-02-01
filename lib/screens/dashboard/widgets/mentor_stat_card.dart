// lib/core/widgets/mentor_stat_card.dart
import 'package:flutter/material.dart';
import '../../../core/constants/colors.dart';
import '../../../core/constants/app_constants.dart';
import '../../../core/widgets/glass_container.dart';

class MentorStatCard extends StatelessWidget {
  final String title;
  final String value;
  final IconData icon;
  final bool isDark;
  final VoidCallback? onTap;

  const MentorStatCard({
    Key? key,
    required this.title,
    required this.value,
    required this.icon,
    required this.isDark,
    this.onTap,
  }) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return GestureDetector(
      onTap: onTap,
      child: GlassContainer(
        isDark: isDark,
        borderRadius: AppConstants.radiusMedium,
        padding: EdgeInsets.all(AppConstants.spaceM),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Container(
              padding: EdgeInsets.all(8),
              decoration: BoxDecoration(
                gradient: LinearGradient(
                  colors: [AppColors.bluePrimary, AppColors.blueLight],
                ),
                borderRadius: BorderRadius.circular(12),
              ),
              child: Icon(icon, color: Colors.white, size: 20),
            ),
            SizedBox(height: AppConstants.spaceM),
            Text(
              value,
              style: TextStyle(
                fontSize: 28,
                fontWeight: FontWeight.w700,
                color: isDark ? AppColors.pureWhite : AppColors.pureBlack,
              ),
            ),
            SizedBox(height: 4),
            Text(
              title,
              style: TextStyle(
                fontSize: 13,
                color: AppColors.mediumGray,
              ),
            ),
          ],
        ),
      ),
    );
  }
}