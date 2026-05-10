import 'package:flutter/material.dart';
import '../theme/theme.dart';

/// Alert card for operational notifications.
/// Supports: warning, info, success, critical types.
enum AlertType { warning, info, success, critical }

extension AlertTypeEx on AlertType {
  Color get color {
    switch (this) {
      case AlertType.warning:
        return const Color(0xFFF57F17);
      case AlertType.info:
        return AppColors.primary;
      case AlertType.success:
        return const Color(0xFF2E7D32);
      case AlertType.critical:
        return AppColors.error;
    }
  }

  Color get bgColor {
    switch (this) {
      case AlertType.warning:
        return AppColors.secondaryContainer.withValues(alpha: 0.4);
      case AlertType.info:
        return AppColors.primaryFixed.withValues(alpha: 0.3);
      case AlertType.success:
        return const Color(0xFFE8F5E9);
      case AlertType.critical:
        return AppColors.errorContainer.withValues(alpha: 0.5);
    }
  }

  IconData get icon {
    switch (this) {
      case AlertType.warning:
        return Icons.warning_amber_rounded;
      case AlertType.info:
        return Icons.info_outline_rounded;
      case AlertType.success:
        return Icons.check_circle_outline_rounded;
      case AlertType.critical:
        return Icons.error_outline_rounded;
    }
  }

  static AlertType fromString(String value) {
    switch (value.toLowerCase()) {
      case 'warning':
        return AlertType.warning;
      case 'success':
        return AlertType.success;
      case 'critical':
        return AlertType.critical;
      default:
        return AlertType.info;
    }
  }
}

class AlertCard extends StatelessWidget {
  final String title;
  final String description;
  final AlertType type;
  final String timeAgo;
  final bool isRead;
  final VoidCallback? onTap;
  final VoidCallback? onDismiss;

  const AlertCard({
    super.key,
    required this.title,
    required this.description,
    required this.type,
    required this.timeAgo,
    this.isRead = false,
    this.onTap,
    this.onDismiss,
  });

  @override
  Widget build(BuildContext context) {
    return GestureDetector(
      onTap: onTap,
      child: AnimatedOpacity(
        opacity: isRead ? 0.7 : 1.0,
        duration: const Duration(milliseconds: 200),
        child: Container(
          padding: const EdgeInsets.all(AppSpacing.cardPadding),
          decoration: BoxDecoration(
            color: type.bgColor,
            borderRadius: AppRadius.card,
            border: Border.all(
              color: type.color.withValues(alpha: 0.2),
              width: 1,
            ),
          ),
          child: Row(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Container(
                width: 40,
                height: 40,
                decoration: BoxDecoration(
                  color: AppColors.surfaceContainerLowest,
                  borderRadius: AppRadius.mdRadius,
                ),
                child: Icon(type.icon, color: type.color, size: 22),
              ),
              const SizedBox(width: AppSpacing.md),
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Row(
                      children: [
                        Expanded(
                          child: Text(
                            title,
                            style: AppTypography.labelLg.copyWith(
                              color: AppColors.onSurface,
                              fontWeight: FontWeight.w700,
                            ),
                          ),
                        ),
                        if (!isRead)
                          Container(
                            width: 8,
                            height: 8,
                            decoration: BoxDecoration(
                              color: type.color,
                              shape: BoxShape.circle,
                            ),
                          ),
                      ],
                    ),
                    const SizedBox(height: 4),
                    Text(
                      description,
                      style: AppTypography.bodyMd.copyWith(
                        color: AppColors.onSurfaceVariant,
                        fontSize: 14,
                        height: 1.4,
                      ),
                    ),
                    const SizedBox(height: 6),
                    Text(
                      timeAgo,
                      style: AppTypography.caption.copyWith(
                        color: AppColors.onSurfaceVariant.withValues(alpha: 0.7),
                      ),
                    ),
                  ],
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}
