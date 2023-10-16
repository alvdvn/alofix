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
import android.telephony.PhoneStateListener
import android.telephony.TelephonyManager
import android.util.Log
import androidx.annotation.RequiresApi
import androidx.core.app.NotificationCompat
import androidx.core.app.NotificationManagerCompat
import com.njv.prod.R
import kotlinx.coroutines.*
import org.json.JSONArray
import java.net.HttpURLConnection
import java.text.SimpleDateFormat
import java.util.Date
import java.util.Locale


class PhoneStateService : Service() {
    private var requestCount = 0
    private var retryCount = 0
    private val maxRetries = 3

    private var telephonyManager: TelephonyManager? = null

    private lateinit var context: Context
    private lateinit var connectivityManager: ConnectivityManager
    private lateinit var networkCallback: ConnectivityManager.NetworkCallback

    override fun onCreate() {
        super.onCreate()
        context = this
        val sharedPreferencesHelper = SharedPreferencesHelper(this)
        AppInstance.preferencesHelper = sharedPreferencesHelper

        telephonyManager = getSystemService(Context.TELEPHONY_SERVICE) as TelephonyManager?
        startForeground(NOTIFICATION_ID, createNotification())

        // Khởi tạo Connectivity Manager và Network Callback
        connectivityManager = getSystemService(CONNECTIVITY_SERVICE) as ConnectivityManager
        networkCallback = object : ConnectivityManager.NetworkCallback() {
            override fun onAvailable(network: Network) {
                Log.d("Flutter Android","onAvailable Network")
                // network back
                val callLogJSONString: String? = AppInstance.preferencesHelper.getString(Contants.AS_SYNCLOGS_STR, "")
                if(callLogJSONString != "" && callLogJSONString != null){
                    CoroutineScope(Dispatchers.Default).launch {
                        retryCount = 0
                        postData( callLogJSONString, AppInstance.preferencesHelper.parseCallLogCacheJSONString(callLogJSONString),true)
                    }

                }
            }

            override fun onLost(network: Network) {
                Log.d("Flutter Android", "onLost Network")
            }
        }

        // Đăng ký Network Callback để lắng nghe sự kiện
        if (Build.VERSION.SDK_INT >= Build.VERSION_CODES.N) {
            connectivityManager.registerDefaultNetworkCallback(networkCallback)
        }
    }

    override fun onStartCommand(intent: Intent, flags: Int, startId: Int): Int {
        if(intent != null ){
            telephonyManager?.listen(phoneStateListener, PhoneStateListener.LISTEN_CALL_STATE)
        }
        return START_STICKY
    }

    override fun onBind(intent: Intent): IBinder? {
        return null
    }

    private  fun saveData(callLogs: MutableList<CallHistory>, name: String, isErrorFromSerVer: Boolean){

        val callLogJSONString: String? = AppInstance.preferencesHelper.getString(name, "")
        var callLogsQueList = mutableListOf<CallHistory>()
        if(callLogJSONString != ""){
            callLogsQueList = AppInstance.preferencesHelper.parseCallLogCacheJSONString(callLogJSONString ?: "")
        }
        callLogsQueList.addAll(callLogs)

        val jsonArrayTemp = JSONArray()
        for (callLog in callLogsQueList) {
            val jsonObject = AppInstance.preferencesHelper.createJsonObject(callLog)
            jsonArrayTemp.put(jsonObject)
        }

        Log.d("Flutter Android Save", jsonArrayTemp.toString())
        AppInstance.preferencesHelper.putString(name,jsonArrayTemp.toString())
        // start small service to handler data
        if(isErrorFromSerVer){
            DataWorker.startDataHandler(context, name)
        }
    }

    override fun onDestroy() {
        super.onDestroy()
        telephonyManager?.listen(phoneStateListener, PhoneStateListener.LISTEN_NONE)
        stopForeground(true)
    }

