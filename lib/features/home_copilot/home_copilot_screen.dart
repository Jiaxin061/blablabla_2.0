import 'dart:math' as math;

import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:go_router/go_router.dart';

import '../../core/constants/app_constants.dart';
import '../../core/constants/mock_farm_data.dart';
import '../../core/routing/app_router.dart';
import '../../core/theme/theme.dart';
import '../../core/widgets/widgets.dart';

class HomeCopilotScreen extends StatelessWidget {
  const HomeCopilotScreen({super.key});

  static String _greeting() {
    final hour = DateTime.now().hour;
    if (hour >= 5 && hour < 12) return 'Good morning';
    if (hour >= 12 && hour < 17) return 'Good afternoon';
    if (hour >= 17 && hour < 22) return 'Good evening';
    return 'Good night';
  }

  static String _formattedDate() {
    final now = DateTime.now();
    const months = [
      'January', 'February', 'March', 'April', 'May', 'June',
      'July', 'August', 'September', 'October', 'November', 'December',
    ];
    const days = ['Monday', 'Tuesday', 'Wednesday', 'Thursday', 'Friday', 'Saturday', 'Sunday'];
    final weekday = days[now.weekday - 1];
    return '$weekday, ${months[now.month - 1]} ${now.day}, ${now.year}';
  }

  @override
  Widget build(BuildContext context) {
    final metrics = MockFarmData.farmMetrics;
    final healthScore = metrics['healthScore'] as int;
    final racks = MockFarmData.racks;

    return Scaffold(
      backgroundColor: AppColors.background,
      body: CustomScrollView(
        physics: const BouncingScrollPhysics(),
        slivers: [
          // ── App Bar ────────────────────────────────────────────────────────
          SliverAppBar(
            floating: true,
            backgroundColor: AppColors.surface.withValues(alpha: 0.95),
            surfaceTintColor: Colors.transparent,
            elevation: 0,
            pinned: false,
            toolbarHeight: 64,
            leading: Padding(
              padding: const EdgeInsets.only(left: 8),
              child: IconButton(
                icon: const Icon(Icons.arrow_back_ios_new_rounded,
                    color: AppColors.onSurface, size: 20),
                onPressed: () => context.pop(),
              ),
            ),
            flexibleSpace: Padding(
              padding: EdgeInsets.only(
                top: MediaQuery.of(context).padding.top,
                right: AppSpacing.marginMobile,
              ),
              child: Align(
                alignment: Alignment.centerRight,
                child: Container(
                  padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 6),
                  decoration: BoxDecoration(
                    color: AppColors.primary.withValues(alpha: 0.1),
                    borderRadius: AppRadius.fullRadius,
                  ),
                  child: const Row(
                    mainAxisSize: MainAxisSize.min,
                    children: [
                      AIPulseIndicator(size: 7),
                      SizedBox(width: 6),
                      Text(
                        'AI Copilot Online',
                        style: TextStyle(
                          fontSize: 12,
                          fontWeight: FontWeight.w700,
                          color: AppColors.primary,
                          letterSpacing: 0.3,
                        ),
                      ),
                    ],
                  ),
                ),
              ),
            ),
          ),

          // ── Body ──────────────────────────────────────────────────────────
          SliverPadding(
            padding: const EdgeInsets.symmetric(horizontal: AppSpacing.marginMobile),
            sliver: SliverList(
              delegate: SliverChildListDelegate([
                const SizedBox(height: AppSpacing.lg),

                // ── 1. Greeting ──────────────────────────────────────────
                _GreetingSection(greeting: _greeting(), date: _formattedDate()),

                const SizedBox(height: AppSpacing.stackSpace),

                // ── 2. Farm Health Hero ──────────────────────────────────
                _FarmHealthHeroCard(healthScore: healthScore, racks: racks),

                const SizedBox(height: AppSpacing.stackSpace),

                // ── 3. AI Operational Insights ───────────────────────────
                const _AIInsightsSection(),

                const SizedBox(height: AppSpacing.stackSpace),

                // ── 4. Quick Actions ─────────────────────────────────────
                _QuickActionsGrid(racks: racks),

                const SizedBox(height: AppSpacing.stackSpace),

                // ── 5. Rack Status Strip ─────────────────────────────────
                _RackStatusStrip(racks: racks),

                const SizedBox(height: 100),
              ]),
            ),
          ),
        ],
      ),
    );
  }
}

