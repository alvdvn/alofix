package com.njv.prod

import android.util.Log
import com.google.gson.Gson
import io.flutter.plugin.common.MethodChannel

class CallLogSingleton {
    companion object {
        private var instance: CallLogData? = null
        private val tag = AppInstance.TAG
        fun instance(): CallLogData? {
            return instance
        }

        fun init(): CallLogData {
            if (instance == null) {
                instance = CallLogData()
            }
            return instance as CallLogData
        }

        fun sendDataToFlutter() {
            if (instance == null) return
            Log.d(tag, "SendFlutter $instance")
            val json = Gson().toJson(instance)
            AppInstance.helper.putString("backup_callog", json)
            AppInstance.methodChannel.invokeMethod(
                "save_call_log",
                json
            )
            instance = null
        }

        fun clear() {
            instance = null
        }
    }

    fun reset() {
        instance = null
    }
}