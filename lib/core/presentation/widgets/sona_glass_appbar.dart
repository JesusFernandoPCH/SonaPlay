import 'package:flutter/material.dart';
import 'package:SonaPlay/core/constants/app_colors.dart';
import 'package:SonaPlay/core/constants/app_dimensions.dart';

/// Premium custom AppBar with glassmorphism and gradient effects
class SonaGlassAppBar extends StatelessWidget implements PreferredSizeWidget {
  final String? title;
  final Widget? titleWidget;
  final List<Widget>? actions;
  final Widget? leading;
  final bool showBackButton;
  final VoidCallback? onBackPressed;
  final double elevation;
  final bool centerTitle;

  const SonaGlassAppBar({
    super.key,
    this.title,
    this.titleWidget,
    this.actions,
    this.leading,
    this.showBackButton = false,
    this.onBackPressed,
    this.elevation = 0,
    this.centerTitle = false,
  });

  @override
  Size get preferredSize => const Size.fromHeight(kToolbarHeight);

  @override
  Widget build(BuildContext context) {
    return Container(
      decoration: BoxDecoration(
        gradient: LinearGradient(
          begin: Alignment.topCenter,
          end: Alignment.bottomCenter,
          colors: [
            AppColors.backgroundDark,
            AppColors.backgroundDark.withValues(alpha: 0.95),
          ],
        ),
      ),
      child: SafeArea(
        bottom: false,
        child: Padding(
          padding: const EdgeInsets.symmetric(
            horizontal: AppDimensions.paddingMedium,
            vertical: AppDimensions.paddingSmall,
          ),
          child: Row(
            children: [
              if (showBackButton || leading != null)
                leading ??
                    IconButton(
                      icon: const Icon(Icons.arrow_back_ios_new_rounded),
                      onPressed:
                          onBackPressed ?? () => Navigator.of(context).pop(),
                      color: AppColors.textPrimary,
                      iconSize: AppDimensions.iconMedium,
                    ),
              if (centerTitle) const Spacer(),
              if (titleWidget != null)
                titleWidget!
              else if (title != null)
                Text(
                  title!,
                  style: Theme.of(context).textTheme.titleLarge?.copyWith(
                    color: AppColors.textPrimary,
                    fontWeight: FontWeight.w600,
                  ),
                ),
              const Spacer(),
              if (actions != null) ...actions!,
            ],
          ),
        ),
      ),
    );
  }
}
