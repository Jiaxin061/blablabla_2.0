import 'package:flutter/material.dart';
import '../../../core/theme/theme.dart';
import '../../../core/widgets/widgets.dart';

class RackStatusRow extends StatelessWidget {
  final List<Map<String, dynamic>> racks;
  const RackStatusRow({super.key, required this.racks});

  @override
  Widget build(BuildContext context) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text('VERTICAL RACKS STATUS', style: AppTypography.sectionLabel),
        const SizedBox(height: 12),
        Row(
          children: racks.map((rack) {
            final healthStr = rack['health'] as String;
            final status = FarmStatusEx.fromString(healthStr);
            final isLast = rack == racks.last;
            return Expanded(
              child: Padding(
                padding: EdgeInsets.only(right: isLast ? 0 : 10),
                child: FarmStatusCard(
                  rackId: rack['id'] as String,
                  cropName: rack['crop'] as String,
                  status: status,
                  metric: '${rack['moisture']}%',
                  metricLabel: 'Moisture',
                ),
              ),
            );
          }).toList(),
        ),
      ],
    );
  }
}
