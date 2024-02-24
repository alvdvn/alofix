package com.njv.prod

import android.util.Log
import com.google.gson.Gson

class CallLogSingleton {
    companion object {
        internal var instance: MutableList<CallLogData> = mutableListOf()

        fun instances(): MutableList<CallLogData> {
            return instance
        }

        fun init(): CallLogData {
            val callLogData = CallLogData()
            instance.add(callLogData)
            return callLogData
        }

        fun sendDataToFlutter(sendBy: String) {
            if (instance.isEmpty()) return
            Log.d("alo2_", "Send data from $sendBy")
            instance.forEach { callLogData ->
                val json = Gson().toJson(callLogData)
                AppInstance.helper.putString("flutter.backup_callog_${callLogData.startAt}", json)
                AppInstance.methodChannel.invokeMethod("save_call_log", json)
            }
            instance.clear()
        }

    }
}