// ─── 1. Greeting ─────────────────────────────────────────────────────────────

class _GreetingSection extends StatelessWidget {
  final String greeting;
  final String date;

  const _GreetingSection({required this.greeting, required this.date});

  @override
  Widget build(BuildContext context) {
    return Row(
      crossAxisAlignment: CrossAxisAlignment.center,
      children: [
        // AI Avatar
        Container(
          width: 52,
          height: 52,
          decoration: BoxDecoration(
            gradient: const LinearGradient(
              colors: [AppColors.primary, AppColors.aiGlow],
              begin: Alignment.topLeft,
              end: Alignment.bottomRight,
            ),
            borderRadius: AppRadius.xlRadius,
            boxShadow: AppShadows.buttonPrimary,
          ),
          child: const Icon(Icons.smart_toy_rounded, color: Colors.white, size: 28),
        ),
        const SizedBox(width: AppSpacing.md),
        Expanded(
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text(
                '$greeting, Farmer 👋',
                style: AppTypography.headlineMd.copyWith(
                  color: AppColors.onSurface,
                  fontWeight: FontWeight.w800,
                ),
              ),
              const SizedBox(height: 2),
              Text(
                date,
                style: AppTypography.caption.copyWith(
                  color: AppColors.onSurfaceVariant,
                  fontSize: 12,
                ),
              ),
            ],
          ),
        ),
      ],
    );
  }
}

// ─── 2. Farm Health Hero Card ─────────────────────────────────────────────────

class _FarmHealthHeroCard extends StatelessWidget {
  final int healthScore;
  final List<Map<String, dynamic>> racks;

  const _FarmHealthHeroCard({required this.healthScore, required this.racks});

  @override
  Widget build(BuildContext context) {
    final healthy = racks.where((r) => r['health'] == 'healthy').length;
    final warning = racks.where((r) => r['health'] == 'warning').length;
    final harvestReady = racks.where((r) => (r['daysToHarvest'] as int) <= 3).length;

    return Container(
      padding: const EdgeInsets.all(AppSpacing.cardPadding),
      decoration: BoxDecoration(
        gradient: LinearGradient(
          colors: [
            AppColors.primary,
            AppColors.aiGlow,
          ],
          begin: Alignment.topLeft,
          end: Alignment.bottomRight,
        ),
        borderRadius: AppRadius.heroCard,
        boxShadow: AppShadows.cardHero,
      ),
      child: Column(
        children: [
          // Header
          Row(
            children: [
              Text(
                'FARM HEALTH OVERVIEW',
                style: AppTypography.sectionLabel.copyWith(
                  color: Colors.white.withValues(alpha: 0.8),
                  letterSpacing: 2.0,
                ),
              ),
              const Spacer(),
              Container(
                padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 4),
                decoration: BoxDecoration(
                  color: Colors.white.withValues(alpha: 0.2),
                  borderRadius: AppRadius.fullRadius,
                ),
                child: Row(
                  mainAxisSize: MainAxisSize.min,
                  children: [
                    const AIPulseIndicator(size: 6, color: Colors.white),
                    const SizedBox(width: 5),
                    Text(
                      'Live',
                      style: AppTypography.caption.copyWith(
                        color: Colors.white,
                        fontWeight: FontWeight.w700,
                      ),
                    ),
                  ],
                ),
              ),
            ],
          ),

          const SizedBox(height: AppSpacing.lg),

          // Arc progress + score
          _HealthArcProgress(score: healthScore),

          const SizedBox(height: AppSpacing.lg),

          // Sub-metrics row
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceAround,
            children: [
              _SubMetric(label: 'Total Racks', value: '${racks.length}', icon: Icons.view_column_rounded),
              _SubMetricDivider(),
              _SubMetric(label: 'Healthy', value: '$healthy', icon: Icons.check_circle_rounded),
              _SubMetricDivider(),
              _SubMetric(label: 'Attention', value: '$warning', icon: Icons.report_rounded),
              _SubMetricDivider(),
              _SubMetric(label: 'Harvest', value: '$harvestReady', icon: Icons.agriculture_rounded),
            ],
          ),
        ],
      ),
    );
  }
}

