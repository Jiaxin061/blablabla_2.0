import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';
import '../../core/theme/theme.dart';
import '../../core/widgets/widgets.dart';
import '../../core/constants/mock_farm_data.dart';

class DigitalTwinScreen extends StatelessWidget {
  final String rackId;
  const DigitalTwinScreen({super.key, required this.rackId});

  Map<String, dynamic> get _rackData {
    return MockFarmData.racks.firstWhere(
      (rack) => (rack['id'] as String).toUpperCase() == rackId.toUpperCase(),
      orElse: () => MockFarmData.racks.first,
    );
  }

  bool get _isHealthyRack => (_rackData['health'] as String) == 'healthy';

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: const Color(0xFFF8F9F4),
      body: CustomScrollView(
        slivers: [
          _buildAppBar(context),
          SliverToBoxAdapter(
            child: Padding(
              padding: const EdgeInsets.all(20),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  _TwinHeroCard(
                    rackId: rackId,
                    rackData: _rackData,
                    isHealthyRack: _isHealthyRack,
                  ),
                  if (rackId.toUpperCase() == 'B') ...[
                    const SizedBox(height: 28),
                    Text('RACK LEVEL STATUS', style: AppTypography.sectionLabel),
                    const SizedBox(height: 16),
                    _RackLevelStatusCard(),
                  ],
                  const SizedBox(height: 24),
                  _ComparisonSection(),
                  const SizedBox(height: 32),
                  Text('AI DIAGNOSTIC PROFILE', style: AppTypography.sectionLabel),
                  const SizedBox(height: 16),
                  _DiagnosticGrid(),
                  const SizedBox(height: 32),
                  Text('THINKING FLOW', style: AppTypography.sectionLabel),
                  const SizedBox(height: 16),
                  _ThinkingFlow(),
                  const SizedBox(height: 24),
                  _RecoveryBanner(),
                  const SizedBox(height: 32),
                  Text('RECOMMENDED OPTIMIZATION', style: AppTypography.sectionLabel),
                  const SizedBox(height: 16),
                  _OptimizationList(),
                  const SizedBox(height: 120), // Bottom padding for chat bar
                ],
              ),
            ),
          ),
        ],
      ),
      bottomSheet: _buildAIChatBar(context),
    );
  }

  Widget _buildAppBar(BuildContext context) {
    return SliverAppBar(
      pinned: true,
      backgroundColor: const Color(0xFFF8F9F4),
      elevation: 0,
      leading: IconButton(
        icon: const Icon(Icons.arrow_back_rounded, color: AppColors.onSurface),
        onPressed: () => context.pop(),
      ),
      title: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text('Rack $rackId', style: AppTypography.headlineMd.copyWith(color: AppColors.primary, fontSize: 18)),
          Text('OPERATIONAL INTELLIGENCE', style: AppTypography.caption.copyWith(color: AppColors.onSurfaceVariant, fontSize: 9, letterSpacing: 1)),
        ],
      ),
      actions: [
        Padding(
          padding: const EdgeInsets.only(right: 16),
          child: Container(
            padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 6),
            decoration: BoxDecoration(
              color: const Color(0xFFE8EDE1),
              borderRadius: BorderRadius.circular(20),
              border: Border.all(color: AppColors.primary.withValues(alpha: 0.1)),
            ),
            child: const Row(
              children: [
                AIPulseIndicator(size: 6),
                SizedBox(width: 6),
                Text('LIVE SYNC', style: TextStyle(fontSize: 9, fontWeight: FontWeight.w800, color: AppColors.primary, letterSpacing: 0.5)),
              ],
            ),
          ),
        ),
      ],
    );
  }

  Widget _buildAIChatBar(BuildContext context) {
    final formattedRackId = rackId.toUpperCase();
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 16),
      decoration: BoxDecoration(
        color: Colors.white,
        border: Border(top: BorderSide(color: Colors.grey.shade200)),
      ),
      child: SafeArea(
        child: GestureDetector(
          onTap: () {
            context.go('/chat', extra: "How is Rack $formattedRackId today?");
          },
          child: Container(
            height: 56,
            decoration: BoxDecoration(
              color: const Color(0xFF38523A),
              borderRadius: BorderRadius.circular(28),
            ),
            child: Row(
              children: [
                const SizedBox(width: 16),
                const Icon(Icons.psychology_outlined, color: Colors.white, size: 24),
                const SizedBox(width: 12),
                Expanded(
                  child: Text('Ask AI About Rack $formattedRackId', style: const TextStyle(color: Colors.white, fontSize: 15, fontWeight: FontWeight.w500)),
                ),
                Container(
                  width: 40, height: 40,
                  margin: const EdgeInsets.only(right: 8),
                  decoration: BoxDecoration(
                    color: Colors.white.withValues(alpha: 0.2),
                    shape: BoxShape.circle,
                  ),
                  child: const Icon(Icons.mic_none_rounded, color: Colors.white, size: 20),
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }
}

class _TwinHeroCard extends StatelessWidget {
  final String rackId;
  final Map<String, dynamic> rackData;
  final bool isHealthyRack;
  const _TwinHeroCard({
    required this.rackId,
    required this.rackData,
    required this.isHealthyRack,
  });

  @override
  Widget build(BuildContext context) {
    final imagePath = 'assets/images/rack${rackId.toUpperCase()}.png';
    final moisture = rackData['moisture'] as int;
    final temperature = rackData['temperature'] as double;
    final ph = rackData['ph'] as double;
    final ec = rackData['ec'] as double;

    return Container(
      height: 320,
      width: double.infinity,
      decoration: BoxDecoration(
        color: const Color(0xFFE3E5DD),
        borderRadius: BorderRadius.circular(32),
      ),
      child: Stack(
        children: [
          // Header Label
          Positioned(
            top: 16, left: 16,
            child: Container(
              padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 6),
              decoration: BoxDecoration(
                color: Colors.white.withValues(alpha: 0.6),
                borderRadius: BorderRadius.circular(20),
              ),
              child: Row(
                children: [
                  const Icon(Icons.data_thresholding_outlined, size: 12, color: AppColors.primary),
                  const SizedBox(width: 6),
                  Text('LIVE DIGITAL TWIN SYNCING', style: AppTypography.caption.copyWith(fontWeight: FontWeight.bold, fontSize: 8)),
                ],
              ),
            ),
          ),
          // Visualization
          Positioned.fill(
            child: ClipRRect(
              borderRadius: BorderRadius.circular(32),
              child: Image.asset(
                imagePath,
                fit: BoxFit.cover,
              ),
            ),
          ),
          // Bottom Cards (Confidence and Anomaly Detail)
          Positioned(
            bottom: 16,
            left: 16,
            right: 16,
            child: Row(
              crossAxisAlignment: CrossAxisAlignment.end,
              children: [
                // Confidence Card
                Expanded(
                  flex: 1,
                  child: Container(
                    padding: const EdgeInsets.all(10),
                    decoration: BoxDecoration(
                      color: Colors.white.withValues(alpha: 0.8),
                      borderRadius: BorderRadius.circular(20),
                    ),
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      mainAxisSize: MainAxisSize.min,
                      children: [
                        Row(
                          children: [
                            Text(
                              isHealthyRack ? '95%' : '88%',
                              style: const TextStyle(
                                fontSize: 16,
                                fontWeight: FontWeight.w800,
                                color: AppColors.primary,
                              ),
                            ),
                            const SizedBox(width: 4),
                            const Expanded(
                              child: Text(
                                'AI CONFIDENCE',
                                style: TextStyle(
                                  fontSize: 7,
                                  fontWeight: FontWeight.bold,
                                  color: Colors.grey,
                                ),
                                maxLines: 1,
                                overflow: TextOverflow.ellipsis,
                              ),
                            ),
                            const SizedBox(width: 2),
                            const Icon(
                              Icons.verified_outlined,
                              size: 14,
                              color: AppColors.primary,
                            ),
                          ],
                        ),
                        const SizedBox(height: 2),
                        Text(
                          isHealthyRack ? 'Healthy profile detected' : 'Divergence detected',
                          style: const TextStyle(fontSize: 8, color: Colors.grey),
                          maxLines: 1,
                          overflow: TextOverflow.ellipsis,
                        ),
                      ],
                    ),
                  ),
                ),
                const SizedBox(width: 8),
                // Anomaly Detail
                Expanded(
                  flex: 1,
                  child: Container(
                    padding: const EdgeInsets.all(10),
                    decoration: BoxDecoration(
                      color: Colors.white.withValues(alpha: 0.9),
                      borderRadius: BorderRadius.circular(20),
                    ),
                    child: Row(
                      children: [
                        Expanded(
                          child: Column(
                            crossAxisAlignment: CrossAxisAlignment.start,
                            mainAxisSize: MainAxisSize.min,
                            children: [
                              Text(
                                isHealthyRack ? 'Rack $rackId Stable' : 'Rack $rackId Alert',
                                style: const TextStyle(
                                  fontSize: 12,
                                  fontWeight: FontWeight.bold,
                                ),
                                maxLines: 1,
                                overflow: TextOverflow.ellipsis,
                              ),
                              const SizedBox(height: 2),
                              Text(
                                'Moisture $moisture% • ${temperature.toStringAsFixed(1)}°C',
                                style: AppTypography.caption.copyWith(fontSize: 8),
                                maxLines: 1,
                                overflow: TextOverflow.ellipsis,
                              ),
                              Text(
                                'pH ${ph.toStringAsFixed(1)} • EC ${ec.toStringAsFixed(1)}',
                                style: AppTypography.caption.copyWith(fontSize: 8),
                                maxLines: 1,
                                overflow: TextOverflow.ellipsis,
                              ),
                            ],
                          ),
                        ),
                        const SizedBox(width: 4),
                        Container(
                          width: 32,
                          height: 32,
                          decoration: const BoxDecoration(
                            color: Color(0xFF38523A),
                            shape: BoxShape.circle,
                          ),
                          child: Icon(
                            isHealthyRack
                                ? Icons.check_circle_outline_rounded
                                : Icons.warning_amber_rounded,
                            color: Colors.white,
                            size: 16,
                          ),
                        ),
                      ],
                    ),
                  ),
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }
}



class _ComparisonSection extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    return Row(
      children: [
        Expanded(child: _CompareCard(label: 'LIVE OBSERVED', value: '72%', subLabel: 'Growth Rate', color: const Color(0xFFB48375))),
        const SizedBox(width: 16),
        Expanded(child: _CompareCard(label: 'AI PREDICTED', value: '84%', subLabel: 'Optimal Potential', delta: '(-12%)')),
      ],
    );
  }
}

class _CompareCard extends StatelessWidget {
  final String label;
  final String value;
  final String subLabel;
  final String? delta;
  final Color? color;

  const _CompareCard({required this.label, required this.value, required this.subLabel, this.delta, this.color});

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(20),
        border: Border.all(color: Colors.grey.shade100),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(label, style: AppTypography.caption.copyWith(fontSize: 8, fontWeight: FontWeight.bold, letterSpacing: 0.5)),
          const SizedBox(height: 12),
          Row(
            crossAxisAlignment: CrossAxisAlignment.end,
            children: [
              Text(value, style: TextStyle(fontSize: 28, fontWeight: FontWeight.w800, color: color ?? AppColors.primary)),
              if (delta != null) ...[
                const SizedBox(width: 4),
                Padding(
                  padding: const EdgeInsets.only(bottom: 6),
                  child: Text(delta!, style: const TextStyle(fontSize: 10, fontWeight: FontWeight.bold, color: Color(0xFFB48375))),
                ),
              ],
            ],
          ),
          const SizedBox(height: 4),
          Text(subLabel, style: AppTypography.caption.copyWith(fontSize: 10)),
        ],
      ),
    );
  }
}

class _DiagnosticGrid extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    return GridView.count(
      crossAxisCount: 2,
      shrinkWrap: true,
      physics: const NeverScrollableScrollPhysics(),
      mainAxisSpacing: 12,
      crossAxisSpacing: 12,
      childAspectRatio: 1.6,
      children: [
        _DiagnosticTile(label: 'ROOT CAUSE', value: 'Humidity\ninstability'),
        _DiagnosticTile(label: 'AFFECTED ZONE', value: 'Lower-middle\n(B)'),
        _DiagnosticTile(label: 'SYSTEM RISK', value: 'Moderate'),
        _DiagnosticTile(label: 'IMPACT', value: '2-day delay', color: const Color(0xFFB48375)),
      ],
    );
  }
}

class _DiagnosticTile extends StatelessWidget {
  final String label;
  final String value;
  final Color? color;

  const _DiagnosticTile({required this.label, required this.value, this.color});

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.all(12),
      decoration: BoxDecoration(
        color: const Color(0xFFFBFBF9),
        borderRadius: BorderRadius.circular(16),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(label, style: AppTypography.caption.copyWith(fontSize: 8, fontWeight: FontWeight.bold, color: Colors.grey)),
          const Spacer(),
          Text(value, style: TextStyle(fontSize: 14, fontWeight: FontWeight.w800, color: color ?? AppColors.onSurface, height: 1.2)),
        ],
      ),
    );
  }
}

