import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';
import 'colors.dart';

/// Zendfast typography system using Google Fonts
/// - Inter: Headers and display text
/// - Source Sans Pro: Body and general text
/// - Nunito Sans: Emotional emphasis and supportive text
class ZendfastTextStyles {
  // Private constructor to prevent instantiation
  ZendfastTextStyles._();

  /// Creates a complete TextTheme for light mode
  static TextTheme lightTextTheme() {
    return TextTheme(
      // Display styles - Inter for headers (largest text)
      displayLarge: GoogleFonts.inter(
        fontSize: 57,
        fontWeight: FontWeight.w400,
        letterSpacing: -0.25,
        height: 64 / 57,
        color: ZendfastColors.lightTextPrimary,
      ),
      displayMedium: GoogleFonts.inter(
        fontSize: 45,
        fontWeight: FontWeight.w400,
        letterSpacing: 0,
        height: 52 / 45,
        color: ZendfastColors.lightTextPrimary,
      ),
      displaySmall: GoogleFonts.inter(
        fontSize: 36,
        fontWeight: FontWeight.w400,
        letterSpacing: 0,
        height: 44 / 36,
        color: ZendfastColors.lightTextPrimary,
      ),

      // Headline styles - Inter for prominent headers
      headlineLarge: GoogleFonts.inter(
        fontSize: 32,
        fontWeight: FontWeight.w600,
        letterSpacing: 0,
        height: 40 / 32,
        color: ZendfastColors.lightTextPrimary,
      ),
      headlineMedium: GoogleFonts.inter(
        fontSize: 28,
        fontWeight: FontWeight.w600,
        letterSpacing: 0,
        height: 36 / 28,
        color: ZendfastColors.lightTextPrimary,
      ),
      headlineSmall: GoogleFonts.inter(
        fontSize: 24,
        fontWeight: FontWeight.w600,
        letterSpacing: 0,
        height: 32 / 24,
        color: ZendfastColors.lightTextPrimary,
      ),

      // Title styles - Inter for card titles and section headers
      titleLarge: GoogleFonts.inter(
        fontSize: 22,
        fontWeight: FontWeight.w500,
        letterSpacing: 0,
        height: 28 / 22,
        color: ZendfastColors.lightTextPrimary,
      ),
      titleMedium: GoogleFonts.inter(
        fontSize: 16,
        fontWeight: FontWeight.w500,
        letterSpacing: 0.15,
        height: 24 / 16,
        color: ZendfastColors.lightTextPrimary,
      ),
      titleSmall: GoogleFonts.inter(
        fontSize: 14,
        fontWeight: FontWeight.w500,
        letterSpacing: 0.1,
        height: 20 / 14,
        color: ZendfastColors.lightTextPrimary,
      ),

      // Body styles - Source Sans 3 for readable body text (min 16sp)
      bodyLarge: GoogleFonts.sourceSans3(
        fontSize: 18,
        fontWeight: FontWeight.w400,
        letterSpacing: 0.5,
        height: 28 / 18,
        color: ZendfastColors.lightTextPrimary,
      ),
      bodyMedium: GoogleFonts.sourceSans3(
        fontSize: 16,
        fontWeight: FontWeight.w400,
        letterSpacing: 0.25,
        height: 24 / 16,
        color: ZendfastColors.lightTextPrimary,
      ),
      bodySmall: GoogleFonts.sourceSans3(
        fontSize: 14,
        fontWeight: FontWeight.w400,
        letterSpacing: 0.4,
        height: 20 / 14,
        color: ZendfastColors.lightTextSecondary,
      ),

      // Label styles - Source Sans 3 for labels and captions
      labelLarge: GoogleFonts.sourceSans3(
        fontSize: 14,
        fontWeight: FontWeight.w500,
        letterSpacing: 0.1,
        height: 20 / 14,
        color: ZendfastColors.lightTextPrimary,
      ),
      labelMedium: GoogleFonts.sourceSans3(
        fontSize: 12,
        fontWeight: FontWeight.w500,
        letterSpacing: 0.5,
        height: 16 / 12,
        color: ZendfastColors.lightTextSecondary,
      ),
      labelSmall: GoogleFonts.sourceSans3(
        fontSize: 11,
        fontWeight: FontWeight.w500,
        letterSpacing: 0.5,
        height: 16 / 11,
        color: ZendfastColors.lightTextSecondary,
      ),
    );
  }

