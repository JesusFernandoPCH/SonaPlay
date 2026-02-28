import 'package:flutter/material.dart';
import 'package:SonaPlay/core/constants/app_colors.dart';
import 'package:SonaPlay/core/constants/app_dimensions.dart';

/// Premium control button with glow effects for player controls
class SonaControlIcon extends StatefulWidget {
  final IconData icon;
  final VoidCallback? onPressed;
  final double size;
  final Color? color;
  final Color? glowColor;
  final bool isActive;
  final bool showGlow;

  const SonaControlIcon({
    super.key,
    required this.icon,
    this.onPressed,
    this.size = 56.0,
    this.color,
    this.glowColor,
    this.isActive = false,
    this.showGlow = true,
  });

  @override
  State<SonaControlIcon> createState() => _SonaControlIconState();
}

class _SonaControlIconState extends State<SonaControlIcon>
    with SingleTickerProviderStateMixin {
  late AnimationController _controller;
  late Animation<double> _scaleAnimation;
  bool _isPressed = false;

  @override
  void initState() {
    super.initState();
    _controller = AnimationController(
      duration: const Duration(milliseconds: AppDimensions.animationFast),
      vsync: this,
    );
    _scaleAnimation = Tween<double>(
      begin: 1.0,
      end: 0.92,
    ).animate(CurvedAnimation(parent: _controller, curve: Curves.easeInOut));
  }

  @override
  void dispose() {
    _controller.dispose();
    super.dispose();
  }

  void _handleTapDown(TapDownDetails details) {
    setState(() => _isPressed = true);
    _controller.forward();
  }

  void _handleTapUp(TapUpDetails details) {
    setState(() => _isPressed = false);
    _controller.reverse();
    widget.onPressed?.call();
  }

  void _handleTapCancel() {
    setState(() => _isPressed = false);
    _controller.reverse();
  }

  @override
  Widget build(BuildContext context) {
    final effectiveColor = widget.color ?? AppColors.textPrimary;
    final effectiveGlowColor = widget.glowColor ?? AppColors.primary;

    return GestureDetector(
      onTapDown: widget.onPressed != null ? _handleTapDown : null,
      onTapUp: widget.onPressed != null ? _handleTapUp : null,
      onTapCancel: widget.onPressed != null ? _handleTapCancel : null,
      child: AnimatedBuilder(
        animation: _scaleAnimation,
        builder: (context, child) {
          return Transform.scale(
            scale: _scaleAnimation.value,
            child: Container(
              width: widget.size,
              height: widget.size,
              decoration: BoxDecoration(
                shape: BoxShape.circle,
                gradient: widget.isActive
                    ? LinearGradient(
                        colors: AppColors.gradientPrimary,
                        begin: Alignment.topLeft,
                        end: Alignment.bottomRight,
                      )
                    : null,
                color: widget.isActive ? null : AppColors.glassWhite,
                boxShadow: widget.showGlow && (widget.isActive || _isPressed)
                    ? [
                        BoxShadow(
                          color: effectiveGlowColor.withValues(alpha: 0.4),
                          blurRadius: AppDimensions.glowBlurRadius,
                          spreadRadius: 2,
                        ),
                      ]
                    : [
                        BoxShadow(
                          color: AppColors.shadow,
                          blurRadius: 12,
                          spreadRadius: 0,
                        ),
                      ],
              ),
              child: Icon(
                widget.icon,
                size: widget.size * 0.5,
                color: widget.isActive ? AppColors.textPrimary : effectiveColor,
              ),
            ),
          );
        },
      ),
    );
  }
}
