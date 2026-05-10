import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'app_colors.dart';
import 'app_typography.dart';
import 'app_radius.dart';

/// Central theme configuration for vBlaFarm.
/// Implements Material 3 with the Agri-Care Intelligence design system.
abstract final class AppTheme {
  // ─── Color Scheme ─────────────────────────────────────────────────────────
  static const ColorScheme _colorScheme = ColorScheme(
    brightness: Brightness.light,
    primary: AppColors.primary,
    onPrimary: AppColors.onPrimary,
    primaryContainer: AppColors.primaryContainer,
    onPrimaryContainer: AppColors.onPrimaryContainer,
    secondary: AppColors.secondary,
    onSecondary: AppColors.onSecondary,
    secondaryContainer: AppColors.secondaryContainer,
    onSecondaryContainer: AppColors.onSecondaryContainer,
    tertiary: AppColors.tertiary,
    onTertiary: AppColors.onTertiary,
    tertiaryContainer: AppColors.tertiaryContainer,
    onTertiaryContainer: AppColors.onTertiaryContainer,
    error: AppColors.error,
    onError: AppColors.onError,
    errorContainer: AppColors.errorContainer,
    onErrorContainer: AppColors.onErrorContainer,
    surface: AppColors.surface,
    onSurface: AppColors.onSurface,
    onSurfaceVariant: AppColors.onSurfaceVariant,
    outline: AppColors.outline,
    outlineVariant: AppColors.outlineVariant,
    shadow: AppColors.shadowCard,
    inverseSurface: AppColors.inverseSurface,
    onInverseSurface: AppColors.inverseOnSurface,
    inversePrimary: AppColors.inversePrimary,
    surfaceTint: AppColors.surfaceTint,
  );

  // ─── Light Theme ──────────────────────────────────────────────────────────
  static ThemeData get light => ThemeData(
        useMaterial3: true,
        colorScheme: _colorScheme,
        scaffoldBackgroundColor: AppColors.background,
        textTheme: AppTypography.textTheme,
        fontFamily: AppTypography.fontFamily,

        // ── AppBar ─────────────────────────────────────────────────────────
        appBarTheme: AppBarTheme(
          backgroundColor: AppColors.surface.withValues(alpha: 0.8),
          foregroundColor: AppColors.onSurface,
          elevation: 0,
          scrolledUnderElevation: 0,
          centerTitle: false,
          titleTextStyle: AppTypography.headlineMd.copyWith(
            color: AppColors.primary,
          ),
          systemOverlayStyle: const SystemUiOverlayStyle(
            statusBarBrightness: Brightness.light,
            statusBarIconBrightness: Brightness.dark,
            statusBarColor: Colors.transparent,
          ),
        ),

        // ── Elevated Button ────────────────────────────────────────────────
        elevatedButtonTheme: ElevatedButtonThemeData(
          style: ElevatedButton.styleFrom(
            backgroundColor: AppColors.primary,
            foregroundColor: AppColors.onPrimary,
            minimumSize: const Size(double.infinity, 56),
            shape: RoundedRectangleBorder(borderRadius: AppRadius.button),
            textStyle: AppTypography.buttonText,
            elevation: 0,
          ),
        ),

        // ── Filled Button ──────────────────────────────────────────────────
        filledButtonTheme: FilledButtonThemeData(
          style: FilledButton.styleFrom(
            backgroundColor: AppColors.primary,
            foregroundColor: AppColors.onPrimary,
            minimumSize: const Size(double.infinity, 56),
            shape: RoundedRectangleBorder(borderRadius: AppRadius.button),
            textStyle: AppTypography.buttonText,
          ),
        ),

        // ── Card ───────────────────────────────────────────────────────────
        cardTheme: CardThemeData(
          color: AppColors.surfaceContainerLowest,
          elevation: 0,
          shape: RoundedRectangleBorder(borderRadius: AppRadius.card),
          margin: EdgeInsets.zero,
        ),

        // ── Chip ───────────────────────────────────────────────────────────
        chipTheme: ChipThemeData(
          backgroundColor: AppColors.surfaceContainerHigh,
          selectedColor: AppColors.primaryFixed,
          labelStyle: AppTypography.labelLg,
          side: const BorderSide(color: AppColors.outlineVariant),
          shape: RoundedRectangleBorder(borderRadius: AppRadius.chip),
          padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 8),
        ),

        // ── Input Decoration ───────────────────────────────────────────────
        inputDecorationTheme: InputDecorationTheme(
          filled: true,
          fillColor: AppColors.surfaceContainerLowest,
          contentPadding: const EdgeInsets.symmetric(horizontal: 20, vertical: 18),
          border: OutlineInputBorder(
            borderRadius: AppRadius.xlRadius,
            borderSide: const BorderSide(
              color: AppColors.outlineVariant,
              width: 2,
            ),
          ),
          enabledBorder: OutlineInputBorder(
            borderRadius: AppRadius.xlRadius,
            borderSide: const BorderSide(
              color: AppColors.outlineVariant,
              width: 2,
            ),
          ),
          focusedBorder: OutlineInputBorder(
            borderRadius: AppRadius.xlRadius,
            borderSide: const BorderSide(
              color: AppColors.primary,
              width: 2,
            ),
          ),
          hintStyle: AppTypography.bodyMd.copyWith(
            color: AppColors.onSurfaceVariant,
          ),
          labelStyle: AppTypography.labelLg.copyWith(
            color: AppColors.onSurfaceVariant,
          ),
        ),

        // ── Bottom Navigation ──────────────────────────────────────────────
        bottomNavigationBarTheme: BottomNavigationBarThemeData(
          backgroundColor: AppColors.surfaceContainerLowest,
          selectedItemColor: AppColors.primary,
          unselectedItemColor: AppColors.onSurfaceVariant,
          selectedLabelStyle: AppTypography.labelLg,
          unselectedLabelStyle: AppTypography.labelLg,
          type: BottomNavigationBarType.fixed,
          elevation: 0,
        ),

        // ── Navigation Bar ─────────────────────────────────────────────────
        navigationBarTheme: NavigationBarThemeData(
          backgroundColor: AppColors.surfaceContainerLowest,
          indicatorColor: AppColors.primaryFixed,
          labelTextStyle: WidgetStateProperty.resolveWith((states) {
            if (states.contains(WidgetState.selected)) {
              return AppTypography.labelLg.copyWith(color: AppColors.primary);
            }
            return AppTypography.labelLg.copyWith(
              color: AppColors.onSurfaceVariant,
            );
          }),
        ),

        // ── Divider ────────────────────────────────────────────────────────
        dividerTheme: const DividerThemeData(
          color: AppColors.outlineVariant,
          thickness: 1,
          space: 0,
        ),

        // ── Icon ───────────────────────────────────────────────────────────
        iconTheme: const IconThemeData(
          color: AppColors.onSurfaceVariant,
          size: 24,
        ),

        // ── Snack Bar ──────────────────────────────────────────────────────
        snackBarTheme: SnackBarThemeData(
          backgroundColor: AppColors.inverseSurface,
          contentTextStyle: AppTypography.bodyMd.copyWith(
            color: AppColors.inverseOnSurface,
          ),
          shape: RoundedRectangleBorder(borderRadius: AppRadius.xlRadius),
          behavior: SnackBarBehavior.floating,
        ),
      );
}
