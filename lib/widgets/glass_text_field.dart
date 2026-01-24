import 'package:flutter/material.dart';
import 'dart:ui';
import '../core/constants/app_constants.dart';
import '../core/theme/app_theme.dart';

class GlassTextField extends StatelessWidget {
  final String label;
  final String hint;
  final TextEditingController controller;
  final bool obscureText;
  final TextInputType keyboardType;
  final IconData? prefixIcon;
  final Widget? suffixIcon;
  final String? Function(String?)? validator;
  final bool isDark;

  const GlassTextField({
    Key? key,
    required this.label,
    required this.hint,
    required this.controller,
    required this.isDark,
    this.obscureText = false,
    this.keyboardType = TextInputType.text,
    this.prefixIcon,
    this.suffixIcon,
    this.validator,
  }) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(
          label,
          style: TextStyle(
            fontSize: 14,
            fontWeight: FontWeight.w600,
            color: isDark ? AppTheme.pureWhite : AppTheme.pureBlack,
          ),
        ),
        SizedBox(height: AppConstants.spaceS),
        ClipRRect(
          borderRadius: BorderRadius.circular(AppConstants.radiusMedium),
          child: BackdropFilter(
            filter: ImageFilter.blur(sigmaX: 10, sigmaY: 10),
            child: TextFormField(
              controller: controller,
              obscureText: obscureText,
              keyboardType: keyboardType,
              validator: validator,
              style: TextStyle(
                color: isDark ? AppTheme.pureWhite : AppTheme.pureBlack,
                fontSize: 16,
                fontWeight: FontWeight.w500,
              ),
              decoration: InputDecoration(
                hintText: hint,
                hintStyle: TextStyle(
                  color: AppTheme.mediumGray,
                  fontWeight: FontWeight.w400,
                ),
                prefixIcon: prefixIcon != null
                    ? Icon(prefixIcon, color: AppTheme.mediumGray, size: 22)
                    : null,
                suffixIcon: suffixIcon,
                filled: true,
                fillColor: isDark
                    ? Colors.white.withOpacity(0.1)
                    : Colors.black.withOpacity(0.05),
                border: OutlineInputBorder(
                  borderRadius: BorderRadius.circular(AppConstants.radiusMedium),
                  borderSide: BorderSide.none,
                ),
                enabledBorder: OutlineInputBorder(
                  borderRadius: BorderRadius.circular(AppConstants.radiusMedium),
                  borderSide: BorderSide(
                    color: isDark
                        ? Colors.white.withOpacity(0.2)
                        : Colors.black.withOpacity(0.1),
                    width: 1.5,
                  ),
                ),
                focusedBorder: OutlineInputBorder(
                  borderRadius: BorderRadius.circular(AppConstants.radiusMedium),
                  borderSide: BorderSide(
                    color: AppTheme.purplePrimary,
                    width: 2,
                  ),
                ),
                errorBorder: OutlineInputBorder(
                  borderRadius: BorderRadius.circular(AppConstants.radiusMedium),
                  borderSide: BorderSide(color: Colors.red, width: 1.5),
                ),
                focusedErrorBorder: OutlineInputBorder(
                  borderRadius: BorderRadius.circular(AppConstants.radiusMedium),
                  borderSide: BorderSide(color: Colors.red, width: 2),
                ),
                contentPadding: EdgeInsets.symmetric(
                  horizontal: AppConstants.spaceM,
                  vertical: AppConstants.spaceM,
                ),
              ),
            ),
          ),
        ),
      ],
    );
  }
}