class _ThinkingFlow extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    final steps = [
      {'title': 'Humidity anomaly detected', 'desc': 'Sensor set B-4 reported +14% spike over 4h.'},
      {'title': 'Moisture inconsistency identified', 'desc': 'Zone B substrate drying 30% faster than model.'},
      {'title': 'Digital twin divergence detected', 'desc': 'Live state vs optimal model mismatch > 10% threshold.'},
      {'title': 'Yield impact predicted', 'desc': 'Simulation projects 5% loss if uncorrected.'},
      {'title': 'Optimization strategy generated', 'desc': 'Recommended adaptive irrigation cycle.'},
    ];

    return Column(
      children: List.generate(steps.length, (i) {
        return Row(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Column(
              children: [
                Container(
                  width: 10, height: 10,
                  decoration: const BoxDecoration(color: Color(0xFF38523A), shape: BoxShape.circle),
                ),
                if (i < steps.length - 1)
                  Container(width: 1, height: 40, color: Colors.grey.shade300),
              ],
            ),
            const SizedBox(width: 16),
            Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(steps[i]['title']!, style: const TextStyle(fontSize: 14, fontWeight: FontWeight.bold)),
                  Text(steps[i]['desc']!, style: AppTypography.caption.copyWith(fontSize: 11)),
                  const SizedBox(height: 16),
                ],
              ),
            ),
          ],
        );
      }),
    );
  }
}

