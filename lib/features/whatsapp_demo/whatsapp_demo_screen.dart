import 'dart:io';

import 'package:flutter/foundation.dart';
import 'package:flutter/material.dart';
import 'package:image_picker/image_picker.dart';
import 'package:intl/intl.dart';

import '../../core/constants/mock_farm_data.dart';
import '../../core/services/gemini_service.dart';
import '../../core/services/voice_recorder_service.dart';
import '../../core/widgets/voice_message_tile.dart';

class WhatsAppDemoScreen extends StatefulWidget {
  const WhatsAppDemoScreen({super.key});

  @override
  State<WhatsAppDemoScreen> createState() => _WhatsAppDemoScreenState();
}

const _waTeal = Color(0xFF075E54);
const _waLightGreen = Color(0xFFDCF8C6);
const _waBackground = Color(0xFFECE5DD);

class _WhatsAppDemoScreenState extends State<WhatsAppDemoScreen> {

  final _controller = TextEditingController();
  final _scrollController = ScrollController();
  final _picker = ImagePicker();

  final List<_WaMessage> _messages = [];
  final _voiceRecorder = VoiceRecorderService.instance;
  bool _isTyping = false;
  bool _showQuickReplies = true;
  bool _isRecordingVoice = false;

  /// Tracks what the bot last offered so "yes/ok/no" replies have context.
  String? _pendingAction;

  /// Rolling history buffer sent to Gemini (max 6 entries).
  final List<Map<String, String>> _chatHistory = [];

  @override
  void initState() {
    super.initState();
    _controller.addListener(() => setState(() {}));
    _messages.add(
      _WaMessage(
        isMe: false,
        text:
            'Hi — vBlaFarm assistant for Block 3A.\n\nAsk about any rack, harvest, or irrigation. You can also send a plant photo for a quick check.',
        time: _formatTime(DateTime.now()),
      ),
    );
  }

  @override
  void dispose() {
    _controller.dispose();
    _scrollController.dispose();
    super.dispose();
  }

  String _formatTime(DateTime dt) => DateFormat.jm().format(dt);