class _HealthArcProgress extends StatelessWidget {
  final int score;
  const _HealthArcProgress({required this.score});

  @override
  Widget build(BuildContext context) {
    return SizedBox(
      width: 160,
      height: 110,
      child: CustomPaint(
        painter: _ArcPainter(progress: score / 100),
        child: Center(
          child: Column(
            mainAxisAlignment: MainAxisAlignment.end,
            children: [
              Text(
                '$score%',
                style: AppTypography.headlineLg.copyWith(
                  color: Colors.white,
                  fontSize: 36,
                  fontWeight: FontWeight.w900,
                ),
              ),
              Text(
                score >= 85 ? 'Excellent' : score >= 70 ? 'Good' : 'Needs Work',
                style: AppTypography.caption.copyWith(
                  color: Colors.white.withValues(alpha: 0.85),
                  fontSize: 12,
                  fontWeight: FontWeight.w700,
                  letterSpacing: 1.5,
                ),
              ),
              const SizedBox(height: 6),
            ],
          ),
        ),
      ),
    );
  }
}

class _ArcPainter extends CustomPainter {
  final double progress;
  const _ArcPainter({required this.progress});

  @override
  void paint(Canvas canvas, Size size) {
    final cx = size.width / 2;
    final cy = size.height * 0.85;
    final radius = size.width / 2 - 8;
    const startAngle = math.pi * 0.75;
    const sweepTotal = math.pi * 1.5;

    final bgPaint = Paint()
      ..color = Colors.white.withValues(alpha: 0.2)
      ..strokeWidth = 10
      ..style = PaintingStyle.stroke
      ..strokeCap = StrokeCap.round;

    canvas.drawArc(
      Rect.fromCircle(center: Offset(cx, cy), radius: radius),
      startAngle,
      sweepTotal,
      false,
      bgPaint,
    );

    final fgPaint = Paint()
      ..color = Colors.white
      ..strokeWidth = 10
      ..style = PaintingStyle.stroke
      ..strokeCap = StrokeCap.round;

    canvas.drawArc(
      Rect.fromCircle(center: Offset(cx, cy), radius: radius),
      startAngle,
      sweepTotal * progress,
      false,
      fgPaint,
    );
  }

  @override
  bool shouldRepaint(_ArcPainter oldDelegate) => oldDelegate.progress != progress;
}

class _SubMetric extends StatelessWidget {
  final String label;
  final String value;
  final IconData icon;

  const _SubMetric({required this.label, required this.value, required this.icon});

  @override
  Widget build(BuildContext context) {
    return Column(
      children: [
        Icon(icon, color: Colors.white, size: 18),
        const SizedBox(height: 4),
        Text(
          value,
          style: AppTypography.headlineMd.copyWith(
            color: Colors.white,
            fontSize: 20,
            fontWeight: FontWeight.w900,
          ),
        ),
        Text(
          label,
          style: AppTypography.caption.copyWith(
            color: Colors.white.withValues(alpha: 0.8),
            fontSize: 10,
          ),
          textAlign: TextAlign.center,
        ),
      ],
    );
  }
}

class _SubMetricDivider extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    return Container(
      width: 1,
      height: 40,
      color: Colors.white.withValues(alpha: 0.25),
    );
  }
}

// ─── 3. AI Insights Section ───────────────────────────────────────────────────

class _AIInsightsSection extends StatelessWidget {
  const _AIInsightsSection();

  static const List<_InsightData> _insights = [
    _InsightData(
      icon: Icons.water_drop_rounded,
      title: 'Moisture Correction',
      description: 'Rack B moisture low — irrigation pulse triggered automatically.',
      severity: _Severity.warning,
    ),
    _InsightData(
      icon: Icons.agriculture_rounded,
      title: 'Harvest Ready Soon',
      description: 'Rack A Butterhead Lettuce ready for harvest in 7 days. Schedule pickup.',
      severity: _Severity.good,
    ),
    _InsightData(
      icon: Icons.bug_report_rounded,
      title: 'Pest Risk Clear',
      description: 'No pest or disease risk detected across all racks. Farm is biosecure.',
      severity: _Severity.good,
    ),
  ];