class _RecoveryBanner extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.all(20),
      decoration: BoxDecoration(
        color: const Color(0xFFE8EDE1),
        borderRadius: BorderRadius.circular(24),
      ),
      child: Row(
        children: [
          Container(
            width: 44, height: 44,
            decoration: BoxDecoration(color: Colors.white.withValues(alpha: 0.5), shape: BoxShape.circle),
            child: const Icon(Icons.show_chart_rounded, color: AppColors.primary),
          ),
          const SizedBox(width: 16),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                const Text('Adaptive Recovery', style: TextStyle(fontSize: 16, fontWeight: FontWeight.bold)),
                Text('Projected recovery within 36h with adaptive irrigation simulation.', style: AppTypography.caption),
              ],
            ),
          ),
        ],
      ),
    );
  }
}

class _OptimizationList extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    return Column(
      children: [
        _OptCard(
          title: 'Stabilize moisture in Zone B',
          desc: 'Expected Recovery: +9% Yield',
          match: '98%',
          icon: Icons.water_drop_outlined,
        ),
        const SizedBox(height: 12),
        _OptCard(
          title: 'Calibrate cooling airflow',
          desc: 'Target: -2.5°C in middle rack zone',
          match: '82%',
          icon: Icons.air_rounded,
          color: const Color(0xFFB48375),
        ),
      ],
    );
  }
}

