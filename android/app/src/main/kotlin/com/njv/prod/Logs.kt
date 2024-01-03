package com.njv.prod

class CallLogData {
    var id: String = ""
    var startAt: Long? = null
    var ringAt: Long? = null
    var phoneNumber: String = ""
    var endedAt: Long? = null
    var type: Int? = null
    var syncBy: Int? = null
    var method: Int = 2
    var endedBy: Int? = null

    override fun toString(): String {
        return """
            ID         : $id
            StartAt    : $startAt
            RingAt     : $ringAt
            Phone      : $phoneNumber
            EndAt      : $endedAt
            Type       : $type
            SyncBy     : $syncBy
            Method     : $method
            endedBy      : $endedBy
        """.trimIndent()
    }
}

data class SimInfo(val phoneNumber: String, val slotIndex: Int)