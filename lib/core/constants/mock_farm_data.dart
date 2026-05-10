/// Mock farm data for demo stability.
/// Provides believable, pre-seeded environmental readings.
abstract final class MockFarmData {
  // ─── Rack Status ──────────────────────────────────────────────────────────
  static const List<Map<String, dynamic>> racks = [
    {
      'id': 'A',
      'name': 'Rack A',
      'crop': 'Butterhead Lettuce',
      'health': 'healthy',
      'moisture': 82,
      'temperature': 23.5,
      'humidity': 68,
      'lightHours': 16,
      'ph': 6.2,
      'ec': 1.8,
      'daysToHarvest': 7,
      'stage': 'Mature',
      'shelves': 5,
    },
    {
      'id': 'B',
      'name': 'Rack B',
      'crop': 'Romaine Lettuce',
      'health': 'warning',
      'moisture': 72,
      'temperature': 24.8,
      'humidity': 75,
      'lightHours': 16,
      'ph': 6.8,
      'ec': 2.1,
      'daysToHarvest': 3,
      'stage': 'Seedling',
      'shelves': 5,
    },
    {
      'id': 'C',
      'name': 'Rack C',
      'crop': 'Basil',
      'health': 'healthy',
      'moisture': 79,
      'temperature': 22.9,
      'humidity': 66,
      'lightHours': 14,
      'ph': 6.0,
      'ec': 1.6,
      'daysToHarvest': 12,
      'stage': 'Vegetative',
      'shelves': 5,
    },
  ];

  // ─── Global Farm Metrics ──────────────────────────────────────────────────
  static const Map<String, dynamic> farmMetrics = {
    'overallHealth': 'healthy',
    'healthScore': 87,
    'activeRacks': 3,
    'totalAlerts': 2,
    'criticalAlerts': 0,
    'avgTemperature': 23.7,
    'avgHumidity': 69.7,
    'waterTankLevel': 34,
    'powerUsageKw': 4.2,
    'aiConfidence': 91,
  };

  // ─── AI Activity Log ──────────────────────────────────────────────────────
  static const List<Map<String, dynamic>> aiActivity = [
    {
      'icon': '🧠',
      'title': 'AI activated irrigation',
      'subtitle': 'Scheduled optimisation for Rack B',
      'timeAgo': '12m ago',
      'type': 'action',
    },
    {
      'icon': '💡',
      'title': 'LED brightness adjusted',
      'subtitle': 'Spectrum tuned for flowering phase',
      'timeAgo': '1h ago',
      'type': 'automation',
    },
    {
      'icon': '🌡️',
      'title': 'Temperature anomaly resolved',
      'subtitle': 'HVAC recalibrated — Rack A, Shelf 3',
      'timeAgo': '3h ago',
      'type': 'resolved',
    },
    {
      'icon': '📅',
      'title': 'Harvest prediction updated',
      'subtitle': 'Rack B lettuce ready in 3 days',
      'timeAgo': '6h ago',
      'type': 'prediction',
    },
  ];

  // ─── Mock Alerts ──────────────────────────────────────────────────────────
  static const List<Map<String, dynamic>> alerts = [
    {
      'id': '1',
      'type': 'warning',
      'title': 'Water Tank Low',
      'description': 'Main reservoir at 34%. Refill recommended within 12 hours.',
      'rack': null,
      'timestamp': '2 min ago',
      'isRead': false,
    },
    {
      'id': '2',
      'type': 'info',
      'title': 'pH Slightly High — Rack B',
      'description': 'pH reading 6.8, optimal range 6.0–6.5. AI adjusting nutrient solution.',
      'rack': 'B',
      'timestamp': '15 min ago',
      'isRead': false,
    },
    {
      'id': '3',
      'type': 'success',
      'title': 'Harvest Ready — Rack A',
      'description': 'Butterhead Lettuce reached optimal harvest parameters. Schedule pickup.',
      'rack': 'A',
      'timestamp': '1 hour ago',
      'isRead': true,
    },
    {
      'id': '4',
      'type': 'warning',
      'title': 'Moisture Instability — Rack B',
      'description': 'Moisture trending 14% below optimal. Irrigation cycle initiated.',
      'rack': 'B',
      'timestamp': '2 hours ago',
      'isRead': true,
    },
  ];

  // ─── Mock Chat Responses ──────────────────────────────────────────────────
  static const Map<String, String> chatWorkflows = {
    'rack b': 'Rack B is currently showing moisture instability at 72% (optimal: 82%). I\'ve already activated an irrigation cycle. pH is slightly elevated at 6.8 — I\'m adjusting the nutrient solution mix. Romaine lettuce in this rack is 3 days from harvest. Recommend scheduling pickup now.',
    'harvest': 'Current harvest predictions:\n\n🌿 Rack A (Butterhead Lettuce) — Ready NOW\n🥬 Rack B (Romaine) — 3 days\n🌱 Rack C (Basil) — 12 days\n\nWould you like me to schedule calendar reminders for these harvest dates?',
    'temperature': 'Current temperature readings:\n\n• Rack A: 23.5°C ✅ Optimal\n• Rack B: 24.8°C ⚠️ Slightly elevated\n• Rack C: 22.9°C ✅ Optimal\n\nRack B temperature spike detected 45 minutes ago — HVAC cycle adjusted. Monitoring continuously.',
    'irrigation': 'Irrigation status across all racks:\n\n• Rack A: Last irrigated 2h ago — Next in 4h\n• Rack B: Active irrigation cycle — started 12 min ago\n• Rack C: Last irrigated 1h ago — Next in 5h\n\nAll drip systems operating normally. Water consumption today: 18.4L (within optimal range).',
    'default': 'I\'m continuously monitoring all 3 racks. Current farm health score is 87/100. Two active alerts require attention: Water Tank at 34% and Rack B pH elevation. I\'ve already initiated corrective actions. What would you like to know more about?',
  };
}
