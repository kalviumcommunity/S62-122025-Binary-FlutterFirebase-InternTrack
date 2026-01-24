// lib/core/widgets/logo_badge.dart
import 'package:flutter/material.dart';
import '../constants/app_constants.dart';
import '../constants/strings.dart';
import '../constants/colors.dart';

class LogoBadge extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    return Container(
      padding: EdgeInsets.symmetric(
        horizontal: AppConstants.spaceM,
        vertical: AppConstants.spaceS + 2,
      ),
      decoration: BoxDecoration(
        gradient: LinearGradient(
          colors: [AppColors.purplePrimary, AppColors.purpleLight],
        ),
        borderRadius: BorderRadius.circular(AppConstants.radiusMedium),
        boxShadow: [
          BoxShadow(
            color: AppColors.purplePrimary.withOpacity(0.5),
            blurRadius: 15,
            offset: Offset(0, 5),
          ),
        ],
      ),
      child: Row(
        mainAxisSize: MainAxisSize.min,
        children: [
          Icon(
            Icons.work_outline_rounded,
            color: Colors.white,
            size: AppConstants.logoIconSize,
          ),
          SizedBox(width: AppConstants.spaceS),
          Text(
            AppStrings.appName,
            style: TextStyle(
              fontSize: 18,
              fontWeight: FontWeight.w700,
              color: Colors.white,
              letterSpacing: 0.5,
            ),
          ),
        ],
      ),
    );
  }
}