class _OptCard extends StatelessWidget {
  final String title;
  final String desc;
  final String match;
  final IconData icon;
  final Color? color;

  const _OptCard({required this.title, required this.desc, required this.match, required this.icon, this.color});

  @override
  Widget build(BuildContext context) {
    final accent = color ?? AppColors.primary;
    return Container(
      padding: const EdgeInsets.all(20),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(24),
        border: Border(left: BorderSide(color: accent, width: 6)),
        boxShadow: [BoxShadow(color: Colors.black.withValues(alpha: 0.02), blurRadius: 10, offset: const Offset(0, 4))],
      ),
      child: Row(
        children: [
          Container(
            width: 48, height: 48,
            decoration: BoxDecoration(color: accent.withValues(alpha: 0.05), borderRadius: BorderRadius.circular(12)),
            child: Icon(icon, color: accent, size: 24),
          ),
          const SizedBox(width: 16),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(title, style: const TextStyle(fontSize: 15, fontWeight: FontWeight.bold)),
                Text(desc, style: AppTypography.caption),
              ],
            ),
          ),
          Column(
            children: [
              Text(match, style: TextStyle(fontSize: 14, fontWeight: FontWeight.bold, color: Colors.grey.shade400)),
              Text('MATCH', style: TextStyle(fontSize: 8, fontWeight: FontWeight.bold, color: Colors.grey.shade400)),
            ],
          ),
        ],
      ),
    );
  }
}