  @override
  Widget build(BuildContext context) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Row(
          children: [
            const Icon(Icons.psychology_rounded, size: 16, color: AppColors.primary),
            const SizedBox(width: 6),
            Text('AI OPERATIONAL INSIGHTS', style: AppTypography.sectionLabel),
          ],
        ),
        const SizedBox(height: AppSpacing.md),
        ...(_insights.map((insight) => Padding(
              padding: const EdgeInsets.only(bottom: AppSpacing.sm),
              child: _InsightCard(data: insight),
            ))),
      ],
    );
  }
}

enum _Severity { good, warning, critical }

class _InsightData {
  final IconData icon;
  final String title;
  final String description;
  final _Severity severity;

  const _InsightData({
    required this.icon,
    required this.title,
    required this.description,
    required this.severity,
  });
}

class _InsightCard extends StatelessWidget {
  final _InsightData data;
  const _InsightCard({required this.data});

  Color get _accentColor {
    switch (data.severity) {
      case _Severity.good:
        return AppColors.statusHealthy;
      case _Severity.warning:
        return AppColors.statusWarning;
      case _Severity.critical:
        return AppColors.statusCritical;
    }
  }

  String get _badgeLabel {
    switch (data.severity) {
      case _Severity.good:
        return 'Good';
      case _Severity.warning:
        return 'Warning';
      case _Severity.critical:
        return 'Critical';
    }
  }

  @override
  Widget build(BuildContext context) {
    final accent = _accentColor;

    return Container(
      padding: const EdgeInsets.all(AppSpacing.md),
      decoration: BoxDecoration(
        color: accent.withValues(alpha: 0.06),
        borderRadius: AppRadius.card,
        border: Border.all(color: accent.withValues(alpha: 0.18), width: 1),
        boxShadow: [
          BoxShadow(
            color: accent.withValues(alpha: 0.06),
            blurRadius: 10,
            offset: const Offset(0, 3),
          ),
        ],
      ),
      child: Row(
        children: [
          Container(
            width: 40,
            height: 40,
            decoration: BoxDecoration(
              color: accent.withValues(alpha: 0.12),
              borderRadius: AppRadius.mdRadius,
            ),
            child: Icon(data.icon, color: accent, size: 20),
          ),
          const SizedBox(width: AppSpacing.md),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  data.title,
                  style: AppTypography.labelLg.copyWith(
                    color: AppColors.onSurface,
                    fontSize: 14,
                    fontWeight: FontWeight.w700,
                  ),
                ),
                const SizedBox(height: 3),
                Text(
                  data.description,
                  style: AppTypography.caption.copyWith(
                    color: AppColors.onSurfaceVariant,
                    fontSize: 12,
                    height: 1.4,
                  ),
                ),
              ],
            ),
          ),
          const SizedBox(width: AppSpacing.sm),
          Container(
            padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
            decoration: BoxDecoration(
              color: accent.withValues(alpha: 0.15),
              borderRadius: AppRadius.fullRadius,
            ),
            child: Text(
              _badgeLabel,
              style: TextStyle(
                fontSize: 10,
                fontWeight: FontWeight.w800,
                color: accent,
                letterSpacing: 0.5,
              ),
            ),
          ),
        ],
      ),
    );
  }
}

// ─── 4. Quick Actions Grid ────────────────────────────────────────────────────

class _QuickActionsGrid extends StatelessWidget {
  final List<Map<String, dynamic>> racks;
  const _QuickActionsGrid({required this.racks});

