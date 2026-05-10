import 'package:flutter/material.dart';

/// Border radius tokens for vBlaFarm.
/// Friendly and padded — 16px standard per design spec.
abstract final class AppRadius {
  static const double sm = 4.0;
  static const double md = 8.0;
  static const double lg = 12.0;
  static const double xl = 16.0;     // Primary cards and buttons (design spec)
  static const double xxl = 20.0;
  static const double xxxl = 24.0;
  static const double huge = 32.0;   // Hero cards
  static const double massive = 40.0; // Top-level containers
  static const double full = 9999.0; // Pill chips

  // ─── BorderRadius objects ─────────────────────────────────────────────────
  static BorderRadius get smRadius => BorderRadius.circular(sm);
  static BorderRadius get mdRadius => BorderRadius.circular(md);
  static BorderRadius get lgRadius => BorderRadius.circular(lg);
  static BorderRadius get xlRadius => BorderRadius.circular(xl);
  static BorderRadius get xxlRadius => BorderRadius.circular(xxl);
  static BorderRadius get xxxlRadius => BorderRadius.circular(xxxl);
  static BorderRadius get hugeRadius => BorderRadius.circular(huge);
  static BorderRadius get massiveRadius => BorderRadius.circular(massive);
  static BorderRadius get fullRadius => BorderRadius.circular(full);

  // ─── Specific component radii ─────────────────────────────────────────────
  static BorderRadius get card => BorderRadius.circular(xxl);
  static BorderRadius get heroCard => BorderRadius.circular(massive);
  static BorderRadius get chip => BorderRadius.circular(full);
  static BorderRadius get button => BorderRadius.circular(xl);
  static BorderRadius get bottomSheet => const BorderRadius.only(
        topLeft: Radius.circular(huge),
        topRight: Radius.circular(huge),
      );
}
