package com.njv.prod

import android.content.Context
import android.content.Intent
import android.telecom.Call

object BroadcastManager {
    private var applicationContext: Context? = null

    fun init(context: Context) {
        applicationContext = context.applicationContext
    }

    fun sendUpdateBroadcast(phoneNumber: String) {
        val intent = Intent("com.example.UPDATE_UI")
        intent.putExtra("callId", phoneNumber)
        applicationContext?.sendBroadcast(intent)
    }
}