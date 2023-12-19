package com.njv.prod


import android.content.ContentResolver
import io.flutter.plugin.common.MethodChannel

object AppInstance {
   const val TAG : String = "alo2_"

   lateinit var helper : SharedHelper
   lateinit var methodChannel : MethodChannel
   lateinit var contentResolver : ContentResolver
}