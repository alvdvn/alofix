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
            Log.d("alo2_","Send data from $sendBy")
            val json = Gson().toJson(instance)
            val call = instance as CallLogData
            AppInstance.helper.putString("flutter.backup_callog_${call.startAt}", json)
            AppInstance.methodChannel.invokeMethod(
                "save_call_log",
                json)
            instance = null
        }
    }
}