  Future<({String text, String? followUp, String? pendingAction})> _resolveReply(
    String userText,
  ) async {
    final q = userText.toLowerCase().trim();

    // ── Pending action — handle yes / no confirmations ─────────────────────────
    if (_pendingAction != null) {
      final isYes = q == 'yes' ||
          q == 'ok' ||
          q == 'sure' ||
          q == 'yeah' ||
          q == 'yep' ||
          q == 'yup' ||
          q.contains('go ahead') ||
          q.contains('do it') ||
          q.contains('sounds good');
      final isNo = q == 'no' ||
          q == 'nope' ||
          q == 'nah' ||
          q == 'cancel' ||
          q.contains('never mind') ||
          q.contains('nevermind') ||
          q.contains('don\'t') ||
          q.contains('dont');

      if (isYes) {
        final action = _pendingAction!;
        return switch (action) {
          'irrigate_A' => (
              text:
                  'Irrigation cycle queued for Rack A. Estimated completion: 4 minutes. Water flow: 2.3 L/min.',
              followUp: null,
              pendingAction: null,
            ),
          'irrigate_B' => (
              text:
                  'Irrigation cycle queued for Rack B. Estimated completion: 4 minutes. Water flow: 2.3 L/min.',
              followUp: null,
              pendingAction: null,
            ),
          'irrigate_C' => (
              text:
                  'Irrigation cycle queued for Rack C. Estimated completion: 4 minutes. Water flow: 2.3 L/min.',
              followUp: null,
              pendingAction: null,
            ),
          'harvest_reminder' => (
              text:
                  "Harvest reminders set! You'll get notified 24h before each scheduled harvest. Rack A is due soonest.",
              followUp: null,
              pendingAction: null,
            ),
          _ => (
              text: 'Done! Action completed.',
              followUp: null,
              pendingAction: null,
            ),
        };
      }

      if (isNo) {
        return (
          text: 'Got it, no action taken.',
          followUp: null,
          pendingAction: null,
        );
      }
    }

    // ── Greetings ──────────────────────────────────────────────────────────────
    if (q.contains('hello') || q.contains(' hi ') || q == 'hi' || q.contains('hey')) {
      return (
        text: 'Hey! vBlaFarm AI here for Block 3A. All 3 racks are online.\n'
            'Ask me about rack status, harvest dates, irrigation, or plant health.',
        followUp: null,
        pendingAction: null,
      );
    }

    // ── Help ──────────────────────────────────────────────────────────────────
    if (q.contains('help') || q.contains('what can you do')) {
      return (
        text: "Here's what I can help with:\n\n"
            '• Rack status — temp, humidity, pH, EC\n'
            '• Plant health — nitrogen, disease, alerts\n'
            '• Harvest dates for all racks\n'
            '• Irrigation — queue a cycle for any rack\n'
            '• Farm overview & health score\n\n'
            'Just ask naturally, e.g. "How is Rack B?" or "Any plant issues?"',
        followUp: null,
        pendingAction: null,
      );
    }

    // ── Specific rack queries ─────────────────────────────────────────────────
    if (q.contains('rack a')) {
      final r = MockFarmData.rackById('A');
      return (
        text: 'Rack A — ${r['crop']}\n'
            'Temp: ${r['temperature']}°C · Humidity: ${r['humidity']}% · pH: ${r['ph']} · EC: ${r['ec']} mS/cm\n'
            'Stage: ${r['stage']} · Light: ${r['lightHours']}h/day\n'
            '✅ Health: Healthy. Harvest in ${r['daysToHarvest']} days.',
        followUp: 'Want me to queue an irrigation cycle for Rack A?',
        pendingAction: 'irrigate_A',
      );
    }

    if (q.contains('rack b')) {
      final r = MockFarmData.rackById('B');
      return (
        text: 'Rack B — ${r['crop']}\n'
            'Temp: ${r['temperature']}°C · Humidity: ${r['humidity']}% · pH: ${r['ph']} · EC: ${r['ec']} mS/cm\n'
            '⚠️ Moisture at ${r['moisture']}% (optimal 82%) — irrigation active. pH elevated at ${r['ph']}.\n'
            'Stage: ${r['stage']} · Harvest in ${r['daysToHarvest']} days.',
        followUp: 'Want me to queue an additional irrigation cycle for Rack B?',
        pendingAction: 'irrigate_B',
      );
    }

    if (q.contains('rack c')) {
      final r = MockFarmData.rackById('C');
      return (
        text: 'Rack C — ${r['crop']}\n'
            'Temp: ${r['temperature']}°C · Humidity: ${r['humidity']}% · pH: ${r['ph']} · EC: ${r['ec']} mS/cm\n'
            'Stage: ${r['stage']} · Light: ${r['lightHours']}h/day\n'
            '✅ Health: Healthy. Harvest in ${r['daysToHarvest']} days.',
        followUp: 'Want me to queue an irrigation cycle for Rack C?',
        pendingAction: 'irrigate_C',
      );
    }

    // Generic "how is rack" / "check rack" without a specific letter
    if (q.contains('how is rack') || q.contains('check rack')) {
      final a = MockFarmData.rackById('A');
      final b = MockFarmData.rackById('B');
      final c = MockFarmData.rackById('C');
      return (
        text: 'Rack status overview:\n\n'
            '✅ Rack A (${a['crop']}): ${a['temperature']}°C, ${a['humidity']}% RH — Healthy\n'
            '⚠️ Rack B (${b['crop']}): ${b['temperature']}°C, ${b['humidity']}% RH — Warning\n'
            '✅ Rack C (${c['crop']}): ${c['temperature']}°C, ${c['humidity']}% RH — Healthy',
        followUp: 'Which rack would you like more details on?',
        pendingAction: null,
      );
    }

    // ── Nutrient / nitrogen deficiency ────────────────────────────────────────
    if (q.contains('nitrogen') || q.contains('nutrient') || q.contains('deficiency')) {
      return (
        text: 'Rack B Level 3 Plant 02 shows nitrogen deficiency (91% confidence).\n'
            'Recommend increasing nutrient concentration by 10%.\n\n'
            'Rack B Level 5 Plant 03 also has a mild case (85% confidence) — pH adjustment and nitrogen supplement advised.',
        followUp: null,
        pendingAction: null,
      );
    }

    // ── Disease / sick / infected ─────────────────────────────────────────────
    if (q.contains('disease') || q.contains('sick') || q.contains('infected')) {
      return (
        text: 'Rack B Level 3 Plant 04 has been flagged for possible disease (87% confidence).\n'
            'Recommendation: isolate the plant and consult an agronomist.\n\n'
            'No disease indicators detected on Racks A or C.',
        followUp: null,
        pendingAction: null,
      );
    }

    // ── Plant monitoring overview ─────────────────────────────────────────────
    if (q.contains('plant')) {
      return (
        text: 'Rack B has individual plant monitoring on Level 3 and Level 5.\n\n'
            'Level 3: 3 healthy · 1 warning (P02 — nitrogen) · 1 critical (P04 — possible disease)\n'
            'Level 5: 4 healthy · 1 warning (P03 — nitrogen deficiency)\n\n'
            'Racks A and C show no plant-level issues.',
        followUp: 'Want details on a specific plant?',
        pendingAction: null,
      );
    }

    // ── Alerts / warnings / issues ────────────────────────────────────────────
    if (q.contains('alert') || q.contains('warning') || q.contains('issue')) {
      return (
        text: 'Active alerts for Block 3A:\n\n'
            '⚠️ Water tank at ${MockFarmData.farmMetrics['waterTankLevel']}% — refill within 12 hours.\n'
            '⚠️ Rack B pH at 6.8 (optimal 6.0–6.5) — AI adjusting nutrient solution.\n'
            '🌱 B-L3-P02: Nitrogen deficiency (91% confidence).\n'
            '🚨 B-L3-P04: Possible disease (87% confidence) — isolation recommended.',
        followUp: null,
        pendingAction: null,
      );
    }

    // ── Irrigation / water ────────────────────────────────────────────────────
    if (q.contains('irrigat') || q.contains('water')) {
      final String rackLabel;
      if (q.contains('rack a')) {
        rackLabel = 'Rack A';
      } else if (q.contains('rack b')) {
        rackLabel = 'Rack B';
      } else if (q.contains('rack c')) {
        rackLabel = 'Rack C';
      } else {
        rackLabel = 'all racks';
      }
      return (
        text: 'Irrigation cycle for $rackLabel has been queued. Estimated completion: 4 minutes.\n'
            'Current water tank level: ${MockFarmData.farmMetrics['waterTankLevel']}% — monitor closely.',
        followUp: null,
        pendingAction: null,
      );
    }

    // ── Harvest ───────────────────────────────────────────────────────────────
    if (q.contains('harvest')) {
      final a = MockFarmData.rackById('A');
      final b = MockFarmData.rackById('B');
      final c = MockFarmData.rackById('C');
      return (
        text: 'Current harvest predictions:\n\n'
            '🌿 Rack A (${a['crop']}) — Ready NOW\n'
            '🥬 Rack B (${b['crop']}) — ${b['daysToHarvest']} days\n'
            '🌱 Rack C (${c['crop']}) — ${c['daysToHarvest']} days\n\n'
            'Rack A is at optimal harvest parameters — schedule pickup soon.',
        followUp: 'Would you like me to set calendar reminders for these harvest dates?',
        pendingAction: 'harvest_reminder',
      );
    }

    // ── Temperature ───────────────────────────────────────────────────────────
    if (q.contains('temp') || q.contains('temperature')) {
      final a = MockFarmData.rackById('A');
      final b = MockFarmData.rackById('B');
      final c = MockFarmData.rackById('C');
      return (
        text: 'Current temperature readings:\n\n'
            '• Rack A: ${a['temperature']}°C ✅ Optimal\n'
            '• Rack B: ${b['temperature']}°C ⚠️ Slightly elevated\n'
            '• Rack C: ${c['temperature']}°C ✅ Optimal\n\n'
            'Farm average: ${MockFarmData.farmMetrics['avgTemperature']}°C. HVAC monitoring active.',
        followUp: null,
        pendingAction: null,
      );
    }

    // ── Humidity ──────────────────────────────────────────────────────────────
    if (q.contains('humidity')) {
      final a = MockFarmData.rackById('A');
      final b = MockFarmData.rackById('B');
      final c = MockFarmData.rackById('C');
      return (
        text: 'Current humidity readings:\n\n'
            '• Rack A: ${a['humidity']}% ✅\n'
            '• Rack B: ${b['humidity']}% ⚠️ Above target range (65–70%)\n'
            '• Rack C: ${c['humidity']}% ✅\n\n'
            'Farm average: ${MockFarmData.farmMetrics['avgHumidity']}%.',
        followUp: null,
        pendingAction: null,
      );
    }

    // ── Farm overview / summary ───────────────────────────────────────────────
    if (q.contains('farm') || q.contains('overview') || q.contains('summary')) {
      return (
        text: 'Block 3A Farm Summary:\n\n'
            '• ${MockFarmData.farmMetrics['activeRacks']} active racks — health score ${MockFarmData.farmMetrics['healthScore']}/100\n'
            '• Avg temp: ${MockFarmData.farmMetrics['avgTemperature']}°C · Avg humidity: ${MockFarmData.farmMetrics['avgHumidity']}%\n'
            '• Water tank: ${MockFarmData.farmMetrics['waterTankLevel']}% ⚠️ · Power: ${MockFarmData.farmMetrics['powerUsageKw']} kW\n'
            '• ${MockFarmData.farmMetrics['totalAlerts']} active alerts — no critical issues.',
        followUp: null,
        pendingAction: null,
      );
    }

    // ── Healthy / all good / status / health score ────────────────────────────
    if (q.contains('healthy') || q.contains('all good') ||
        q.contains('status') || q.contains('health') || q.contains('score')) {
      return (
        text: 'All racks are operational.\n\n'
            '✅ Rack A: Healthy (Butterhead Lettuce)\n'
            '⚠️ Rack B: 1 warning — L3-P02 nitrogen deficiency\n'
            '✅ Rack C: Healthy (Basil)\n\n'
            'Farm health score: ${MockFarmData.farmMetrics['healthScore']}/100.',
        followUp: null,
        pendingAction: null,
      );
    }

    // ── Gemini fallback ───────────────────────────────────────────────────────
    if (GeminiService.isConfigured) {
      final geminiReply = await GeminiService.chat(userText, history: _chatHistory);
      if (geminiReply != null) {
        return (text: geminiReply, followUp: null, pendingAction: null);
      }
    }

    // ── Default fallback ──────────────────────────────────────────────────────
    return (
      text: "I'm not sure about that. Try asking about a specific rack, plant health, irrigation, or harvest dates.",
      followUp: null,
      pendingAction: null,
    );
  }

