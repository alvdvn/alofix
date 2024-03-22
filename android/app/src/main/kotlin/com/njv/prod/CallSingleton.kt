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

        fun update(callLogData: CallLogData) {
            // Tìm kiếm và cập nhật CallLogData tương ứng trong instance list
            val index = instance.indexOfFirst { it.phoneNumber == callLogData.phoneNumber }
            if (index != -1) {
                instance[index] = callLogData
            } else {
                // Nếu không tìm thấy CallLogData, thêm mới vào instance list
                instance.add(callLogData)
            }
        }

        fun sendDataToFlutter(sendBy: String) {
            if (instance.isEmpty()) return
            Log.d("alo2_", "Send data from $sendBy")
            val callLogs :MutableList<CallLogData> = mutableListOf()
            callLogs.addAll(instance)
            instance.forEach { callLogData ->
                if (callLogData.endedAt != null) {
                    callLogData.syncBy = 1
                    val json = Gson().toJson(callLogData)
                    AppInstance.helper.putString(
                        "flutter.backup_callog_${callLogData.startAt}",
                        json
                    )
                    AppInstance.methodChannel.invokeMethod("save_call_log", json)
                    callLogs.remove(callLogData)
                }
            }
            instance = callLogs

        }


    }
}
