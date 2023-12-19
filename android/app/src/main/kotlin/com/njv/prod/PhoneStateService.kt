package com.njv.prod

import android.annotation.SuppressLint
import android.app.Notification
import android.app.NotificationChannel
import android.app.NotificationManager
import android.app.Service
import android.content.Context
import android.content.Intent
import android.net.ConnectivityManager
import android.net.Network
import android.os.AsyncTask
import android.os.Build
import android.os.Handler
import android.os.IBinder
import android.os.Looper
import android.provider.CallLog
import android.telecom.Call
import android.telecom.TelecomManager
import android.telephony.PhoneStateListener
import android.telephony.TelephonyManager
import android.util.Log
import androidx.annotation.RequiresApi
import androidx.core.app.NotificationCompat
import androidx.core.app.NotificationManagerCompat
import io.flutter.plugin.common.MethodChannel
import kotlinx.coroutines.*
import org.json.JSONArray
import java.lang.System
import java.net.HttpURLConnection
import java.text.SimpleDateFormat
import java.util.*
import com.google.gson.Gson
import java.lang.Math

class PhoneStateService : Service() {
    private val tag = AppInstance.TAG

    companion object {
        private const val NOTIFICATION_ID = 1324
    }

    private var telephonyManager: TelephonyManager? = null

    private lateinit var context: Context
    private lateinit var connectivityManager: ConnectivityManager
    private lateinit var networkCallback: ConnectivityManager.NetworkCallback

    private var userId: String? = ""
    private var callLog: CallLogData? = null;
    private var previousState: Int = TelephonyManager.CALL_STATE_IDLE
    private val phoneStateListener: PhoneStateListener = object : PhoneStateListener() {

        @RequiresApi(Build.VERSION_CODES.O)
        override fun onCallStateChanged(state: Int, phoneNumber: String) {
            Log.d(tag, "onCallStateChanged $state - $phoneNumber")
            if (phoneNumber == "") return
            handlerCallStateChange(state, phoneNumber.replace(" ", ""))
            previousState = state
        }

        private fun sendDataToFlutter(callLog: CallLogData?) {
            Log.d(tag, "Save $callLog");
            if (callLog != null) {
                var gson = Gson()
                AppInstance.methodChannel.invokeMethod("save_call_log", gson.toJson(callLog));
            }
        }

        @RequiresApi(Build.VERSION_CODES.O)
        private fun handlerCallStateChange(state: Int, phoneNumber: String) {
            var current = System.currentTimeMillis();
            var currentBySeconds = current / 1000;
            when (state) {
                TelephonyManager.CALL_STATE_RINGING -> {
                    Log.d(tag, "CALL_STATE_RINGING $current")
                    if (previousState == TelephonyManager.CALL_STATE_IDLE) {

                        callLog = CallLogData();
                        callLog?.id = "$currentBySeconds&$userId";
                        callLog?.startAt = current;
                        callLog?.ringAt = current;
                        callLog?.phoneNumber = phoneNumber;
                        callLog?.type = 1; //in
                        callLog?.syncBy = 1;
                        sendDataToFlutter(callLog)
                    }
                }

                TelephonyManager.CALL_STATE_OFFHOOK -> {
                    Log.d(tag, "CALL_STATE_OFFHOOK $current")
                    if (previousState == TelephonyManager.CALL_STATE_IDLE) {
                        callLog = CallLogData();
                        callLog?.id = "$currentBySeconds&$userId";
                        callLog?.startAt = current;
                        callLog?.phoneNumber = phoneNumber;
                        callLog?.type = 2; //out
                        callLog?.syncBy = 1;
                        sendDataToFlutter(callLog)
                    }
                }

                TelephonyManager.CALL_STATE_IDLE -> {
                    Log.d(tag, "CALL_STATE_IDLE $current")
                    if (callLog != null) {
                        callLog?.endedAt = current;
                        sendDataToFlutter(callLog)
                        callLog = null;
                    }
                }
            }
        }
    }

    override fun onCreate() {
        super.onCreate()
        context = this
        AppInstance.helper = SharedHelper(this)

        userId = AppInstance.helper.getString("flutter.user_name", "")

        telephonyManager = getSystemService(Context.TELEPHONY_SERVICE) as TelephonyManager?
        startForeground(NOTIFICATION_ID, createNotification())

        // Create Connectivity Manager and Network Callback
        connectivityManager = getSystemService(CONNECTIVITY_SERVICE) as ConnectivityManager
        networkCallback = object : ConnectivityManager.NetworkCallback() {
            override fun onAvailable(network: Network) {
                Log.d(tag, "onAvailable Network")
                // network back

            }

            override fun onLost(network: Network) {
                Log.d(tag, "onLost Network")
            }
        }

        if (Build.VERSION.SDK_INT >= Build.VERSION_CODES.N) {
            connectivityManager.registerDefaultNetworkCallback(networkCallback)
        }
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