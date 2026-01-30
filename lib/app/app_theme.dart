// lib\app\app_theme.dart
import 'package:flutter/material.dart';
import '../core/constants/colors.dart';

class AppTheme {
  // Glass colors
  static Color glassWhite = AppColors.pureWhite.withOpacity(0.1);
  static Color glassBorder = AppColors.pureWhite.withOpacity(0.2);

  static ThemeData darkTheme = ThemeData(
    brightness: Brightness.dark,
    scaffoldBackgroundColor: AppColors.pureBlack,
    primaryColor: AppColors.pureWhite,
    fontFamily: 'SF Pro Display',
    colorScheme: ColorScheme.dark(
      primary: AppColors.purplePrimary,
      secondary: AppColors.purpleLight,
      surface: AppColors.darkGray,
      background: AppColors.pureBlack,
    ),
    textTheme: TextTheme(
      displayLarge: TextStyle(
        fontSize: 40,
        fontWeight: FontWeight.w700,
        color: AppColors.pureWhite,
        letterSpacing: -1.2,
        height: 1.1,
      ),
      displayMedium: TextStyle(
        fontSize: 32,
        fontWeight: FontWeight.w700,
        color: AppColors.pureWhite,
        letterSpacing: -0.8,
      ),
      headlineSmall: TextStyle(
        fontSize: 24,
        fontWeight: FontWeight.w600,
        color: AppColors.pureWhite,
      ),
      bodyLarge: TextStyle(
        fontSize: 17,
        color: AppColors.mediumGray,
        height: 1.5,
        letterSpacing: 0.2,
      ),
      bodyMedium: TextStyle(
        fontSize: 15,
        color: AppColors.mediumGray,
      ),
    ),
  );

  static ThemeData lightTheme = ThemeData(
    brightness: Brightness.light,
    scaffoldBackgroundColor: AppColors.pureWhite,
    primaryColor: AppColors.pureBlack,
    fontFamily: 'SF Pro Display',
    colorScheme: ColorScheme.light(
      primary: AppColors.purplePrimary,
      secondary: AppColors.purpleLight,
      surface: AppColors.lightGray,
      background: AppColors.pureWhite,
    ),
    textTheme: TextTheme(
      displayLarge: TextStyle(
        fontSize: 40,
        fontWeight: FontWeight.w700,
        color: AppColors.pureBlack,
        letterSpacing: -1.2,
        height: 1.1,
      ),
      displayMedium: TextStyle(
        fontSize: 32,
        fontWeight: FontWeight.w700,
        color: AppColors.pureBlack,
        letterSpacing: -0.8,
      ),
      headlineSmall: TextStyle(
        fontSize: 24,
        fontWeight: FontWeight.w600,
        color: AppColors.pureBlack,
      ),
      bodyLarge: TextStyle(
        fontSize: 17,
        color: AppColors.mediumGray,
        height: 1.5,
        letterSpacing: 0.2,
      ),
      bodyMedium: TextStyle(
        fontSize: 15,
        color: AppColors.mediumGray,
      ),
    ),
  );
}