package com.njv.prod


import android.content.ContentResolver
import io.flutter.plugin.common.MethodChannel

object AppInstance {
   const val TAG : String = "alo2_"

   lateinit var helper : SharedHelper
   lateinit var methodChannel : MethodChannel
   lateinit var contentResolver : ContentResolver

   const val LAST_SYNC_ID_STR: String = "flutter.last_sync_id"

   const val LAST_SYNC_TIME_STR: String = "flutter.last_recovered_time_stamp"

   const val DESTROY_TIME_STR: String = "flutter.service_destroy_time"
}