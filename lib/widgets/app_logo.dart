import 'package:flutter/material.dart';
import '../core/constants/app_constants.dart';

class AppLogo extends StatelessWidget {
  final bool isDark;

  const AppLogo({
    Key? key,
    required this.isDark,
  }) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: EdgeInsets.symmetric(horizontal: 16, vertical: 8),
      decoration: BoxDecoration(
        gradient: LinearGradient(
          colors: isDark
              ? [Color(0xFF6B4FBB), Color(0xFF4A90E2)]
              : [Color(0xFF4A90E2), Color(0xFF6B4FBB)],
        ),
        borderRadius: BorderRadius.circular(AppConstants.borderRadiusSmall),
        boxShadow: [
          BoxShadow(
            color: (isDark ? Color(0xFF6B4FBB) : Color(0xFF4A90E2))
                .withOpacity(0.3),
            blurRadius: 15,
            offset: Offset(0, 5),
          ),
        ],
      ),
      child: Text(
        AppConstants.appName,
        style: TextStyle(
          fontSize: 18,
          fontWeight: FontWeight.w900,
          color: Colors.white,
          letterSpacing: 0.5,
        ),
      ),
    );
  }
}