// ─────────────────────────────────────────────────────────────────────────────
// Rack Level Status card — Level 2–5 rows for Rack B
// ─────────────────────────────────────────────────────────────────────────────

class _RackLevelStatusCard extends StatelessWidget {
  const _RackLevelStatusCard();

  static const _levels = [
    _LevelMeta(level: 1, hasIssue: false, issueLabel: 'All Good'),
    _LevelMeta(level: 2, hasIssue: false, issueLabel: 'All Good'),
    _LevelMeta(level: 3, hasIssue: true,  issueLabel: 'Low Moisture & Elevated pH'),
    _LevelMeta(level: 4, hasIssue: false, issueLabel: 'All Good'),
    _LevelMeta(level: 5, hasIssue: false, issueLabel: 'All Good'),
  ];

  @override
  Widget build(BuildContext context) {
    return Container(
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(24),
        border: Border.all(color: Colors.grey.shade100),
        boxShadow: [BoxShadow(color: Colors.black.withValues(alpha: 0.03), blurRadius: 12, offset: const Offset(0, 4))],
      ),
      child: Column(
        children: List.generate(_levels.length, (i) {
          final meta = _levels[i];
          final isFirst = i == 0;
          final isLast = i == _levels.length - 1;
          return _LevelRow(meta: meta, isFirst: isFirst, isLast: isLast);
        }),
      ),
    );
  }
}

class _LevelMeta {
  final int level;
  final bool hasIssue;
  final String issueLabel;
  const _LevelMeta({required this.level, required this.hasIssue, required this.issueLabel});
}

class _LevelRow extends StatelessWidget {
  final _LevelMeta meta;
  final bool isFirst;
  final bool isLast;
  const _LevelRow({required this.meta, required this.isFirst, required this.isLast});

  Color get _badgeColor => meta.hasIssue ? const Color(0xFFF57F17) : AppColors.primary;
  String get _badgeText => meta.hasIssue ? 'Action Needed' : 'Healthy';