    suspend fun postData (
        postData: String,
        callLogListPost: MutableList<CallHistory>?,
        isSync: Boolean
    ){
        coroutineScope{
            while (retryCount < maxRetries) {
                var isError = false
                var isErrorOnServer = false
                try {
                    Log.d("Flutter Android post", postData + " ")
                    requestCount++

                    val responseCode =  DataWorker.doPostData(postData)
                    if (responseCode == HttpURLConnection.HTTP_OK) {
                        Log.d("Flutter Android", "HTTP OK ")
                        // CLEAR DATA ON SYNC REQUEST
                        if (isSync) {
                            Log.d("Flutter Android", "Sync success !!! ")
                            AppInstance.preferencesHelper.putString(Contants.AS_SYNCLOGS_STR, "")
                        }
                        // END
                        isError = false
                        isErrorOnServer = false
                        break
                    } else {
                        isErrorOnServer = true
                        Log.d("Flutter Android", "HTTP NOT OK $responseCode")
                    }

                } catch (e: Exception) {
                    isError = true
                    Log.d("PhoneLogServiceEx",  e.message + " " + e.cause)
                    e.printStackTrace()
                } finally{
                    retryCount++
                    if(retryCount == 2 && callLogListPost != null){
                        if(isError){
                            saveData(callLogListPost,Contants.AS_SYNCLOGS_STR, false)
                        }
                        if(isErrorOnServer){
                            saveData(callLogListPost,Contants.AS_CALLOGS_STR, isErrorOnServer)
                        }
                    }
                }
            }
        }
    }


