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
                  const SizedBox(height: 24),
                  _TrendSection(),
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
    final normalizedRackId = rackId.toUpperCase();
    final imagePath = switch (normalizedRackId) {
      'A' => 'assets/images/rackA.png',
      'B' => 'assets/images/rackB.png',
      'C' => 'assets/images/rackC.png',
      _ => 'assets/images/rackA.png', // Default case to fix exhaustiveness
    };
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

class _ZoneChip extends StatelessWidget {
  final String label;
  final IconData icon;
  final Color color;
  final bool isDivergence;

  const _ZoneChip({required this.label, required this.icon, required this.color, this.isDivergence = false});

  @override
  Widget build(BuildContext context) {
    return Container(
      width: 160,
      height: 70,
      decoration: BoxDecoration(
        color: isDivergence ? const Color(0xFFEBDDD9).withValues(alpha: 0.8) : Colors.white.withValues(alpha: 0.8),
        borderRadius: BorderRadius.circular(20),
        border: isDivergence ? Border.all(color: color.withValues(alpha: 0.3), width: 1.5) : null,
      ),
      child: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          Icon(icon, color: color, size: 20),
          const SizedBox(height: 6),
          Text(label, style: TextStyle(color: color, fontSize: 9, fontWeight: FontWeight.w800, letterSpacing: 0.5)),
        ],
      ),
    );
  }
}

class _TrendSection extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    return Row(
      children: [
        Expanded(
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text('48H TREND CHANGE', style: AppTypography.sectionLabel),
              const SizedBox(height: 12),
              Row(
                children: [
                  _TrendItem(value: '+14%', label: 'Humidity Spike', color: const Color(0xFFB48375)),
                  const SizedBox(width: 16),
                  _TrendItem(value: '-6%', label: 'Consistency', color: const Color(0xFFB48375)),
                ],
              ),
            ],
          ),
        ),
        _MiniChart(),
      ],
    );
  }
}

class _TrendItem extends StatelessWidget {
  final String value;
  final String label;
  final Color color;

  const _TrendItem({required this.value, required this.label, required this.color});

  @override
  Widget build(BuildContext context) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(value, style: TextStyle(fontSize: 24, fontWeight: FontWeight.w800, color: color)),
        Text(label, style: AppTypography.caption.copyWith(fontSize: 10)),
      ],
    );
  }
}

class _MiniChart extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    return Row(
      crossAxisAlignment: CrossAxisAlignment.end,
      children: List.generate(5, (i) {
        final height = [15.0, 25.0, 40.0, 30.0, 25.0][i];
        final color = i == 4 ? const Color(0xFFB48375) : Colors.grey.shade300;
        return Container(
          width: 8,
          height: height,
          margin: const EdgeInsets.only(left: 4),
          decoration: BoxDecoration(color: color, borderRadius: BorderRadius.circular(2)),
        );
      }),
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
