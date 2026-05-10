import 'package:flutter/material.dart';
import '../../../core/theme/theme.dart';
import '../../../core/widgets/widgets.dart';

class MetricTabsSection extends StatefulWidget {
  const MetricTabsSection({super.key});

  @override
  State<MetricTabsSection> createState() => _MetricTabsSectionState();
}

class _MetricTabsSectionState extends State<MetricTabsSection> {
  int _tab = 0;
  final _tabs = ['Environment', 'Resources', 'Plant Health'];

  final _envMetrics = [
    {'icon': Icons.thermostat_rounded, 'label': 'Temp', 'value': '24.5°C', 'status': 'stable'},
    {'icon': Icons.water_drop_rounded, 'label': 'Humidity', 'value': '68%', 'status': 'optimal'},
    {'icon': Icons.air_rounded, 'label': 'CO₂', 'value': '850ppm', 'status': 'stable'},
    {'icon': Icons.light_mode_rounded, 'label': 'Light', 'value': '16hrs', 'status': 'optimal'},
  ];

  final _resourceMetrics = [
    {'icon': Icons.water_rounded, 'label': 'Water Tank', 'value': '34%', 'status': 'warning'},
    {'icon': Icons.science_rounded, 'label': 'pH Level', 'value': '6.2', 'status': 'stable'},
    {'icon': Icons.bolt_rounded, 'label': 'Power', 'value': '4.2kW', 'status': 'optimal'},
    {'icon': Icons.opacity_rounded, 'label': 'EC Level', 'value': '1.8 mS', 'status': 'stable'},
  ];

  final _healthMetrics = [
    {'icon': Icons.eco_rounded, 'label': 'Growth Rate', 'value': '+12%', 'status': 'optimal'},
    {'icon': Icons.pest_control_rounded, 'label': 'Pest Risk', 'value': 'Low', 'status': 'stable'},
    {'icon': Icons.calendar_today_rounded, 'label': 'Harvest', 'value': '3 days', 'status': 'stable'},
    {'icon': Icons.health_and_safety_rounded, 'label': 'Health', 'value': '87/100', 'status': 'optimal'},
  ];

  List<Map<String, dynamic>> get _currentMetrics {
    switch (_tab) {
      case 1: return _resourceMetrics;
      case 2: return _healthMetrics;
      default: return _envMetrics;
    }
  }

  @override
  Widget build(BuildContext context) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        // Tab bar
        SingleChildScrollView(
          scrollDirection: Axis.horizontal,
          child: Row(
            children: List.generate(_tabs.length, (i) {
              final isActive = _tab == i;
              return GestureDetector(
                onTap: () => setState(() => _tab = i),
                child: AnimatedContainer(
                  duration: const Duration(milliseconds: 200),
                  margin: const EdgeInsets.only(right: 24),
                  padding: const EdgeInsets.only(bottom: 10),
                  decoration: BoxDecoration(
                    border: Border(
                      bottom: BorderSide(
                        color: isActive ? AppColors.primary : Colors.transparent,
                        width: 3,
                      ),
                    ),
                  ),
                  child: Text(
                    _tabs[i],
                    style: AppTypography.labelLg.copyWith(
                      color: isActive ? AppColors.primary : AppColors.onSurfaceVariant,
                      fontWeight: isActive ? FontWeight.w700 : FontWeight.w600,
                    ),
                  ),
                ),
              );
            }),
          ),
        ),
        const SizedBox(height: 14),
        // Metrics grid
        GridView.count(
          shrinkWrap: true,
          physics: const NeverScrollableScrollPhysics(),
          crossAxisCount: 2,
          crossAxisSpacing: 12,
          mainAxisSpacing: 12,
          childAspectRatio: 1.2,
          children: _currentMetrics.map((m) => MetricChip(
            icon: m['icon'] as IconData,
            label: m['label'] as String,
            value: m['value'] as String,
            status: m['status'] as String,
          )).toList(),
        ),
      ],
    );
  }
}
