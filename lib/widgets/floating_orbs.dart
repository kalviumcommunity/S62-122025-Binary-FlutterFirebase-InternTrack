import 'package:flutter/material.dart';
import 'dart:math' as math;

class FloatingOrbs extends StatelessWidget {
  final AnimationController controller;
  final bool isDark;
  final bool showMultiple;

  const FloatingOrbs({
    Key? key,
    required this.controller,
    required this.isDark,
    this.showMultiple = false,
  }) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return Stack(
      children: [
        // Top right orb
        Positioned(
          top: -100,
          right: -80,
          child: _buildOrb(
            size: 250,
            colors: isDark
                ? [Color(0xFF6B4FBB).withOpacity(0.2), Colors.transparent]
                : [Color(0xFF6B4FBB).withOpacity(0.15), Colors.transparent],
          ),
        ),
        
        // Bottom left orb (only if showMultiple is true)
        if (showMultiple)
          Positioned(
            bottom: -120,
            left: -100,
            child: AnimatedBuilder(
              animation: controller,
              builder: (context, child) {
                return Transform.translate(
                  offset: Offset(
                    math.cos(controller.value * 2 * math.pi) * 30,
                    math.sin(controller.value * 2 * math.pi) * 30,
                  ),
                  child: Container(
                    width: 300,
                    height: 300,
                    decoration: BoxDecoration(
                      shape: BoxShape.circle,
                      gradient: RadialGradient(
                        colors: isDark
                            ? [
                                Color(0xFF4A90E2).withOpacity(0.15),
                                Colors.transparent,
                              ]
                            : [
                                Color(0xFF4A90E2).withOpacity(0.12),
                                Colors.transparent,
                              ],
                      ),
                    ),
                  ),
                );
              },
            ),
          ),
      ],
    );
  }

  Widget _buildOrb({required double size, required List<Color> colors}) {
    return AnimatedBuilder(
      animation: controller,
      builder: (context, child) {
        return Transform.translate(
          offset: Offset(
            math.sin(controller.value * 2 * math.pi) * 20,
            math.cos(controller.value * 2 * math.pi) * 20,
          ),
          child: Container(
            width: size,
            height: size,
            decoration: BoxDecoration(
              shape: BoxShape.circle,
              gradient: RadialGradient(colors: colors),
            ),
          ),
        );
      },
    );
  }
}