import 'package:flutter/material.dart';
import '../theme/theme.dart';

/// Farm status card for rack/shelf overview display.
enum FarmStatus { healthy, warning, critical, unknown }

extension FarmStatusEx on FarmStatus {
  Color get color {
    switch (this) {
      case FarmStatus.healthy:
        return AppColors.primary;
      case FarmStatus.warning:
        return const Color(0xFFF57F17);
      case FarmStatus.critical:
        return AppColors.error;
      case FarmStatus.unknown:
        return AppColors.onSurfaceVariant;
    }
  }

  Color get bgColor {
    switch (this) {
      case FarmStatus.healthy:
        return AppColors.primaryFixed.withValues(alpha: 0.3);
      case FarmStatus.warning:
        return AppColors.secondaryContainer.withValues(alpha: 0.5);
      case FarmStatus.critical:
        return AppColors.errorContainer.withValues(alpha: 0.5);
      case FarmStatus.unknown:
        return AppColors.surfaceContainerHigh;
    }
  }

  IconData get icon {
    switch (this) {
      case FarmStatus.healthy:
        return Icons.check_circle_rounded;
      case FarmStatus.warning:
        return Icons.report_rounded;
      case FarmStatus.critical:
        return Icons.error_rounded;
      case FarmStatus.unknown:
        return Icons.help_rounded;
    }
  }

  String get label {
    switch (this) {
      case FarmStatus.healthy:
        return 'Healthy';
      case FarmStatus.warning:
        return 'Warning';
      case FarmStatus.critical:
        return 'Critical';
      case FarmStatus.unknown:
        return 'Unknown';
    }
  }

  static FarmStatus fromString(String value) {
    switch (value.toLowerCase()) {
      case 'healthy':
        return FarmStatus.healthy;
      case 'warning':
        return FarmStatus.warning;
      case 'critical':
        return FarmStatus.critical;
      default:
        return FarmStatus.unknown;
    }
  }
}

class FarmStatusCard extends StatelessWidget {
  final String rackId;
  final String cropName;
  final FarmStatus status;
  final String? metric;
  final String? metricLabel;
  final VoidCallback? onTap;

  const FarmStatusCard({
    super.key,
    required this.rackId,
    required this.cropName,
    required this.status,
    this.metric,
    this.metricLabel,
    this.onTap,
  });

  @override
  Widget build(BuildContext context) {
    return GestureDetector(
      onTap: onTap,
      child: AnimatedContainer(
        duration: const Duration(milliseconds: 200),
        padding: const EdgeInsets.all(16),
        decoration: BoxDecoration(
          color: status.bgColor,
          borderRadius: AppRadius.xlRadius,
          border: Border.all(
            color: status.color.withValues(alpha: 0.25),
            width: 1.5,
          ),
        ),
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Text(
              'RACK $rackId',
              style: AppTypography.caption.copyWith(
                color: AppColors.onSurfaceVariant,
                letterSpacing: 1.5,
              ),
            ),
            const SizedBox(height: 6),
            Icon(
              status.icon,
              color: status.color,
              size: 28,
            ),
            if (metric != null) ...[
              const SizedBox(height: 4),
              Text(
                metric!,
                style: AppTypography.labelLg.copyWith(
                  color: status.color,
                  fontWeight: FontWeight.w700,
                ),
              ),
            ],
            const SizedBox(height: 2),
            Text(
              cropName,
              style: AppTypography.caption.copyWith(
                color: AppColors.onSurfaceVariant,
              ),
              textAlign: TextAlign.center,
              maxLines: 1,
              overflow: TextOverflow.ellipsis,
            ),
          ],
        ),
      ),
    );
  }
}
