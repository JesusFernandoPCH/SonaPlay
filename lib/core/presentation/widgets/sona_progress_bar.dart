import 'package:flutter/material.dart';
import 'package:SonaPlay/core/constants/app_colors.dart';
import 'package:SonaPlay/core/constants/app_dimensions.dart';

/// Premium custom music progress bar with glow and smooth animations
class SonaProgressBar extends StatelessWidget {
  final Duration position;
  final Duration duration;
  final ValueChanged<Duration>? onSeek;
  final Color? activeColor;
  final Color? inactiveColor;
  final bool showThumb;

  const SonaProgressBar({
    super.key,
    required this.position,
    required this.duration,
    this.onSeek,
    this.activeColor,
    this.inactiveColor,
    this.showThumb = true,
  });

  String _formatDuration(Duration duration) {
    String twoDigits(int n) => n.toString().padLeft(2, "0");
    String twoDigitMinutes = twoDigits(duration.inMinutes.remainder(60));
    String twoDigitSeconds = twoDigits(duration.inSeconds.remainder(60));
    return "$twoDigitMinutes:$twoDigitSeconds";
  }

  @override
  Widget build(BuildContext context) {
    final double percent = duration.inMilliseconds > 0
        ? (position.inMilliseconds / duration.inMilliseconds).clamp(0.0, 1.0)
        : 0.0;

    return Column(
      mainAxisSize: MainAxisSize.min,
      children: [
        LayoutBuilder(
          builder: (context, constraints) {
            return GestureDetector(
              onHorizontalDragUpdate: (details) {
                if (onSeek != null) {
                  final double boxWidth = constraints.maxWidth;
                  final double seekPercent =
                      (details.localPosition.dx / boxWidth).clamp(0.0, 1.0);
                  final int seekMilliseconds =
                      (duration.inMilliseconds * seekPercent).toInt();
                  onSeek!(Duration(milliseconds: seekMilliseconds));
                }
              },
              onTapDown: (details) {
                if (onSeek != null) {
                  final double boxWidth = constraints.maxWidth;
                  final double seekPercent =
                      (details.localPosition.dx / boxWidth).clamp(0.0, 1.0);
                  final int seekMilliseconds =
                      (duration.inMilliseconds * seekPercent).toInt();
                  onSeek!(Duration(milliseconds: seekMilliseconds));
                }
              },
              child: SizedBox(
                height: 24,
                width: double.infinity,
                child: Stack(
                  alignment: Alignment.centerLeft,
                  children: [
                    // Inactive Track
                    Container(
                      height: 6,
                      width: double.infinity,
                      decoration: BoxDecoration(
                        color: inactiveColor ?? AppColors.glassWhite,
                        borderRadius: BorderRadius.circular(3),
                      ),
                    ),
                    // Active Track
                    Container(
                      height: 6,
                      width: constraints.maxWidth * percent,
                      decoration: BoxDecoration(
                        gradient: LinearGradient(
                          colors: [
                            activeColor ?? AppColors.primary,
                            (activeColor ?? AppColors.primaryLight).withValues(
                              alpha: 0.8,
                            ),
                          ],
                        ),
                        borderRadius: BorderRadius.circular(3),
                        boxShadow: [
                          BoxShadow(
                            color: (activeColor ?? AppColors.primary)
                                .withValues(alpha: 0.4),
                            blurRadius: 8,
                            spreadRadius: 1,
                          ),
                        ],
                      ),
                    ),
                    // Thumb
                    if (showThumb)
                      Positioned(
                        left: (constraints.maxWidth * percent) - 8,
                        child: Container(
                          width: 16,
                          height: 16,
                          decoration: BoxDecoration(
                            color: Colors.white,
                            shape: BoxShape.circle,
                            boxShadow: [
                              BoxShadow(
                                color: Colors.black.withValues(alpha: 0.3),
                                blurRadius: 4,
                                spreadRadius: 1,
                              ),
                              BoxShadow(
                                color: (activeColor ?? AppColors.primary)
                                    .withValues(alpha: 0.5),
                                blurRadius: 10,
                                spreadRadius: 2,
                              ),
                            ],
                          ),
                          child: Center(
                            child: Container(
                              width: 6,
                              height: 6,
                              decoration: BoxDecoration(
                                color: activeColor ?? AppColors.primary,
                                shape: BoxShape.circle,
                              ),
                            ),
                          ),
                        ),
                      ),
                  ],
                ),
              ),
            );
          },
        ),
        const SizedBox(height: AppDimensions.paddingSmall),
        Row(
          mainAxisAlignment: MainAxisAlignment.spaceBetween,
          children: [
            Text(
              _formatDuration(position),
              style: TextStyle(
                color: AppColors.textSecondary,
                fontSize: 12,
                fontWeight: FontWeight.w500,
              ),
            ),
            Text(
              _formatDuration(duration),
              style: TextStyle(
                color: AppColors.textSecondary,
                fontSize: 12,
                fontWeight: FontWeight.w500,
              ),
            ),
          ],
        ),
      ],
    );
  }
}
