import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';
import 'package:url_launcher/url_launcher.dart';
import '../../core/theme/theme.dart';
import '../../core/widgets/widgets.dart';
import '../../core/constants/mock_farm_data.dart';

class DigitalTwinScreen extends StatelessWidget {
  final String rackId;
  const DigitalTwinScreen({super.key, required this.rackId});

  Map<String, dynamic> get _rack =>
      MockFarmData.racks.firstWhere((r) => r['id'] == rackId,
          orElse: () => MockFarmData.racks.first);

  @override
  Widget build(BuildContext context) {
    final rack = _rack;
    final isWarning = rack['health'] == 'warning';

    return Scaffold(
      backgroundColor: AppColors.background,
      body: CustomScrollView(
        slivers: [
          SliverAppBar(
            pinned: true,
            backgroundColor: AppColors.surface.withValues(alpha: 0.9),
            leading: IconButton(
              icon: const Icon(Icons.arrow_back_rounded, color: AppColors.onSurface),
              onPressed: () => context.pop(),
            ),
            title: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text('Rack $rackId',
                    style: AppTypography.headlineMd.copyWith(color: AppColors.primary)),
                Text('Operational Intelligence',
                    style: AppTypography.caption.copyWith(
                        color: AppColors.onSurfaceVariant, letterSpacing: 1)),
              ],
            ),
            actions: [
              Padding(
                padding: const EdgeInsets.only(right: 16),
                child: Container(
                  padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 6),
                  decoration: BoxDecoration(
                    color: AppColors.primary.withValues(alpha: 0.1),
                    borderRadius: AppRadius.fullRadius,
                    border: Border.all(color: AppColors.primary.withValues(alpha: 0.2)),
                  ),
                  child: const Row(
                    children: [
                      AIPulseIndicator(size: 6),
                      SizedBox(width: 5),
                      Text('Live Sync',
                          style: TextStyle(
                              fontSize: 11, fontWeight: FontWeight.w700, color: AppColors.primary)),
                    ],
                  ),
                ),
              ),
            ],
          ),
          SliverPadding(
            padding: const EdgeInsets.all(AppSpacing.marginMobile),
            sliver: SliverList(
              delegate: SliverChildListDelegate([
                // Hero Twin Visualization
                _TwinHeroCard(rack: rack, isWarning: isWarning),
                const SizedBox(height: 20),

                // 48h Trend
                _TrendCard(rack: rack),
                const SizedBox(height: 20),

                // AI Reasoning
                Text('AI REASONING FLOW', style: AppTypography.sectionLabel),
                const SizedBox(height: 12),
                AIReasoningTimeline(
                  steps: [
                    const AIReasoningStep(
                      title: 'Sensor data ingested',
                      detail: '12 data points collected across 5 shelves',
                      icon: Icons.sensors_rounded,
                      isDone: true,
                    ),
                    AIReasoningStep(
                      title: 'Anomaly detected',
                      detail: isWarning
                          ? 'Moisture drift detected — Zone B shelf 3'
                          : 'All parameters within optimal range',
                      icon: Icons.search_rounded,
                      isDone: true,
                    ),
                    AIReasoningStep(
                      title: 'Predictive model applied',
                      detail: '91% confidence — Growth model v2.4',
                      icon: Icons.psychology_rounded,
                      isActive: true,
                    ),
                    const AIReasoningStep(
                      title: 'Corrective action scheduled',
                      detail: 'Irrigation cycle queued for +15 minutes',
                      icon: Icons.schedule_rounded,
                    ),
                  ],
                ),
                const SizedBox(height: 20),

                // Recommendations
                Text('OPTIMIZATION ACTIONS', style: AppTypography.sectionLabel),
                const SizedBox(height: 12),
                RecommendationCard(
                  title: 'Activate Irrigation',
                  description: 'Restore moisture to 82% optimal range',
                  actionLabel: 'Apply',
                  icon: Icons.water_drop_rounded,
                  onAction: () {},
                ),
                const SizedBox(height: 10),
                RecommendationCard(
                  title: 'Schedule Harvest',
                  description: 'Rack $rackId ready in ${rack['daysToHarvest']} days',
                  actionLabel: 'Calendar',
                  icon: Icons.calendar_today_rounded,
                  accentColor: AppColors.secondary,
                  onAction: () async {
                    final url = Uri.parse('https://calendar.google.com/calendar/render?action=TEMPLATE&text=Harvest+Rack+$rackId+${rack['crop']}&details=AI+predicted+harvest+time');
                    if (await canLaunchUrl(url)) {
                      await launchUrl(url, mode: LaunchMode.externalApplication);
                    }
                  },
                ),
                const SizedBox(height: 100),
              ]),
            ),
          ),
        ],
      ),
    );
  }
}

class _TwinHeroCard extends StatelessWidget {
  final Map<String, dynamic> rack;
  final bool isWarning;
  const _TwinHeroCard({required this.rack, required this.isWarning});

