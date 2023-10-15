package com.example.base_project

import android.os.Build
import android.telephony.TelephonyManager
import androidx.annotation.RequiresApi
import java.text.SimpleDateFormat
import java.time.Instant
import java.time.ZoneId
import java.time.format.DateTimeFormatter
import java.util.Date
import java.util.Locale
import java.util.concurrent.TimeUnit


data class CallLogStore(var id: String, val duration: Int, val startTime:Long, var phoneNumber: String){
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
    var CallStatus: Int?, // Fail 1, success 2
    var Date: String?
) {
    override fun toString(): String {
        return "Call History Item:\n" +
                "Call Id: $Id\n" +
                "Phone Number: $PhoneNumber\n" +
                "Call Status: $CallStatus\n" +
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
        private const val OUT_GOING_CALL: Int = 2

        @RequiresApi(Build.VERSION_CODES.O)
        fun getFormattedTimeZone(timestamp: Long): String {
            val instant_startTimeSend = Instant.ofEpochMilli(timestamp)
            val formatter =
                DateTimeFormatter.ofPattern("yyyy-MM-dd'T'HH:mm:ss.SSS'Z'").withZone(
                    ZoneId.of("UTC"))
            return formatter.format(instant_startTimeSend)
        }

        private fun getFormattedTime(timestamp: Long): String {
            val sdf = SimpleDateFormat("yyyy-MM-dd HH:mm:ss", Locale.getDefault())
            return sdf.format(Date(timestamp))
        }

        fun formatDuration(duration: Long): String {
            val hours = TimeUnit.MILLISECONDS.toHours(duration)
            val minutes = TimeUnit.MILLISECONDS.toMinutes(duration - TimeUnit.HOURS.toMillis(hours))
            val seconds = TimeUnit.MILLISECONDS.toSeconds(duration - TimeUnit.HOURS.toMillis(hours) - TimeUnit.MINUTES.toMillis(minutes))
            return String.format("%02d:%02d:%02d", hours, minutes, seconds)
        }

        fun getType(callType: CallType?): Int {
            if(callType == CallType.INCOMING) return 2
            if(callType == CallType.OUTGOING) return 1
            return 0 // UNKNOWN
        }

        fun getRingingTime(call: CallLogStore,previousCallState: Int, type: Int,
                           startTime: Long, endTime: Long , ringTime: Long) : Int{
            var ringingTime: Int
            val duration = call.duration
            ringingTime = if( previousCallState == TelephonyManager.CALL_STATE_OFFHOOK
                && type == OUT_GOING_CALL){
                ((endTime - startTime - duration * 1000)/1000).toInt()
            }else{
                (ringTime/1000).toInt()
            }
            return ringingTime
        }

        fun getCalStatus(callStatus: CallStatus): Int? {
            return if(callStatus == CallStatus.ANSWERED) {2} else {1}
        }

        fun getFormattedDate(callEndTime: Long): String? {
            val sdf = SimpleDateFormat("yyyy-MM-dd", Locale.getDefault())
            return sdf.format(Date(callEndTime))
        }
    }
}

enum class CallType {
    INCOMING,
    OUTGOING,
    UNKNOWN
}

enum class CallStatus {
    ANSWERED,
    MISSED,
    UNKNOWN
}

enum class CallEndedBy {
    CALLER, CUSTOMER, UNKNOWN
}
