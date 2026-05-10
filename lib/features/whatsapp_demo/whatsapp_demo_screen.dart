import 'package:flutter/material.dart';

class WhatsAppDemoScreen extends StatefulWidget {
  const WhatsAppDemoScreen({super.key});

  @override
  State<WhatsAppDemoScreen> createState() => _WhatsAppDemoScreenState();
}

class _WhatsAppDemoScreenState extends State<WhatsAppDemoScreen> {
  final _controller = TextEditingController();
  final _scrollController = ScrollController();
  final List<_WaMessage> _messages = [
    _WaMessage(
      isMe: false,
      text: 'Hello! I am FarmPilot. Send me a photo of a plant or ask about a rack status.',
      time: '10:00 AM',
    ),
  ];
  bool _isTyping = false;
  int _step = 0;

  @override
  void dispose() {
    _controller.dispose();
    _scrollController.dispose();
    super.dispose();
  }

  void _sendMessage(String text, {bool isImage = false}) async {
    if (text.trim().isEmpty && !isImage) return;
    _controller.clear();

    setState(() {
      _messages.add(_WaMessage(
        isMe: true,
        text: isImage ? '📷 Image attached' : text,
        time: '10:01 AM',
        isImage: isImage,
      ));
      _isTyping = true;
    });

    _scrollToBottom();

    await Future.delayed(const Duration(milliseconds: 1500));

    String reply = '';
    if (isImage) {
      reply = 'Analysis complete. 🔬\n\nIssue: Early stage calcium deficiency detected on the leaves.\nAction: I have scheduled a nutrient mix adjustment for the next fertigation cycle.';
    } else {
      if (_step == 0) {
        reply = 'Rack B is currently experiencing moisture instability on Shelf 3. 📉\n\nI have already activated a 5-minute targeted irrigation cycle to compensate. 💧';
        _step++;
      } else {
        reply = 'Everything else is running optimally! Health score is 87%. 🌱';
      }
    }

    if (mounted) {
      setState(() {
        _isTyping = false;
        _messages.add(_WaMessage(isMe: false, text: reply, time: '10:01 AM'));
      });
      _scrollToBottom();
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
    // WhatsApp specific colors
    const waTeal = Color(0xFF075E54);
    const waLightGreen = Color(0xFFDCF8C6);
    const waBackground = Color(0xFFECE5DD);

    return Scaffold(
      backgroundColor: waBackground,
      appBar: AppBar(
        backgroundColor: waTeal,
        leadingWidth: 70,
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
              backgroundColor: Colors.white24,
              child: Icon(Icons.psychology, color: Colors.white, size: 22),
            ),
          ],
        ),
        title: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            const Text(
              'FarmPilot Bot',
              style: TextStyle(fontSize: 18, fontWeight: FontWeight.w500, color: Colors.white),
            ),
            Text(
              _isTyping ? 'typing...' : 'online',
              style: const TextStyle(fontSize: 13, fontWeight: FontWeight.w400, color: Colors.white70),
            ),
          ],
        ),
        actions: [
          IconButton(icon: const Icon(Icons.videocam, color: Colors.white), onPressed: () {}),
          IconButton(icon: const Icon(Icons.call, color: Colors.white), onPressed: () {}),
          IconButton(icon: const Icon(Icons.more_vert, color: Colors.white), onPressed: () {}),
        ],
      ),
      body: Column(
        children: [
          Expanded(
            child: ListView.builder(
              controller: _scrollController,
              padding: const EdgeInsets.all(12),
              itemCount: _messages.length,
              itemBuilder: (context, i) {
                final m = _messages[i];
                return Align(
                  alignment: m.isMe ? Alignment.centerRight : Alignment.centerLeft,
                  child: Container(
                    constraints: BoxConstraints(maxWidth: MediaQuery.of(context).size.width * 0.75),
                    margin: const EdgeInsets.only(bottom: 8),
                    padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 8),
                    decoration: BoxDecoration(
                      color: m.isMe ? waLightGreen : Colors.white,
                      borderRadius: BorderRadius.only(
                        topLeft: const Radius.circular(12),
                        topRight: const Radius.circular(12),
                        bottomLeft: Radius.circular(m.isMe ? 12 : 0),
                        bottomRight: Radius.circular(m.isMe ? 0 : 12),
                      ),
                      boxShadow: [
                        BoxShadow(
                          color: Colors.black.withValues(alpha: 0.1),
                          blurRadius: 1,
                          offset: const Offset(0, 1),
                        ),
                      ],
                    ),
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        if (m.isImage)
                          Container(
                            height: 150,
                            width: 200,
                            margin: const EdgeInsets.only(bottom: 6),
                            decoration: BoxDecoration(
                              color: Colors.green.shade800,
                              borderRadius: BorderRadius.circular(8),
                            ),
                            child: const Center(
                              child: Icon(Icons.eco, color: Colors.white54, size: 48),
                            ),
                          ),
                        Row(
                          mainAxisSize: MainAxisSize.min,
                          crossAxisAlignment: CrossAxisAlignment.end,
                          children: [
                            Flexible(
                              child: Text(
                                m.text,
                                style: const TextStyle(fontSize: 15, color: Colors.black87),
                              ),
                            ),
                            const SizedBox(width: 8),
                            Text(
                              m.time,
                              style: const TextStyle(fontSize: 11, color: Colors.black45),
                            ),
                            if (m.isMe) ...[
                              const SizedBox(width: 4),
                              const Icon(Icons.done_all, size: 14, color: Colors.blue),
                            ],
                          ],
                        ),
                      ],
                    ),
                  ),
                );
              },
            ),
          ),
          // Demo Actions Bar
          Container(
            color: Colors.white,
            padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 8),
            child: SingleChildScrollView(
              scrollDirection: Axis.horizontal,
              child: Row(
                children: [
                  ActionChip(
                    label: const Text('Ask Rack B'),
                    onPressed: () => _sendMessage('How is Rack B today?'),
                    backgroundColor: Colors.grey.shade200,
                    shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(20)),
                  ),
                  const SizedBox(width: 8),
                  ActionChip(
                    label: const Text('Simulate Image Upload'),
                    avatar: const Icon(Icons.image, size: 16),
                    onPressed: () => _sendMessage('', isImage: true),
                    backgroundColor: Colors.grey.shade200,
                    shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(20)),
                  ),
                ],
              ),
            ),
          ),
          // Input Bar
          Container(
            color: waBackground,
            padding: EdgeInsets.only(
              left: 8, right: 8, top: 8,
              bottom: MediaQuery.of(context).viewInsets.bottom + 8,
            ),
            child: Row(
              children: [
                Expanded(
                  child: Container(
                    decoration: BoxDecoration(
                      color: Colors.white,
                      borderRadius: BorderRadius.circular(24),
                    ),
                    child: Row(
                      children: [
                        IconButton(
                          icon: const Icon(Icons.emoji_emotions_outlined, color: Colors.grey),
                          onPressed: () {},
                        ),
                        Expanded(
                          child: TextField(
                            controller: _controller,
                            decoration: const InputDecoration(
                              hintText: 'Message',
                              border: InputBorder.none,
                            ),
                            onSubmitted: (v) => _sendMessage(v),
                          ),
                        ),
                        IconButton(
                          icon: const Icon(Icons.attach_file, color: Colors.grey),
                          onPressed: () {},
                        ),
                        IconButton(
                          icon: const Icon(Icons.camera_alt, color: Colors.grey),
                          onPressed: () {},
                        ),
                      ],
                    ),
                  ),
                ),
                const SizedBox(width: 8),
                GestureDetector(
                  onTap: () => _sendMessage(_controller.text),
                  child: Container(
                    width: 48,
                    height: 48,
                    decoration: const BoxDecoration(
                      color: waTeal,
                      shape: BoxShape.circle,
                    ),
                    child: const Icon(Icons.mic, color: Colors.white),
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

class _WaMessage {
  final bool isMe;
  final String text;
  final String time;
  final bool isImage;

  _WaMessage({
    required this.isMe,
    required this.text,
    required this.time,
    this.isImage = false,
  });
}
