package com.njv.prod

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

        fun sendDataToFlutter() {
            if (instance == null) return
            val json = Gson().toJson(instance)
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