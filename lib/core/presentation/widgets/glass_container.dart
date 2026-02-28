import 'dart:ui';
import 'package:flutter/material.dart';
import 'package:SonaPlay/core/constants/app_colors.dart';
import 'package:SonaPlay/core/constants/app_dimensions.dart';

/// Premium glassmorphism container with blur, gradients, and depth
class GlassContainer extends StatelessWidget {
  final Widget child;
  final double blur;
  final double opacity;
  final BorderRadius? borderRadius;
  final EdgeInsetsGeometry? padding;
  final Color? color;
  final Gradient? gradient;
  final bool showBorder;
  final Color? borderColor;
  final double? borderWidth;
  final List<BoxShadow>? shadows;

  const GlassContainer({
    super.key,
    required this.child,
    this.blur = 20.0,
    this.opacity = 0.1,
    this.borderRadius,
    this.padding,
    this.color,
    this.gradient,
    this.showBorder = true,
    this.borderColor,
    this.borderWidth,
    this.shadows,
  });

  @override
  Widget build(BuildContext context) {
    final effectiveBorderRadius =
        borderRadius ?? BorderRadius.circular(AppDimensions.radiusMedium);

    return ClipRRect(
      borderRadius: effectiveBorderRadius,
      child: BackdropFilter(
        filter: ImageFilter.blur(sigmaX: blur, sigmaY: blur),
        child: Container(
          padding: padding,
          decoration: BoxDecoration(
            color: gradient == null
                ? (color ?? AppColors.glassWhite).withValues(alpha: opacity)
                : null,
            gradient: gradient,
            borderRadius: effectiveBorderRadius,
            border: showBorder
                ? Border.all(
                    color: borderColor ?? AppColors.glassBorder,
                    width: borderWidth ?? AppDimensions.glassBorderWidth,
                  )
                : null,
            boxShadow:
                shadows ??
                [
                  BoxShadow(
                    color: AppColors.shadow,
                    blurRadius: AppDimensions.shadowBlurRadius,
                    spreadRadius: AppDimensions.shadowSpreadRadius,
                  ),
                ],
          ),
          child: child,
        ),
      ),
    );
  }
}
