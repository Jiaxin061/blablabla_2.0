package com.vblafarm.vbla_farm

import android.util.Log
import io.flutter.embedding.android.FlutterActivity
import io.flutter.embedding.engine.FlutterEngine
import io.flutter.plugin.common.MethodChannel
import org.opencv.android.OpenCVLoader

class MainActivity : FlutterActivity() {
    companion object {
        private const val CHANNEL = "com.vblafarm.vbla_farm/apriltag"
        private const val TAG = "AprilTag"
    }

    override fun onCreate(savedInstanceState: android.os.Bundle?) {
        super.onCreate(savedInstanceState)
        // initLocal() is available in org.opencv:opencv:4.9.0+; works without OpenCV Manager app.
        if (OpenCVLoader.initLocal()) {
            OpenCvNative.markLoaded()
            Log.i(TAG, "OpenCV loaded via initLocal()")
        } else {
            Log.e(TAG, "OpenCV failed to initialize")
        }
    }

    override fun configureFlutterEngine(flutterEngine: FlutterEngine) {
        super.configureFlutterEngine(flutterEngine)
        MethodChannel(flutterEngine.dartExecutor.binaryMessenger, CHANNEL)
            .setMethodCallHandler(AprilTagDetectorHandler())
    }
}