  Future<void> _replyAsBot(String text, {String? followUp}) async {
    final typingMs = (800 + text.length * 6).clamp(800, 1500);
    await Future.delayed(Duration(milliseconds: typingMs));
    if (!mounted) return;

    setState(() {
      _isTyping = false;
      _messages.add(_WaMessage(isMe: false, text: text, time: _formatTime(DateTime.now())));
    });
    _scrollToBottom();

    if (followUp != null) {
      setState(() => _isTyping = true);
      await Future.delayed(const Duration(milliseconds: 1000));
      if (!mounted) return;
      setState(() {
        _isTyping = false;
        _messages.add(_WaMessage(isMe: false, text: followUp, time: _formatTime(DateTime.now())));
      });
      _scrollToBottom();
    }
  }

  Future<void> _sendVoiceMessage(String path, int durationSeconds) async {
    setState(() {
      _showQuickReplies = false;
      _messages.add(
        _WaMessage(
          isMe: true,
          text: '',
          time: _formatTime(DateTime.now()),
          voicePath: path,
          voiceDurationSeconds: durationSeconds,
        ),
      );
      _isTyping = true;
    });
    _scrollToBottom();

    await _replyAsBot(
      'Voice note received (${durationSeconds}s). '
      'Rack B moisture is recovering and no urgent action is needed right now.',
      followUp: 'Would you like a harvest reminder for Rack B?',
    );
  }

