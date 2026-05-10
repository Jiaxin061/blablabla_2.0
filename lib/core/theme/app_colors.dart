import 'package:flutter/material.dart';

/// Design token colors from "Agri-Care Intelligence" design system.
/// Based on a thriving greenhouse at dawn palette.
abstract final class AppColors {
  // ─── Primary (Sage Green) ──────────────────────────────────────────────────
  static const Color primary = Color(0xFF45634B);
  static const Color onPrimary = Color(0xFFFFFFFF);
  static const Color primaryContainer = Color(0xFF5D7C62);
  static const Color onPrimaryContainer = Color(0xFFF7FFF4);
  static const Color inversePrimary = Color(0xFFADCFB1);

  // Primary Fixed
  static const Color primaryFixed = Color(0xFFC9EBCC);
  static const Color primaryFixedDim = Color(0xFFADCFB1);
  static const Color onPrimaryFixed = Color(0xFF03210E);
  static const Color onPrimaryFixedVariant = Color(0xFF304D36);

  // ─── Secondary (Earthy Brown) ──────────────────────────────────────────────
  static const Color secondary = Color(0xFF75584D);
  static const Color onSecondary = Color(0xFFFFFFFF);
  static const Color secondaryContainer = Color(0xFFFED7CA);
  static const Color onSecondaryContainer = Color(0xFF795C51);

  // Secondary Fixed
  static const Color secondaryFixed = Color(0xFFFFDBCE);
  static const Color secondaryFixedDim = Color(0xFFE4BEB2);
  static const Color onSecondaryFixed = Color(0xFF2B160F);
  static const Color onSecondaryFixedVariant = Color(0xFF5B4137);

  // ─── Tertiary ─────────────────────────────────────────────────────────────
  static const Color tertiary = Color(0xFF7B5059);
  static const Color onTertiary = Color(0xFFFFFFFF);
  static const Color tertiaryContainer = Color(0xFF966871);
  static const Color onTertiaryContainer = Color(0xFFFFFBFF);

  // Tertiary Fixed
  static const Color tertiaryFixed = Color(0xFFFFD9DF);
  static const Color tertiaryFixedDim = Color(0xFFEFB8C2);
  static const Color onTertiaryFixed = Color(0xFF311119);
  static const Color onTertiaryFixedVariant = Color(0xFF633B44);

  // ─── Surface ──────────────────────────────────────────────────────────────
  static const Color surface = Color(0xFFFAF9F5);
  static const Color surfaceDim = Color(0xFFDADAD6);
  static const Color surfaceBright = Color(0xFFFAF9F5);
  static const Color surfaceContainerLowest = Color(0xFFFFFFFF);
  static const Color surfaceContainerLow = Color(0xFFF4F4F0);
  static const Color surfaceContainer = Color(0xFFEEEEEA);
  static const Color surfaceContainerHigh = Color(0xFFE9E8E4);
  static const Color surfaceContainerHighest = Color(0xFFE3E3DF);
  static const Color surfaceVariant = Color(0xFFE3E3DF);
  static const Color surfaceTint = Color(0xFF47654D);
  static const Color inverseSurface = Color(0xFF2F312E);
  static const Color inverseOnSurface = Color(0xFFF1F1ED);

  // ─── On Surface ───────────────────────────────────────────────────────────
  static const Color onSurface = Color(0xFF1A1C1A);
  static const Color onSurfaceVariant = Color(0xFF424842);

  // ─── Background ───────────────────────────────────────────────────────────
  static const Color background = Color(0xFFFAF9F5);
  static const Color onBackground = Color(0xFF1A1C1A);

  // ─── Error ────────────────────────────────────────────────────────────────
  static const Color error = Color(0xFFBA1A1A);
  static const Color onError = Color(0xFFFFFFFF);
  static const Color errorContainer = Color(0xFFFFDAD6);
  static const Color onErrorContainer = Color(0xFF93000A);

  // ─── Outline ──────────────────────────────────────────────────────────────
  static const Color outline = Color(0xFF727971);
  static const Color outlineVariant = Color(0xFFC2C8C0);

  // ─── AI Glow Accents ──────────────────────────────────────────────────────
  static const Color aiGlow = Color(0xFF6E8A75);
  static const Color aiPulse = Color(0xFF45634B);

  // ─── Status Colors ────────────────────────────────────────────────────────
  static const Color statusHealthy = Color(0xFF2E7D32);
  static const Color statusWarning = Color(0xFFF57F17);
  static const Color statusCritical = Color(0xFFBA1A1A);

  // ─── Semantic Shadows ─────────────────────────────────────────────────────
  static const Color shadowPrimary = Color(0x1F5D7C62); // rgba(93,124,98,0.12)
  static const Color shadowCard = Color(0x145D7C62);    // rgba(93,124,98,0.08)
}
