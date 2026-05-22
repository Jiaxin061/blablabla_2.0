import 'package:camera/camera.dart';
import 'package:flutter/services.dart';
import 'package:image/image.dart' as img;

import '../constants/tag_constants.dart';
import 'camera_y_plane.dart';

/// Detects bundled tag36h11 AprilTags using binary thresholding + Hamming distance.
///
/// Why this works better than NCC:
/// - AprilTags are binary patterns — comparing grayscale with NCC is fundamentally wrong.
/// - Otsu thresholding adapts to the real-world lighting of the camera frame.
/// - Hamming similarity (fraction of matching pixels) is the correct metric for binary patterns.
/// - Multiple crop fractions handle the tag appearing at different sizes in the frame.
class AprilTagImageDetector {
  AprilTagImageDetector._();

  static final AprilTagImageDetector instance = AprilTagImageDetector._();

  static const _templateSize = 72;

  // Minimum fraction of pixels that must agree (after binarization) to consider a match.
  // Random noise scores ~0.50; a solid uniform region scores up to ~0.75 coincidentally.
  // Require 0.80+ so only genuine tag patterns pass.
  static const _matchThreshold = 0.80;

  // The best match must also beat the second-best by this margin to avoid ambiguous results.
  static const _marginThreshold = 0.06;

  // Try multiple center-crop fractions to handle different distances to the tag.
  static const _cropFractions = [0.30, 0.42, 0.55, 0.68];

  // Pre-binarized templates (threshold at 128 for the clean PNG source images).
  Map<int, img.Image>? _templates;
  Future<void>? _loading;

  bool get hasTemplates => _templates != null && _templates!.isNotEmpty;

  Future<void> preload() => _ensureTemplates();

  Future<void> _ensureTemplates() {
    return _loading ??= _loadTemplates();
  }

  Future<void> _loadTemplates() async {
    final templates = <int, img.Image>{};
    for (final tagId in TagConstants.demoTagIds) {
      final data = await rootBundle.load(TagConstants.assetPathForTagId(tagId));
      final decoded = img.decodeImage(data.buffer.asUint8List());
      if (decoded == null) continue;
      final gray = img.grayscale(
        img.copyResize(decoded, width: _templateSize, height: _templateSize),
      );
      // Binarize template at fixed 128: PNG source is clean black/white.
      templates[tagId] = _binarize(gray, 128);
    }
    _templates = templates;
  }

  Future<List<int>> detect(CameraImage image) async {
    await _ensureTemplates();
    final refs = _templates;
    if (refs == null || refs.isEmpty) return [];

    final yPlane = CameraYPlane.fromCameraImage(image);
    if (yPlane == null) return [];

    final frame = _frameFromYPlane(yPlane);
    if (frame == null) return [];

    var bestId = -1;
    var bestScore = -1.0;
    var secondScore = -1.0;

    for (final fraction in _cropFractions) {
      final crop = _centerCrop(frame, fraction);

      // Blur to suppress sensor noise before thresholding.
      final blurred = img.gaussianBlur(crop, radius: 1);

      // Otsu thresholding adapts to per-frame brightness / contrast.
      final level = _otsuThreshold(blurred);

      // Skip crops with near-zero contrast (uniform scene — no tag present).
      if (level < 30 || level > 220) continue;

      final binary = _binarize(
        img.copyResize(blurred, width: _templateSize, height: _templateSize),
        level,
      );

      // Score against all templates; track best AND second-best to check margin.
      final scores = refs.map((id, tmpl) => MapEntry(id, _hammingSimilarity(binary, tmpl)));
      for (final entry in scores.entries) {
        if (entry.value > bestScore) {
          secondScore = bestScore;
          bestScore = entry.value;
          bestId = entry.key;
        } else if (entry.value > secondScore) {
          secondScore = entry.value;
        }
      }
    }

    // Require high absolute score AND clear margin over second-best to avoid false positives.
    if (bestId >= 0 &&
        bestScore >= _matchThreshold &&
        (bestScore - secondScore) >= _marginThreshold) {
      return [bestId];
    }
    return [];
  }

  img.Image? _frameFromYPlane(CameraYPlane yPlane) {
    try {
      final gray = img.Image.fromBytes(
        width: yPlane.width,
        height: yPlane.height,
        bytes: yPlane.bytes.buffer,
        bytesOffset: yPlane.bytes.offsetInBytes,
        rowStride: yPlane.width,
        format: img.Format.uint8,
        numChannels: 1,
      );
      // Downsample to 240×180 for fast processing while preserving tag detail.
      return img.copyResize(gray, width: 240, height: 180);
    } catch (_) {
      return null;
    }
  }

  img.Image _centerCrop(img.Image source, double fraction) {
    final w = (source.width * fraction).round().clamp(1, source.width);
    final h = (source.height * fraction).round().clamp(1, source.height);
    final x = (source.width - w) ~/ 2;
    final y = (source.height - h) ~/ 2;
    return img.copyCrop(source, x: x, y: y, width: w, height: h);
  }

  /// Otsu's method: finds the threshold that maximises inter-class variance,
  /// automatically adapting to the lighting conditions of each frame.
  int _otsuThreshold(img.Image image) {
    final hist = List<int>.filled(256, 0);
    for (var y = 0; y < image.height; y++) {
      for (var x = 0; x < image.width; x++) {
        hist[image.getPixel(x, y).r.toInt().clamp(0, 255)]++;
      }
    }

    final total = image.width * image.height;
    var sum = 0.0;
    for (var i = 0; i < 256; i++) {
      sum += i * hist[i];
    }

    var sumB = 0.0;
    var wB = 0;
    var maxVar = 0.0;
    var threshold = 128;

    for (var t = 0; t < 256; t++) {
      wB += hist[t];
      if (wB == 0) continue;
      final wF = total - wB;
      if (wF == 0) break;
      sumB += t * hist[t];
      final mB = sumB / wB;
      final mF = (sum - sumB) / wF;
      final between = wB.toDouble() * wF * (mB - mF) * (mB - mF);
      if (between > maxVar) {
        maxVar = between;
        threshold = t;
      }
    }
    return threshold;
  }

  /// Binarise: pixels with luminance >= level become white (255), rest black (0).
  img.Image _binarize(img.Image src, int level) {
    final out = img.Image(
      width: src.width,
      height: src.height,
      format: img.Format.uint8,
      numChannels: 1,
    );
    for (var y = 0; y < src.height; y++) {
      for (var x = 0; x < src.width; x++) {
        final v = src.getPixel(x, y).r.toInt();
        out.setPixelR(x, y, v >= level ? 255 : 0);
      }
    }
    return out;
  }

  /// Hamming similarity: fraction of pixels that agree between two binary images.
  double _hammingSimilarity(img.Image a, img.Image b) {
    if (a.width != b.width || a.height != b.height) return 0;
    var matches = 0;
    final total = a.width * a.height;
    for (var y = 0; y < a.height; y++) {
      for (var x = 0; x < a.width; x++) {
        final va = a.getPixel(x, y).r.toInt() > 127 ? 1 : 0;
        final vb = b.getPixel(x, y).r.toInt() > 127 ? 1 : 0;
        if (va == vb) matches++;
      }
    }
    return matches / total;
  }
}
