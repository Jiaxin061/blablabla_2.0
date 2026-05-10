import 'package:flutter/material.dart';
import '../theme/theme.dart';

/// Rack Tower Card — isometric-style vertical rack visualization.
/// Represents individual rack units in the Farm Overview.
class RackTowerCard extends StatelessWidget {
  final String rackId;
  final String cropName;
  final int totalShelves;
  final List<ShelfStatus> shelves;
  final String status;
  final VoidCallback? onTap;

  const RackTowerCard({
    super.key,
    required this.rackId,
    required this.cropName,
    required this.totalShelves,
    required this.shelves,
    required this.status,
    this.onTap,
  });

  @override
  Widget build(BuildContext context) {
    final isWarning = status == 'warning';
    final borderColor = isWarning
        ? AppColors.secondary.withValues(alpha: 0.4)
        : AppColors.primary.withValues(alpha: 0.2);

    return GestureDetector(
      onTap: onTap,
      child: Container(
        decoration: BoxDecoration(
          color: AppColors.surfaceContainerLowest,
          borderRadius: AppRadius.card,
          border: Border.all(color: borderColor, width: 1.5),
          boxShadow: AppShadows.card,
        ),
        child: Column(
          children: [
            // Header
            Container(
              padding: const EdgeInsets.symmetric(
                horizontal: 16,
                vertical: 12,
              ),
              decoration: BoxDecoration(
                color: isWarning
                    ? AppColors.secondaryContainer.withValues(alpha: 0.3)
                    : AppColors.primaryFixed.withValues(alpha: 0.2),
                borderRadius: const BorderRadius.only(
                  topLeft: Radius.circular(AppRadius.xxl),
                  topRight: Radius.circular(AppRadius.xxl),
                ),
              ),
              child: Row(
                children: [
                  Text(
                    'RACK $rackId',
                    style: AppTypography.sectionLabel.copyWith(
                      color: isWarning
                          ? AppColors.secondary
                          : AppColors.primary,
                    ),
                  ),
                  const Spacer(),
                  Icon(
                    isWarning
                        ? Icons.report_rounded
                        : Icons.check_circle_rounded,
                    color: isWarning ? AppColors.secondary : AppColors.primary,
                    size: 18,
                  ),
                ],
              ),
            ),
            // Shelf visualization
            Padding(
              padding: const EdgeInsets.all(12),
              child: Column(
                children: List.generate(
                  shelves.length,
                  (i) => _ShelfRow(
                    shelf: shelves[i],
                    isLast: i == shelves.length - 1,
                  ),
                ),
              ),
            ),
            // Footer
            Padding(
              padding: const EdgeInsets.fromLTRB(16, 0, 16, 12),
              child: Row(
                children: [
                  Icon(
                    Icons.grass_rounded,
                    color: AppColors.primary,
                    size: 14,
                  ),
                  const SizedBox(width: 4),
                  Expanded(
                    child: Text(
                      cropName,
                      style: AppTypography.caption.copyWith(
                        color: AppColors.onSurfaceVariant,
                        fontWeight: FontWeight.w600,
                      ),
                      overflow: TextOverflow.ellipsis,
                    ),
                  ),
                  Icon(
                    Icons.chevron_right_rounded,
                    color: AppColors.onSurfaceVariant,
                    size: 18,
                  ),
                ],
              ),
            ),
          ],
        ),
      ),
    );
  }
}

class _ShelfRow extends StatelessWidget {
  final ShelfStatus shelf;
  final bool isLast;

  const _ShelfRow({required this.shelf, required this.isLast});

  @override
  Widget build(BuildContext context) {
    final color = _shelfColor(shelf.health);

    return Container(
      margin: EdgeInsets.only(bottom: isLast ? 0 : 4),
      height: 28,
      decoration: BoxDecoration(
        color: color.withValues(alpha: 0.15),
        borderRadius: AppRadius.smRadius,
        border: Border.all(
          color: color.withValues(alpha: 0.3),
          width: 1,
        ),
      ),
      child: Row(
        children: [
          const SizedBox(width: 8),
          Text(
            'L${shelf.level}',
            style: AppTypography.caption.copyWith(
              color: color,
              fontWeight: FontWeight.w700,
              fontSize: 9,
            ),
          ),
          const Spacer(),
          // Growth bars
          ...List.generate(
            5,
            (i) => Container(
              width: 6,
              height: 14 + (i % 3) * 4.0,
              margin: const EdgeInsets.only(right: 2),
              decoration: BoxDecoration(
                color: color.withValues(alpha: 0.4 + i * 0.1),
                borderRadius: AppRadius.smRadius,
              ),
            ),
          ),
          const SizedBox(width: 8),
        ],
      ),
    );
  }

  Color _shelfColor(String health) {
    switch (health) {
      case 'healthy':
        return AppColors.primary;
      case 'warning':
        return const Color(0xFFF57F17);
      case 'critical':
        return AppColors.error;
      default:
        return AppColors.onSurfaceVariant;
    }
  }
}

class ShelfStatus {
  final int level;
  final String health;
  final double? moisture;
  final double? temperature;

  const ShelfStatus({
    required this.level,
    required this.health,
    this.moisture,
    this.temperature,
  });
}
