package com.njv.prod

import android.app.Application
import android.content.ContentResolver
import io.flutter.embedding.engine.FlutterEngine
import io.flutter.plugin.common.MethodChannel

object AppInstance {
    const val TAG: String = "alo2_"

    lateinit var helper: SharedHelper
    lateinit var methodChannel: MethodChannel
    lateinit var contentResolver: ContentResolver
}

class MyApplication : Application() {
    override fun onCreate() {
        super.onCreate()
        AppInstance.helper = SharedHelper(this)
        val flutterEngine = FlutterEngine(this)
        AppInstance.methodChannel = MethodChannel(
            flutterEngine.dartExecutor.binaryMessenger,
            Constants.FLUTTER_ANDROID_CHANNEL
        )
    }
}