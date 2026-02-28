/// App-wide constants for consistent UI/UX
///
/// This file defines standard values for spacing, border radius, icon sizes,
/// and animation durations to ensure visual consistency across the app.
library;

/// Standard spacing values following 4px grid
class AppSpacing {
  AppSpacing._(); // Private constructor to prevent instantiation

  /// Extra small spacing: 4px
  static const double xs = 4.0;

  /// Small spacing: 8px
  static const double sm = 8.0;

  /// Medium spacing: 12px
  static const double md = 12.0;

  /// Large spacing: 16px
  static const double lg = 16.0;

  /// Extra large spacing: 24px
  static const double xl = 24.0;

  /// Extra extra large spacing: 32px
  static const double xxl = 32.0;
}

/// Standard border radius values
class AppRadius {
  AppRadius._(); // Private constructor to prevent instantiation

  /// Small radius: 4px (artwork thumbnails)
  static const double sm = 4.0;

  /// Medium radius: 8px (cards, buttons)
  static const double md = 8.0;

  /// Large radius: 12px (dialogs, bottom sheets)
  static const double lg = 12.0;

  /// Extra large radius: 16px (large artwork, player screen)
  static const double xl = 16.0;
}

/// Standard icon sizes
class AppIconSize {
  AppIconSize._(); // Private constructor to prevent instantiation

  /// Extra small: 16px (inline icons)
  static const double xs = 16.0;

  /// Small: 20px (menu buttons)
  static const double sm = 20.0;

  /// Medium: 24px (standard icons)
  static const double md = 24.0;

  /// Large: 32px (play button in mini player)
  static const double lg = 32.0;

  /// Extra large: 48px (play button in full player)
  static const double xl = 48.0;
}

/// Standard animation durations
class AppDuration {
  AppDuration._(); // Private constructor to prevent instantiation

  /// Fast animation: 150ms (micro-interactions)
  static const Duration fast = Duration(milliseconds: 150);

  /// Normal animation: 200ms (standard transitions)
  static const Duration normal = Duration(milliseconds: 200);

  /// Slow animation: 300ms (page transitions)
  static const Duration slow = Duration(milliseconds: 300);
}

/// Standard artwork sizes
class AppArtworkSize {
  AppArtworkSize._(); // Private constructor to prevent instantiation

  /// Thumbnail: 48px (mini player, queue)
  static const double thumbnail = 48.0;

  /// Small: 56px (song list)
  static const double small = 56.0;

  /// Medium: 80px (playlist covers)
  static const double medium = 80.0;

  /// Large: 300px (full player)
  static const double large = 300.0;
}
