import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';
import '../../core/theme/theme.dart';
import '../../core/widgets/widgets.dart';
import '../../core/services/farm_provider.dart';
import '../../core/routing/app_router.dart';

class FarmOverviewScreen extends ConsumerWidget {
  const FarmOverviewScreen({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final farm = ref.watch(farmProvider);

    return Scaffold(
      backgroundColor: AppColors.background,
      appBar: AppBar(
        backgroundColor: AppColors.surface.withValues(alpha: 0.9),
        title: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text('Farm Overview',
                style: AppTypography.headlineMd.copyWith(color: AppColors.primary)),
            Text('Live Digital Twin',
                style: AppTypography.caption.copyWith(
                    color: AppColors.onSurfaceVariant, letterSpacing: 1)),
          ],
        ),
        actions: [
          Padding(
            padding: const EdgeInsets.only(right: 16),
            child: Container(
              padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 6),
              decoration: BoxDecoration(
                color: AppColors.primary.withValues(alpha: 0.1),
                borderRadius: AppRadius.fullRadius,
                border: Border.all(color: AppColors.primary.withValues(alpha: 0.2)),
              ),
              child: const Row(
                children: [
                  AIPulseIndicator(size: 7),
                  SizedBox(width: 6),
                  Text('Live Sync',
                      style: TextStyle(
                          fontSize: 12,
                          fontWeight: FontWeight.w700,
                          color: AppColors.primary)),
                ],
              ),
            ),
          ),
        ],
      ),
      body: ListView(
        padding: const EdgeInsets.all(AppSpacing.marginMobile),
        children: [
          AIInsightCard(
            insight:
                'All 3 racks are within operational parameters. Rack B requires attention — moisture drift detected. Predictive irrigation active.',
            reasoning: 'Based on 48h sensor trend analysis',
            icon: Icons.monitor_heart_rounded,
          ),
          const SizedBox(height: AppSpacing.stackSpace),

          Text('RACK VISUALIZATION', style: AppTypography.sectionLabel),
          const SizedBox(height: 12),
          ...farm.racks.map((rack) => Padding(
                padding: const EdgeInsets.only(bottom: 14),
                child: _RackExpandableCard(
                  rack: rack,
                  onViewTwin: () => context.go(
                    '${AppRoutes.farmOverview}/digital-twin/${rack['id']}',
                  ),
                ),
              )),

          const SizedBox(height: 80),
        ],
      ),
    );
  }
}

// ─── Expandable Rack Card ────────────────────────────────────────────────────

class _RackExpandableCard extends StatefulWidget {
  final Map<String, dynamic> rack;
  final VoidCallback onViewTwin;

  const _RackExpandableCard({
    required this.rack,
    required this.onViewTwin,
  });

  @override
  State<_RackExpandableCard> createState() => _RackExpandableCardState();
}

class _RackExpandableCardState extends State<_RackExpandableCard> {
  bool _expanded = false;

  @override
  Widget build(BuildContext context) {
    final rack = widget.rack;
    final isWarning = rack['health'] == 'warning';
    final borderColor = isWarning
        ? AppColors.secondary.withValues(alpha: 0.4)
        : AppColors.primary.withValues(alpha: 0.2);

    return Container(
      decoration: BoxDecoration(
        color: AppColors.surfaceContainerLowest,
        borderRadius: AppRadius.card,
        border: Border.all(color: borderColor, width: 1.5),
        boxShadow: AppShadows.card,
      ),
      clipBehavior: Clip.antiAlias,
      child: Column(
        mainAxisSize: MainAxisSize.min,
        children: [
          _buildHeader(rack, isWarning),
          _buildShelfViz(rack),
          _buildExpandToggle(rack),
          AnimatedSize(
            duration: const Duration(milliseconds: 280),
            curve: Curves.easeInOut,
            child: _expanded ? _buildDetailsPanel(rack, isWarning) : const SizedBox.shrink(),
          ),
        ],
      ),
    );
  }

  // ─── Header ────────────────────────────────────────────────────────────────