  /// Creates a complete TextTheme for dark mode
  static TextTheme darkTextTheme() {
    return TextTheme(
      // Display styles - Inter for headers (largest text)
      displayLarge: GoogleFonts.inter(
        fontSize: 57,
        fontWeight: FontWeight.w400,
        letterSpacing: -0.25,
        height: 64 / 57,
        color: ZendfastColors.darkTextPrimary,
      ),
      displayMedium: GoogleFonts.inter(
        fontSize: 45,
        fontWeight: FontWeight.w400,
        letterSpacing: 0,
        height: 52 / 45,
        color: ZendfastColors.darkTextPrimary,
      ),
      displaySmall: GoogleFonts.inter(
        fontSize: 36,
        fontWeight: FontWeight.w400,
        letterSpacing: 0,
        height: 44 / 36,
        color: ZendfastColors.darkTextPrimary,
      ),

      // Headline styles - Inter for prominent headers
      headlineLarge: GoogleFonts.inter(
        fontSize: 32,
        fontWeight: FontWeight.w600,
        letterSpacing: 0,
        height: 40 / 32,
        color: ZendfastColors.darkTextPrimary,
      ),
      headlineMedium: GoogleFonts.inter(
        fontSize: 28,
        fontWeight: FontWeight.w600,
        letterSpacing: 0,
        height: 36 / 28,
        color: ZendfastColors.darkTextPrimary,
      ),
      headlineSmall: GoogleFonts.inter(
        fontSize: 24,
        fontWeight: FontWeight.w600,
        letterSpacing: 0,
        height: 32 / 24,
        color: ZendfastColors.darkTextPrimary,
      ),

      // Title styles - Inter for card titles and section headers
      titleLarge: GoogleFonts.inter(
        fontSize: 22,
        fontWeight: FontWeight.w500,
        letterSpacing: 0,
        height: 28 / 22,
        color: ZendfastColors.darkTextPrimary,
      ),
      titleMedium: GoogleFonts.inter(
        fontSize: 16,
        fontWeight: FontWeight.w500,
        letterSpacing: 0.15,
        height: 24 / 16,
        color: ZendfastColors.darkTextPrimary,
      ),
      titleSmall: GoogleFonts.inter(
        fontSize: 14,
        fontWeight: FontWeight.w500,
        letterSpacing: 0.1,
        height: 20 / 14,
        color: ZendfastColors.darkTextPrimary,
      ),

      // Body styles - Source Sans 3 for readable body text (min 16sp)
      bodyLarge: GoogleFonts.sourceSans3(
        fontSize: 18,
        fontWeight: FontWeight.w400,
        letterSpacing: 0.5,
        height: 28 / 18,
        color: ZendfastColors.darkTextPrimary,
      ),
      bodyMedium: GoogleFonts.sourceSans3(
        fontSize: 16,
        fontWeight: FontWeight.w400,
        letterSpacing: 0.25,
        height: 24 / 16,
        color: ZendfastColors.darkTextPrimary,
      ),
      bodySmall: GoogleFonts.sourceSans3(
        fontSize: 14,
        fontWeight: FontWeight.w400,
        letterSpacing: 0.4,
        height: 20 / 14,
        color: ZendfastColors.darkTextSecondary,
      ),

      // Label styles - Source Sans 3 for labels and captions
      labelLarge: GoogleFonts.sourceSans3(
        fontSize: 14,
        fontWeight: FontWeight.w500,
        letterSpacing: 0.1,
        height: 20 / 14,
        color: ZendfastColors.darkTextPrimary,
      ),
      labelMedium: GoogleFonts.sourceSans3(
        fontSize: 12,
        fontWeight: FontWeight.w500,
        letterSpacing: 0.5,
        height: 16 / 12,
        color: ZendfastColors.darkTextSecondary,
      ),
      labelSmall: GoogleFonts.sourceSans3(
        fontSize: 11,
        fontWeight: FontWeight.w500,
        letterSpacing: 0.5,
        height: 16 / 11,
        color: ZendfastColors.darkTextSecondary,
      ),
    );
  }

  /// Custom style for emotional/supportive text using Nunito Sans
  static TextStyle emotionalSupport({
    required bool isDark,
    double fontSize = 16,
    FontWeight fontWeight = FontWeight.w400,
  }) {
    return GoogleFonts.nunitoSans(
      fontSize: fontSize,
      fontWeight: fontWeight,
      letterSpacing: 0.3,
      height: 1.5,
      color: isDark ? ZendfastColors.darkTextPrimary : ZendfastColors.lightTextPrimary,
    );
  }

  /// Style for panic button text
  static TextStyle panicButtonText({required bool isDark}) {
    return GoogleFonts.inter(
      fontSize: 18,
      fontWeight: FontWeight.w700,
      letterSpacing: 0.5,
      color: Colors.white,
    );
  }

  /// Style for success messages
  static TextStyle successText({required bool isDark}) {
    return GoogleFonts.nunitoSans(
      fontSize: 16,
      fontWeight: FontWeight.w600,
      letterSpacing: 0.3,
      color: ZendfastColors.success,
    );
  }

  /// Style for warning messages
  static TextStyle warningText({required bool isDark}) {
    return GoogleFonts.nunitoSans(
      fontSize: 16,
      fontWeight: FontWeight.w600,
      letterSpacing: 0.3,
      color: ZendfastColors.warning,
    );
  }
}