  void _showVoiceUnavailableSnackBar() {
    if (!mounted) return;
    ScaffoldMessenger.of(context).showSnackBar(
      const SnackBar(content: Text('Voice recording is available on mobile only')),
    );
  }

  Future<void> _toggleVoiceRecording() async {
    if (!_voiceRecorder.isSupported) {
      _showVoiceUnavailableSnackBar();
      return;
    }

    if (_isRecordingVoice) {
      try {
        final result = await _voiceRecorder.stop();
        if (!mounted) return;
        setState(() => _isRecordingVoice = false);
        if (result != null) {
          await _sendVoiceMessage(result.path, result.durationSeconds);
        }
      } catch (e) {
        if (!mounted) return;
        setState(() => _isRecordingVoice = false);
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(content: Text('Could not save recording: $e')),
        );
      }
      return;
    }

    try {
      await _voiceRecorder.start();
      if (!mounted) return;
      setState(() => _isRecordingVoice = true);
    } catch (e) {
      if (!mounted) return;
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text('$e')),
      );
    }
  }

  void _addToHistory(String role, String text) {
    _chatHistory.add({'role': role, 'text': text});
    if (_chatHistory.length > 6) _chatHistory.removeAt(0);
  }

  Future<void> _sendText(String text) async {
    final trimmed = text.trim();
    if (trimmed.isEmpty) return;
    _controller.clear();
    setState(() {
      _showQuickReplies = false;
      _messages.add(_WaMessage(isMe: true, text: trimmed, time: _formatTime(DateTime.now())));
      _isTyping = true;
    });
    _scrollToBottom();
    _addToHistory('user', trimmed);

    final reply = await _resolveReply(trimmed);

    // Update pending action: clear any previous, then set the new one.
    setState(() => _pendingAction = reply.pendingAction);

    await _replyAsBot(reply.text, followUp: reply.followUp);
    _addToHistory('bot', reply.text);
  }

  Future<void> _pickAndSendPhoto(ImageSource source) async {
    try {
      final file = await _picker.pickImage(source: source, imageQuality: 85);
      if (file == null || !mounted) return;

      setState(() {
        _showQuickReplies = false;
        _messages.add(
          _WaMessage(
            isMe: true,
            text: '',
            time: _formatTime(DateTime.now()),
            imagePath: file.path,
          ),
        );
        _isTyping = true;
      });
      final bytes = await file.readAsBytes();
      if (mounted) {
        setState(() {
          final i = _messages.length - 1;
          _messages[i] = _WaMessage(
            isMe: true,
            text: '',
            time: _messages[i].time,
            imageBytes: bytes,
            imagePath: kIsWeb ? null : file.path,
          );
        });
      }
      _scrollToBottom();

      await _replyAsBot(
        'Thanks for the photo — I\'ve checked the leaves.\n\n'
        'Early nitrogen stress is likely on Rack B (pale leaf colour). '
        'I\'ve logged a short irrigation pulse and adjusted the nutrient mix for the next cycle.',
        followUp: 'I can suggest a product or monitor Rack B for the next 2 hours.',
      );
    } catch (e) {
      if (!mounted) return;
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text('Could not open camera: $e')),
      );
    }
  }

  void _scrollToBottom() {
    Future.delayed(const Duration(milliseconds: 100), () {
      if (_scrollController.hasClients) {
        _scrollController.animateTo(
          _scrollController.position.maxScrollExtent,
          duration: const Duration(milliseconds: 300),
          curve: Curves.easeOut,
        );
      }
    });
  }

  @override
  Widget build(BuildContext context) {
    final hasText = _controller.text.trim().isNotEmpty;
    final viewInsets = MediaQuery.viewInsetsOf(context);
    final keyboardVisible = viewInsets.bottom > 0;

    return Scaffold(
      resizeToAvoidBottomInset: true,
      backgroundColor: _waBackground,
      appBar: AppBar(
        backgroundColor: _waTeal,
        leadingWidth: 95,
        leading: Row(
          children: [
            IconButton(
              icon: const Icon(Icons.arrow_back, color: Colors.white),
              padding: EdgeInsets.zero,
              constraints: const BoxConstraints(minWidth: 30),
              onPressed: () => Navigator.of(context).pop(),
            ),
            const CircleAvatar(
              radius: 18,
              backgroundColor: Color(0xFF25D366),
              child: Icon(Icons.eco_rounded, color: Colors.white, size: 20),
            ),
          ],
        ),
        title: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            const Text(
              'vBlaFarm',
              style: TextStyle(fontSize: 18, fontWeight: FontWeight.w500, color: Colors.white),
            ),
            Text(
              _isTyping ? 'typing…' : 'online',
              style: const TextStyle(fontSize: 13, color: Colors.white70),
            ),
          ],
        ),
        actions: [
          IconButton(icon: const Icon(Icons.videocam, color: Colors.white), onPressed: () {}),
          IconButton(icon: const Icon(Icons.call, color: Colors.white), onPressed: () {}),
          IconButton(icon: const Icon(Icons.more_vert, color: Colors.white), onPressed: () {}),
        ],
      ),
      body: SafeArea(
        top: false,
        bottom: !keyboardVisible,
        child: Column(
          children: [
            Expanded(
              child: ListView.builder(
                controller: _scrollController,
                padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 8),
                itemCount: _messages.length + (_isTyping ? 1 : 0),
                itemBuilder: (context, i) {
                  if (_isTyping && i == _messages.length) {
                    return const Align(
                      alignment: Alignment.centerLeft,
                      child: _TypingBubble(),
                    );
                  }
                  final m = _messages[i];
                  if (i == 0) {
                    return Column(
                      children: [
                        const _EncryptionNotice(),
                        const SizedBox(height: 8),
                        _MessageBubble(message: m),
                      ],
                    );
                  }
                  return _MessageBubble(message: m);
                },
              ),
            ),
            if (_showQuickReplies && !_isTyping && !keyboardVisible)
              Container(
                color: Colors.white,
                padding: const EdgeInsets.fromLTRB(8, 6, 8, 4),
                child: SingleChildScrollView(
                  scrollDirection: Axis.horizontal,
                  child: Row(
                    children: [
                      _QuickReply(label: 'How is Rack B?', onTap: () => _sendText('How is Rack B?')),
                      _QuickReply(label: 'Any plant issues?', onTap: () => _sendText('Any plant issues?')),
                      _QuickReply(label: 'Harvest dates', onTap: () => _sendText('Harvest dates')),
                      _QuickReply(label: 'Irrigate Rack A', onTap: () => _sendText('Irrigate Rack A')),
                      _QuickReply(label: 'Farm health', onTap: () => _sendText('Farm health overview')),
                    ],
                  ),
                ),
              ),
            _MessageInputBar(
              hasText: hasText,
              isRecordingVoice: _isRecordingVoice,
              controller: _controller,
              onSend: _sendText,
              onPickPhoto: _pickAndSendPhoto,
              onMicTap: _toggleVoiceRecording,
            ),
            _AiStatusBar(),
          ],
        ),
      ),
    );
  }
}

