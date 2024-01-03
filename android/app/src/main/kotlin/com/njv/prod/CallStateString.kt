package com.njv.prod

import android.telecom.Call
import android.util.Log


fun Int.asString(): String = when (this) {
    Call.STATE_NEW -> "NEW"
    Call.STATE_RINGING -> "Cuộc gọi đến"
    Call.STATE_DIALING -> "Đang quay số"
    Call.STATE_ACTIVE -> "Đang nghe máy"
    Call.STATE_HOLDING -> "HOLDING"
    Call.STATE_DISCONNECTED -> "Kết thúc"
    Call.STATE_CONNECTING -> "Đang kết nối"
    Call.STATE_DISCONNECTING -> "DISCONNECTING"
    Call.STATE_SELECT_PHONE_ACCOUNT -> "Chọn Sim"
    else -> {
        Log.d("CallStateString", "UNKNOWN ${this}")
        "UNKNOWN"
    }
}