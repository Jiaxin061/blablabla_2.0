import 'dart:async';

import 'package:camera/camera.dart';
import 'package:flutter/material.dart';
import 'package:permission_handler/permission_handler.dart';

import '../../../core/services/apriltag_platform_detector.dart';

/// Live camera preview with AprilTag detection (Dart image match on Android).
class ArCameraScanner extends StatefulWidget {
  final void Function(int tagId) onTagDetected;
  final Widget scanOverlay;
  final bool enabled;

  const ArCameraScanner({
    super.key,
    required this.onTagDetected,
    required this.scanOverlay,
    this.enabled = true,
  });

  @override
  State<ArCameraScanner> createState() => _ArCameraScannerState();
}

class _ArCameraScannerState extends State<ArCameraScanner> {
  CameraController? _controller;
  bool _initializing = true;
  bool _disposing = false;
  String? _error;
  bool _processingFrame = false;
  DateTime _lastFrameAt = DateTime.fromMillisecondsSinceEpoch(0);
  static const _frameInterval = Duration(milliseconds: 400);

  @override
  void initState() {
    super.initState();
    unawaited(_initCamera());
  }

  @override
  void didUpdateWidget(ArCameraScanner oldWidget) {
    super.didUpdateWidget(oldWidget);
    if (widget.enabled && !oldWidget.enabled) {
      unawaited(_startStream());
    } else if (!widget.enabled && oldWidget.enabled) {
      unawaited(_stopStream());
    }
  }

  @override
  void dispose() {
    _disposing = true;
    final controller = _controller;
    _controller = null;
    if (controller != null) {
      if (controller.value.isStreamingImages) {
        try {
          controller.stopImageStream();
        } catch (_) {}
      }
      controller.dispose();
    }
    super.dispose();
  }

  Future<void> _initCamera() async {
    if (!AprilTagPlatformDetector.isSupported) {
      setState(() {
        _initializing = false;
        _error = 'Camera detection not supported on this device';
      });
      return;
    }

    final permission = await Permission.camera.request();
    if (!permission.isGranted) {
      setState(() {
        _initializing = false;
        _error = 'Camera permission is required to scan AprilTags';
      });
      return;
    }

    try {
      final cameras = await availableCameras();
      if (cameras.isEmpty) {
        setState(() {
          _initializing = false;
          _error = 'No camera found on this device';
        });
        return;
      }

      final back = cameras.firstWhere(
        (c) => c.lensDirection == CameraLensDirection.back,
        orElse: () => cameras.first,
      );

      final controller = CameraController(
        back,
        ResolutionPreset.low,
        enableAudio: false,
        imageFormatGroup: ImageFormatGroup.yuv420,
      );
      await controller.initialize();

      if (!mounted) {
        await controller.dispose();
        return;
      }

      _controller = controller;
      setState(() => _initializing = false);
      if (widget.enabled) {
        await _startStream();
      }
    } catch (e) {
      if (!mounted) return;
      setState(() {
        _initializing = false;
        _error = 'Could not start camera: $e';
      });
    }
  }

  Future<void> _startStream() async {
    final controller = _controller;
    if (controller == null || !controller.value.isInitialized) return;
    if (controller.value.isStreamingImages) return;
    try {
      await controller.startImageStream(_onCameraImage);
    } catch (_) {}
  }

  Future<void> _stopStream() async {
    final controller = _controller;
    if (controller == null) return;
    if (!controller.value.isStreamingImages) return;
    try {
      await controller.stopImageStream();
    } catch (_) {}
  }

  Future<void> _onCameraImage(CameraImage image) async {
    if (_disposing || !mounted || !widget.enabled || _processingFrame) return;
    final now = DateTime.now();
    if (now.difference(_lastFrameAt) < _frameInterval) return;
    _lastFrameAt = now;
    _processingFrame = true;
    try {
      final ids = await AprilTagPlatformDetector.detectFromCameraImage(image);
      if (_disposing || !mounted || !widget.enabled || ids.isEmpty) return;
      await _stopStream();
      if (_disposing || !mounted) return;
      widget.onTagDetected(ids.first);
    } finally {
      _processingFrame = false;
    }
  }

  @override
  Widget build(BuildContext context) {
    if (_initializing) {
      return const Center(
        child: CircularProgressIndicator(color: Colors.white),
      );
    }

    if (_error != null) {
      return Center(
        child: Padding(
          padding: const EdgeInsets.all(24),
          child: Text(
            _error!,
            textAlign: TextAlign.center,
            style: const TextStyle(color: Colors.orangeAccent),
          ),
        ),
      );
    }

    final controller = _controller;
    if (controller == null || !controller.value.isInitialized) {
      return const SizedBox.shrink();
    }

    return ClipRRect(
      borderRadius: BorderRadius.circular(24),
      child: Stack(
        fit: StackFit.expand,
        children: [
          CameraPreview(controller),
          Container(color: Colors.black.withValues(alpha: 0.15)),
          Center(child: widget.scanOverlay),
        ],
      ),
    );
  }
}
