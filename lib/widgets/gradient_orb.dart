import 'package:flutter/material.dart';

class GradientOrb extends StatelessWidget {
  final double size;
  final Alignment alignment;
  final List<Color> colors;
  final double opacity;

  const GradientOrb({
    Key? key,
    required this.size,
    required this.alignment,
    required this.colors,
    this.opacity = 0.3,
  }) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return Align(
      alignment: alignment,
      child: Container(
        width: size,
        height: size,
        decoration: BoxDecoration(
          shape: BoxShape.circle,
          gradient: RadialGradient(
            colors: colors.map((c) => c.withOpacity(opacity)).toList(),
          ),
        ),
      ),
    );
  }
}