class _AiStatusBar extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    final isGemini = GeminiService.isConfigured;
    return Container(
      color: _waBackground,
      padding: const EdgeInsets.only(bottom: 6, top: 2),
      child: Center(
        child: Text(
          isGemini
              ? '✦ Powered by Gemini AI'
              : 'AI powered by keyword matching · Add Gemini key for full AI',
          style: const TextStyle(fontSize: 11, color: Color(0xFF90A4AE)),
        ),
      ),
    );
  }
}

class _MessageInputBar extends StatelessWidget {
  const _MessageInputBar({
    required this.hasText,
    required this.isRecordingVoice,
    required this.controller,
    required this.onSend,
    required this.onPickPhoto,
    required this.onMicTap,
  });

  final bool hasText;
  final bool isRecordingVoice;
  final TextEditingController controller;
  final ValueChanged<String> onSend;
  final ValueChanged<ImageSource> onPickPhoto;
  final VoidCallback onMicTap;

  @override
  Widget build(BuildContext context) {
    return Container(
      color: _waBackground,
      padding: const EdgeInsets.fromLTRB(6, 6, 6, 6),
      child: Row(
        crossAxisAlignment: CrossAxisAlignment.end,
        children: [
          IconButton(
            icon: const Icon(Icons.emoji_emotions_outlined, color: Color(0xFF54656F)),
            onPressed: () {},
          ),
          Expanded(
            child: Container(
              decoration: BoxDecoration(
                color: Colors.white,
                borderRadius: BorderRadius.circular(24),
              ),
              child: Row(
                crossAxisAlignment: CrossAxisAlignment.end,
                children: [
                  Expanded(
                    child: TextField(
                      controller: controller,
                      maxLines: 4,
                      minLines: 1,
                      decoration: const InputDecoration(
                        hintText: 'Message',
                        border: InputBorder.none,
                        contentPadding: EdgeInsets.symmetric(horizontal: 12, vertical: 10),
                      ),
                      onSubmitted: onSend,
                    ),
                  ),
                  PopupMenuButton<ImageSource>(
                    icon: const Icon(Icons.attach_file, color: Color(0xFF54656F)),
                    padding: EdgeInsets.zero,
                    onSelected: onPickPhoto,
                    itemBuilder: (context) => [
                      const PopupMenuItem(
                        value: ImageSource.gallery,
                        child: Text('Gallery'),
                      ),
                      if (!kIsWeb)
                        const PopupMenuItem(
                          value: ImageSource.camera,
                          child: Text('Camera'),
                        ),
                    ],
                  ),
                ],
              ),
            ),
          ),
          const SizedBox(width: 4),
          GestureDetector(
            onTap: hasText ? () => onSend(controller.text) : onMicTap,
            child: Container(
              width: 48,
              height: 48,
              decoration: BoxDecoration(
                color: isRecordingVoice && !hasText
                    ? const Color(0xFFC62828)
                    : const Color(0xFF25D366),
                shape: BoxShape.circle,
              ),
              child: Icon(
                hasText
                    ? Icons.send_rounded
                    : (isRecordingVoice ? Icons.stop_rounded : Icons.mic_rounded),
                color: Colors.white,
              ),
            ),
          ),
        ],
      ),
    );
  }
}

