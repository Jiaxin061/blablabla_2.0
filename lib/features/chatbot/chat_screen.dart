import 'package:flutter/material.dart';
import '../../core/theme/theme.dart';
import '../../core/widgets/widgets.dart';
import '../../core/constants/mock_farm_data.dart';

class ChatScreen extends StatefulWidget {
  const ChatScreen({super.key});

  @override
  State<ChatScreen> createState() => _ChatScreenState();
}

class _ChatScreenState extends State<ChatScreen> {
  final _controller = TextEditingController();
  final _scrollController = ScrollController();
  final List<_ChatMessage> _messages = [
    _ChatMessage(
      role: 'ai',
      text: 'Hello! I\'m FarmPilot AI. I\'m currently monitoring all 3 racks. Farm health is at 87%. How can I help you today?',
    ),
  ];
  bool _isTyping = false;

  @override
  void dispose() {
    _controller.dispose();
    _scrollController.dispose();
    super.dispose();
  }

  Future<void> _sendMessage(String text) async {
    if (text.trim().isEmpty) return;
    _controller.clear();

    setState(() {
      _messages.add(_ChatMessage(role: 'user', text: text));
      _isTyping = true;
    });

    _scrollToBottom();

    // Mock AI response with delay
    await Future.delayed(const Duration(milliseconds: 1400));

    final response = _getAIResponse(text.toLowerCase());
    if (mounted) {
      setState(() {
        _messages.add(_ChatMessage(role: 'ai', text: response));
        _isTyping = false;
      });
      _scrollToBottom();
    }
  }

  String _getAIResponse(String query) {
    for (final key in MockFarmData.chatWorkflows.keys) {
      if (query.contains(key)) return MockFarmData.chatWorkflows[key]!;
    }
    return MockFarmData.chatWorkflows['default']!;
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
    return Scaffold(
      backgroundColor: AppColors.background,
      appBar: AppBar(
        backgroundColor: AppColors.surfaceContainerLowest,
        elevation: 0,
        title: Row(
          children: [
            Container(
              width: 36, height: 36,
              decoration: const BoxDecoration(color: AppColors.primary, shape: BoxShape.circle),
              child: const Icon(Icons.psychology_alt_rounded, color: Colors.white, size: 20),
            ),
            const SizedBox(width: 10),
            Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text('FarmPilot AI', style: AppTypography.headlineMd.copyWith(color: AppColors.primary, fontSize: 18)),
                const Row(
                  children: [
                    AIPulseIndicator(size: 6),
                    SizedBox(width: 4),
                    Text('Online', style: TextStyle(fontSize: 11, color: AppColors.primary, fontWeight: FontWeight.w600)),
                  ],
                ),
              ],
            ),
          ],
        ),
        actions: [
          IconButton(icon: const Icon(Icons.add_comment_rounded, color: AppColors.onSurfaceVariant), onPressed: () {}),
        ],
      ),
      body: Column(
        children: [
          // Messages
          Expanded(
            child: ListView.builder(
              controller: _scrollController,
              padding: const EdgeInsets.all(16),
              itemCount: _messages.length + (_isTyping ? 1 : 0),
              itemBuilder: (context, i) {
                if (_isTyping && i == _messages.length) {
                  return const _TypingIndicator();
                }
                return _ChatBubble(message: _messages[i]);
              },
            ),
          ),
          // Quick suggestions
          _QuickSuggestions(onTap: _sendMessage),
          // Input bar
          _ChatInputBar(
            controller: _controller,
            onSend: () => _sendMessage(_controller.text),
          ),
        ],
      ),
    );
  }
}

class _ChatMessage {
  final String role;
  final String text;
  _ChatMessage({required this.role, required this.text});
}

class _ChatBubble extends StatelessWidget {
  final _ChatMessage message;
  const _ChatBubble({required this.message});

  @override
  Widget build(BuildContext context) {
    final isAI = message.role == 'ai';
    return Padding(
      padding: const EdgeInsets.only(bottom: 12),
      child: Row(
        crossAxisAlignment: CrossAxisAlignment.end,
        mainAxisAlignment: isAI ? MainAxisAlignment.start : MainAxisAlignment.end,
        children: [
          if (isAI) ...[
            Container(
              width: 28, height: 28,
              decoration: const BoxDecoration(color: AppColors.primary, shape: BoxShape.circle),
              child: const Icon(Icons.psychology_alt_rounded, color: Colors.white, size: 16),
            ),
            const SizedBox(width: 8),
          ],
          Flexible(
            child: Container(
              padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 12),
              decoration: BoxDecoration(
                color: isAI ? AppColors.surfaceContainerLowest : AppColors.primary,
                borderRadius: BorderRadius.only(
                  topLeft: const Radius.circular(20),
                  topRight: const Radius.circular(20),
                  bottomLeft: Radius.circular(isAI ? 4 : 20),
                  bottomRight: Radius.circular(isAI ? 20 : 4),
                ),
                boxShadow: AppShadows.card,
                border: isAI ? Border.all(color: AppColors.outlineVariant) : null,
              ),
              child: Text(
                message.text,
                style: AppTypography.bodyMd.copyWith(
                  color: isAI ? AppColors.onSurface : Colors.white,
                  fontSize: 15,
                  height: 1.5,
                ),
              ),
            ),
          ),
          if (!isAI) ...[
            const SizedBox(width: 8),
            Container(
              width: 28, height: 28,
              decoration: BoxDecoration(color: AppColors.surfaceContainerHigh, shape: BoxShape.circle),
              child: const Icon(Icons.person_rounded, color: AppColors.onSurfaceVariant, size: 16),
            ),
          ],
        ],
      ),
    );
  }
}

