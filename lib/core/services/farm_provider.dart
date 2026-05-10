import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../constants/mock_farm_data.dart';

// ─── Farm State ────────────────────────────────────────────────────────────

class FarmState {
  final List<Map<String, dynamic>> racks;
  final Map<String, dynamic> metrics;
  final List<Map<String, dynamic>> aiActivity;
  final bool isLoading;
  final bool isSyncing;

  const FarmState({
    required this.racks,
    required this.metrics,
    required this.aiActivity,
    this.isLoading = false,
    this.isSyncing = false,
  });

  FarmState copyWith({
    List<Map<String, dynamic>>? racks,
    Map<String, dynamic>? metrics,
    List<Map<String, dynamic>>? aiActivity,
    bool? isLoading,
    bool? isSyncing,
  }) =>
      FarmState(
        racks: racks ?? this.racks,
        metrics: metrics ?? this.metrics,
        aiActivity: aiActivity ?? this.aiActivity,
        isLoading: isLoading ?? this.isLoading,
        isSyncing: isSyncing ?? this.isSyncing,
      );
}

class FarmNotifier extends Notifier<FarmState> {
  @override
  FarmState build() {
    return FarmState(
      racks: MockFarmData.racks,
      metrics: MockFarmData.farmMetrics,
      aiActivity: MockFarmData.aiActivity,
    );
  }

  Future<void> refresh() async {
    state = state.copyWith(isSyncing: true);
    await Future.delayed(const Duration(milliseconds: 1200));
    state = state.copyWith(isSyncing: false);
  }
}

final farmProvider = NotifierProvider<FarmNotifier, FarmState>(FarmNotifier.new);

// ─── Alerts Provider ───────────────────────────────────────────────────────

class AlertsNotifier extends Notifier<List<Map<String, dynamic>>> {
  @override
  List<Map<String, dynamic>> build() => MockFarmData.alerts;

  void markAsRead(String id) {
    state = [
      for (final alert in state)
        if (alert['id'] == id) {...alert, 'isRead': true} else alert,
    ];
  }

  void dismissAlert(String id) {
    state = state.where((a) => a['id'] != id).toList();
  }

  int get unreadCount => state.where((a) => !(a['isRead'] as bool)).length;
}

final alertsProvider =
    NotifierProvider<AlertsNotifier, List<Map<String, dynamic>>>(
  AlertsNotifier.new,
);

final unreadAlertsCountProvider = Provider<int>((ref) {
  final alerts = ref.watch(alertsProvider);
  return alerts.where((a) => !(a['isRead'] as bool)).length;
});
