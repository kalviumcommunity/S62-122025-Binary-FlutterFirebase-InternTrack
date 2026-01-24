// lib/features/dashboard/widgets/stats_card.dart
import 'package:flutter/material.dart';
import '../../../core/widgets/glass_container.dart';
import '../../../core/constants/app_constants.dart';
import '../../../core/constants/colors.dart';

class StatsCard extends StatelessWidget {
  final bool isDark;
  final IconData icon;
  final String title;
  final String value;
  final List<Color> gradient;

  const StatsCard({
    Key? key,
    required this.isDark,
    required this.icon,
    required this.title,
    required this.value,
    required this.gradient,
  }) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return GlassContainer(
      isDark: isDark,
      padding: EdgeInsets.all(AppConstants.spaceM),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        mainAxisAlignment: MainAxisAlignment.spaceBetween,
        children: [
          Container(
            padding: EdgeInsets.all(10),
            decoration: BoxDecoration(
              gradient: LinearGradient(colors: gradient),
              borderRadius: BorderRadius.circular(12),
            ),
            child: Icon(icon, color: Colors.white, size: 20),
          ),
          SizedBox(height: 4),
          Flexible(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              mainAxisSize: MainAxisSize.min,
              children: [
                FittedBox(
                  fit: BoxFit.scaleDown,
                  child: Text(
                    value,
                    style: TextStyle(
                      fontSize: 28,
                      fontWeight: FontWeight.w700,
                      color: isDark ? AppColors.pureWhite : AppColors.pureBlack,
                      letterSpacing: -0.5,
                    ),
                  ),
                ),
                SizedBox(height: 2),
                FittedBox(
                  fit: BoxFit.scaleDown,
                  child: Text(
                    title,
                    style: TextStyle(
                      fontSize: 13,
                      color: AppColors.mediumGray,
                      fontWeight: FontWeight.w600,
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