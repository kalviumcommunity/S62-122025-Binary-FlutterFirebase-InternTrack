import 'package:flutter/material.dart';

class AppTheme {
  // Enhanced Color Palette
  static const Color primaryBlack = Color(0xFF0A0A0A);
  static const Color primaryWhite = Color(0xFFFFFFFF);
  static const Color accentGray = Color(0xFF1A1A1A);
  static const Color lightGray = Color(0xFFF5F5F5);
  static const Color mediumGray = Color(0xFF6B6B6B);
  static const Color darkGray = Color(0xFF2A2A2A);
  
  // Gradient Colors
  static const Color gradientPurple = Color(0xFF6B4FBB);
  static const Color gradientBlue = Color(0xFF4A90E2);
  static const Color gradientPink = Color(0xFFE94B8C);
  static const Color gradientOrange = Color(0xFFFF6B35);
  
  // Glassmorphism overlay
  static Color glassOverlay = Colors.white.withOpacity(0.05);

  // Dark Theme with enhanced visuals
  static ThemeData darkTheme = ThemeData(
    brightness: Brightness.dark,
    scaffoldBackgroundColor: primaryBlack,
    primaryColor: primaryWhite,
    colorScheme: ColorScheme.dark(
      primary: primaryWhite,
      secondary: gradientPurple,
      surface: accentGray,
      background: primaryBlack,
    ),
    appBarTheme: AppBarTheme(
      backgroundColor: Colors.transparent,
      elevation: 0,
      iconTheme: IconThemeData(color: primaryWhite),
      titleTextStyle: TextStyle(
        color: primaryWhite,
        fontSize: 20,
        fontWeight: FontWeight.w700,
        letterSpacing: 0.5,
      ),
    ),
    textTheme: TextTheme(
      displayLarge: TextStyle(
        fontSize: 36,
        fontWeight: FontWeight.w900,
        color: primaryWhite,
        letterSpacing: -1.5,
        height: 1.1,
      ),
      displayMedium: TextStyle(
        fontSize: 28,
        fontWeight: FontWeight.w700,
        color: primaryWhite,
        letterSpacing: -0.5,
      ),
      bodyLarge: TextStyle(
        fontSize: 17,
        color: mediumGray,
        height: 1.6,
        letterSpacing: 0.2,
      ),
      bodyMedium: TextStyle(
        fontSize: 15,
        color: mediumGray,
        letterSpacing: 0.2,
      ),
    ),
    elevatedButtonTheme: ElevatedButtonThemeData(
      style: ElevatedButton.styleFrom(
        backgroundColor: primaryWhite,
        foregroundColor: primaryBlack,
        elevation: 0,
        padding: EdgeInsets.symmetric(horizontal: 32, vertical: 18),
        shape: RoundedRectangleBorder(
          borderRadius: BorderRadius.circular(16),
        ),
        textStyle: TextStyle(
          fontSize: 17,
          fontWeight: FontWeight.w700,
          letterSpacing: 0.5,
        ),
      ),
    ),
  );

  // Light Theme with enhanced visuals
  static ThemeData lightTheme = ThemeData(
    brightness: Brightness.light,
    scaffoldBackgroundColor: primaryWhite,
    primaryColor: primaryBlack,
    colorScheme: ColorScheme.light(
      primary: primaryBlack,
      secondary: gradientBlue,
      surface: lightGray,
      background: primaryWhite,
    ),
    appBarTheme: AppBarTheme(
      backgroundColor: Colors.transparent,
      elevation: 0,
      iconTheme: IconThemeData(color: primaryBlack),
      titleTextStyle: TextStyle(
        color: primaryBlack,
        fontSize: 20,
        fontWeight: FontWeight.w700,
        letterSpacing: 0.5,
      ),
    ),
    textTheme: TextTheme(
      displayLarge: TextStyle(
        fontSize: 36,
        fontWeight: FontWeight.w900,
        color: primaryBlack,
        letterSpacing: -1.5,
        height: 1.1,
      ),
      displayMedium: TextStyle(
        fontSize: 28,
        fontWeight: FontWeight.w700,
        color: primaryBlack,
        letterSpacing: -0.5,
      ),
      bodyLarge: TextStyle(
        fontSize: 17,
        color: mediumGray,
        height: 1.6,
        letterSpacing: 0.2,
      ),
      bodyMedium: TextStyle(
        fontSize: 15,
        color: mediumGray,
        letterSpacing: 0.2,
      ),
    ),
    elevatedButtonTheme: ElevatedButtonThemeData(
      style: ElevatedButton.styleFrom(
        backgroundColor: primaryBlack,
        foregroundColor: primaryWhite,
        elevation: 0,
        padding: EdgeInsets.symmetric(horizontal: 32, vertical: 18),
        shape: RoundedRectangleBorder(
          borderRadius: BorderRadius.circular(16),
        ),
        textStyle: TextStyle(
          fontSize: 17,
          fontWeight: FontWeight.w700,
          letterSpacing: 0.5,
        ),
      ),
    ),
  );
}