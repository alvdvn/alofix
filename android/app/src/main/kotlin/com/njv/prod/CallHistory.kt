package com.njv.prod

import android.os.Build
import androidx.annotation.RequiresApi
import java.text.SimpleDateFormat
import java.time.Instant
import java.time.ZoneId
import java.time.format.DateTimeFormatter
import java.util.Date
import java.util.Locale

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
