/// Spacing design tokens for vBlaFarm.
/// Mobile-first, thumb-zone optimised.
abstract final class AppSpacing {
  // ─── Base Grid ────────────────────────────────────────────────────────────
  static const double xs = 4.0;
  static const double sm = 8.0;
  static const double md = 12.0;
  static const double gutter = 16.0;    // Design spec: gutter
  static const double lg = 20.0;
  static const double marginMobile = 20.0; // Design spec: margin-mobile
  static const double stackSpace = 24.0;   // Design spec: stack-space
  static const double xl = 32.0;
  static const double xxl = 40.0;
  static const double xxxl = 48.0;

  // ─── Component Specific ───────────────────────────────────────────────────
  static const double touchTargetMin = 56.0; // Minimum tap target height
  static const double cardPadding = 20.0;
  static const double sectionGap = 24.0;
  static const double itemGap = 12.0;

  // ─── Card & Container ─────────────────────────────────────────────────────
  static const double cardPaddingH = 20.0;
  static const double cardPaddingV = 20.0;
}
