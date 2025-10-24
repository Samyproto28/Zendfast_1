import 'package:flutter/material.dart';

/// Zendfast color palette with zen-inspired colors for mental health support
class ZendfastColors {
  // Private constructor to prevent instantiation
  ZendfastColors._();

  // Primary Colors - Teal for calmness and trust
  static const Color primaryTeal = Color(0xFF069494);
  static const Color primaryTealLight = Color(0xFF38AEAE);
  static const Color primaryTealDark = Color(0xFF047A7A);

  // Secondary Colors - Green for growth and balance
  static const Color secondaryGreen = Color(0xFF7FB069);
  static const Color secondaryGreenLight = Color(0xFF99C284);
  static const Color secondaryGreenDark = Color(0xFF659654);

  // Panic Button - Orange for urgency but warmth
  static const Color panicOrange = Color(0xFFFFB366);
  static const Color panicOrangeLight = Color(0xFFFFC285);
  static const Color panicOrangeDark = Color(0xFFFF9F47);

  // Semantic Colors
  static const Color success = Color(0xFF4CAF50);
  static const Color warning = Color(0xFFFFA726);
  static const Color error = Color(0xFFEF5350);
  static const Color info = Color(0xFF42A5F5);

  // Light Theme Surface Colors
  static const Color lightBackground = Color(0xFFFAFAFA);
  static const Color lightSurface = Color(0xFFFFFFFF);
  static const Color lightSurfaceVariant = Color(0xFFF5F5F5);

  // Dark Theme Surface Colors
  static const Color darkBackground = Color(0xFF121212);
  static const Color darkSurface = Color(0xFF1E1E1E);
  static const Color darkSurfaceVariant = Color(0xFF2C2C2C);

  // Text Colors
  static const Color lightTextPrimary = Color(0xFF212121);
  static const Color lightTextSecondary = Color(0xFF757575);
  static const Color darkTextPrimary = Color(0xFFFFFFFF);
  static const Color darkTextSecondary = Color(0xFFBDBDBD);

  /// Creates a Material 3 ColorScheme for light theme
  static ColorScheme lightColorScheme() {
    return ColorScheme.fromSeed(
      seedColor: primaryTeal,
      brightness: Brightness.light,
      primary: primaryTeal,
      onPrimary: Colors.white,
      primaryContainer: primaryTealLight,
      onPrimaryContainer: primaryTealDark,
      secondary: secondaryGreen,
      onSecondary: Colors.white,
      secondaryContainer: secondaryGreenLight,
      onSecondaryContainer: secondaryGreenDark,
      tertiary: panicOrange,
      onTertiary: Colors.white,
      tertiaryContainer: panicOrangeLight,
      onTertiaryContainer: panicOrangeDark,
      error: error,
      onError: Colors.white,
      surface: lightSurface,
      onSurface: lightTextPrimary,
      surfaceContainerHighest: lightSurfaceVariant,
      onSurfaceVariant: lightTextSecondary,
      outline: Color(0xFFBDBDBD),
      shadow: Colors.black.withValues(alpha: 0.1),
    );
  }

  /// Creates a Material 3 ColorScheme for dark theme
  static ColorScheme darkColorScheme() {
    return ColorScheme.fromSeed(
      seedColor: primaryTeal,
      brightness: Brightness.dark,
      primary: primaryTealLight,
      onPrimary: Color(0xFF003333),
      primaryContainer: primaryTealDark,
      onPrimaryContainer: primaryTealLight,
      secondary: secondaryGreenLight,
      onSecondary: Color(0xFF1B3A1B),
      secondaryContainer: secondaryGreenDark,
      onSecondaryContainer: secondaryGreenLight,
      tertiary: panicOrange,
      onTertiary: Color(0xFF4D2800),
      tertiaryContainer: panicOrangeDark,
      onTertiaryContainer: panicOrangeLight,
      error: Color(0xFFFFB4AB),
      onError: Color(0xFF690005),
      surface: darkSurface,
      onSurface: darkTextPrimary,
      surfaceContainerHighest: darkSurfaceVariant,
      onSurfaceVariant: darkTextSecondary,
      outline: Color(0xFF757575),
      shadow: Colors.black.withValues(alpha: 0.3),
    );
  }
}
