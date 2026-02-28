import 'package:flutter/material.dart';

/// Reusable empty state widget for consistent UI across the app
///
/// Displays an icon, title, optional subtitle, and optional action button
/// when a screen or list has no content to show.
class EmptyState extends StatelessWidget {
  /// Icon to display (e.g., Icons.music_note, Icons.queue_music)
  final IconData icon;

  /// Main title text (e.g., "No songs found")
  final String title;

  /// Optional subtitle text for additional context
  final String? subtitle;

  /// Optional action button label (e.g., "Add Songs")
  final String? actionLabel;

  /// Optional action button callback
  final VoidCallback? onAction;

  /// Optional custom icon color (defaults to theme outline color)
  final Color? iconColor;

  const EmptyState({
    super.key,
    required this.icon,
    required this.title,
    this.subtitle,
    this.actionLabel,
    this.onAction,
    this.iconColor,
  });

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final colorScheme = theme.colorScheme;

    return Center(
      child: Padding(
        padding: const EdgeInsets.all(32.0),
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            // Icon
            Icon(icon, size: 80, color: iconColor ?? colorScheme.outline),
            const SizedBox(height: 24),

            // Title
            Text(
              title,
              style: theme.textTheme.titleLarge?.copyWith(
                color: colorScheme.onSurface,
                fontWeight: FontWeight.w500,
              ),
              textAlign: TextAlign.center,
            ),

            // Subtitle (optional)
            if (subtitle != null) ...[
              const SizedBox(height: 8),
              Text(
                subtitle!,
                style: theme.textTheme.bodyMedium?.copyWith(
                  color: colorScheme.onSurfaceVariant,
                ),
                textAlign: TextAlign.center,
              ),
            ],

            // Action button (optional)
            if (actionLabel != null && onAction != null) ...[
              const SizedBox(height: 24),
              FilledButton.icon(
                onPressed: onAction,
                icon: const Icon(Icons.add),
                label: Text(actionLabel!),
              ),
            ],
          ],
        ),
      ),
    );
  }
}
