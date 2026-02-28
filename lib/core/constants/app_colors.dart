import 'package:flutter/material.dart';

/// Premium color system for SonaPlay - Dark futuristic theme with glassmorphism
class AppColors {
  AppColors._();

  // === PRIMARY BRAND COLORS ===
  // Vibrant purple gradient - main brand identity
  static const Color primary = Color(0xFF5B13EC); // Deep vibrant purple
  static const Color primaryBlue = Color(0xFF0D59F2); // New vibrant blue
  static const Color primaryLight = Color(0xFF7B3FFF);
  static const Color primaryDark = Color(0xFF4A0FBD);

  // Accent gradient - complementary highlights
  static const Color accent = Color(0xFFFF3D9A); // Vibrant pink
  static const Color accentLight = Color(0xFFFF6BB5);
  static const Color accentSecondary = Color(0xFF00D9FF); // Cyan accent

  // === DARK THEME BACKGROUNDS ===
  static const Color backgroundDark = Color(0xFF0A0A0F); // Deep space black
  static const Color backgroundDarkBlue = Color(
    0xFF101622,
  ); // New dark blue background
  static const Color backgroundLightBlue = Color(
    0xFFF5F6F8,
  ); // New light background
  static const Color surfaceDark = Color(
    0xFF121218,
  ); // Slightly lighter surface
  static const Color cardDark = Color(0xFF1A1A24); // Card background
  static const Color elevatedSurface = Color(0xFF1F1F2E); // Elevated elements

  // === GLASSMORPHISM TOKENS ===
  static const Color glassWhite = Color(0x1AFFFFFF); // 10% white
  static const Color glassDark = Color(0x33000000); // 20% black
  static const Color glassBorder = Color(0x40FFFFFF); // 25% white border
  static const Color glassHighlight = Color(0x0DFFFFFF); // 5% white highlight

  // === TEXT HIERARCHY ===
  static const Color textPrimary = Color(0xFFFFFFFF); // Pure white
  static const Color textSecondary = Color(0xB3FFFFFF); // 70% white
  static const Color textTertiary = Color(0x80FFFFFF); // 50% white
  static const Color textDisabled = Color(0x4DFFFFFF); // 30% white

  // === GRADIENTS (as List<Color> for easy LinearGradient usage) ===
  static const List<Color> gradientPrimary = [
    Color(0xFF5B13EC),
    Color(0xFF7B3FFF),
  ];

  static const List<Color> gradientAccent = [
    Color(0xFFFF3D9A),
    Color(0xFFFF6BB5),
  ];

  static const List<Color> gradientBackground = [
    Color(0xFF0A0A0F),
    Color(0xFF1A1A24),
  ];

  static const List<Color> gradientCyan = [
    Color(0xFF00D9FF),
    Color(0xFF5B13EC),
  ];

  // === SEMANTIC COLORS ===
  static const Color success = Color(0xFF00E676);
  static const Color error = Color(0xFFFF3D71);
  static const Color warning = Color(0xFFFFAB00);
  static const Color info = Color(0xFF00D9FF);

  // === OVERLAY & EFFECTS ===
  static const Color overlay = Color(0x80000000); // 50% black overlay
  static const Color shimmer = Color(0x1AFFFFFF); // Shimmer effect
  static const Color shadow = Color(0x40000000); // Soft shadow
  static const Color glow = Color(0x40FF3D9A); // Pink glow effect

  // === LEGACY LIGHT THEME (minimal support) ===
  static const Color backgroundLight = Color(0xFFF8F9FA);
  static const Color surfaceLight = Color(0xFFFFFFFF);
  static const Color cardLight = Color(0xFFF5F6F8);
  static const Color textPrimaryLight = Color(0xFF1A1A1A);
  static const Color textSecondaryLight = Color(0xFF6B6B6B);
}
