// lib\core\widgets\glass_container.dart
import 'package:flutter/material.dart';
import 'dart:ui';
import '../constants/app_constants.dart';

class GlassContainer extends StatelessWidget {
  final Widget child;
  final bool isDark;
  final double? borderRadius;
  final EdgeInsetsGeometry? padding;
  final double opacity;
  final double borderOpacity;

  const GlassContainer({
    Key? key,
    required this.child,
    required this.isDark,
    this.borderRadius,
    this.padding,
    this.opacity = 0.1,
    this.borderOpacity = 0.2,
  }) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return ClipRRect(
      borderRadius: BorderRadius.circular(borderRadius ?? AppConstants.radiusLarge),
      child: BackdropFilter(
        filter: ImageFilter.blur(sigmaX: AppConstants.glassBlur, sigmaY: AppConstants.glassBlur),
        child: Container(
          padding: padding ?? EdgeInsets.all(AppConstants.spaceL),
          decoration: BoxDecoration(
            color: isDark
                ? Colors.white.withOpacity(opacity)
                : Colors.black.withOpacity(opacity * 0.5),
            borderRadius: BorderRadius.circular(borderRadius ?? AppConstants.radiusLarge),
            border: Border.all(
              color: isDark
                  ? Colors.white.withOpacity(borderOpacity)
                  : Colors.black.withOpacity(borderOpacity),
              width: 1.5,
            ),
          ),
          child: child,
        ),
      ),
    );
  }
}