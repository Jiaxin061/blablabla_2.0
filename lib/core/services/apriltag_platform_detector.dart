import 'dart:io';

import 'package:camera/camera.dart';
import 'package:flutter/foundation.dart';
import 'package:flutter/services.dart';

/// AprilTag detection routed to the native Android OpenCV ArucoDetector.
///
/// Native side: AprilTagDetectorHandler.kt uses org.opencv:opencv:4.10.0
/// with Objdetect.getPredefinedDictionary(DICT_APRILTAG_36h11) and
/// ArucoDetector.detectMarkers() — the same approach as the "AprilTag Detector"
/// app the user showed, running at ~15fps on a real device.
class AprilTagPlatformDetector {
  AprilTagPlatformDetector._();

  static const _channel = MethodChannel('com.vblafarm.vbla_farm/apriltag');

  static bool get isSupported => !kIsWeb && Platform.isAndroid;

  static bool _nativeReady = false;

  /// Calls native `isSupported` to warm up OpenCV / ArucoDetector.
  static Future<bool> checkSupported() async {
    if (!isSupported) return false;
    try {
      final ok = await _channel.invokeMethod<bool>('isSupported') ?? false;
      _nativeReady = ok;
      return ok;
    } catch (_) {
      _nativeReady = false;
      return false;
    }
  }

  /// Detect tag IDs {0,1,2} from a camera frame via native OpenCV ArUco.
  static Future<List<int>> detectFromCameraImage(CameraImage image) async {
    if (!isSupported || !_nativeReady) return [];
    if (image.planes.isEmpty) return [];

    final plane = image.planes[0];
    final yBytes = plane.bytes;
    final int width = image.width;
    final int height = image.height;
    final int rowStride = plane.bytesPerRow;

    try {
      final result = await _channel.invokeMethod<List<dynamic>>(
        'detectFromYPlane',
        {
          'yBytes': yBytes,
          'width': width,
          'height': height,
          'rowStride': rowStride,
        },
      );
      if (result == null) return [];
      return result.cast<int>();
    } on PlatformException {
      return [];
    }
  }
}
