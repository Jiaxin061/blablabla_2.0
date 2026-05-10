import 'package:flutter/material.dart';
import '../theme/theme.dart';

/// Metric chip — pill-shaped chip with icon + value for environmental readings.
/// Follows design spec: large, rounded, both icon and text label.
class MetricChip extends StatelessWidget {
  final IconData icon;
  final String value;
  final String label;
  final Color? iconColor;
  final Color? backgroundColor;
  final String? status; // 'stable' | 'optimal' | 'warning' | 'critical'

  const MetricChip({
    super.key,
    required this.icon,
    required this.value,
    required this.label,
    this.iconColor,
    this.backgroundColor,
    this.status,
  });

  Color get _statusBadgeColor {
    switch (status?.toLowerCase()) {
      case 'stable':
        return AppColors.primary;
      case 'optimal':
        return AppColors.secondary;
      case 'warning':
        return const Color(0xFFF57F17);
      case 'critical':
        return AppColors.error;
      default:
        return AppColors.onSurfaceVariant;
    }
  }

  Color get _statusBgColor {
    switch (status?.toLowerCase()) {
      case 'stable':
        return AppColors.primaryFixed.withValues(alpha: 0.4);
      case 'optimal':
        return AppColors.secondaryContainer.withValues(alpha: 0.5);
      case 'warning':
        return const Color(0xFFFFF3E0);
      case 'critical':
        return AppColors.errorContainer.withValues(alpha: 0.5);
      default:
        return AppColors.surfaceContainerHigh;
    }
  }

  @override
  Widget build(BuildContext context) {
    final bg = backgroundColor ?? AppColors.surfaceContainerLow;
    final ic = iconColor ?? AppColors.primary;

    return Container(
      padding: const EdgeInsets.all(AppSpacing.md),
      decoration: BoxDecoration(
        color: bg,
        borderRadius: AppRadius.xxxlRadius,
        border: Border.all(color: AppColors.surfaceContainerHigh, width: 1),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              Container(
                width: 40,
                height: 40,
                decoration: BoxDecoration(
                  color: AppColors.surfaceContainerLowest,
                  borderRadius: AppRadius.xlRadius,
                  boxShadow: AppShadows.card,
                ),
                child: Icon(icon, color: ic, size: 22),
              ),
              if (status != null)
                Container(
                  padding:
                      const EdgeInsets.symmetric(horizontal: 8, vertical: 3),
                  decoration: BoxDecoration(
                    color: _statusBgColor,
                    borderRadius: AppRadius.fullRadius,
                  ),
                  child: Text(
                    status!.toUpperCase(),
                    style: AppTypography.caption.copyWith(
                      color: _statusBadgeColor,
                      fontWeight: FontWeight.w700,
                      fontSize: 9,
                    ),
                  ),
                ),
            ],
          ),
          const SizedBox(height: AppSpacing.sm),
          Text(
            label,
            style: AppTypography.labelLg.copyWith(
              color: AppColors.onSurfaceVariant,
              fontSize: 14,
            ),
          ),
          Text(
            value,
            style: AppTypography.headlineMd.copyWith(
              color: AppColors.onSurface,
              fontSize: 20,
            ),
          ),
        ],
      ),
    );
  }
}
