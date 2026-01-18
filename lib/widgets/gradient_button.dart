import 'package:flutter/material.dart';
import '../core/constants/app_constants.dart';

class GradientButton extends StatelessWidget {
  final String text;
  final VoidCallback? onPressed;
  final bool isLoading;
  final IconData? icon;
  final bool isDark;
  final double? width;
  final double? height;

  const GradientButton({
    Key? key,
    required this.text,
    required this.onPressed,
    required this.isDark,
    this.isLoading = false,
    this.icon,
    this.width,
    this.height,
  }) : super(key: key);

  @override
  Widget build(BuildContext context) {
    final buttonContent = Container(
      height: height ?? AppConstants.buttonHeight,
      decoration: BoxDecoration(
        gradient: LinearGradient(
          colors: isDark
              ? [Color(0xFF6B4FBB), Color(0xFF4A90E2)]
              : [Color(0xFF4A90E2), Color(0xFF6B4FBB)],
        ),
        borderRadius: BorderRadius.circular(AppConstants.borderRadiusMedium),
        boxShadow: [
          BoxShadow(
            color: (isDark ? Color(0xFF6B4FBB) : Color(0xFF4A90E2))
                .withOpacity(0.4),
            blurRadius: 20,
            offset: Offset(0, 8),
          ),
        ],
      ),
      child: ElevatedButton(
        onPressed: isLoading ? null : onPressed,
        style: ElevatedButton.styleFrom(
          backgroundColor: Colors.transparent,
          shadowColor: Colors.transparent,
          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(AppConstants.borderRadiusMedium),
          ),
        ),
        child: isLoading
            ? SizedBox(
                width: 24,
                height: 24,
                child: CircularProgressIndicator(
                  color: Colors.white,
                  strokeWidth: 2.5,
                ),
              )
            : Row(
                mainAxisAlignment: MainAxisAlignment.center,
                mainAxisSize: MainAxisSize.min,
                children: [
                  Text(
                    text,
                    style: TextStyle(
                      fontSize: 17,
                      fontWeight: FontWeight.w700,
                      color: Colors.white,
                      letterSpacing: 0.5,
                    ),
                  ),
                  if (icon != null) ...[
                    SizedBox(width: 10),
                    Icon(icon, color: Colors.white, size: 22),
                  ],
                ],
              ),
      ),
    );

    // If width is specified, wrap in SizedBox, otherwise let it shrink-wrap
    if (width != null) {
      return SizedBox(
        width: width,
        child: buttonContent,
      );
    }
    
    return buttonContent;
  }
}