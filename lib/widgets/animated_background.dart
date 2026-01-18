import 'package:flutter/material.dart';

class AnimatedBackground extends StatelessWidget {
  final AnimationController controller;
  final bool isDark;

  const AnimatedBackground({
    Key? key,
    required this.controller,
    required this.isDark,
  }) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return AnimatedBuilder(
      animation: controller,
      builder: (context, child) {
        return Container(
          decoration: BoxDecoration(
            gradient: LinearGradient(
              begin: Alignment.topLeft,
              end: Alignment.bottomRight,
              colors: isDark
                  ? [
                      Color(0xFF0A0A0A),
                      Color(0xFF1A0F2E),
                      Color(0xFF0A0A0A),
                    ]
                  : [
                      Color(0xFFFFFFFF),
                      Color(0xFFF0F4FF),
                      Color(0xFFFFFFFF),
                    ],
              stops: [
                0.0,
                0.5 + (controller.value * 0.3),
                1.0,
              ],
            ),
          ),
        );
      },
    );
  }
}