  @override
  Widget build(BuildContext context) {
    return InkWell(
      onTap: () => _showFullScreenImage(context),
      borderRadius: BorderRadius.vertical(
        top: isFirst ? const Radius.circular(24) : Radius.zero,
        bottom: isLast ? const Radius.circular(24) : Radius.zero,
      ),
      child: Container(
        padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 14),
        decoration: BoxDecoration(
          border: isLast ? null : Border(bottom: BorderSide(color: Colors.grey.shade100)),
        ),
        child: Row(
          children: [
            Container(
              width: 36,
              height: 36,
              decoration: BoxDecoration(
                color: _badgeColor.withValues(alpha: 0.1),
                shape: BoxShape.circle,
              ),
              child: Center(
                child: Text(
                  'L${meta.level}',
                  style: TextStyle(
                    fontSize: 11,
                    fontWeight: FontWeight.w800,
                    color: _badgeColor,
                  ),
                ),
              ),
            ),
            const SizedBox(width: 14),
            Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    'Level ${meta.level}',
                    style: const TextStyle(fontSize: 14, fontWeight: FontWeight.bold),
                  ),
                  const SizedBox(height: 2),
                  Text(
                    meta.issueLabel,
                    style: AppTypography.caption.copyWith(fontSize: 11, color: _badgeColor),
                  ),
                ],
              ),
            ),
            Container(
              padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 5),
              decoration: BoxDecoration(
                color: _badgeColor.withValues(alpha: 0.1),
                borderRadius: BorderRadius.circular(20),
                border: Border.all(color: _badgeColor.withValues(alpha: 0.25)),
              ),
              child: Row(
                mainAxisSize: MainAxisSize.min,
                children: [
                  Icon(
                    meta.hasIssue ? Icons.warning_amber_rounded : Icons.check_circle_outline_rounded,
                    size: 12,
                    color: _badgeColor,
                  ),
                  const SizedBox(width: 4),
                  Text(
                    _badgeText,
                    style: TextStyle(
                      fontSize: 10,
                      fontWeight: FontWeight.w800,
                      color: _badgeColor,
                    ),
                  ),
                ],
              ),
            ),
            const SizedBox(width: 8),
            Icon(Icons.chevron_right_rounded, size: 18, color: AppColors.onSurfaceVariant),
          ],
        ),
      ),
    );
  }

  void _showFullScreenImage(BuildContext context) {
    showDialog(
      context: context,
      barrierColor: Colors.black.withValues(alpha: 0.92),
      builder: (_) => _LevelFullScreenViewer(level: meta.level, hasIssue: meta.hasIssue),
    );
  }
}

class _LevelFullScreenViewer extends StatelessWidget {
  final int level;
  final bool hasIssue;
  const _LevelFullScreenViewer({required this.level, required this.hasIssue});

  String get _zoomAsset => level == 3 ? 'assets/images/zoom3.png' : 'assets/images/zoom5.png';
  String get _statusLabel => hasIssue ? 'Action Needed' : 'Healthy';
  Color get _statusColor => hasIssue ? const Color(0xFFF57F17) : AppColors.primary;

  bool _isUnhealthy(int plantIndex) => level == 3 && (plantIndex == 1 || plantIndex == 2);

