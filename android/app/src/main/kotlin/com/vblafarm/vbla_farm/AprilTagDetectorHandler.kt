package com.vblafarm.vbla_farm

import edu.wpi.first.apriltag.AprilTagDetector
import io.flutter.plugin.common.MethodCall
import io.flutter.plugin.common.MethodChannel
import org.opencv.core.CvType
import org.opencv.core.Mat

/**
 * Detects tag36h11 AprilTags from the camera Y-plane (grayscale luminance).
 * OpenCV must be initialized in MainActivity before use.
 */
class AprilTagDetectorHandler : MethodChannel.MethodCallHandler {

    private var detector: AprilTagDetector? = null

    private fun ensureDetector(): AprilTagDetector {
        if (detector == null) {
            detector = AprilTagDetector().apply {
                addFamily("tag36h11", 1)
            }
        }
        return detector!!
    }

    override fun onMethodCall(call: MethodCall, result: MethodChannel.Result) {
        when (call.method) {
            "isSupported" -> result.success(true)
            "detectFromYPlane" -> {
                val yBytes = call.argument<ByteArray>("yBytes")
                val width = call.argument<Int>("width")
                val height = call.argument<Int>("height")
                val rowStride = call.argument<Int>("rowStride")
                if (yBytes == null || width == null || height == null || rowStride == null) {
                    result.error("INVALID_ARGS", "Missing y plane arguments", null)
                    return
                }
                try {
                    val ids = detect(yBytes, width, height, rowStride)
                    result.success(ids)
                } catch (e: Exception) {
                    result.error("DETECT_FAILED", e.message, null)
                }
            }
            else -> result.notImplemented()
        }
    }

    private fun detect(
        yBytes: ByteArray,
        width: Int,
        height: Int,
        rowStride: Int,
    ): List<Int> {
        val gray = Mat(height, width, CvType.CV_8UC1)
        if (rowStride == width) {
            gray.put(0, 0, yBytes)
        } else {
            var offset = 0
            for (row in 0 until height) {
                gray.put(row, 0, yBytes, offset, width)
                offset += rowStride
            }
        }
        val detections = ensureDetector().detect(gray)
        gray.release()
        val allowed = setOf(0, 1, 2)
        return detections
            .map { it.id }
            .filter { allowed.contains(it) }
            .distinct()
            .sorted()
    }
}
