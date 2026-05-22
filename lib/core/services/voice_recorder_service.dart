import 'dart:io';

import 'package:flutter/foundation.dart';
import 'package:path_provider/path_provider.dart';
import 'package:permission_handler/permission_handler.dart';
import 'package:record/record.dart';

class VoiceRecordingResult {
  const VoiceRecordingResult({
    required this.path,
    required this.durationSeconds,
  });

  final String path;
  final int durationSeconds;
}

/// Captures short voice clips on Android/iOS for chat demos.
class VoiceRecorderService {
  VoiceRecorderService._();

  static final VoiceRecorderService instance = VoiceRecorderService._();

  final AudioRecorder _recorder = AudioRecorder();
  DateTime? _startedAt;
  String? _activePath;

  bool get isSupported =>
      !kIsWeb && (Platform.isAndroid || Platform.isIOS);

  bool get isRecording => _startedAt != null;

  Future<bool> requestPermission() async {
    if (!isSupported) return false;
    final status = await Permission.microphone.request();
    return status.isGranted;
  }

  Future<bool> hasPermission() async {
    if (!isSupported) return false;
    return Permission.microphone.isGranted;
  }

  Future<void> start() async {
    if (!isSupported) {
      throw UnsupportedError('Voice recording is only available on mobile.');
    }

    if (_startedAt != null) return;

    final granted = await hasPermission() || await requestPermission();
    if (!granted) {
      throw StateError('Microphone permission was denied.');
    }

    final dir = await getTemporaryDirectory();
    final path =
        '${dir.path}/voice_${DateTime.now().millisecondsSinceEpoch}.m4a';

    await _recorder.start(
      const RecordConfig(
        encoder: AudioEncoder.aacLc,
        sampleRate: 44100,
        numChannels: 1,
      ),
      path: path,
    );

    _activePath = path;
    _startedAt = DateTime.now();
  }

  Future<VoiceRecordingResult?> stop() async {
    if (_startedAt == null) return null;

    final started = _startedAt!;
    final path = _activePath;
    _startedAt = null;
    _activePath = null;

    final stoppedPath = await _recorder.stop();
    final filePath = stoppedPath ?? path;
    if (filePath == null || filePath.isEmpty) return null;

    final elapsed = DateTime.now().difference(started);
    final seconds = elapsed.inSeconds < 1 ? 1 : elapsed.inSeconds.clamp(1, 300);

    return VoiceRecordingResult(path: filePath, durationSeconds: seconds);
  }

  Future<void> cancel() async {
    if (_startedAt == null) return;
    _startedAt = null;
    _activePath = null;
    await _recorder.stop();
  }

  Future<void> dispose() async {
    await cancel();
    await _recorder.dispose();
  }
}
