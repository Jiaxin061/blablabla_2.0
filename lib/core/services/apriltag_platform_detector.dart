import 'dart:io';

import 'package:camera/camera.dart';
import 'package:flutter/foundation.dart';
import 'package:flutter/services.dart';

/// Native AprilTag detection (Android). Uses tag36h11 via platform channel.
class AprilTagPlatformDetector {
  AprilTagPlatformDetector._();

  static const MethodChannel _channel =
      MethodChannel('com.vblafarm.vbla_farm/apriltag');

  static bool get isSupported =>
      !kIsWeb && Platform.isAndroid;

  static Future<bool> checkSupported() async {
    if (!isSupported) return false;
    try {
      final supported = await _channel.invokeMethod<bool>('isSupported');
      return supported ?? false;
    } catch (_) {
      return false;
    }
  }

  /// Detect tag IDs 0, 1, 2 from a camera frame (Y-plane on Android).
  static Future<List<int>> detectFromCameraImage(CameraImage image) async {
    if (!isSupported || image.planes.isEmpty) return [];
    final plane = image.planes.first;
    try {
      final ids = await _channel.invokeMethod<List<dynamic>>(
        'detectFromYPlane',
        {
          'yBytes': plane.bytes,
          'width': image.width,
          'height': image.height,
          'rowStride': plane.bytesPerRow,
        },
      );
      if (ids == null) return [];
      return ids.map((e) => (e as num).toInt()).toList();
    } catch (_) {
      return [];
    }
  }
}
