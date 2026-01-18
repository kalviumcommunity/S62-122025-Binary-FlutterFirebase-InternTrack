import 'package:flutter/material.dart';
import '../core/constants/app_constants.dart';

class GlassmorphicContainer extends StatelessWidget {
  final Widget child;
  final bool isDark;
  final double? borderRadius;
  final EdgeInsetsGeometry? padding;
  final bool hasShadow;

  const GlassmorphicContainer({
    Key? key,
    required this.child,
    required this.isDark,
    this.borderRadius,
    this.padding,
    this.hasShadow = true,
  }) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: padding ?? EdgeInsets.all(28),
      decoration: BoxDecoration(
        color: isDark
            ? Colors.white.withOpacity(0.05)
            : Colors.white.withOpacity(0.7),
        borderRadius: BorderRadius.circular(borderRadius ?? AppConstants.borderRadiusLarge),
        border: Border.all(
          color: isDark
              ? Colors.white.withOpacity(0.1)
              : Colors.black.withOpacity(0.08),
          width: 1.5,
        ),
        boxShadow: hasShadow
            ? [
                BoxShadow(
                  color: isDark
                      ? Colors.black.withOpacity(0.3)
                      : Colors.black.withOpacity(0.05),
                  blurRadius: 30,
                  offset: Offset(0, 10),
                ),
              ]
            : null,
      ),
      child: child,
    );
  }
}