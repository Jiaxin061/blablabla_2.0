/// Application-wide constants for vBlaFarm.
abstract final class AppConstants {
  // ─── App Identity ─────────────────────────────────────────────────────────
  static const String appName = 'vBlaFarm';
  static const String appTagline = 'AI-Powered Vertical Farming Intelligence';

  // ─── AI Identity ──────────────────────────────────────────────────────────
  static const String aiAssistantName = 'vBlaFarm AI';
  static const String aiSystemPrompt = '''
You are vBlaFarm AI, an intelligent operational assistant for indoor vertical farming.
You monitor, predict, and optimise growing environments across all racks.
Your responses are precise, actionable, and empathetic to farm operators.
Focus on: crop health, environmental conditions, irrigation, harvesting, and anomaly detection.
Always provide structured insights with confidence levels when making predictions.
''';

  // ─── Demo Farm Data ───────────────────────────────────────────────────────
  static const List<String> rackIds = ['A', 'B', 'C'];
  static const int defaultShelvesPerRack = 5;

  // ─── Firestore Collections ────────────────────────────────────────────────
  static const String colUsers = 'users';
  static const String colRacks = 'racks';
  static const String colAlerts = 'alerts';
  static const String colChatHistory = 'chat_history';
  static const String colHarvestPredictions = 'harvest_predictions';
  static const String colAiLogs = 'ai_logs';

  // ─── Hive Boxes ───────────────────────────────────────────────────────────
  static const String hiveBoxSettings = 'settings';
  static const String hiveBoxChat = 'chat_cache';
  static const String hiveBoxFarm = 'farm_cache';
  static const String hiveBoxTagRegistry = 'tag_registry';

  // ─── Web layout (desktop browser: phone-width column, unchanged on native) ─
  static const double webMobileViewportMaxWidth = 428;

  // ─── Animation Durations ──────────────────────────────────────────────────
  static const Duration animFast = Duration(milliseconds: 150);
  static const Duration animMedium = Duration(milliseconds: 300);
  static const Duration animSlow = Duration(milliseconds: 600);
  static const Duration animPulse = Duration(seconds: 2);
  static const Duration aiThinkingDelay = Duration(milliseconds: 800);
  static const Duration aiResponseDelay = Duration(milliseconds: 1500);

  // ─── Polling / Refresh ────────────────────────────────────────────────────
  static const Duration refreshInterval = Duration(seconds: 30);
  static const Duration syncIndicatorDuration = Duration(seconds: 3);
}