  @override
  Widget build(BuildContext context) {
    final actions = [
      _QuickAction(
        emoji: '💧',
        label: 'Water Plants',
        color: const Color(0xFF1976D2),
        onTap: () {
          HapticFeedback.lightImpact();
          ScaffoldMessenger.of(context).showSnackBar(
            SnackBar(
              content: const Row(
                children: [
                  Text('💧', style: TextStyle(fontSize: 16)),
                  SizedBox(width: 8),
                  Text(
                    'Irrigation pulse sent to all racks',
                    style: TextStyle(fontWeight: FontWeight.w600),
                  ),
                ],
              ),
              backgroundColor: const Color(0xFF1976D2),
              behavior: SnackBarBehavior.floating,
              shape: RoundedRectangleBorder(borderRadius: AppRadius.mdRadius),
              duration: const Duration(seconds: 3),
            ),
          );
        },
      ),
      _QuickAction(
        emoji: '📷',
        label: 'Scan Rack',
        color: const Color(0xFF7B1FA2),
        onTap: () => context.go(AppRoutes.arScan),
      ),
      _QuickAction(
        emoji: '🤖',
        label: 'AI Assistant',
        color: AppColors.primary,
        onTap: () => context.go(AppRoutes.chat),
      ),
      _QuickAction(
        emoji: '📊',
        label: 'Digital Twin',
        color: const Color(0xFF00796B),
        onTap: () => context.go('${AppRoutes.farmOverview}/digital-twin/${racks.first['id']}'),
      ),
    ];

    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Row(
          children: [
            const Icon(Icons.bolt_rounded, size: 16, color: AppColors.primary),
            const SizedBox(width: 6),
            Text('QUICK ACTIONS', style: AppTypography.sectionLabel),
          ],
        ),
        const SizedBox(height: AppSpacing.md),
        GridView.count(
          crossAxisCount: 2,
          crossAxisSpacing: AppSpacing.md,
          mainAxisSpacing: AppSpacing.md,
          childAspectRatio: 2.0,
          shrinkWrap: true,
          physics: const NeverScrollableScrollPhysics(),
          children: actions.map((a) => _QuickActionTile(action: a)).toList(),
        ),
      ],
    );
  }
}

class _QuickAction {
  final String emoji;
  final String label;
  final Color color;
  final VoidCallback onTap;

  const _QuickAction({
    required this.emoji,
    required this.label,
    required this.color,
    required this.onTap,
  });
}

class _QuickActionTile extends StatefulWidget {
  final _QuickAction action;
  const _QuickActionTile({required this.action});

  @override
  State<_QuickActionTile> createState() => _QuickActionTileState();
}