  Widget _buildHeader(Map<String, dynamic> rack, bool isWarning) {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 12),
      decoration: BoxDecoration(
        color: isWarning
            ? AppColors.secondaryContainer.withValues(alpha: 0.3)
            : AppColors.primaryFixed.withValues(alpha: 0.2),
      ),
      child: Row(
        children: [
          Text(
            'RACK ${rack['id']}',
            style: AppTypography.sectionLabel.copyWith(
              color: isWarning ? AppColors.secondary : AppColors.primary,
            ),
          ),
          const SizedBox(width: 8),
          Text(
            rack['stage'] as String,
            style: AppTypography.caption.copyWith(
              color: AppColors.onSurfaceVariant,
            ),
          ),
          const Spacer(),
          _HealthBadge(isWarning: isWarning),
        ],
      ),
    );
  }

  // ─── Shelf Visualization ───────────────────────────────────────────────────

  Widget _buildShelfViz(Map<String, dynamic> rack) {
    final levels = rack['levels'] as List<dynamic>;

    return Padding(
      padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 8),
      child: Column(
        children: List.generate(levels.length, (i) {
          final level = levels[i] as Map<String, dynamic>;
          final isLevelWarning = level['status'] == 'warning';
          final color = isLevelWarning ? AppColors.statusWarning : AppColors.primary;
          final isLast = i == levels.length - 1;

          return Container(
            margin: EdgeInsets.only(bottom: isLast ? 0 : 4),
            height: 28,
            decoration: BoxDecoration(
              color: color.withValues(alpha: 0.12),
              borderRadius: AppRadius.smRadius,
              border: Border.all(color: color.withValues(alpha: 0.3), width: 1),
            ),
            child: Row(
              children: [
                const SizedBox(width: 8),
                Text(
                  'L${level['level']}',
                  style: AppTypography.caption.copyWith(
                    color: color,
                    fontWeight: FontWeight.w700,
                    fontSize: 9,
                  ),
                ),
                const Spacer(),
                ...List.generate(
                  5,
                  (j) => Container(
                    width: 6,
                    height: 14 + (j % 3) * 4.0,
                    margin: const EdgeInsets.only(right: 2),
                    decoration: BoxDecoration(
                      color: color.withValues(alpha: 0.4 + j * 0.1),
                      borderRadius: AppRadius.smRadius,
                    ),
                  ),
                ),
                const SizedBox(width: 8),
              ],
            ),
          );
        }),
      ),
    );
  }

  // ─── Expand Toggle Row ─────────────────────────────────────────────────────

  Widget _buildExpandToggle(Map<String, dynamic> rack) {
    return InkWell(
      onTap: () => setState(() => _expanded = !_expanded),
      child: Padding(
        padding: const EdgeInsets.fromLTRB(16, 0, 16, 12),
        child: Row(
          children: [
            Icon(Icons.grass_rounded, color: AppColors.primary, size: 14),
            const SizedBox(width: 4),
            Expanded(
              child: Text(
                rack['crop'] as String,
                style: AppTypography.caption.copyWith(
                  color: AppColors.onSurfaceVariant,
                  fontWeight: FontWeight.w600,
                ),
                overflow: TextOverflow.ellipsis,
              ),
            ),
            Text(
              _expanded ? 'Hide details' : 'Show details',
              style: AppTypography.caption.copyWith(
                color: AppColors.primary,
                fontWeight: FontWeight.w700,
              ),
            ),
            const SizedBox(width: 4),
            AnimatedRotation(
              turns: _expanded ? 0.5 : 0.0,
              duration: const Duration(milliseconds: 280),
              child: const Icon(
                Icons.keyboard_arrow_down_rounded,
                color: AppColors.primary,
                size: 18,
              ),
            ),
          ],
        ),
      ),
    );
  }

  // ─── Details Panel ─────────────────────────────────────────────────────────

  Widget _buildDetailsPanel(Map<String, dynamic> rack, bool isWarning) {
    final levels = rack['levels'] as List<dynamic>;
    final healthyCount = levels
        .where((l) => (l as Map<String, dynamic>)['status'] == 'healthy')
        .length;
    final warningLevels = levels
        .where((l) => (l as Map<String, dynamic>)['status'] == 'warning')
        .map((l) => (l as Map<String, dynamic>)['level'] as int)
        .toList();

    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Divider(
          color: AppColors.outlineVariant.withValues(alpha: 0.5),
          height: 1,
        ),
        Padding(
          padding: const EdgeInsets.all(16),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              _buildSectionLabel('ENVIRONMENT'),
              const SizedBox(height: 8),
              _buildEnvStrip(rack),
              const SizedBox(height: 14),

              _buildSectionLabel('CROP CONDITION'),
              const SizedBox(height: 8),
              _buildCropCondition(rack, healthyCount, warningLevels, isWarning),
              const SizedBox(height: 14),

              _buildSectionLabel('LAST WATERED'),
              const SizedBox(height: 8),
              _buildWateringHistory(rack),
              const SizedBox(height: 14),

              _buildSectionLabel('AI RECOMMENDATION'),
              const SizedBox(height: 8),
              _buildAIRecommendation(rack),
              const SizedBox(height: 14),

              _buildViewTwinButton(),
            ],
          ),
        ),
      ],
    );
  }

  Widget _buildSectionLabel(String text) => Text(
        text,
        style: AppTypography.sectionLabel,
      );

  // ─── Section A: Environment Strip ─────────────────────────────────────────

  Widget _buildEnvStrip(Map<String, dynamic> rack) {
    return Container(
      padding: const EdgeInsets.symmetric(vertical: 12, horizontal: 8),
      decoration: BoxDecoration(
        color: AppColors.surfaceContainerLow,
        borderRadius: AppRadius.lgRadius,
        border: Border.all(
          color: AppColors.outlineVariant.withValues(alpha: 0.5),
        ),
      ),
      child: Row(
        children: [
          _EnvMetricTile(
            icon: Icons.water_drop_rounded,
            value: '${rack['moisture']}%',
            label: 'Moisture',
            color: AppColors.primary,
          ),
          _verticalDivider(),
          _EnvMetricTile(
            icon: Icons.thermostat_rounded,
            value: '${rack['temperature']}°C',
            label: 'Temp',
            color: AppColors.statusWarning,
          ),
          _verticalDivider(),
          _EnvMetricTile(
            icon: Icons.science_rounded,
            value: '${rack['ph']}',
            label: 'pH',
            color: AppColors.secondary,
          ),
          _verticalDivider(),
          _EnvMetricTile(
            icon: Icons.electric_bolt_rounded,
            value: '${rack['ec']}',
            label: 'EC',
            color: AppColors.tertiary,
          ),
        ],
      ),
    );
  }

  Widget _verticalDivider() => Container(
        width: 1,
        height: 36,
        color: AppColors.outlineVariant.withValues(alpha: 0.5),
        margin: const EdgeInsets.symmetric(horizontal: 4),
      );

  // ─── Section B: Crop Condition ─────────────────────────────────────────────

  Widget _buildCropCondition(
    Map<String, dynamic> rack,
    int healthyCount,
    List<int> warningLevels,
    bool isWarning,
  ) {
    final statusColor = isWarning ? AppColors.statusWarning : AppColors.statusHealthy;
    final conditionText = isWarning && warningLevels.isNotEmpty
        ? '$healthyCount/5 levels healthy · Level ${warningLevels.join(', ')} needs attention'
        : '$healthyCount/5 levels healthy';

    return Container(
      padding: const EdgeInsets.all(12),
      decoration: BoxDecoration(
        color: statusColor.withValues(alpha: 0.06),
        borderRadius: AppRadius.lgRadius,
        border: Border.all(color: statusColor.withValues(alpha: 0.25)),
      ),
      child: Row(
        children: [
          Container(
            padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 5),
            decoration: BoxDecoration(
              color: statusColor,
              borderRadius: AppRadius.chip,
            ),
            child: Text(
              isWarning ? 'Warning' : 'Healthy',
              style: AppTypography.caption.copyWith(
                color: AppColors.onPrimary,
                fontWeight: FontWeight.w700,
                fontSize: 10,
              ),
            ),
          ),
          const SizedBox(width: 12),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  rack['crop'] as String,
                  style: AppTypography.labelLg.copyWith(
                    fontSize: 13,
                    color: AppColors.onSurface,
                  ),
                ),
                const SizedBox(height: 2),
                Text(
                  conditionText,
                  style: AppTypography.caption.copyWith(
                    color: statusColor,
                    fontWeight: FontWeight.w600,
                    fontSize: 10,
                  ),
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }

  // ─── Section C: Watering History ──────────────────────────────────────────

  Widget _buildWateringHistory(Map<String, dynamic> rack) {
    final history = rack['wateringHistory'] as List<dynamic>;

    return Column(
      children: history.map((entry) {
        final e = entry as Map<String, dynamic>;
        final isAuto = e['triggered'] == 'Auto';
        final badgeColor = isAuto ? AppColors.primary : AppColors.secondary;

        return Padding(
          padding: const EdgeInsets.only(bottom: 7),
          child: Row(
            children: [
              Icon(
                Icons.water_drop_outlined,
                size: 12,
                color: AppColors.primary.withValues(alpha: 0.6),
              ),
              const SizedBox(width: 7),
              Expanded(
                child: Text(
                  e['time'] as String,
                  style: AppTypography.caption.copyWith(
                    color: AppColors.onSurface,
                    fontWeight: FontWeight.w600,
                    fontSize: 11,
                  ),
                ),
              ),
              Text(
                e['duration'] as String,
                style: AppTypography.caption.copyWith(
                  color: AppColors.onSurfaceVariant,
                  fontSize: 11,
                ),
              ),
              const SizedBox(width: 8),
              Container(
                padding: const EdgeInsets.symmetric(horizontal: 7, vertical: 2),
                decoration: BoxDecoration(
                  color: badgeColor.withValues(alpha: 0.1),
                  borderRadius: AppRadius.chip,
                  border: Border.all(color: badgeColor.withValues(alpha: 0.3)),
                ),
                child: Text(
                  e['triggered'] as String,
                  style: AppTypography.caption.copyWith(
                    color: badgeColor,
                    fontWeight: FontWeight.w700,
                    fontSize: 9,
                  ),
                ),
              ),
            ],
          ),
        );
      }).toList(),
    );
  }

  // ─── Section D: AI Recommendation ─────────────────────────────────────────

  Widget _buildAIRecommendation(Map<String, dynamic> rack) {
    return Container(
      padding: const EdgeInsets.all(12),
      decoration: BoxDecoration(
        color: AppColors.primaryFixed.withValues(alpha: 0.25),
        borderRadius: AppRadius.lgRadius,
        border: Border.all(color: AppColors.primary.withValues(alpha: 0.2)),
      ),
      child: Row(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Container(
            padding: const EdgeInsets.all(6),
            decoration: BoxDecoration(
              color: AppColors.primary.withValues(alpha: 0.12),
              borderRadius: AppRadius.smRadius,
            ),
            child: const Icon(
              Icons.psychology_rounded,
              size: 16,
              color: AppColors.primary,
            ),
          ),
          const SizedBox(width: 10),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  'AI Recommendation',
                  style: AppTypography.caption.copyWith(
                    color: AppColors.primary,
                    fontWeight: FontWeight.w700,
                    letterSpacing: 0.5,
                  ),
                ),
                const SizedBox(height: 5),
                Text(
                  rack['aiRecommendation'] as String,
                  style: AppTypography.caption.copyWith(
                    color: AppColors.onPrimaryFixed,
                    height: 1.55,
                    fontSize: 11,
                  ),
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }

  // ─── View Digital Twin Button ──────────────────────────────────────────────

  Widget _buildViewTwinButton() {
    return GestureDetector(
      onTap: widget.onViewTwin,
      child: Container(
        width: double.infinity,
        padding: const EdgeInsets.symmetric(vertical: 11),
        decoration: BoxDecoration(
          color: AppColors.primary,
          borderRadius: AppRadius.lgRadius,
          boxShadow: AppShadows.buttonPrimary,
        ),
        child: Row(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            const Icon(
              Icons.view_in_ar_rounded,
              size: 14,
              color: AppColors.onPrimary,
            ),
            const SizedBox(width: 7),
            Text(
              'View Digital Twin',
              style: AppTypography.caption.copyWith(
                color: AppColors.onPrimary,
                fontWeight: FontWeight.w700,
                letterSpacing: 0.5,
                fontSize: 12,
              ),
            ),
          ],
        ),
      ),
    );
  }
}

// ─── Health Badge Pill ────────────────────────────────────────────────────────

class _HealthBadge extends StatelessWidget {
  final bool isWarning;

  const _HealthBadge({required this.isWarning});

  @override
  Widget build(BuildContext context) {
    final color = isWarning ? AppColors.statusWarning : AppColors.statusHealthy;

    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 3),
      decoration: BoxDecoration(
        color: color.withValues(alpha: 0.12),
        borderRadius: AppRadius.chip,
        border: Border.all(color: color.withValues(alpha: 0.35)),
      ),
      child: Row(
        mainAxisSize: MainAxisSize.min,
        children: [
          Icon(
            isWarning ? Icons.warning_amber_rounded : Icons.check_circle_rounded,
            size: 10,
            color: color,
          ),
          const SizedBox(width: 3),
          Text(
            isWarning ? 'Warning' : 'Healthy',
            style: AppTypography.caption.copyWith(
              color: color,
              fontWeight: FontWeight.w700,
              fontSize: 9,
            ),
          ),
        ],
      ),
    );
  }
}

// ─── Environment Metric Tile ──────────────────────────────────────────────────

class _EnvMetricTile extends StatelessWidget {
  final IconData icon;
  final String value;
  final String label;
  final Color color;

  const _EnvMetricTile({
    required this.icon,
    required this.value,
    required this.label,
    required this.color,
  });

  @override
  Widget build(BuildContext context) {
    return Expanded(
      child: Column(
        mainAxisSize: MainAxisSize.min,
        children: [
          Icon(icon, size: 16, color: color),
          const SizedBox(height: 4),
          Text(
            value,
            style: AppTypography.caption.copyWith(
              color: AppColors.onSurface,
              fontWeight: FontWeight.w700,
              fontSize: 11,
            ),
            textAlign: TextAlign.center,
          ),
          const SizedBox(height: 2),
          Text(
            label,
            style: AppTypography.caption.copyWith(
              color: AppColors.onSurfaceVariant,
              fontSize: 9,
            ),
            textAlign: TextAlign.center,
          ),
        ],
      ),
    );
  }
}