    private val phoneStateListener: PhoneStateListener = object : PhoneStateListener() {
        private var phoneNumber: String? = null
        private var previousCallState : Int = TelephonyManager.CALL_STATE_IDLE
        private var talkingStartTime: Long = 0
        private var ringingStartTime: Long = 0
        private var callType: CallType? = null
        private var callStatus: CallStatus = CallStatus.UNKNOWN
        private var callEndedBy: CallEndedBy = CallEndedBy.UNKNOWN
        private var isFirstTimeIdle: Boolean = true

        private var isNewCall: Boolean = false
        private var newPhoneNumber: String? = null
        private var newRingingStartTime : Long = 0
        private var newEndRingTime : Long = 0

        inner class PostDataAsyncTask(private val callHistory: CallHistory, private val newRingingTime: Long, private val isNewCall: Boolean)
            : AsyncTask<Void?, Void?, CallHistory>() {

            @SuppressLint("Range")
            @RequiresApi(Build.VERSION_CODES.O)
            protected override  fun doInBackground(vararg p0: Void?): CallHistory {
                CoroutineScope(Dispatchers.Default).launch {
                    sendCalls(callHistory, isNewCall, newRingingTime)
                }
                return callHistory
            }
            @SuppressLint("Range")
            protected override fun onPostExecute(callHistoryItem: CallHistory) {
                super.onPostExecute(callHistoryItem)
                Log.d("Flutter Android","Number requests: " + requestCount.toString())
            }
        }

        @RequiresApi(Build.VERSION_CODES.O)
        suspend fun sendCalls(callHistory: CallHistory, isNewCall: Boolean, newRingingTime: Long){
            val callLogsListPost = mutableListOf<CallHistory>()
            var callLog = getCallLogs(1)[0]
            if(isNewCall){
                // cuoc goi truoc
                val historyAdd = getHistory(callHistory, getCallLogs(2)[1])
                callLogsListPost.add(historyAdd)

                // cuoc goi sau
                callHistory.TimeRinging = (newRingingTime/1000).toInt()
                val historyNewAdd = getHistory(callHistory,callLog)
                callLogsListPost.add(historyNewAdd)
            }else{
                val historyAdd = getHistory(callHistory,callLog)
                callLogsListPost.add(historyAdd)
            }

            val jsonArrayTemp = JSONArray()
            for (callLog in callLogsListPost) {
                val jsonObject = AppInstance.preferencesHelper.createJsonObject(callLog)
                jsonArrayTemp.put(jsonObject)
            }

            val jsonStringToPost = jsonArrayTemp.toString()
            postData( jsonStringToPost, callLogsListPost,false)
            callLogsListPost.clear()
        }

        @RequiresApi(Build.VERSION_CODES.O)
        fun getHistory(callHistory: CallHistory, callLog: CallLogStore) : CallHistory {
            Log.d("Flutter Android ", callHistory.toString())
            callHistory.StartAt = CallHistory.getFormattedTimeZone(callLog.startTime)
            callHistory.CallDuration = callLog.duration
            return callHistory
        }

        @RequiresApi(Build.VERSION_CODES.O)
        override fun onCallStateChanged(state: Int, phoneNumber: String) {
            when (state) {
                TelephonyManager.CALL_STATE_RINGING -> {
                    // INCOMING INSIDE ANOTHER CALL
                    if(previousCallState == TelephonyManager.CALL_STATE_OFFHOOK){
                        if(this.phoneNumber != phoneNumber){
                            // đang có cuộc gọi mới đến trong cuộc gọi
                            // chỉ quan tâm ringingTime của cuộc gọi mới đến
                            isNewCall = true
                            this.newPhoneNumber == phoneNumber
                            this.newRingingStartTime = System.currentTimeMillis()
                        }
                    }else{
                        // 1 cuộc gọi mới
                        ringingStartTime = System.currentTimeMillis()
                        this.phoneNumber = phoneNumber
                        callType = CallType.INCOMING
                        callStatus = CallStatus.MISSED
                        callEndedBy = CallEndedBy.UNKNOWN
                    }

                    Log.d("Flutter Android", "CALL_STATE_RINGING $phoneNumber")
                }

                TelephonyManager.CALL_STATE_OFFHOOK -> {
                    Log.d("Flutter Android", "CALL_STATE_OFFHOOK : $phoneNumber")

                    if(isNewCall){
                        newEndRingTime = System.currentTimeMillis()
                    }else{
                        // cuộc gọi bình thường
                        talkingStartTime = System.currentTimeMillis()
                        if (phoneNumber == this.phoneNumber) {
                            // nghe gọi tới
                            callType = CallType.INCOMING
                            callStatus = CallStatus.ANSWERED

                        } else {
                            // gọi đi
                            callType = CallType.OUTGOING
                            ringingStartTime = System.currentTimeMillis()
                            callStatus = CallStatus.UNKNOWN
                            callEndedBy = CallEndedBy.UNKNOWN
                        }
                    }
                }

                TelephonyManager.CALL_STATE_IDLE -> {
                    if(!isFirstTimeIdle){

                        Log.d("Flutter Android", "CALL_STATE_IDLE : " + phoneNumber)
                        val callEndTime = System.currentTimeMillis()
                        var ringingDuration: Long = 0
                        var talkingTime : Long = 0
                        if (callType == CallType.INCOMING && callStatus == CallStatus.ANSWERED) {
                            ringingDuration = talkingStartTime - ringingStartTime
                            talkingTime= callEndTime - talkingStartTime
                        }
                        else{
                            ringingDuration = callEndTime - ringingStartTime
                        }

                        if (previousCallState == TelephonyManager.CALL_STATE_OFFHOOK
                            && callType == CallType.OUTGOING) {
                            callEndedBy = CallEndedBy.UNKNOWN
                            callStatus = CallStatus.ANSWERED
                            talkingTime = callEndTime - talkingStartTime
                            ringingDuration = talkingTime
                        }


                        // Khởi tạo một Handler trên main looper
                        val mainHandler = Handler(Looper.getMainLooper())
                        val delayMillis: Long = 500
                        try {
                            mainHandler.postDelayed({
                                // New Map
                                val mCall = getCallLogs(1)[0]

                                val user_name: String? = AppInstance.preferencesHelper.getString("flutter.user_name", "")
                                val mPhoneNumber = phoneNumber
                                val mId : String = mCall.startTime.toString() + "&" + user_name
                                val mRingAt: String = CallHistory.getFormattedTimeZone(ringingStartTime)
                                val mStartAt: String = CallHistory.getFormattedTimeZone(mCall.startTime)
                                val mEndedAt: String = CallHistory.getFormattedTimeZone(callEndTime)
                                val mType: Int = CallHistory.getType(callType)
                                val mCallStatus = CallHistory.getCalStatus(callStatus)

                                val mAnsweredAt: String? = if(callStatus == CallStatus.ANSWERED){CallHistory.getFormattedTimeZone(talkingStartTime)}else{null}

                                val mAnsweredDuration = if(callStatus == CallStatus.ANSWERED){
                                    mCall.duration
                                } else { 0 }// with answered

                                val mCallTotalDuration = ((callEndTime - ringingStartTime)/1000).toInt()
                                // TODO detect ended by
                                val mEndedBy = 0 // UNKNOWN
                                val mTimeRinging = CallHistory.getRingingTime(
                                    mCall,
                                    previousCallState,
                                    mType,
                                    ringingStartTime,
                                    callEndTime,
                                    ringingDuration)
                                val mMethod = CallHistory.SIM_METHOD
                                val mSyncAt = CallHistory.getFormattedTimeZone( callEndTime)
                                val mDate = CallHistory.getFormattedDate(callEndTime)
                                var mDeepLink : DeepLink? = getDeepLink(phoneNumber)
                                val callHistoryItem = CallHistory(
                                    mId, // startAt&phoneNumber
                                    mPhoneNumber,
                                    mRingAt,
                                    mStartAt,
                                    mEndedAt,
                                    mAnsweredAt,
                                    mType,
                                    mCallTotalDuration,
                                    mEndedBy,
                                    mAnsweredDuration,
                                    mTimeRinging,
                                    mDeepLink,
                                    mMethod,
                                    mSyncAt,
                                    mCallStatus,
                                    mDate,
                                )

                                var newRingingTime: Long = 0
                                if(isNewCall){
                                    newRingingTime = newEndRingTime - newRingingStartTime
                                }
                                val postDataAsync = PostDataAsyncTask(callHistoryItem, newRingingTime, isNewCall)
                                postDataAsync.execute().get()!!

                                retryCount = 0
                                resetCallState()

                            }, delayMillis)

                        } catch (e: Exception) {
                            Log.d("Flutter Android","wrong here")
                            e.printStackTrace()
                        }
                    }

                    isFirstTimeIdle = false
                    isNewCall = false
                }
            }
            previousCallState = state
        }

        private fun getDeepLink(phoneNumber: String?): DeepLink? {
            var id = AppInstance.preferencesHelper.getString("flutter.id_deeplink","")
            var routeId = AppInstance.preferencesHelper.getString("flutter.router_deeplink","")

            val deeplinkPhone: String? = AppInstance.preferencesHelper.getString("flutter.deep_link_phone", "")
            if(id.equals("") || !phoneNumber.equals(deeplinkPhone)){
                return null
            }
            return DeepLink(id, routeId, "trackIng", phoneNumber)
        }

        @SuppressLint("Range")
        private fun getCallLogs(limit: Int) : ArrayList<CallLogStore> {
            val projection = arrayOf(
                CallLog.Calls._ID,
                CallLog.Calls.NUMBER,
                CallLog.Calls.DURATION,
                CallLog.Calls.TYPE,
                CallLog.Calls.DATE
            )
            val sortOrder = CallLog.Calls.DATE + " DESC"
            val results: ArrayList<CallLogStore> = ArrayList()

            val queryUri = CallLog.Calls.CONTENT_URI.buildUpon()
                .appendQueryParameter(CallLog.Calls.LIMIT_PARAM_KEY, limit.toString())
                .build()

            contentResolver.query(
                queryUri,
                projection,
                null,
                null,
                sortOrder
            )?.use { cursor ->
                if (cursor.moveToFirst()) {
                    do {
                        val id = cursor.getString(cursor.getColumnIndex(CallLog.Calls._ID))
                        val callNumber = cursor.getString(cursor.getColumnIndex(CallLog.Calls.NUMBER))
                        val callDuration = cursor.getInt(cursor.getColumnIndex(CallLog.Calls.DURATION))
                        val callType = cursor.getInt(cursor.getColumnIndex(CallLog.Calls.TYPE))
                        val startTime = cursor.getLong(cursor.getColumnIndex(CallLog.Calls.DATE))
                        val startTimeStr = getFormattedTime(startTime)
                        // Log.d("Flutter Android", "ID: $id, Number: $callNumber, Duration: $callDuration seconds, Type: $callType, StartTime: $startTimeStr")
                        val callLogs = CallLogStore(id, callDuration, startTime, callNumber)
                        results.add(callLogs)
                    } while (cursor.moveToNext())
                }
            }
            return results
        }

        private fun getFormattedTime(timestamp: Long): String {
            val sdf = SimpleDateFormat("yyyy-MM-dd HH:mm:ss", Locale.getDefault())
            return sdf.format(Date(timestamp))
        }

        private fun resetCallState() {
            phoneNumber = null
            ringingStartTime = 0
            callType = CallType.UNKNOWN
            callStatus = CallStatus.UNKNOWN
            callEndedBy = CallEndedBy.UNKNOWN
        }
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
                    "Foreground Service Channel",
                    NotificationManager.IMPORTANCE_LOW
                )
            )
        }
        return builder.build()
    }

    companion object {
        private const val NOTIFICATION_ID = 123
    }
}