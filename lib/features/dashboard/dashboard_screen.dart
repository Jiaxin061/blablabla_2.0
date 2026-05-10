import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';
import '../../core/theme/theme.dart';
import '../../core/constants/app_constants.dart';
import '../../core/constants/mock_farm_data.dart';
import '../../core/routing/app_router.dart';
import '../../core/widgets/widgets.dart';
import '../../core/services/farm_provider.dart';
import 'widgets/farm_health_hero.dart';
import 'widgets/quick_action_grid.dart';
import 'widgets/ai_activity_timeline.dart';
import 'widgets/metric_tabs_section.dart';
import 'widgets/rack_status_row.dart';

class DashboardScreen extends ConsumerWidget {
  const DashboardScreen({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final farm = ref.watch(farmProvider);

    return Scaffold(
      backgroundColor: AppColors.background,
      body: CustomScrollView(
        slivers: [
          // ── App Bar ──────────────────────────────────────────────────────
          SliverAppBar(
            floating: true,
            backgroundColor: AppColors.surface.withValues(alpha: 0.9),
            surfaceTintColor: Colors.transparent,
            elevation: 0,
            pinned: false,
            toolbarHeight: 64,
            flexibleSpace: Padding(
              padding: EdgeInsets.only(
                top: MediaQuery.of(context).padding.top,
                left: AppSpacing.marginMobile,
                right: AppSpacing.marginMobile,
              ),
              child: Row(
                children: [
                  // Avatar
                  Container(
                    width: 40,
                    height: 40,
                    decoration: BoxDecoration(
                      shape: BoxShape.circle,
                      border: Border.all(
                        color: AppColors.primaryFixed,
                        width: 2,
                      ),
                      color: AppColors.primaryFixed,
                    ),
                    child: const Icon(
                      Icons.person_rounded,
                      color: AppColors.primary,
                      size: 22,
                    ),
                  ),
                  const SizedBox(width: AppSpacing.sm),
                  Column(
                    mainAxisAlignment: MainAxisAlignment.center,
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Row(
                        children: [
                          Text(
                            'vBlaFarm',
                            style: AppTypography.headlineMd.copyWith(
                              color: AppColors.primary,
                              fontWeight: FontWeight.w800,
                            ),
                          ),
                          const SizedBox(width: 8),
                          // AI Active badge
                          Container(
                            padding: const EdgeInsets.symmetric(
                              horizontal: 8,
                              vertical: 3,
                            ),
                            decoration: BoxDecoration(
                              color: AppColors.primary.withValues(alpha: 0.1),
                              borderRadius: AppRadius.fullRadius,
                            ),
                            child: const Row(
                              children: [
                                AIPulseIndicator(size: 6),
                                SizedBox(width: 4),
                                Text(
                                  'AI Active',
                                  style: TextStyle(
                                    fontSize: 10,
                                    fontWeight: FontWeight.w700,
                                    color: AppColors.primary,
                                    letterSpacing: 0.5,
                                  ),
                                ),
                              ],
                            ),
                          ),
                        ],
                      ),
                    ],
                  ),
                  const Spacer(),
                  // Settings button
                  GestureDetector(
                    onTap: () => context.push(AppRoutes.settings),
                    child: Container(
                      width: 40,
                      height: 40,
                      decoration: BoxDecoration(
                        color: AppColors.surfaceContainerHigh,
                        borderRadius: AppRadius.mdRadius,
                      ),
                      child: const Icon(
                        Icons.settings_rounded,
                        color: AppColors.onSurfaceVariant,
                        size: 22,
                      ),
                    ),
                  ),
                ],
              ),
            ),
          ),

          // ── Body ─────────────────────────────────────────────────────────
          SliverPadding(
            padding: const EdgeInsets.symmetric(
              horizontal: AppSpacing.marginMobile,
            ),
            sliver: SliverList(
              delegate: SliverChildListDelegate([
                const SizedBox(height: AppSpacing.lg),

                // 1. AI Farm Health Hero
                FarmHealthHero(
                  healthScore: farm.metrics['healthScore'] as int,
                  isSyncing: farm.isSyncing,
                  onRefresh: () => ref.read(farmProvider.notifier).refresh(),
                ),

                const SizedBox(height: AppSpacing.stackSpace),

                // 2. Priority alert chips
                _AlertChipsRow(alerts: MockFarmData.alerts),

                const SizedBox(height: AppSpacing.stackSpace),

                // 3. Quick Actions
                const QuickActionGrid(),

                const SizedBox(height: AppSpacing.stackSpace),

                // 4. Rack status mini grid
                RackStatusRow(racks: farm.racks),

                const SizedBox(height: AppSpacing.stackSpace),

                // 5. AI Autonomous Activity
                const AiActivityTimeline(),

                const SizedBox(height: AppSpacing.stackSpace),

                // 6. Metric Tabs
                const MetricTabsSection(),

                const SizedBox(height: 120), // bottom nav clearance
              ]),
            ),
          ),
        ],
      ),

      // Floating AI Assistant Button
      floatingActionButton: _AskAIFab(
        onTap: () => context.go(AppRoutes.chat),
      ),
      floatingActionButtonLocation: FloatingActionButtonLocation.endFloat,
    );
  }
}

