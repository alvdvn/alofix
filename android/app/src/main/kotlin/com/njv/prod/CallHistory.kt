package com.njv.prod

import android.os.Build
import androidx.annotation.RequiresApi
import java.text.SimpleDateFormat
import java.time.Instant
import java.time.ZoneId
import java.time.format.DateTimeFormatter
import java.util.Date
import java.util.Locale


data class CallLogStore(var id: String, val duration: Int, val startAt: Long, var phoneNumber: String, val callType: Int, var endAt: Long){
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
    var SyncBy: Int?, // syncBy, 1: Đồng bộ bằng BG service, 2: Đồng bộ bằng các luồng khác
    var AnsweredDuration: Int,
    var TimeRinging: Long?,
    var CustomData: DeepLink?,
    var Method: Int?,
    var SyncAt: String?, // post time
    var CallBy: Int?, // 1 - Rider ấn end, #1 là N/A
    var CallLogValid: Int?, // 0,1 Ko hợp lệ, 2: Hợp lệ
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
                "SyncBy: $SyncBy\n" +
                "Type: $Type \n" +
                "TimeRinging: $TimeRinging\n" +
                "CustomData: ${CustomData.toString()}\n" +
                "AnsweredDuration: $AnsweredDuration \n" +
                "CallBy: $CallBy \n" +
                "CallLogValid: $CallLogValid"
    }

    companion object {
        const val SIM_METHOD: Int = 2
        @RequiresApi(Build.VERSION_CODES.O)
        fun getFormattedTimeZone(timestamp: Long): String {
            val instant = Instant.ofEpochMilli(timestamp)
            val formatter = DateTimeFormatter.ofPattern("yyyy-MM-dd'T'HH:mm:ss.SSS'Z'").withZone(ZoneId.of("UTC"))
            return formatter.format(instant)
        }

        fun getType(callType: Int): Int {
            return if(callType == 2) return 1
            else 2
        }

        fun getEndBy(): Int? {
            return null
        }

        fun getFormattedDate(callEndTime: Long): String? {
            val sdf = SimpleDateFormat("yyyy-MM-dd", Locale.getDefault())
            return sdf.format(Date(callEndTime))
        }

        fun getRingTime(duration: Int, startTime: Long, endTime: Long): Long {
            val duration = duration.toLong()
            return ((endTime - startTime - duration))
        }

        fun setAnsweredDuration(callType: Int, duration: Int): Int {
            if ((callType == 1 || callType == 2) && (duration > 0)) {
                return duration;
            } else {
                return 0;
            }
        }

        fun getSyncBy(): Int? {
            return 1
        }

        fun getCallBy(type: Int?): Int? {
            return if(type != null) return 2
            else null
        }

        fun getCallLogValid(): Int? {
            return 0
        }
    }
}
