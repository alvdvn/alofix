package com.njv.prod

import android.os.Build
import androidx.annotation.RequiresApi
import java.text.SimpleDateFormat
import java.time.Instant
import java.time.ZoneId
import java.time.format.DateTimeFormatter
import java.util.Date
import java.util.Locale


data class CallLogStore(var id: String, val duration: Int, val startAt: Long, var phoneNumber: String, val callType: Int){
}

data class DeepLink(
    var ID: String?,
    var routeId: String?,
    var type: String?,
    var phoneNumber: String?
){
    override fun toString(): String {
        return "$ID - $routeId - $type - $phoneNumber"
    }
}

data class CallHistory(
    var Id: String,
    var PhoneNumber: String?, // user_name
    var RingAt: String?,
    var StartAt: String?,
    var EndedAt: String,
    var AnsweredAt: String?,// replace endTime endTimeStr
    var Type: Int, // 1 Out 2 In - replace callType
    var CallDuration: Int,
    var EndedBy: Int?,
    var AnsweredDuration: Int,
    var TimeRinging: Int?,
    var CustomData: DeepLink?,
    var Method: Int?,
    var SyncAt: String?, // post time
    var Date: String?
) {
    override fun toString(): String {
        return "Call History Item:\n" +
                "Call Id: $Id\n" +
                "Phone Number: $PhoneNumber\n" +
                "Start At: $StartAt\n" +
                "RingAt Time: $RingAt\n" +
                "AnsweredAt Time: $AnsweredAt\n" +
                "Ended At: $EndedAt\n" +
                "TimeRinging: $TimeRinging\n" +
                "CustomData: ${CustomData.toString()}\n" +
                "AnsweredDuration: $AnsweredDuration"
    }

    companion object {
        const val SIM_METHOD: Int = 2
        @RequiresApi(Build.VERSION_CODES.O)
        fun getFormattedTimeZone(timestamp: Long): String {
            val instant = Instant.ofEpochMilli(timestamp)
            val formatter =
                DateTimeFormatter.ofPattern("yyyy-MM-dd'T'HH:mm:ss.SSS'Z'").withZone(
                    ZoneId.of("UTC"))
            return formatter.format(instant)
        }

        fun getType(callType: Int): Int {
            return if(callType == 2) return 1
            else 2
        }

        fun getEndBy(callType: Int): Int? {
            return 0
        }

        fun getFormattedDate(callEndTime: Long): String? {
            val sdf = SimpleDateFormat("yyyy-MM-dd", Locale.getDefault())
            return sdf.format(Date(callEndTime))
        }

        fun getRingTime(duration: Int, startTime: Long, endTime: Long, type: Int): Int {
            val ringingDuration: Int = ((endTime - startTime - duration * 1000 ) / 1000).toInt()
            return ringingDuration
        }
    }
}
