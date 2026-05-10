import 'package:flutter/material.dart';
import 'app_colors.dart';

/// Shadow definitions for vBlaFarm.
/// Uses primary sage-green tinted shadows for organic depth.
abstract final class AppShadows {
  /// Soft card shadow — primary tinted
  static List<BoxShadow> get card => [
        BoxShadow(
          color: AppColors.shadowCard,
          blurRadius: 20,
          spreadRadius: 0,
          offset: const Offset(0, 4),
        ),
      ];

  /// Hero card shadow — stronger
  static List<BoxShadow> get cardHero => [
        BoxShadow(
          color: AppColors.shadowPrimary,
          blurRadius: 30,
          spreadRadius: 0,
          offset: const Offset(0, 8),
        ),
      ];

  /// Button primary shadow with glow
  static List<BoxShadow> get buttonPrimary => [
        BoxShadow(
          color: AppColors.primary.withValues(alpha: 0.4),
          blurRadius: 25,
          spreadRadius: 0,
          offset: const Offset(0, 10),
        ),
      ];

  /// Bottom navigation shadow
  static List<BoxShadow> get bottomNav => [
        BoxShadow(
          color: AppColors.shadowCard,
          blurRadius: 20,
          spreadRadius: 0,
          offset: const Offset(0, -4),
        ),
      ];

  /// AI pulse glow ring
  static List<BoxShadow> aiGlow({double radius = 10}) => [
        BoxShadow(
          color: AppColors.primary.withValues(alpha: 0.4),
          blurRadius: radius,
          spreadRadius: 0,
        ),
      ];
}
