// lib\core\widgets\theme_toggle.dart
import 'package:flutter/material.dart';
import 'dart:ui';
import '../../../providers/theme_provider.dart';
import '../constants/app_constants.dart';

class ThemeToggle extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    final themeProvider = ThemeProvider.of(context);
    final isDark = themeProvider?.themeMode == ThemeMode.dark;

    return GestureDetector(
      onTap: () => themeProvider?.onThemeToggle(),
      child: ClipRRect(
        borderRadius: BorderRadius.circular(AppConstants.radiusSmall),
        child: BackdropFilter(
          filter: ImageFilter.blur(sigmaX: 10, sigmaY: 10),
          child: Container(
            width: 56,
            height: 56,
            decoration: BoxDecoration(
              color: isDark
                  ? Colors.white.withOpacity(0.1)
                  : Colors.black.withOpacity(0.05),
              borderRadius: BorderRadius.circular(AppConstants.radiusSmall),
              border: Border.all(
                color: isDark
                    ? Colors.white.withOpacity(0.2)
                    : Colors.black.withOpacity(0.1),
                width: 1.5,
              ),
            ),
            child: Icon(
              isDark ? Icons.light_mode_rounded : Icons.dark_mode_rounded,
              color: isDark ? Colors.white : Colors.black,
              size: 24,
            ),
          ),
        ),
      ),
    );
  }
}