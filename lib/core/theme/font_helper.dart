import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';

/// Helper class to apply Google Fonts to TextTheme
class FontHelper {
  FontHelper._();

  /// Apply Inter font to all text styles in the theme
  static TextTheme applyInterFont(TextTheme base) {
    return GoogleFonts.interTextTheme(base);
  }
}