class _EncryptionNotice extends StatelessWidget {
  const _EncryptionNotice();

  @override
  Widget build(BuildContext context) {
    return Center(
      child: Container(
        margin: const EdgeInsets.only(bottom: 4),
        padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 6),
        decoration: BoxDecoration(
          color: const Color(0xFFFFF0C4),
          borderRadius: BorderRadius.circular(8),
        ),
        child: const Text(
          'Messages are end-to-end encrypted. Only people in this chat can read them.',
          textAlign: TextAlign.center,
          style: TextStyle(fontSize: 11, color: Color(0xFF54656F)),
        ),
      ),
    );
  }
}

class _TypingBubble extends StatelessWidget {
  const _TypingBubble();

  @override
  Widget build(BuildContext context) {
    return Container(
      margin: const EdgeInsets.only(bottom: 8),
      padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 10),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: const BorderRadius.only(
          topLeft: Radius.circular(12),
          topRight: Radius.circular(12),
          bottomRight: Radius.circular(12),
        ),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withValues(alpha: 0.06),
            blurRadius: 1,
            offset: const Offset(0, 1),
          ),
        ],
      ),
      child: const Row(
        mainAxisSize: MainAxisSize.min,
        children: [
          _TypingDot(delay: 0),
          SizedBox(width: 4),
          _TypingDot(delay: 200),
          SizedBox(width: 4),
          _TypingDot(delay: 400),
        ],
      ),
    );
  }
}

