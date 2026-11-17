package com.minicoreapps.ezan_hatirlatici

import android.hardware.GeomagneticField
import io.flutter.embedding.android.FlutterActivity
import io.flutter.embedding.engine.FlutterEngine
import io.flutter.plugin.common.MethodChannel

class MainActivity : FlutterActivity() {
    override fun configureFlutterEngine(flutterEngine: FlutterEngine) {
        super.configureFlutterEngine(flutterEngine)
        // Pusula: manyetik kuzey ile gerçek kuzey arasındaki sapma (Android'in yerleşik dünya manyetik modeli)
        MethodChannel(flutterEngine.dartExecutor.binaryMessenger, "ezan_hatirlatici/compass")
            .setMethodCallHandler { call, result ->
                val lat = call.argument<Double>("lat")
                val lon = call.argument<Double>("lon")
                if (call.method != "declination" || lat == null || lon == null) {
                    result.notImplemented()
                    return@setMethodCallHandler
                }
                val field = GeomagneticField(lat.toFloat(), lon.toFloat(), 0f, System.currentTimeMillis())
                result.success(field.declination.toDouble())
            }
    }
}
