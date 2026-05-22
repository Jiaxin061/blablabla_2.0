package com.vblafarm.vbla_farm

import android.os.Handler
import android.os.Looper
import android.util.Log
import io.flutter.plugin.common.MethodCall
import io.flutter.plugin.common.MethodChannel
import org.opencv.core.CvType
import org.opencv.core.Mat
import org.opencv.objdetect.ArucoDetector
import org.opencv.objdetect.DetectorParameters
import org.opencv.objdetect.Objdetect
import java.util.concurrent.Executors

/**
 * Native AprilTag detection via OpenCV 4.7+ ArucoDetector (org.opencv:opencv:4.10.0).
 *
 * In OpenCV 4.7, ArUco was promoted from contrib to the main module under
 * org.opencv.objdetect.ArucoDetector, replacing the old org.opencv.aruco.Aruco API.
 *
 * DICT_APRILTAG_36h11 = Objdetect.DICT_APRILTAG_36h11 (constant 38).
 */
class AprilTagDetectorHandler : MethodChannel.MethodCallHandler {

    private val detectExecutor = Executors.newSingleThreadExecutor()
    private val mainHandler = Handler(Looper.getMainLooper())

    override fun onMethodCall(call: MethodCall, result: MethodChannel.Result) {
        when (call.method) {
            "isSupported" -> {
                val ready = try {
                    val gray = Mat(1, 1, CvType.CV_8UC1)
                    gray.release()
                    ArucoWrapper.warmUp()
                    true
                } catch (t: Throwable) {
                    Log.e(TAG, "OpenCV ArucoDetector init failed: ${t.message}", t)
                    false
                }
                result.success(ready)
            }

            "detectFromYPlane" -> {
                val yBytes    = call.argument<ByteArray>("yBytes")
                val width     = call.argument<Int>("width")
                val height    = call.argument<Int>("height")
                val rowStride = call.argument<Int>("rowStride")

                if (yBytes == null || width == null || height == null || rowStride == null) {
                    result.error("INVALID_ARGS", "Missing y plane arguments", null)
                    return
                }
                if (width <= 0 || height <= 0 || rowStride < width) {
                    result.error("INVALID_ARGS", "Invalid dimensions", null)
                    return
                }
                val minBytes = rowStride * (height - 1) + width
                if (yBytes.size < minBytes) {
                    result.error("INVALID_ARGS", "Y buffer too small: ${yBytes.size} < $minBytes", null)
                    return
                }

                detectExecutor.execute {
                    try {
                        val ids = ArucoWrapper.detect(yBytes, width, height, rowStride)
                        mainHandler.post { result.success(ids) }
                    } catch (t: Throwable) {
                        Log.e(TAG, "Detection failed: ${t.message}", t)
                        mainHandler.post { result.error("DETECT_FAILED", t.message, null) }
                    }
                }
            }

            else -> result.notImplemented()
        }
    }

    companion object {
        private const val TAG = "AprilTag"
    }
}

/** OpenCV loading flag set by MainActivity after initLocal(). */
object OpenCvNative {
    @Volatile private var loaded = false
    fun markLoaded() { loaded = true }
    fun isLoaded() = loaded
}

/** Singleton ArucoDetector — created once, reused per frame. */
private object ArucoWrapper {
    private val ALLOWED_IDS = setOf(0, 1, 2)

    @Volatile private var detector: ArucoDetector? = null

    @Synchronized
    fun warmUp() {
        if (detector == null) {
            // Objdetect.getPredefinedDictionary() + DICT_APRILTAG_36h11 (== 38) in OpenCV 4.7+
            val dict = Objdetect.getPredefinedDictionary(Objdetect.DICT_APRILTAG_36h11)
            detector = ArucoDetector(dict, DetectorParameters())
        }
    }

    @Synchronized
    fun detect(yBytes: ByteArray, width: Int, height: Int, rowStride: Int): List<Int> {
        warmUp()
        val det = detector ?: return emptyList()

        val gray = Mat(height, width, CvType.CV_8UC1)
        val corners = ArrayList<Mat>()
        val ids = Mat()
        val rejected = ArrayList<Mat>()

        try {
            if (rowStride == width) {
                gray.put(0, 0, yBytes)
            } else {
                var offset = 0
                for (row in 0 until height) {
                    gray.put(row, 0, yBytes, offset, width)
                    offset += rowStride
                }
            }

            det.detectMarkers(gray, corners, ids, rejected)

            if (ids.empty()) return emptyList()

            val found = mutableListOf<Int>()
            for (row in 0 until ids.rows()) {
                val tagId = ids.get(row, 0)[0].toInt()
                if (tagId in ALLOWED_IDS) found.add(tagId)
            }
            return found.distinct().sorted()

        } finally {
            corners.forEach { it.release() }
            ids.release()
            rejected.forEach { it.release() }
            gray.release()
        }
    }
}
