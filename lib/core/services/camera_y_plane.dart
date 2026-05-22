import 'dart:typed_data';

import 'package:camera/camera.dart';

/// Builds a compact grayscale copy of the camera Y-plane for native AprilTag detection.
///
/// Copies bytes synchronously before any [await] — the camera plugin reuses plane
/// buffers on the next frame.
class CameraYPlane {
  final Uint8List bytes;
  final int width;
  final int height;

  const CameraYPlane({
    required this.bytes,
    required this.width,
    required this.height,
  });

  /// Returns null when the frame cannot be converted safely.
  static CameraYPlane? fromCameraImage(CameraImage image) {
    if (image.planes.isEmpty) return null;

    final plane = image.planes.first;
    final width = image.width;
    final height = image.height;
    if (width <= 0 || height <= 0) return null;

    final rowStride = plane.bytesPerRow;
    final src = plane.bytes;
    final size = width * height;
    if (src.length < rowStride * (height - 1) + width) return null;

    if (rowStride == width) {
      if (src.length < size) return null;
      return CameraYPlane(
        bytes: Uint8List.fromList(src.sublist(0, size)),
        width: width,
        height: height,
      );
    }

    final gray = Uint8List(size);
    var srcOffset = 0;
    for (var row = 0; row < height; row++) {
      gray.setRange(row * width, row * width + width, src.sublist(srcOffset, srcOffset + width));
      srcOffset += rowStride;
    }
    return CameraYPlane(bytes: gray, width: width, height: height);
  }
}
