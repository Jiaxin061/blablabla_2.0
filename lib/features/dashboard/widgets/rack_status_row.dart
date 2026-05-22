import 'package:flutter/material.dart';
import '../../../core/theme/theme.dart';
import '../../../core/widgets/widgets.dart';

class RackStatusRow extends StatelessWidget {
  final List<Map<String, dynamic>> racks;
  const RackStatusRow({super.key, required this.racks});

  static String _imagePath(String rackId) {
    switch (rackId.toUpperCase()) {
      case 'A':
        return 'assets/images/rackA.png';
      case 'B':
        return 'assets/images/rackB.png';
      case 'C':
        return 'assets/images/rackC.png';
      default:
        return 'assets/images/rackA.png';
    }
  }

  @override
  Widget build(BuildContext context) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text('VERTICAL RACKS STATUS', style: AppTypography.sectionLabel),
        const SizedBox(height: 12),
        ...racks.map((rack) {
          final healthStr = rack['health'] as String;
          final status = FarmStatusEx.fromString(healthStr);
          return Padding(
            padding: const EdgeInsets.only(bottom: 10),
            child: FarmStatusCard(
              rackId: rack['id'] as String,
              cropName: rack['crop'] as String,
              status: status,
              imagePath: _imagePath(rack['id'] as String),
              details: rack,
              metric: '${rack['moisture']}%',
              metricLabel: 'Moisture',
            ),
          );
        }),
      ],
    );
  }
}
