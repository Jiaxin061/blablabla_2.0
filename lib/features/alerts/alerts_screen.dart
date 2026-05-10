import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../../core/theme/theme.dart';
import '../../core/widgets/widgets.dart';
import '../../core/services/farm_provider.dart';

class AlertsScreen extends ConsumerWidget {
  const AlertsScreen({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final alerts = ref.watch(alertsProvider);
    final unread = alerts.where((a) => !(a['isRead'] as bool)).length;

    return Scaffold(
      backgroundColor: AppColors.background,
      appBar: AppBar(
        backgroundColor: AppColors.surfaceContainerLowest,
        title: Row(
          children: [
            Text('Alerts', style: AppTypography.headlineMd.copyWith(color: AppColors.onSurface)),
            if (unread > 0) ...[
              const SizedBox(width: 10),
              Container(
                padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 3),
                decoration: BoxDecoration(
                  color: AppColors.error,
                  borderRadius: AppRadius.fullRadius,
                ),
                child: Text('$unread',
                    style: const TextStyle(color: Colors.white, fontSize: 12, fontWeight: FontWeight.w700)),
              ),
            ],
          ],
        ),
        actions: [
          TextButton(
            onPressed: () {
              for (final a in alerts) {
                ref.read(alertsProvider.notifier).markAsRead(a['id'] as String);
              }
            },
            child: Text('Mark all read',
                style: AppTypography.labelLg.copyWith(color: AppColors.primary, fontSize: 14)),
          ),
        ],
      ),
      body: alerts.isEmpty
          ? Center(
              child: Column(
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  Icon(Icons.check_circle_outline_rounded, size: 64, color: AppColors.primary.withValues(alpha: 0.4)),
                  const SizedBox(height: 16),
                  Text('All clear!', style: AppTypography.headlineMd.copyWith(color: AppColors.onSurfaceVariant)),
                ],
              ),
            )
          : ListView.separated(
              padding: const EdgeInsets.all(AppSpacing.marginMobile),
              itemCount: alerts.length,
              separatorBuilder: (_, __) => const SizedBox(height: 10),
              itemBuilder: (context, i) {
                final a = alerts[i];
                return AlertCard(
                  title: a['title'] as String,
                  description: a['description'] as String,
                  type: AlertTypeEx.fromString(a['type'] as String),
                  timeAgo: a['timestamp'] as String,
                  isRead: a['isRead'] as bool,
                  onTap: () => ref.read(alertsProvider.notifier).markAsRead(a['id'] as String),
                );
              },
            ),
    );
  }
}
