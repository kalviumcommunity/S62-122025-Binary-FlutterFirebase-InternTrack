import 'package:flutter/material.dart';

class AppTheme {
  // Pure Black & White with Purple accent
  static const Color pureBlack = Color(0xFF000000);
  static const Color pureWhite = Color(0xFFFFFFFF);
  static const Color darkGray = Color(0xFF0A0A0A);
  static const Color lightGray = Color(0xFFF8F8F8);
  static const Color mediumGray = Color(0xFF808080);
  
  // Purple accent - sophisticated and minimal
  static const Color purplePrimary = Color(0xFF8B5CF6);
  static const Color purpleLight = Color(0xFFA78BFA);
  static const Color purpleDark = Color(0xFF7C3AED);
  
  // Glass colors
  static Color glassWhite = pureWhite.withOpacity(0.1);
  static Color glassBorder = pureWhite.withOpacity(0.2);

  static ThemeData darkTheme = ThemeData(
    brightness: Brightness.dark,
    scaffoldBackgroundColor: pureBlack,
    primaryColor: pureWhite,
    fontFamily: 'SF Pro Display',
    colorScheme: ColorScheme.dark(
      primary: purplePrimary,
      secondary: purpleLight,
      surface: darkGray,
      background: pureBlack,
    ),
    textTheme: TextTheme(
      displayLarge: TextStyle(
        fontSize: 40,
        fontWeight: FontWeight.w700,
        color: pureWhite,
        letterSpacing: -1.2,
        height: 1.1,
      ),
      displayMedium: TextStyle(
        fontSize: 32,
        fontWeight: FontWeight.w700,
        color: pureWhite,
        letterSpacing: -0.8,
      ),
      headlineSmall: TextStyle(
        fontSize: 24,
        fontWeight: FontWeight.w600,
        color: pureWhite,
      ),
      bodyLarge: TextStyle(
        fontSize: 17,
        color: mediumGray,
        height: 1.5,
        letterSpacing: 0.2,
      ),
      bodyMedium: TextStyle(
        fontSize: 15,
        color: mediumGray,
      ),
    ),
  );

  static ThemeData lightTheme = ThemeData(
    brightness: Brightness.light,
    scaffoldBackgroundColor: pureWhite,
    primaryColor: pureBlack,
    fontFamily: 'SF Pro Display',
    colorScheme: ColorScheme.light(
      primary: purplePrimary,
      secondary: purpleLight,
      surface: lightGray,
      background: pureWhite,
    ),
    textTheme: TextTheme(
      displayLarge: TextStyle(
        fontSize: 40,
        fontWeight: FontWeight.w700,
        color: pureBlack,
        letterSpacing: -1.2,
        height: 1.1,
      ),
      displayMedium: TextStyle(
        fontSize: 32,
        fontWeight: FontWeight.w700,
        color: pureBlack,
        letterSpacing: -0.8,
      ),
      headlineSmall: TextStyle(
        fontSize: 24,
        fontWeight: FontWeight.w600,
        color: pureBlack,
      ),
      bodyLarge: TextStyle(
        fontSize: 17,
        color: mediumGray,
        height: 1.5,
        letterSpacing: 0.2,
      ),
      bodyMedium: TextStyle(
        fontSize: 15,
        color: mediumGray,
      ),
    ),
  );
}