class _TypingIndicator extends StatefulWidget {
  const _TypingIndicator();

  @override
  State<_TypingIndicator> createState() => _TypingIndicatorState();
}

class _TypingIndicatorState extends State<_TypingIndicator>
    with SingleTickerProviderStateMixin {
  late final AnimationController _ctrl;

  @override
  void initState() {
    super.initState();
    _ctrl = AnimationController(vsync: this, duration: const Duration(milliseconds: 600))
      ..repeat(reverse: true);
  }

  @override
  void dispose() { _ctrl.dispose(); super.dispose(); }

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.only(bottom: 12),
      child: Row(
        children: [
          Container(
            width: 28, height: 28,
            decoration: const BoxDecoration(color: AppColors.primary, shape: BoxShape.circle),
            child: const Icon(Icons.psychology_alt_rounded, color: Colors.white, size: 16),
          ),
          const SizedBox(width: 8),
          Container(
            padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 12),
            decoration: BoxDecoration(
              color: AppColors.surfaceContainerLowest,
              borderRadius: const BorderRadius.only(
                topLeft: Radius.circular(20), topRight: Radius.circular(20),
                bottomRight: Radius.circular(20), bottomLeft: Radius.circular(4),
              ),
              border: Border.all(color: AppColors.outlineVariant),
            ),
            child: AnimatedBuilder(
              animation: _ctrl,
              builder: (_, __) => Row(
                mainAxisSize: MainAxisSize.min,
                children: List.generate(3, (i) => Container(
                  width: 7, height: 7,
                  margin: const EdgeInsets.only(right: 4),
                  decoration: BoxDecoration(
                    color: AppColors.primary.withValues(alpha: 0.3 + _ctrl.value * 0.7),
                    shape: BoxShape.circle,
                  ),
                )),
              ),
            ),
          ),
        ],
      ),
    );
  }
}

class _QuickSuggestions extends StatelessWidget {
  final void Function(String) onTap;
  const _QuickSuggestions({required this.onTap});

  @override
  Widget build(BuildContext context) {
    final suggestions = ['How is Rack B?', 'Harvest schedule?', 'Temperature status', 'Irrigation status'];
    return SizedBox(
      height: 40,
      child: ListView.separated(
        scrollDirection: Axis.horizontal,
        padding: const EdgeInsets.symmetric(horizontal: 16),
        itemCount: suggestions.length,
        separatorBuilder: (_, __) => const SizedBox(width: 8),
        itemBuilder: (_, i) => GestureDetector(
          onTap: () => onTap(suggestions[i]),
          child: Container(
            padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 8),
            decoration: BoxDecoration(
              color: AppColors.primaryFixed.withValues(alpha: 0.4),
              borderRadius: AppRadius.fullRadius,
              border: Border.all(color: AppColors.primary.withValues(alpha: 0.2)),
            ),
            child: Text(suggestions[i],
                style: AppTypography.labelLg.copyWith(color: AppColors.primary, fontSize: 13)),
          ),
        ),
      ),
    );
  }
}

class _ChatInputBar extends StatelessWidget {
  final TextEditingController controller;
  final VoidCallback onSend;
  const _ChatInputBar({required this.controller, required this.onSend});

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: EdgeInsets.only(
        left: 16, right: 8, top: 10,
        bottom: MediaQuery.of(context).viewInsets.bottom + 12,
      ),
      decoration: const BoxDecoration(
        color: AppColors.surfaceContainerLowest,
        border: Border(top: BorderSide(color: AppColors.surfaceContainerHigh)),
      ),
      child: Row(
        children: [
          Expanded(
            child: TextField(
              controller: controller,
              decoration: InputDecoration(
                hintText: 'Ask about your farm...',
                hintStyle: AppTypography.bodyMd.copyWith(color: AppColors.onSurfaceVariant, fontSize: 15),
                border: OutlineInputBorder(
                  borderRadius: AppRadius.xxlRadius,
                  borderSide: const BorderSide(color: AppColors.outlineVariant),
                ),
                enabledBorder: OutlineInputBorder(
                  borderRadius: AppRadius.xxlRadius,
                  borderSide: const BorderSide(color: AppColors.outlineVariant),
                ),
                focusedBorder: OutlineInputBorder(
                  borderRadius: AppRadius.xxlRadius,
                  borderSide: const BorderSide(color: AppColors.primary, width: 1.5),
                ),
                contentPadding: const EdgeInsets.symmetric(horizontal: 16, vertical: 12),
                filled: true,
                fillColor: AppColors.surfaceContainerLow,
              ),
              textInputAction: TextInputAction.send,
              onSubmitted: (_) => onSend(),
            ),
          ),
          const SizedBox(width: 8),
          GestureDetector(
            onTap: onSend,
            child: Container(
              width: 48, height: 48,
              decoration: const BoxDecoration(color: AppColors.primary, shape: BoxShape.circle),
              child: const Icon(Icons.send_rounded, color: Colors.white, size: 22),
            ),
          ),
        ],
      ),
    );
  }
}
