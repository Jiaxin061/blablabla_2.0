import 'package:flutter/material.dart';
import '../../../core/theme/theme.dart';
import '../../../core/constants/mock_farm_data.dart';

/// Displays individual plant monitoring cards for a single rack level.
/// Used only for Rack B, levels 3 and 5.
class PlantLevelGrid extends StatelessWidget {
  final int level;
  const PlantLevelGrid({super.key, required this.level});

  @override
  Widget build(BuildContext context) {
    final plants = MockFarmData.rackBPlantLevels[level];
    if (plants == null || plants.isEmpty) return const SizedBox.shrink();

    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        _LevelHeader(level: level),
        const SizedBox(height: 12),
        SizedBox(
          height: 92,
          child: ListView.separated(
            scrollDirection: Axis.horizontal,
            padding: EdgeInsets.zero,
            itemCount: plants.length,
            separatorBuilder: (_, __) => const SizedBox(width: 10),
            itemBuilder: (context, i) => _PlantCard(
              plant: plants[i],
              onTap: () => _showPlantDetail(context, plants[i]),
            ),
          ),
        ),
      ],
    );
  }

  void _showPlantDetail(BuildContext context, Map<String, dynamic> plant) {
    showModalBottomSheet(
      context: context,
      isScrollControlled: true,
      backgroundColor: Colors.transparent,
      builder: (_) => _PlantDetailSheet(plant: plant),
    );
  }
}

class _LevelHeader extends StatelessWidget {
  final int level;
  const _LevelHeader({required this.level});

  @override
  Widget build(BuildContext context) {
    return Row(
      children: [
        Container(
          width: 4,
          height: 18,
          decoration: BoxDecoration(
            color: AppColors.primary,
            borderRadius: BorderRadius.circular(2),
          ),
        ),
        const SizedBox(width: 8),
        Text(
          'Level $level — Individual Plant Monitor',
          style: AppTypography.sectionLabel.copyWith(
            color: AppColors.primary,
            fontSize: 12,
          ),
        ),
      ],
    );
  }
}

class _PlantCard extends StatelessWidget {
  final Map<String, dynamic> plant;
  final VoidCallback onTap;
  const _PlantCard({required this.plant, required this.onTap});

  Color get _dotColor {
    return switch (plant['status'] as String) {
      'healthy' => AppColors.statusHealthy,
      'warning' => AppColors.statusWarning,
      'critical' => AppColors.statusCritical,
      _ => AppColors.onSurfaceVariant,
    };
  }

  @override
  Widget build(BuildContext context) {
    final id = plant['id'] as String;
    final health = plant['health'] as int;
    final shortId = id.split('-').last; // "P01"

    return GestureDetector(
      onTap: onTap,
      child: Container(
        width: 76,
        padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 10),
        decoration: BoxDecoration(
          color: Colors.white,
          borderRadius: AppRadius.xxlRadius,
          border: Border.all(color: AppColors.outlineVariant.withValues(alpha: 0.5)),
          boxShadow: AppShadows.card,
        ),
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Container(
              width: 14,
              height: 14,
              decoration: BoxDecoration(
                color: _dotColor,
                shape: BoxShape.circle,
                boxShadow: [
                  BoxShadow(
                    color: _dotColor.withValues(alpha: 0.35),
                    blurRadius: 6,
                    spreadRadius: 1,
                  ),
                ],
              ),
            ),
            const SizedBox(height: 8),
            Text(
              shortId,
              style: AppTypography.labelLg.copyWith(
                fontSize: 11,
                fontWeight: FontWeight.w800,
                color: AppColors.onSurface,
              ),
            ),
            const SizedBox(height: 4),
            Text(
              '$health%',
              style: AppTypography.caption.copyWith(
                fontSize: 10,
                color: AppColors.onSurfaceVariant,
              ),
            ),
          ],
        ),
      ),
    );
  }
}

class _PlantDetailSheet extends StatelessWidget {
  final Map<String, dynamic> plant;
  const _PlantDetailSheet({required this.plant});

