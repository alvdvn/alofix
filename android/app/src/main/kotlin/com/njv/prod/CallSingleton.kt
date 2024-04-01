package com.njv.prod

import android.util.Log
import com.google.gson.Gson
import java.util.LinkedList
import java.util.Queue

object CallLogSingleton {
    private val instance: MutableList<CallLogData> = mutableListOf()
    private val sendDataQueue: Queue<Pair<String, String>> = LinkedList()

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
        }
    }

    fun sendDataToFlutter(sendBy: String, callNumber: String) {
        if (instance.isEmpty()) return
        Log.d("alo2_", "Send data from $sendBy")

        val callLogData = instance.find { it.phoneNumber == callNumber }

        if (callLogData != null) {
            sendDataQueue.add(Pair(sendBy, callNumber))
            processSendDataQueue()
        }
    }

    private fun processSendDataQueue() {
        while (sendDataQueue.isNotEmpty()) {
            val (sendBy, callNumber) = sendDataQueue.poll()

            val callLogData = instance.find { it.phoneNumber == callNumber }

            if (callLogData != null) {
                val json = Gson().toJson(callLogData)
                AppInstance.helper.putString("flutter.backup_callog_${callLogData.startAt}", json)
                AppInstance.methodChannel.invokeMethod("save_call_log", json)
                instance.remove(callLogData)
            }
        }
    }
}
