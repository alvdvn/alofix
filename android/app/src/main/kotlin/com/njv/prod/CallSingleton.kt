package com.njv.prod

import android.util.Log
import com.google.gson.Gson

class CallLogSingleton {
    companion object {
        private var instance: CallLogData? = null
        fun instance(): CallLogData? {
            return instance
        }

        fun init(): CallLogData {
            if (instance == null) {
                instance = CallLogData()
            }
            return instance as CallLogData
        }

        fun sendDataToFlutter(sendBy: String) {
            if (instance == null) return
            val json = Gson().toJson(instance)
            Log.d("alo2_", "sendDataToFlutter $sendBy $instance")
            AppInstance.methodChannel.invokeMethod(
                "save_call_log",
                json
            )
            instance = null
        }
    }
}