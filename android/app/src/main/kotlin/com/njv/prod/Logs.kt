package com.njv.prod

class CallLogData {
    var id: String = ""
    var startAt: Long? = null
    var phoneNumber: String = ""
    var endedAt: Long? = null
    var type: Int? = null
    var syncBy: Int? = null
    var method: Int = 2
    var endedBy: Int? = null
    var callBy: Int? = null

    override fun toString(): String {
        return "CallLog{Id: $id,StartAt: $startAt, PhoneNumber: $phoneNumber, EndAt: $endedAt, Type: $type, SyncBy: $syncBy, EndBy: $endedBy, CallBy: $callBy}"
    }
}

data class SimInfo(val phoneNumber: String, val slotIndex: Int)