  Color get _statusColor {
    return switch (plant['status'] as String) {
      'healthy' => AppColors.statusHealthy,
      'warning' => AppColors.statusWarning,
      'critical' => AppColors.statusCritical,
      _ => AppColors.onSurfaceVariant,
    };
  }

  String get _statusLabel {
    return switch (plant['status'] as String) {
      'healthy' => 'Healthy',
      'warning' => 'Nutrient Deficiency',
      'critical' => 'Possible Disease',
      _ => 'Unknown',
    };
  }

  @override
  Widget build(BuildContext context) {
    final id = plant['id'] as String;
    final health = plant['health'] as int;
    final issue = plant['issue'] as String;
    final confidence = plant['confidence'] as int;
    final recommendation = plant['recommendation'] as String;
    final zoomAsset = plant['zoomAsset'] as String;
    final hasIssue = issue.isNotEmpty;

    return Container(
      decoration: BoxDecoration(
        color: AppColors.surface,
        borderRadius: AppRadius.bottomSheet,
      ),
      child: Column(
        mainAxisSize: MainAxisSize.min,
        children: [
          const SizedBox(height: 12),
          Container(
            width: 40,
            height: 4,
            decoration: BoxDecoration(
              color: AppColors.outlineVariant,
              borderRadius: BorderRadius.circular(2),
            ),
          ),
          const SizedBox(height: 16),
          // Zoom image
          _ZoomImage(assetPath: zoomAsset),
          Padding(
            padding: const EdgeInsets.fromLTRB(20, 20, 20, 0),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                // Plant ID + status badge + health/unhealthy thumbnail
                Row(
                  crossAxisAlignment: CrossAxisAlignment.center,
                  children: [
                    _StatusThumbnail(status: plant['status'] as String),
                    const SizedBox(width: 14),
                    Expanded(
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Text(
                            id,
                            style: AppTypography.headlineMd.copyWith(fontSize: 20),
                          ),
                          const SizedBox(height: 6),
                          Container(
                            padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 5),
                            decoration: BoxDecoration(
                              color: _statusColor.withValues(alpha: 0.1),
                              borderRadius: AppRadius.fullRadius,
                              border: Border.all(color: _statusColor.withValues(alpha: 0.3)),
                            ),
                            child: Row(
                              mainAxisSize: MainAxisSize.min,
                              children: [
                                Container(
                                  width: 8,
                                  height: 8,
                                  decoration: BoxDecoration(
                                    color: _statusColor,
                                    shape: BoxShape.circle,
                                  ),
                                ),
                                const SizedBox(width: 5),
                                Text(
                                  _statusLabel,
                                  style: AppTypography.caption.copyWith(
                                    color: _statusColor,
                                    fontWeight: FontWeight.w800,
                                    fontSize: 10,
                                  ),
                                ),
                              ],
                            ),
                          ),
                        ],
                      ),
                    ),
                  ],
                ),
                const SizedBox(height: 20),
                // Health Score
                Text(
                  'HEALTH SCORE',
                  style: AppTypography.sectionLabel,
                ),
                const SizedBox(height: 8),
                Row(
                  children: [
                    Expanded(
                      child: ClipRRect(
                        borderRadius: BorderRadius.circular(4),
                        child: LinearProgressIndicator(
                          value: health / 100,
                          minHeight: 10,
                          backgroundColor: AppColors.surfaceContainerHighest,
                          valueColor: AlwaysStoppedAnimation<Color>(_statusColor),
                        ),
                      ),
                    ),
                    const SizedBox(width: 12),
                    Text(
                      '$health%',
                      style: AppTypography.labelLg.copyWith(
                        color: _statusColor,
                        fontWeight: FontWeight.w800,
                      ),
                    ),
                  ],
                ),
                if (hasIssue) ...[
                  const SizedBox(height: 20),
                  // Issue + Confidence
                  Container(
                    padding: const EdgeInsets.all(14),
                    decoration: BoxDecoration(
                      color: _statusColor.withValues(alpha: 0.06),
                      borderRadius: AppRadius.xlRadius,
                      border: Border.all(color: _statusColor.withValues(alpha: 0.15)),
                    ),
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Row(
                          children: [
                            Icon(
                              Icons.warning_amber_rounded,
                              size: 16,
                              color: _statusColor,
                            ),
                            const SizedBox(width: 6),
                            Expanded(
                              child: Text(
                                issue,
                                style: AppTypography.labelLg.copyWith(
                                  fontSize: 14,
                                  color: _statusColor,
                                ),
                              ),
                            ),
                            Container(
                              padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 3),
                              decoration: BoxDecoration(
                                color: _statusColor.withValues(alpha: 0.12),
                                borderRadius: AppRadius.fullRadius,
                              ),
                              child: Text(
                                '$confidence% confidence',
                                style: AppTypography.caption.copyWith(
                                  color: _statusColor,
                                  fontWeight: FontWeight.w800,
                                ),
                              ),
                            ),
                          ],
                        ),
                        if (recommendation.isNotEmpty) ...[
                          const SizedBox(height: 10),
                          Row(
                            crossAxisAlignment: CrossAxisAlignment.start,
                            children: [
                              Icon(
                                Icons.lightbulb_outline_rounded,
                                size: 14,
                                color: AppColors.onSurfaceVariant,
                              ),
                              const SizedBox(width: 6),
                              Expanded(
                                child: Text(
                                  recommendation,
                                  style: AppTypography.caption.copyWith(
                                    fontSize: 11,
                                    color: AppColors.onSurfaceVariant,
                                  ),
                                ),
                              ),
                            ],
                          ),
                        ],
                      ],
                    ),
                  ),
                ],
                const SizedBox(height: 28),
              ],
            ),
          ),
          SizedBox(height: MediaQuery.of(context).padding.bottom),
        ],
      ),
    );
  }
}

