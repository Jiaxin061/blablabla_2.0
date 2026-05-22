import 'package:audioplayers/audioplayers.dart';
import 'package:flutter/material.dart';

/// Compact voice-message row with play/pause and duration label.
class VoiceMessageTile extends StatefulWidget {
  const VoiceMessageTile({
    super.key,
    required this.durationSeconds,
    this.filePath,
    this.isOutgoing = true,
    this.accentColor,
    this.iconColor,
    this.labelColor,
  });

  final int durationSeconds;
  final String? filePath;
  final bool isOutgoing;
  final Color? accentColor;
  final Color? iconColor;
  final Color? labelColor;

  @override
  State<VoiceMessageTile> createState() => _VoiceMessageTileState();
}

class _VoiceMessageTileState extends State<VoiceMessageTile> {
  final AudioPlayer _player = AudioPlayer();
  bool _playing = false;

  @override
  void initState() {
    super.initState();
    _player.onPlayerComplete.listen((_) {
      if (mounted) setState(() => _playing = false);
    });
  }

  @override
  void dispose() {
    _player.dispose();
    super.dispose();
  }

  String get _durationLabel {
    final s = widget.durationSeconds;
    return '${s ~/ 60}:${(s % 60).toString().padLeft(2, '0')}';
  }

  Future<void> _togglePlay() async {
    final path = widget.filePath;
    if (path == null || path.isEmpty) return;

    if (_playing) {
      await _player.stop();
      if (mounted) setState(() => _playing = false);
      return;
    }

    await _player.play(DeviceFileSource(path));
    if (mounted) setState(() => _playing = true);
  }

  @override
  Widget build(BuildContext context) {
    final accent = widget.accentColor ?? const Color(0xFF25D366);
    final iconColor = widget.iconColor ?? Colors.white;
    final labelColor = widget.labelColor ??
        (widget.isOutgoing ? const Color(0xFF111B21) : const Color(0xFF111B21));
    final canPlay = widget.filePath != null && widget.filePath!.isNotEmpty;

    return Row(
      mainAxisSize: MainAxisSize.min,
      children: [
        Material(
          color: accent,
          shape: const CircleBorder(),
          child: InkWell(
            customBorder: const CircleBorder(),
            onTap: canPlay ? _togglePlay : null,
            child: SizedBox(
              width: 40,
              height: 40,
              child: Icon(
                _playing ? Icons.pause_rounded : Icons.play_arrow_rounded,
                color: iconColor,
                size: 24,
              ),
            ),
          ),
        ),
        const SizedBox(width: 10),
        Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            SizedBox(
              width: 120,
              height: 22,
              child: CustomPaint(
                painter: _WaveformPainter(
                  color: labelColor.withValues(alpha: 0.45),
                  active: _playing,
                ),
              ),
            ),
            Text(
              'Voice message ($_durationLabel)',
              style: TextStyle(
                fontSize: 12,
                color: labelColor.withValues(alpha: 0.75),
                fontWeight: FontWeight.w500,
              ),
            ),
          ],
        ),
      ],
    );
  }
}

class _WaveformPainter extends CustomPainter {
  _WaveformPainter({required this.color, required this.active});

  final Color color;
  final bool active;

  static const _heights = [0.35, 0.7, 0.5, 0.9, 0.45, 0.75, 0.55, 0.85, 0.4, 0.65];

  @override
  void paint(Canvas canvas, Size size) {
    final paint = Paint()
      ..color = color
      ..strokeWidth = 2.5
      ..strokeCap = StrokeCap.round;

    final barWidth = size.width / (_heights.length * 2);
    for (var i = 0; i < _heights.length; i++) {
      final h = _heights[i] * size.height * (active ? 1.0 : 0.85);
      final x = i * barWidth * 2 + barWidth;
      final y = (size.height - h) / 2;
      canvas.drawLine(Offset(x, y), Offset(x, y + h), paint);
    }
  }

  @override
  bool shouldRepaint(covariant _WaveformPainter oldDelegate) =>
      oldDelegate.color != color || oldDelegate.active != active;
}
