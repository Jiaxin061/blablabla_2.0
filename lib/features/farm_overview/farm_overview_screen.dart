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
          // AI Summary banner
          AIInsightCard(
            insight:
                'All 3 racks are within operational parameters. Rack B requires attention — moisture drift detected. Predictive irrigation active.',
            reasoning: 'Based on 48h sensor trend analysis',
            icon: Icons.monitor_heart_rounded,
          ),
          const SizedBox(height: AppSpacing.stackSpace),

          // Rack towers
          Text('RACK VISUALIZATION', style: AppTypography.sectionLabel),
          const SizedBox(height: 12),
          ...farm.racks.map((rack) {
            final shelves = List.generate(
              5,
              (i) => ShelfStatus(
                level: i + 1,
                health: i == 2 && rack['id'] == 'B' ? 'warning' : 'healthy',
                moisture: (rack['moisture'] as int).toDouble(),
              ),
            );
            return Padding(
              padding: const EdgeInsets.only(bottom: 14),
              child: RackTowerCard(
                rackId: rack['id'] as String,
                cropName: rack['crop'] as String,
                totalShelves: 5,
                shelves: shelves,
                status: rack['health'] as String,
                onTap: () => context.go(
                  '${AppRoutes.farmOverview}/digital-twin/${rack['id']}',
                ),
              ),
            );
          }),

          const SizedBox(height: 80),
        ],
      ),
    );
  }
}