class _StatusThumbnail extends StatelessWidget {
  final String status;
  const _StatusThumbnail({required this.status});

  String get _assetPath => status == 'healthy'
      ? 'assets/images/healthy.png'
      : 'assets/images/unhealthy.png';

  @override
  Widget build(BuildContext context) {
    return Container(
      width: 72,
      height: 72,
      decoration: BoxDecoration(
        color: AppColors.surfaceContainerHighest,
        borderRadius: AppRadius.xxlRadius,
        border: Border.all(color: AppColors.outlineVariant.withValues(alpha: 0.4)),
      ),
      clipBehavior: Clip.hardEdge,
      child: Image.asset(
        _assetPath,
        fit: BoxFit.cover,
        errorBuilder: (_, __, ___) => Center(
          child: Icon(
            status == 'healthy'
                ? Icons.eco_outlined
                : Icons.warning_amber_rounded,
            size: 28,
            color: AppColors.onSurfaceVariant.withValues(alpha: 0.4),
          ),
        ),
      ),
    );
  }
}

class _ZoomImage extends StatelessWidget {
  final String assetPath;
  const _ZoomImage({required this.assetPath});

  @override
  Widget build(BuildContext context) {
    final assetLabel = assetPath.split('/').last.replaceAll('.png', '');
    return Container(
      width: double.infinity,
      height: 200,
      margin: const EdgeInsets.symmetric(horizontal: 20),
      decoration: BoxDecoration(
        color: AppColors.surfaceContainerHighest,
        borderRadius: AppRadius.xxlRadius,
      ),
      clipBehavior: Clip.hardEdge,
      child: Image.asset(
        assetPath,
        fit: BoxFit.cover,
        errorBuilder: (_, __, ___) => Center(
          child: Column(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              Icon(
                Icons.image_outlined,
                size: 36,
                color: AppColors.onSurfaceVariant.withValues(alpha: 0.4),
              ),
              const SizedBox(height: 8),
              Text(
                'Image: $assetLabel',
                style: AppTypography.caption.copyWith(
                  color: AppColors.onSurfaceVariant,
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}
