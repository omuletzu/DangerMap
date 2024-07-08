package com.example.dangermap

import android.app.AlarmManager
import android.app.PendingIntent
import android.content.Context
import android.content.Intent
import android.os.Bundle
import android.provider.Settings
import android.net.Uri
import io.flutter.embedding.android.FlutterActivity
import io.flutter.embedding.engine.FlutterEngine
import io.flutter.plugin.common.MethodCall
import io.flutter.plugin.common.MethodChannel
import io.flutter.plugins.GeneratedPluginRegistrant
import androidx.core.app.NotificationCompat
import androidx.core.app.NotificationManagerCompat
import android.app.NotificationChannel
import android.app.NotificationManager

class MainActivity: FlutterActivity() {

    companion object {
        const val CHANNEL = "com.example.dangermap/channel"
        private var flutterEngineInstance : FlutterEngine? = null

        fun invokeDartCode(methodName : String, methodData : Map<String, Double>) {
            flutterEngineInstance?.dartExecutor?.binaryMessenger?.let {
                MethodChannel(it, CHANNEL).invokeMethod(methodName, methodData)
            }
        }
    }

    override fun configureFlutterEngine(flutterEngine: FlutterEngine) {
        super.configureFlutterEngine(flutterEngine)

        flutterEngineInstance = flutterEngine

        val locationIntent = Intent(this, LocationService::class.java)

        MethodChannel(flutterEngine.dartExecutor.binaryMessenger, CHANNEL).setMethodCallHandler { call, result ->

            when(call.method){
                "sendNotif" -> {
                    
                    startForegroundService(locationIntent)

                    result.success(null)
                }

                "stopNotif" -> {

                    LocationService.stopNotif()
                
                    result.success(null);
                }

                "pushNotif" -> {

                    val methodArgs = call.arguments as? Map<String, Any>

                    methodArgs?.let{
                        val dangerName = it["dangerName"] as? String ?: "Unidentified"
                        LocationService.pushNotif(this, dangerName )
                    }
                }

                else -> {
                    result.notImplemented();
                }
            }
        }
    }
}