class _QuickActionTileState extends State<_QuickActionTile>
    with SingleTickerProviderStateMixin {
  late final AnimationController _ctrl;
  late final Animation<double> _scale;

  @override
  void initState() {
    super.initState();
    _ctrl = AnimationController(
      vsync: this,
      duration: AppConstants.animFast,
    );
    _scale = Tween<double>(begin: 1.0, end: 0.94).animate(
      CurvedAnimation(parent: _ctrl, curve: Curves.easeOut),
    );
  }

  @override
  void dispose() {
    _ctrl.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final a = widget.action;
    return GestureDetector(
      onTapDown: (_) => _ctrl.forward(),
      onTapUp: (_) {
        _ctrl.reverse();
        a.onTap();
      },
      onTapCancel: () => _ctrl.reverse(),
      child: AnimatedBuilder(
        animation: _scale,
        builder: (_, child) => Transform.scale(scale: _scale.value, child: child),
        child: Container(
          decoration: BoxDecoration(
            color: a.color.withValues(alpha: 0.08),
            borderRadius: AppRadius.card,
            border: Border.all(color: a.color.withValues(alpha: 0.2), width: 1),
            boxShadow: [
              BoxShadow(
                color: a.color.withValues(alpha: 0.08),
                blurRadius: 10,
                offset: const Offset(0, 3),
              ),
            ],
          ),
          child: Padding(
            padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 10),
            child: Row(
              children: [
                Container(
                  width: 38,
                  height: 38,
                  decoration: BoxDecoration(
                    color: a.color.withValues(alpha: 0.15),
                    borderRadius: AppRadius.mdRadius,
                  ),
                  child: Center(
                    child: Text(a.emoji, style: const TextStyle(fontSize: 18)),
                  ),
                ),
                const SizedBox(width: 10),
                Expanded(
                  child: Text(
                    a.label,
                    style: AppTypography.labelLg.copyWith(
                      color: a.color,
                      fontSize: 13,
                      fontWeight: FontWeight.w700,
                    ),
                    maxLines: 2,
                  ),
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }
}

// ─── 5. Rack Status Strip ─────────────────────────────────────────────────────

class _RackStatusStrip extends StatelessWidget {
  final List<Map<String, dynamic>> racks;
  const _RackStatusStrip({required this.racks});

  @override
  Widget build(BuildContext context) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Row(
          children: [
            const Icon(Icons.view_column_rounded, size: 16, color: AppColors.primary),
            const SizedBox(width: 6),
            Text('RACK STATUS', style: AppTypography.sectionLabel),
          ],
        ),
        const SizedBox(height: AppSpacing.md),
        SizedBox(
          height: 130,
          child: ListView.separated(
            scrollDirection: Axis.horizontal,
            itemCount: racks.length,
            separatorBuilder: (_, __) => const SizedBox(width: AppSpacing.sm),
            itemBuilder: (context, i) {
              final rack = racks[i];
              return _RackMiniCard(
                rack: rack,
                onTap: () => context.go(
                  '${AppRoutes.farmOverview}/digital-twin/${rack['id']}',
                ),
              );
            },
          ),
        ),
      ],
    );
  }
}

class _RackMiniCard extends StatelessWidget {
  final Map<String, dynamic> rack;
  final VoidCallback onTap;

  const _RackMiniCard({required this.rack, required this.onTap});

  Color get _statusColor {
    switch ((rack['health'] as String).toLowerCase()) {
      case 'healthy':
        return AppColors.statusHealthy;
      case 'warning':
        return AppColors.statusWarning;
      case 'critical':
        return AppColors.statusCritical;
      default:
        return AppColors.onSurfaceVariant;
    }
  }

  @override
  Widget build(BuildContext context) {
    final color = _statusColor;
    final moisture = rack['moisture'] as int;
    final name = rack['name'] as String;
    final crop = rack['crop'] as String;

    return GestureDetector(
      onTap: onTap,
      child: Container(
        width: 112,
        padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 10),
        decoration: BoxDecoration(
          color: color.withValues(alpha: 0.07),
          borderRadius: AppRadius.card,
          border: Border.all(color: color.withValues(alpha: 0.25), width: 1.2),
          boxShadow: [
            BoxShadow(
              color: color.withValues(alpha: 0.07),
              blurRadius: 8,
              offset: const Offset(0, 2),
            ),
          ],
        ),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Row(
              children: [
                Container(
                  width: 8,
                  height: 8,
                  decoration: BoxDecoration(
                    color: color,
                    shape: BoxShape.circle,
                    boxShadow: [
                      BoxShadow(
                        color: color.withValues(alpha: 0.5),
                        blurRadius: 4,
                      ),
                    ],
                  ),
                ),
                const SizedBox(width: 5),
                Expanded(
                  child: Text(
                    name,
                    style: AppTypography.caption.copyWith(
                      color: color,
                      fontWeight: FontWeight.w800,
                      fontSize: 11,
                      letterSpacing: 0.5,
                    ),
                    overflow: TextOverflow.ellipsis,
                  ),
                ),
              ],
            ),
            const SizedBox(height: 6),
            const Text('🌿', style: TextStyle(fontSize: 22)),
            const SizedBox(height: 4),
            Text(
              crop,
              style: AppTypography.caption.copyWith(
                color: AppColors.onSurface,
                fontSize: 10,
                fontWeight: FontWeight.w600,
              ),
              maxLines: 1,
              overflow: TextOverflow.ellipsis,
            ),
            const SizedBox(height: 2),
            Row(
              children: [
                Icon(Icons.water_drop_rounded, size: 10, color: AppColors.onSurfaceVariant),
                const SizedBox(width: 2),
                Text(
                  '$moisture%',
                  style: AppTypography.caption.copyWith(
                    color: AppColors.onSurfaceVariant,
                    fontSize: 10,
                  ),
                ),
              ],
            ),
          ],
        ),
      ),
    );
  }
}
