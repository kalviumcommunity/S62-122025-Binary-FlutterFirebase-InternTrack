import 'package:flutter/material.dart';
import '../core/constants/app_constants.dart';
import '../core/theme/app_theme.dart';

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
          colors: [AppTheme.purplePrimary, AppTheme.purpleLight],
        ),
        borderRadius: BorderRadius.circular(AppConstants.radiusMedium),
        boxShadow: [
          BoxShadow(
            color: AppTheme.purplePrimary.withOpacity(0.5),
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
            AppConstants.appName,
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