package com.minicoreapps.ezan_hatirlatici

import android.content.ActivityNotFoundException
import android.content.Intent
import android.hardware.GeomagneticField
import android.net.Uri
import io.flutter.embedding.android.FlutterActivity
import io.flutter.embedding.engine.FlutterEngine
import io.flutter.plugin.common.MethodChannel

class MainActivity : FlutterActivity() {
    override fun configureFlutterEngine(flutterEngine: FlutterEngine) {
        super.configureFlutterEngine(flutterEngine)
        MethodChannel(flutterEngine.dartExecutor.binaryMessenger, "ezan_hatirlatici/platform")
            .setMethodCallHandler { call, result ->
                when (call.method) {
                    // Pusula: manyetik kuzey ile gerçek kuzey arasındaki sapma (Android'in yerleşik dünya manyetik modeli)
                    "declination" -> {
                        val lat = call.argument<Double>("lat")
                        val lon = call.argument<Double>("lon")
                        if (lat == null || lon == null) {
                            result.notImplemented()
                        } else {
                            val field = GeomagneticField(lat.toFloat(), lon.toFloat(), 0f, System.currentTimeMillis())
                            result.success(field.declination.toDouble())
                        }
                    }
                    // Gizlilik politikası bağlantısını tarayıcıda açar (tek bağlantı için url_launcher eklenmedi)
                    "openUrl" -> {
                        val url = call.argument<String>("url")
                        try {
                            startActivity(Intent(Intent.ACTION_VIEW, Uri.parse(url)))
                            result.success(true)
                        } catch (e: ActivityNotFoundException) {
                            result.success(false)
                        }
                    }
                    else -> result.notImplemented()
                }
            }
    }
}
