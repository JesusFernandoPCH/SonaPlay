import 'dart:ui';
import 'package:flutter/material.dart';

class VibrantBackground extends StatelessWidget {
  final Color accentColor;
  final bool useRadial;

  const VibrantBackground({
    super.key,
    required this.accentColor,
    this.useRadial = true,
  });

  @override
  Widget build(BuildContext context) {
    return Stack(
      children: [
        // Base Dark Purple/Black
        Positioned.fill(child: Container(color: const Color(0xFF080B12))),

        // Gradient layer
        Positioned.fill(
          child: Container(
            decoration: BoxDecoration(
              gradient: LinearGradient(
                begin: Alignment.topLeft,
                end: Alignment.bottomRight,
                colors: [
                  const Color(0xFF080B12),
                  const Color(0xFF161022),
                  accentColor.withValues(alpha: 0.12),
                  accentColor.withValues(alpha: 0.04),
                ],
                stops: const [0.0, 0.4, 0.7, 1.0],
              ),
            ),
          ),
        ),

        if (useRadial) ...[
          // Top Left Radial Highlight
          Positioned(
            top: -150,
            left: -150,
            child: RadialBlur(
              color: accentColor.withValues(alpha: 0.25),
              size: 500,
            ),
          ),

          // Bottom Right Radial Highlight (Static dark for depth)
          Positioned(
            bottom: -200,
            right: -150,
            child: RadialBlur(
              color: const Color(0xFF1E3A5F).withValues(alpha: 0.15),
              size: 600,
            ),
          ),
        ],
      ],
    );
  }
}

class RadialBlur extends StatelessWidget {
  final Color color;
  final double size;

  const RadialBlur({super.key, required this.color, required this.size});

  @override
  Widget build(BuildContext context) {
    return Container(
      width: size,
      height: size,
      decoration: BoxDecoration(
        shape: BoxShape.circle,
        gradient: RadialGradient(colors: [color, Colors.transparent]),
      ),
      child: BackdropFilter(
        filter: ImageFilter.blur(sigmaX: 90, sigmaY: 90),
        child: Container(color: Colors.transparent),
      ),
    );
  }
}