// ─── Alert Chips Row ──────────────────────────────────────────────────────────

class _AlertChipsRow extends StatelessWidget {
  final List<Map<String, dynamic>> alerts;
  const _AlertChipsRow({required this.alerts});

  @override
  Widget build(BuildContext context) {
    final unread = alerts.where((a) => !(a['isRead'] as bool)).toList();
    if (unread.isEmpty) return const SizedBox.shrink();

    return SizedBox(
      height: 44,
      child: ListView.separated(
        scrollDirection: Axis.horizontal,
        itemCount: unread.length,
        separatorBuilder: (_, __) => const SizedBox(width: 10),
        itemBuilder: (context, i) {
          final alert = unread[i];
          final type = alert['type'] as String;
          final isError = type == 'warning' || type == 'critical';
          final bg = isError
              ? AppColors.errorContainer.withValues(alpha: 0.6)
              : AppColors.secondaryContainer.withValues(alpha: 0.5);
          final fg = isError ? AppColors.onErrorContainer : AppColors.onSecondaryContainer;

          return Container(
            padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 10),
            decoration: BoxDecoration(
              color: bg,
              borderRadius: AppRadius.fullRadius,
              border: Border.all(
                color: isError
                    ? AppColors.error.withValues(alpha: 0.2)
                    : AppColors.secondary.withValues(alpha: 0.2),
              ),
            ),
            child: Row(
              mainAxisSize: MainAxisSize.min,
              children: [
                Icon(
                  isError ? Icons.warning_rounded : Icons.info_outline_rounded,
                  size: 16,
                  color: fg,
                ),
                const SizedBox(width: 6),
                Text(
                  alert['title'] as String,
                  style: AppTypography.labelLg.copyWith(
                    color: fg,
                    fontWeight: FontWeight.w700,
                    fontSize: 13,
                  ),
                ),
              ],
            ),
          );
        },
      ),
    );
  }
}

// ─── Floating AI FAB ──────────────────────────────────────────────────────────

class _AskAIFab extends StatefulWidget {
  final VoidCallback onTap;
  const _AskAIFab({required this.onTap});

  @override
  State<_AskAIFab> createState() => _AskAIFabState();
}

class _AskAIFabState extends State<_AskAIFab>
    with SingleTickerProviderStateMixin {
  late final AnimationController _ctrl;
  late final Animation<double> _scale;

  @override
  void initState() {
    super.initState();
    _ctrl = AnimationController(
      vsync: this,
      duration: AppConstants.animFast,
      lowerBound: 0,
      upperBound: 0.04,
    );
    _scale = Tween<double>(begin: 1.0, end: 0.95).animate(_ctrl);
  }

  @override
  void dispose() {
    _ctrl.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return GestureDetector(
      onTapDown: (_) => _ctrl.forward(),
      onTapUp: (_) {
        _ctrl.reverse();
        widget.onTap();
      },
      onTapCancel: () => _ctrl.reverse(),
      child: AnimatedBuilder(
        animation: _scale,
        builder: (_, child) => Transform.scale(scale: _scale.value, child: child),
        child: Container(
          padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 14),
          decoration: BoxDecoration(
            gradient: const LinearGradient(
              colors: [AppColors.primary, AppColors.aiGlow],
              begin: Alignment.topLeft,
              end: Alignment.bottomRight,
            ),
            borderRadius: AppRadius.fullRadius,
            boxShadow: AppShadows.buttonPrimary,
            border: Border.all(
              color: Colors.white.withValues(alpha: 0.2),
              width: 1,
            ),
          ),
          child: Row(
            mainAxisSize: MainAxisSize.min,
            children: [
              const Text('💬', style: TextStyle(fontSize: 18)),
              const SizedBox(width: 8),
              Text(
                'Ask AI',
                style: AppTypography.labelLg.copyWith(
                  color: Colors.white,
                  fontWeight: FontWeight.w700,
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}