  @override
  Widget build(BuildContext context) {
    return Container(
      height: 280,
      decoration: BoxDecoration(
        color: const Color(0xFFE0E2DB),
        borderRadius: AppRadius.massiveRadius,
        boxShadow: AppShadows.cardHero,
      ),
      child: Stack(
        children: [
          // Background glow blobs
          Positioned(
            top: 20, left: 20,
            child: Container(
              width: 80, height: 80,
              decoration: BoxDecoration(
                color: AppColors.primary.withValues(alpha: 0.15),
                shape: BoxShape.circle,
              ),
            ),
          ),
          Positioned(
            bottom: 20, right: 20,
            child: Container(
              width: 100, height: 100,
              decoration: BoxDecoration(
                color: AppColors.secondary.withValues(alpha: 0.15),
                shape: BoxShape.circle,
              ),
            ),
          ),
          // Live sync label
          Positioned(
            top: 20, left: 20,
            child: Container(
              padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 6),
              decoration: BoxDecoration(
                color: Colors.white.withValues(alpha: 0.7),
                borderRadius: AppRadius.fullRadius,
              ),
              child: const Row(
                children: [
                  Icon(Icons.data_thresholding_rounded, size: 14, color: AppColors.primary),
                  SizedBox(width: 6),
                  Text('Live Digital Twin Syncing',
                      style: TextStyle(fontSize: 10, fontWeight: FontWeight.w700, color: AppColors.onSurface, letterSpacing: 1)),
                ],
              ),
            ),
          ),
          // Rack visualization
          Center(
            child: Column(
              mainAxisAlignment: MainAxisAlignment.center,
              children: List.generate(3, (i) {
                final isDivergence = i == 1 && isWarning;
                return Container(
                  margin: const EdgeInsets.only(bottom: 8),
                  width: 140,
                  height: 60,
                  decoration: BoxDecoration(
                    color: isDivergence
                        ? AppColors.secondaryContainer.withValues(alpha: 0.5)
                        : Colors.white.withValues(alpha: 0.6),
                    borderRadius: AppRadius.xlRadius,
                    border: Border.all(
                      color: isDivergence
                          ? AppColors.secondary.withValues(alpha: 0.5)
                          : Colors.white.withValues(alpha: 0.8),
                      width: isDivergence ? 2 : 1,
                    ),
                  ),
                  child: Row(
                    mainAxisAlignment: MainAxisAlignment.center,
                    children: [
                      Icon(
                        isDivergence ? Icons.error_rounded : Icons.verified_rounded,
                        color: isDivergence ? AppColors.secondary : AppColors.primary,
                        size: 20,
                      ),
                      const SizedBox(width: 6),
                      Text(
                        isDivergence ? 'DIVERGENCE' : 'STABLE ZONE',
                        style: TextStyle(
                          fontSize: 9,
                          fontWeight: FontWeight.w700,
                          color: isDivergence ? AppColors.secondary : AppColors.primary,
                          letterSpacing: 1,
                        ),
                      ),
                    ],
                  ),
                );
              }),
            ),
          ),
          // AI confidence
          Positioned(
            bottom: 20, left: 20,
            child: Container(
              padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 8),
              decoration: BoxDecoration(
                color: Colors.white.withValues(alpha: 0.7),
                borderRadius: AppRadius.xlRadius,
              ),
              child: const Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Row(
                    children: [
                      Text('91%',
                          style: TextStyle(fontSize: 18, fontWeight: FontWeight.w800, color: AppColors.primary)),
                      SizedBox(width: 6),
                      Text('AI Confidence',
                          style: TextStyle(fontSize: 10, fontWeight: FontWeight.w700, color: AppColors.onSurfaceVariant, letterSpacing: 0.5)),
                    ],
                  ),
                  Text('Live Stream • Growth Model',
                      style: TextStyle(fontSize: 9, color: AppColors.onSurfaceVariant)),
                ],
              ),
            ),
          ),
        ],
      ),
    );
  }
}

class _TrendCard extends StatelessWidget {
  final Map<String, dynamic> rack;
  const _TrendCard({required this.rack});

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.all(20),
      decoration: BoxDecoration(
        color: Colors.white.withValues(alpha: 0.7),
        borderRadius: AppRadius.card,
        border: Border.all(color: AppColors.outlineVariant.withValues(alpha: 0.5)),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text('48H TREND CHANGE', style: AppTypography.sectionLabel),
          const SizedBox(height: 12),
          Row(
            children: [
              Expanded(child: _TrendMetric(label: 'Humidity Spike', value: '+14%', isNegative: true)),
              Container(width: 1, height: 40, color: AppColors.outlineVariant),
              Expanded(child: _TrendMetric(label: 'Consistency', value: '-6%', isNegative: true)),
              Container(width: 1, height: 40, color: AppColors.outlineVariant),
              Expanded(child: _TrendMetric(label: 'Growth Rate', value: '+3%', isNegative: false)),
            ],
          ),
        ],
      ),
    );
  }
}

class _TrendMetric extends StatelessWidget {
  final String label;
  final String value;
  final bool isNegative;
  const _TrendMetric({required this.label, required this.value, required this.isNegative});

  @override
  Widget build(BuildContext context) {
    final color = isNegative ? AppColors.secondary : AppColors.primary;
    return Column(
      children: [
        Text(value,
            style: AppTypography.headlineMd.copyWith(color: color, fontSize: 20),
            textAlign: TextAlign.center),
        Text(label,
            style: AppTypography.caption.copyWith(color: AppColors.onSurfaceVariant),
            textAlign: TextAlign.center),
      ],
    );
  }
}