class _TypingDot extends StatefulWidget {
  final int delay;
  const _TypingDot({required this.delay});

  @override
  State<_TypingDot> createState() => _TypingDotState();
}

class _TypingDotState extends State<_TypingDot> with SingleTickerProviderStateMixin {
  late final AnimationController _ctrl;

  @override
  void initState() {
    super.initState();
    _ctrl = AnimationController(vsync: this, duration: const Duration(milliseconds: 900))..repeat(reverse: true);
    Future.delayed(Duration(milliseconds: widget.delay), () {
      if (mounted) _ctrl.repeat(reverse: true);
    });
  }

  @override
  void dispose() {
    _ctrl.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return FadeTransition(
      opacity: Tween<double>(begin: 0.35, end: 1).animate(_ctrl),
      child: Container(
        width: 8,
        height: 8,
        decoration: const BoxDecoration(color: Color(0xFF90A4AE), shape: BoxShape.circle),
      ),
    );
  }
}

class _MessageBubble extends StatelessWidget {
  final _WaMessage message;
  const _MessageBubble({required this.message});

  @override
  Widget build(BuildContext context) {
    final m = message;
    return Align(
      alignment: m.isMe ? Alignment.centerRight : Alignment.centerLeft,
      child: Container(
        constraints: BoxConstraints(maxWidth: MediaQuery.of(context).size.width * 0.78),
        margin: const EdgeInsets.only(bottom: 6),
        padding: EdgeInsets.fromLTRB(8, 8, 8, m.hasImage ? 4 : 8),
        decoration: BoxDecoration(
          color: m.isMe ? _waLightGreen : Colors.white,
          borderRadius: BorderRadius.only(
            topLeft: const Radius.circular(8),
            topRight: const Radius.circular(8),
            bottomLeft: Radius.circular(m.isMe ? 8 : 2),
            bottomRight: Radius.circular(m.isMe ? 2 : 8),
          ),
          boxShadow: [
            BoxShadow(
              color: Colors.black.withValues(alpha: 0.06),
              blurRadius: 1,
              offset: const Offset(0, 1),
            ),
          ],
        ),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.end,
          children: [
            if (m.hasImage) ...[
              ClipRRect(
                borderRadius: BorderRadius.circular(6),
                child: _buildImage(m),
              ),
              if (m.text.isNotEmpty) const SizedBox(height: 4),
            ],
            if (m.isVoiceMessage)
              Padding(
                padding: const EdgeInsets.symmetric(horizontal: 4),
                child: VoiceMessageTile(
                  durationSeconds: m.voiceDurationSeconds!,
                  filePath: m.voicePath,
                  isOutgoing: m.isMe,
                  accentColor: const Color(0xFF25D366),
                ),
              )
            else if (m.text.isNotEmpty)
              Padding(
                padding: const EdgeInsets.symmetric(horizontal: 4),
                child: Text(
                  m.text,
                  style: const TextStyle(fontSize: 15, height: 1.35, color: Color(0xFF111B21)),
                ),
              ),
            Padding(
              padding: const EdgeInsets.only(right: 4, top: 2),
              child: Row(
                mainAxisSize: MainAxisSize.min,
                children: [
                  Text(m.time, style: const TextStyle(fontSize: 11, color: Color(0xFF667781))),
                  if (m.isMe) ...[
                    const SizedBox(width: 4),
                    const Icon(
                      Icons.done_all,
                      size: 16,
                      color: Color(0xFF53BDEB),
                    ),
                  ],
                ],
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildImage(_WaMessage m) {
    if (m.imageBytes != null) {
      return Image.memory(m.imageBytes!, width: 220, height: 160, fit: BoxFit.cover);
    }
    if (m.imagePath != null && !kIsWeb) {
      return Image.file(File(m.imagePath!), width: 220, height: 160, fit: BoxFit.cover);
    }
    return const SizedBox(
      width: 220,
      height: 120,
      child: Center(child: Icon(Icons.image_not_supported_outlined)),
    );
  }
}

class _QuickReply extends StatelessWidget {
  final String label;
  final VoidCallback onTap;
  const _QuickReply({required this.label, required this.onTap});

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.only(right: 8),
      child: ActionChip(
        label: Text(label),
        onPressed: onTap,
        backgroundColor: const Color(0xFFF0F2F5),
        labelStyle: const TextStyle(color: Color(0xFF027B5B), fontWeight: FontWeight.w500),
        side: BorderSide.none,
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(16)),
      ),
    );
  }
}

class _WaMessage {
  final bool isMe;
  final String text;
  final String time;
  final String? imagePath;
  final Uint8List? imageBytes;
  final String? voicePath;
  final int? voiceDurationSeconds;

  _WaMessage({
    required this.isMe,
    required this.text,
    required this.time,
    this.imagePath,
    this.imageBytes,
    this.voicePath,
    this.voiceDurationSeconds,
  });

  bool get hasImage => imagePath != null || imageBytes != null;

  bool get isVoiceMessage =>
      voiceDurationSeconds != null && voiceDurationSeconds! > 0;
}
