package com.example.todoapp

import android.media.AudioAttributes
import android.media.AudioManager
import android.media.Ringtone
import android.media.RingtoneManager
import android.net.Uri
import android.os.Build
import io.flutter.embedding.android.FlutterActivity
import io.flutter.embedding.engine.FlutterEngine
import io.flutter.plugin.common.MethodChannel

class MainActivity : FlutterActivity() {
    private val CHANNEL = "com.example.todoapp/ringtone"
    private var ringtone: Ringtone? = null

    override fun configureFlutterEngine(flutterEngine: FlutterEngine) {
        super.configureFlutterEngine(flutterEngine)

        MethodChannel(flutterEngine.dartExecutor.binaryMessenger, CHANNEL).setMethodCallHandler { call, result ->
            when (call.method) {
                "playAlarm" -> {
                    try {
                        stopAlarmInternal()

                        var alertUri: Uri? = RingtoneManager.getDefaultUri(RingtoneManager.TYPE_ALARM)
                        if (alertUri == null) {
                            alertUri = RingtoneManager.getDefaultUri(RingtoneManager.TYPE_RINGTONE)
                        }
                        if (alertUri == null) {
                            alertUri = RingtoneManager.getDefaultUri(RingtoneManager.TYPE_NOTIFICATION)
                        }

                        ringtone = RingtoneManager.getRingtone(applicationContext, alertUri)
                        ringtone?.let {
                            if (Build.VERSION.SDK_INT >= Build.VERSION_CODES.LOLLIPOP) {
                                it.audioAttributes = AudioAttributes.Builder()
                                    .setUsage(AudioAttributes.USAGE_ALARM)
                                    .setContentType(AudioAttributes.CONTENT_TYPE_SONIFICATION)
                                    .build()
                            } else {
                                @Suppress("DEPRECATION")
                                it.streamType = AudioManager.STREAM_ALARM
                            }
                            if (Build.VERSION.SDK_INT >= Build.VERSION_CODES.P) {
                                it.isLooping = true
                            }
                            it.play()
                        }
                        result.success(true)
                    } catch (e: Exception) {
                        result.error("RINGTONE_ERROR", e.message, null)
                    }
                }
                "stopAlarm" -> {
                    stopAlarmInternal()
                    result.success(true)
                }
                else -> result.notImplemented()
            }
        }
    }

    private fun stopAlarmInternal() {
        try {
            ringtone?.let {
                if (it.isPlaying) {
                    it.stop()
                }
            }
            ringtone = null
        } catch (_: Exception) {}
    }

    override fun onDestroy() {
        stopAlarmInternal()
        super.onDestroy()
    }
}
