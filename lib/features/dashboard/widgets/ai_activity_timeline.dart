import 'package:flutter/material.dart';
import '../../../core/theme/theme.dart';
import '../../../core/constants/mock_farm_data.dart';

class AiActivityTimeline extends StatelessWidget {
  const AiActivityTimeline({super.key});

  @override
  Widget build(BuildContext context) {
    final activities = MockFarmData.aiActivity;

    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Row(
          mainAxisAlignment: MainAxisAlignment.spaceBetween,
          children: [
            Text('AUTONOMOUS ACTIVITY', style: AppTypography.sectionLabel),
            Text(
              'View History',
              style: AppTypography.labelLg.copyWith(
                color: AppColors.primary,
                fontWeight: FontWeight.w700,
                fontSize: 14,
              ),
            ),
          ],
        ),
        const SizedBox(height: 12),
        ...activities.map((a) => _ActivityItem(activity: a)),
      ],
    );
  }
}

class _ActivityItem extends StatelessWidget {
  final Map<String, dynamic> activity;
  const _ActivityItem({required this.activity});

  @override
  Widget build(BuildContext context) {
    final isAI = activity['type'] == 'action';
    final bg = isAI
        ? AppColors.primaryFixed.withValues(alpha: 0.3)
        : AppColors.surfaceContainerLow;
    final border = isAI ? AppColors.primaryFixedDim : AppColors.surfaceContainerHigh;

    return Container(
      margin: const EdgeInsets.only(bottom: 10),
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: bg,
        borderRadius: AppRadius.xxlRadius,
        border: Border.all(color: border),
      ),
      child: Row(
        children: [
          Container(
            width: 40,
            height: 40,
            decoration: BoxDecoration(
              color: AppColors.surfaceContainerLowest,
              shape: BoxShape.circle,
              boxShadow: AppShadows.card,
            ),
            child: Center(
              child: Text(
                activity['icon'] as String,
                style: const TextStyle(fontSize: 18),
              ),
            ),
          ),
          const SizedBox(width: 12),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  activity['title'] as String,
                  style: AppTypography.labelLg.copyWith(
                    color: AppColors.onSurface,
                    fontWeight: FontWeight.w700,
                  ),
                ),
                const SizedBox(height: 2),
                Text(
                  '${activity['subtitle']} • ${activity['timeAgo']}',
                  style: AppTypography.caption.copyWith(
                    color: AppColors.onSurfaceVariant,
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
