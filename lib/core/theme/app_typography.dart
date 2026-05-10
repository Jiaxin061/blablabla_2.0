import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';
import 'app_colors.dart';

/// Typography tokens for vBlaFarm.
/// Uses Atkinson Hyperlegible Next — designed for low-vision clarity.
abstract final class AppTypography {
  // ─── Font Family ──────────────────────────────────────────────────────────
  static String get fontFamily => GoogleFonts.atkinsonHyperlegible().fontFamily!;

  // ─── Text Styles ──────────────────────────────────────────────────────────

  /// headlineLg: 28sp / 700 / lh 36
  static TextStyle get headlineLg => GoogleFonts.atkinsonHyperlegible(
        fontSize: 28,
        fontWeight: FontWeight.w700,
        height: 36 / 28,
        color: AppColors.onSurface,
      );

  /// headlineMd: 22sp / 700 / lh 28
  static TextStyle get headlineMd => GoogleFonts.atkinsonHyperlegible(
        fontSize: 22,
        fontWeight: FontWeight.w700,
        height: 28 / 22,
        color: AppColors.onSurface,
      );

  /// bodyLg: 20sp / 400 / lh 30
  static TextStyle get bodyLg => GoogleFonts.atkinsonHyperlegible(
        fontSize: 20,
        fontWeight: FontWeight.w400,
        height: 30 / 20,
        color: AppColors.onSurface,
      );

  /// bodyMd: 18sp / 400 / lh 26
  static TextStyle get bodyMd => GoogleFonts.atkinsonHyperlegible(
        fontSize: 18,
        fontWeight: FontWeight.w400,
        height: 26 / 18,
        color: AppColors.onSurface,
      );

  /// labelLg: 16sp / 600 / lh 20 / ls 0.5
  static TextStyle get labelLg => GoogleFonts.atkinsonHyperlegible(
        fontSize: 16,
        fontWeight: FontWeight.w600,
        height: 20 / 16,
        letterSpacing: 0.5,
        color: AppColors.onSurface,
      );

  /// buttonText: 20sp / 700 / lh 24
  static TextStyle get buttonText => GoogleFonts.atkinsonHyperlegible(
        fontSize: 20,
        fontWeight: FontWeight.w700,
        height: 24 / 20,
        color: AppColors.onPrimary,
      );

  /// Micro labels for section headers (10-11sp, uppercase tracking)
  static TextStyle get sectionLabel => GoogleFonts.atkinsonHyperlegible(
        fontSize: 11,
        fontWeight: FontWeight.w700,
        letterSpacing: 2.0,
        height: 1.4,
        color: AppColors.onSurfaceVariant,
      );

  /// Caption: 10sp
  static TextStyle get caption => GoogleFonts.atkinsonHyperlegible(
        fontSize: 10,
        fontWeight: FontWeight.w600,
        letterSpacing: 0.3,
        color: AppColors.onSurfaceVariant,
      );

  // ─── Theme Text Theme ─────────────────────────────────────────────────────
  static TextTheme get textTheme => TextTheme(
        displayLarge: headlineLg.copyWith(fontSize: 32),
        displayMedium: headlineLg,
        displaySmall: headlineMd,
        headlineLarge: headlineLg,
        headlineMedium: headlineMd,
        headlineSmall: headlineMd.copyWith(fontSize: 20),
        titleLarge: headlineMd,
        titleMedium: labelLg.copyWith(fontSize: 18),
        titleSmall: labelLg,
        bodyLarge: bodyLg,
        bodyMedium: bodyMd,
        bodySmall: bodyMd.copyWith(fontSize: 14),
        labelLarge: labelLg,
        labelMedium: labelLg.copyWith(fontSize: 14),
        labelSmall: caption,
      );
}
