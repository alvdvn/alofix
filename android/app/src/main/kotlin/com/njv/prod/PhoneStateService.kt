package com.njv.prod

import android.app.Notification
import android.app.NotificationChannel
import android.app.NotificationManager
import android.app.Service
import android.content.Context
import android.content.Intent
import android.os.Build
import android.os.IBinder
import android.telephony.PhoneStateListener
import android.telephony.TelephonyManager
import android.util.Log
import androidx.annotation.RequiresApi
import androidx.core.app.NotificationCompat
import androidx.core.app.NotificationManagerCompat

class PhoneStateService : Service() {
    private val tag = AppInstance.TAG

    companion object {
        private const val NOTIFICATION_ID = 1324
    }

    private var telephonyManager: TelephonyManager? = null

    private lateinit var context: Context
    private var previousState: Int = TelephonyManager.CALL_STATE_IDLE
    private val phoneStateListener: PhoneStateListener = object : PhoneStateListener() {

        @RequiresApi(Build.VERSION_CODES.O)
        override fun onCallStateChanged(state: Int, phoneNumber: String) {
            Log.d(tag, "onCallStateChanged $state - $phoneNumber")
            if (phoneNumber == "") return
            handlerCallStateChange(state, phoneNumber.replace(" ", ""))
            previousState = state
        }


        @RequiresApi(Build.VERSION_CODES.O)
        private fun handlerCallStateChange(state: Int, phoneNumber: String) {
            var callLogInstance = CallLogSingleton.instance()
            val current = System.currentTimeMillis()
            val currentBySeconds = current / 1000
            Log.d(tag, "$state $current $callLogInstance")
            when (state) {

                TelephonyManager.CALL_STATE_RINGING -> {
                    Log.d(tag, "CALL_STATE_RINGING $current")
                    if (previousState == TelephonyManager.CALL_STATE_IDLE) {
                        if (callLogInstance == null) {
                            callLogInstance = CallLogSingleton.init()
                            callLogInstance.id = "$currentBySeconds&${phoneNumber}"
                            callLogInstance.startAt = current
                            callLogInstance.phoneNumber = phoneNumber
                            callLogInstance.type = 2 //in
                            callLogInstance.syncBy = 1
                        }
                    }
                }

                TelephonyManager.CALL_STATE_OFFHOOK -> {
                    Log.d(tag, "CALL_STATE_OFFHOOK $current")
                    if (previousState == TelephonyManager.CALL_STATE_IDLE) {
                        if (callLogInstance == null) {
                            callLogInstance = CallLogSingleton.init()
                            callLogInstance.id = "$currentBySeconds&${phoneNumber}"
                            callLogInstance.startAt = current
                            callLogInstance.phoneNumber = phoneNumber
                            callLogInstance.type = 1 //out
                            callLogInstance.syncBy = 1
                        }
                    }
                }

                TelephonyManager.CALL_STATE_IDLE -> {
                    Log.d(tag, "CALL_STATE_IDLE $current")
                    if (callLogInstance != null && callLogInstance.endedAt == null) {
                        callLogInstance.endedAt = current
                        CallLogSingleton.sendDataToFlutter("BG")
                    }
                }
            }
        }
    }

    override fun onCreate() {
        super.onCreate()
        context = this
//        if(!AppInstance.init){
//            AppInstance.helper = SharedHelper(this)
//        }
        telephonyManager = getSystemService(Context.TELEPHONY_SERVICE) as TelephonyManager?
        startForeground(NOTIFICATION_ID, createNotification())
    }

    override fun onStartCommand(intent: Intent?, flags: Int, startId: Int): Int {
        if (intent != null) {
            telephonyManager?.listen(phoneStateListener, PhoneStateListener.LISTEN_CALL_STATE)
            return START_STICKY
        }
        return START_NOT_STICKY
    }

    override fun onBind(intent: Intent): IBinder? {
        return null
    }

    override fun onDestroy() {
        super.onDestroy()
        AppInstance.methodChannel.invokeMethod("destroyBg", null)
        Log.d(
            tag,
            "onDestroy PhoneStateService time ${System.currentTimeMillis()}"
        )
        telephonyManager?.listen(phoneStateListener, PhoneStateListener.LISTEN_NONE)
        stopForeground(true)
    }

    private fun createNotification(): Notification {
        val builder: NotificationCompat.Builder = NotificationCompat.Builder(this, "channel_id")
            .setContentTitle("Phone State Service")
            .setContentText("Listening to phone state...")
            .setSmallIcon(R.drawable.icon_notification)
            .setPriority(NotificationCompat.PRIORITY_LOW)
        if (Build.VERSION.SDK_INT >= Build.VERSION_CODES.O) {
            NotificationManagerCompat.from(this).createNotificationChannel(
                NotificationChannel(
                    "channel_id",
                    "Cần ở trạng thái ON lằng nghe cuộc gọi",
                    NotificationManager.IMPORTANCE_LOW
                )
            )
        }
        return builder.build()
    }
}