  @override
  Widget build(BuildContext context) {
    return Material(
      color: const Color(0xFF111411),
      child: SafeArea(
        child: Column(
          children: [
            // ── Sticky header ─────────────────────────────────────────────
            Padding(
              padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 10),
              child: Row(
                children: [
                  Container(
                    padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 7),
                    decoration: BoxDecoration(
                      color: Colors.white.withValues(alpha: 0.08),
                      borderRadius: BorderRadius.circular(20),
                    ),
                    child: Row(
                      mainAxisSize: MainAxisSize.min,
                      children: [
                        Icon(
                          hasIssue ? Icons.warning_amber_rounded : Icons.check_circle_outline_rounded,
                          size: 13,
                          color: _statusColor,
                        ),
                        const SizedBox(width: 6),
                        Text(
                          'Level $level — $_statusLabel',
                          style: const TextStyle(
                            color: Colors.white,
                            fontSize: 13,
                            fontWeight: FontWeight.w700,
                          ),
                        ),
                      ],
                    ),
                  ),
                  const Spacer(),
                  GestureDetector(
                    onTap: () => Navigator.of(context).pop(),
                    child: Container(
                      width: 36,
                      height: 36,
                      decoration: BoxDecoration(
                        color: Colors.white.withValues(alpha: 0.12),
                        shape: BoxShape.circle,
                      ),
                      child: const Icon(Icons.close_rounded, color: Colors.white, size: 20),
                    ),
                  ),
                ],
              ),
            ),
            // ── Scrollable body ────────────────────────────────────────────
            Expanded(
              child: SingleChildScrollView(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    // Zoom photo
                    SizedBox(
                      height: 240,
                      width: double.infinity,
                      child: Image.asset(
                        _zoomAsset,
                        fit: BoxFit.cover,
                        errorBuilder: (_, __, ___) => Center(
                          child: Column(
                            mainAxisSize: MainAxisSize.min,
                            children: [
                              Icon(Icons.image_outlined, size: 48, color: Colors.white.withValues(alpha: 0.4)),
                              const SizedBox(height: 12),
                              Text(
                                _zoomAsset.split('/').last,
                                style: TextStyle(color: Colors.white.withValues(alpha: 0.5), fontSize: 13),
                              ),
                            ],
                          ),
                        ),
                      ),
                    ),
                    const SizedBox(height: 24),
                    // Plant Health section title
                    Padding(
                      padding: const EdgeInsets.symmetric(horizontal: 16),
                      child: Text(
                        'Plant Health — Level $level',
                        style: const TextStyle(
                          color: Colors.white,
                          fontSize: 16,
                          fontWeight: FontWeight.w800,
                          letterSpacing: 0.3,
                        ),
                      ),
                    ),
                    const SizedBox(height: 14),
                    // 2-column grid of plant cards (P01–P05)
                    Padding(
                      padding: const EdgeInsets.symmetric(horizontal: 16),
                      child: GridView.builder(
                        shrinkWrap: true,
                        physics: const NeverScrollableScrollPhysics(),
                        itemCount: 4,
                        gridDelegate: const SliverGridDelegateWithFixedCrossAxisCount(
                          crossAxisCount: 2,
                          crossAxisSpacing: 12,
                          mainAxisSpacing: 12,
                          childAspectRatio: 0.88,
                        ),
                        itemBuilder: (context, index) => _PlantCard(
                          slotLabel: 'P${(index + 1).toString().padLeft(2, '0')}',
                          isUnhealthy: _isUnhealthy(index),
                        ),
                      ),
                    ),
                    const SizedBox(height: 32),
                  ],
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }
}

class _PlantCard extends StatelessWidget {
  final String slotLabel;
  final bool isUnhealthy;
  const _PlantCard({required this.slotLabel, required this.isUnhealthy});

  @override
  Widget build(BuildContext context) {
    final badgeColor = isUnhealthy ? const Color(0xFFEF5350) : const Color(0xFF4CAF50);
    final badgeText = isUnhealthy ? 'Needs Attention' : 'Healthy';
    final imagePath = isUnhealthy ? 'assets/images/unhealthy.png' : 'assets/images/healthy.png';

    return Container(
      decoration: BoxDecoration(
        color: const Color(0xFF1C201C),
        borderRadius: BorderRadius.circular(16),
        border: Border.all(color: Colors.white.withValues(alpha: 0.06)),
      ),
      child: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          ClipRRect(
            borderRadius: BorderRadius.circular(12),
            child: Image.asset(
              imagePath,
              width: 80,
              height: 80,
              fit: BoxFit.cover,
              errorBuilder: (_, __, ___) => Container(
                width: 80,
                height: 80,
                color: Colors.white12,
                child: const Icon(Icons.eco_outlined, color: Colors.white38, size: 32),
              ),
            ),
          ),
          const SizedBox(height: 10),
          Text(
            slotLabel,
            style: const TextStyle(
              color: Colors.white,
              fontSize: 13,
              fontWeight: FontWeight.w700,
            ),
          ),
          const SizedBox(height: 6),
          Container(
            padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
            decoration: BoxDecoration(
              color: badgeColor.withValues(alpha: 0.15),
              borderRadius: BorderRadius.circular(12),
              border: Border.all(color: badgeColor.withValues(alpha: 0.4)),
            ),
            child: Text(
              badgeText,
              style: TextStyle(
                color: badgeColor,
                fontSize: 9,
                fontWeight: FontWeight.w800,
              ),
            ),
          ),
        ],
      ),
    );
  }
}
