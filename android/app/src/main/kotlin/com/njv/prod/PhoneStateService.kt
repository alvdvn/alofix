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
import java.net.HttpURLConnection
import java.text.SimpleDateFormat
import java.util.*
import kotlin.math.abs

class CallLogState{
    var startAt: Long = 0
    var ringAt: Long = 0
    var phone: String= ""
    override fun toString(): String {
        return "$startAt - $ringAt - $phone"
    }
}

class PhoneStateService : Service() {
    private val tag = AppInstance.TAG

    companion object {
        private const val NOTIFICATION_ID = 1324
    }

    private var requestCount = 0
    private var retryCount = 0
    private val maxRetries = 3
    private var telephonyManager: TelephonyManager? = null

    private lateinit var context: Context
    private lateinit var connectivityManager: ConnectivityManager
    private lateinit var networkCallback: ConnectivityManager.NetworkCallback
    private var retryNum : Int = 0

    private var lastSyncId : Int = 0
    private var userId : String? = ""
    private val collectTimeout : Long = 2000
    private var delayTimeout : Long = 1000

    private val list = Collections.synchronizedList(mutableListOf<CallLogState>())

    private var previousState : Int = TelephonyManager.CALL_STATE_IDLE
    private val phoneStateListener: PhoneStateListener = object : PhoneStateListener() {

        @RequiresApi(Build.VERSION_CODES.O)
        override fun onCallStateChanged(state: Int, phoneNumber: String) {
            Log.d(tag,"onCallStateChanged $state - $phoneNumber")
            if(phoneNumber == "") return
            var newPhoneNumber = phoneNumber.replace(" ","")
            val isOverlap = isOverlapCall(state)
            handlerCallStateChange(isOverlap, state, newPhoneNumber)
            previousState = state
        }

        @RequiresApi(Build.VERSION_CODES.O)
        private fun handlerCallStateChange(overlap: Boolean, state: Int, phoneNumber: String) {
            when (state) {
                TelephonyManager.CALL_STATE_RINGING -> {
                    Log.d(tag, "CALL_STATE_RINGING")
                    if(previousState == TelephonyManager.CALL_STATE_IDLE){
                        synchronized(list) {
                            var index = list.indexOfLast { it.phone == phoneNumber }
                            if(index >= 0){
                                list[index].ringAt = System.currentTimeMillis()
                            }else{
                                Log.d(tag, "Phone in cache is not exist $phoneNumber")
                                var callLogState = CallLogState()
                                callLogState.startAt = System.currentTimeMillis()
                                callLogState.phone = phoneNumber
                                list.add(callLogState)
                            }
                        }
                    }
                    ringingCall(phoneNumber, overlap)
                }

                TelephonyManager.CALL_STATE_OFFHOOK -> {
                    Log.d(tag, "CALL_STATE_OFFHOOK $previousState $phoneNumber")
                    if(previousState == TelephonyManager.CALL_STATE_IDLE){
                        synchronized(list) {
                            var callLogState = CallLogState()
                            callLogState.startAt = System.currentTimeMillis()
                            callLogState.phone = phoneNumber
                            list.add(callLogState)
                        }
                    }
                    connectCall(phoneNumber, overlap)
                }

                TelephonyManager.CALL_STATE_IDLE -> {
                    Log.d(tag, "CALL_STATE_IDLE")
                    synchronized(list) {
                        var index = list.indexOfLast { it.phone == phoneNumber }
                        if(index >=0){
                            var endAt =  System.currentTimeMillis()
                            endCall(list[index],endAt)
                        }else{
                            Log.d(tag, "Phone in cache is not exist $phoneNumber")
                        }
                    }
                }
            }
        }

        private fun isOverlapCall(state: Int): Boolean {
            return previousState == TelephonyManager.CALL_STATE_OFFHOOK && state == TelephonyManager.CALL_STATE_RINGING
        }

        fun ringingCall(phoneNumber: String, overlap: Boolean){
            Log.d(tag, "Ringing : $phoneNumber")
        }

        fun connectCall(phoneNumber: String, overlap: Boolean){
            Log.d(tag, "Connect : $phoneNumber")
            // count ring time in single case
        }
        //get lasted call by phone number in peroperty list

        @RequiresApi(Build.VERSION_CODES.O)
        fun endCall(call: CallLogState,endAt: Long){
            print("Enccall : $call")
            Log.d(tag, "End Call: $call at $endAt" )
            val mainHandler = Handler(Looper.getMainLooper())
            try {
                mainHandler.postDelayed({
                    sendSingleCall(call.phone, endAt)
                }, collectTimeout)
            } catch (e: Exception) {
                Log.d(tag, e.toString())
                e.printStackTrace()
            }
        }

        fun sendOverLapCalls(){

        }

        @RequiresApi(Build.VERSION_CODES.O)
        fun correctCallAndSend(wrongId: String, endTime: Long) {
            Log.d(tag, "Retry Find The Correct Call $retryNum")
            val call = AppInstance.helper.getCallLogs(1)[0];
            if(retryNum < 10) {
                if (call.id == wrongId){
                    val mainHandler = Handler(Looper.getMainLooper())
                    try {
                        mainHandler.postDelayed({
                            correctCallAndSend(wrongId, endTime)
                            delayTimeout += 1000
                        }, delayTimeout)

                        retryNum += 1
                    } catch (e: Exception) {
                        Log.d(tag, e.toString())
                        e.printStackTrace()
                    }
                }else{
                    actuallySend(call, endTime )
                    retryNum = 0
                }
            }

        }

        @RequiresApi(Build.VERSION_CODES.O)
        fun doSend(mCall: CallLogStore, endTime: Long, mType: Int, mTimeRinging: Int) {
            Log.d(tag, "mEndedBy: $endTime")
            val userName: String? = AppInstance.helper.getString("flutter.user_name", "")
            val mPhoneNumber = mCall.phoneNumber
            val mId : String = "call&sim&" + mCall.startAt.toString() + "&" + userName
            val mRingAt: String = CallHistory.getFormattedTimeZone(mCall.startAt)
            val mStartAt: String = CallHistory.getFormattedTimeZone(mCall.startAt)
            val mEndedAt: String = CallHistory.getFormattedTimeZone(endTime)
            val startTalkingTime = endTime - mCall.duration * 1000;
            val mAnsweredAt: String? = if( mCall.duration > 0 ){ CallHistory.getFormattedTimeZone(startTalkingTime) } else { null }
            val mCallTotalDuration = ((endTime - mCall.startAt) / 1000).toInt()
            val mEndedBy = CallHistory.getEndBy()
            val mSyncBy = CallHistory.getSyncBy()
            val mMethod = CallHistory.SIM_METHOD
            val mSyncAt = CallHistory.getFormattedTimeZone(System.currentTimeMillis())
            val mDate = CallHistory.getFormattedDate(mCall.startAt)
            val mDeepLink : DeepLink? = getDeepLink(mPhoneNumber)
            val mDuration = CallHistory.setAnsweredDuration(mCall.callType,  mCall.duration)

            val callHistoryItem = CallHistory(
                mId,
                mPhoneNumber,
                mRingAt,
                mStartAt,
                mEndedAt,
                mAnsweredAt,
                mType,
                mCallTotalDuration,
                mEndedBy,
                mSyncBy,
                mDuration,
                mTimeRinging,
                mDeepLink,
                mMethod,
                mSyncAt,
                mDate,
            )
            Log.d(tag, "CallHistoryItem: $callHistoryItem")
            val postDataAsync = PostDataAsyncTask(callHistoryItem, mCall.id.toInt(), mCall.startAt)
            postDataAsync.execute().get()!!
        }

        @RequiresApi(Build.VERSION_CODES.O)
        fun actuallySend(mCall :CallLogStore, endTime: Long){

            val mType: Int = CallHistory.getType(mCall.callType)
            var mTimeRinging = CallHistory.getRingTime(mCall.duration, mCall.startAt, endTime, mType)

            mTimeRinging = Math.abs(mTimeRinging)

            doSend(mCall, endTime, mType, mTimeRinging)
            retryCount = 0
        }

        @RequiresApi(Build.VERSION_CODES.O)
        fun sendSingleCall( phoneNumber: String, endTime: Long) {
            val calls = AppInstance.helper.getCallLogs(1);
            if(calls.isEmpty()) return

            val mCall: CallLogStore = calls[0]
            val isCorrectCall = mCall.id.toInt() != lastSyncId  && mCall.phoneNumber == phoneNumber
            Log.d(tag, "Synced ID: $lastSyncId")
            Log.d(tag, "Is Correct Call: $isCorrectCall")
            Log.d(tag, "endTime Int: ${endTime.toInt()}")
            if (mCall.id.toInt() != lastSyncId  && mCall.phoneNumber == phoneNumber){
                Log.d(tag, "Correct Call");
                actuallySend(mCall, endTime);
            }else{
                Log.d(tag, "Wrong Call ${mCall.id}");
                retryNum = 0
                correctCallAndSend(mCall.id, endTime)
            }
        }

        inner class PostDataAsyncTask(private val call: CallHistory, private val id: Int, private val startAt: Long)
            : AsyncTask<Void?, Void?, CallHistory>() {

            @SuppressLint("Range")
            @RequiresApi(Build.VERSION_CODES.O)
            protected override  fun doInBackground(vararg p0: Void?): CallHistory {
                CoroutineScope(Dispatchers.Default).launch {
                    sendCalls(call, id, startAt)
                }
                return call
            }
            @SuppressLint("Range")
            protected override fun onPostExecute(callHistoryItem: CallHistory) {
                super.onPostExecute(callHistoryItem)
                Log.d(tag, "Number requests: $requestCount")
            }
        }

        @RequiresApi(Build.VERSION_CODES.O)
        suspend fun sendCalls(call: CallHistory, id: Int, startAt: Long){
            val listPost = mutableListOf<CallHistory>()
            listPost.add(call)

            val arrayTemp = JSONArray()
            for (callLog in listPost) {
                val jsonObject = AppInstance.helper.createJsonObject(callLog)
                arrayTemp.put(jsonObject)
            }
            val stringToPost = arrayTemp.toString()
            postData( stringToPost, listPost,false, id, startAt)
            listPost.clear()
        }

        private fun getDeepLink(phoneNumber: String?): DeepLink? {
            var id = AppInstance.helper.getString("flutter.id_deeplink","")
            var routeId = AppInstance.helper.getString("flutter.router_deeplink","")

            val deeplinkPhone: String? = AppInstance.helper.getString("flutter.deep_link_phone", "")
            Log.d(tag, "deeplinkPhone $deeplinkPhone routerId $routeId va id $id")
            if(id.equals("") || !phoneNumber.equals(deeplinkPhone)){
                return null
            }
            return DeepLink(id, routeId, "trackIng", phoneNumber)
        }
    }

    override fun onCreate() {
        super.onCreate()
        context = this
        AppInstance.helper = SharedHelper(this)

        userId = AppInstance.helper.getString("flutter.user_name", "")
        lastSyncId = AppInstance.helper.getInt(AppInstance.LAST_SYNC_ID_STR,0)
        val lastSyncTime = AppInstance.helper.getString(AppInstance.LAST_SYNC_TIME_STR,"")
        if(lastSyncTime != ""){
            Log.d(tag, "lastSyncTime $lastSyncTime")
//            val lastSyncTimeStr: Int = lastSyncTime?.toInt()
//            Log.d(tag,"onCreate PhoneStateService lastSyncId : $lastSyncId lastTime : ${getFormattedTime(lastSyncTime.toLong())}")
        }

        telephonyManager = getSystemService(Context.TELEPHONY_SERVICE) as TelephonyManager?
        startForeground(NOTIFICATION_ID, createNotification())

        // Create Connectivity Manager and Network Callback
        connectivityManager = getSystemService(CONNECTIVITY_SERVICE) as ConnectivityManager
        networkCallback = object : ConnectivityManager.NetworkCallback() {
            override fun onAvailable(network: Network) {
                Log.d(tag,"onAvailable Network")
                // network back
                val callLogJSONString: String? = AppInstance.helper.getString(Constants.AS_SYNC_LOGS_STR, "")
                Log.d(tag, "onAvailable Network With $callLogJSONString")
                if(callLogJSONString != "" && callLogJSONString != null) {
                    CoroutineScope(Dispatchers.Default).launch {
                        retryCount = 0
                        postData(callLogJSONString, AppInstance.helper.parseCallLogCacheJSONString(callLogJSONString), true, 0, 0)
                    }
                }
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
        AppInstance.helper.putInt(AppInstance.LAST_SYNC_ID_STR, lastSyncId)
        AppInstance.helper.putLong(AppInstance.DESTROY_TIME_STR, System.currentTimeMillis())

        Log.d(tag,"onDestroy PhoneStateService lastSyncId $lastSyncId time ${System.currentTimeMillis()}")
        telephonyManager?.listen(phoneStateListener, PhoneStateListener.LISTEN_NONE)
        stopForeground(true)
    }

    private fun updateView(isSuccess: Boolean) {

    }

    suspend fun postData(
        postData: String,
        callLogListPost: MutableList<CallHistory>?,
        isSync: Boolean,
        id: Int,
        startAt: Long
    ){
        coroutineScope{
            while (retryCount < maxRetries) {
                var isError = false
                var isErrorOnServer = false
                try {
                    Log.d(tag,"Post $postData ")
                    if (callLogListPost != null) {

                        val callLogBGJSONString: String? = AppInstance.helper.getString(Constants.AS_SYNC_IN_BG_LOGS, "")
                        val callLogEndByJSONString: String? = AppInstance.helper.getString(Constants.AS_ENDBY_SYNC_LOGS_STR, "")

                        var callLogsEndByQueList = mutableListOf<CallLogStore>()
                        if(callLogEndByJSONString != ""){
                            callLogsEndByQueList = AppInstance.helper.parseCallLogEndByCacheJSONString(callLogEndByJSONString ?: "")
                        }

                        var callLogsBGQueList = mutableListOf<CallHistory>()
                        if(callLogBGJSONString != ""){
                            callLogsBGQueList = AppInstance.helper.parseCallLogCacheJSONString(callLogBGJSONString ?: "")
                        }
                        callLogsBGQueList.addAll(callLogListPost)

                        for (i in 0 until callLogsBGQueList.size) {
                            for (cl in callLogsEndByQueList) {

                            }
                        }

//                        saveData(callLogListPost,Constants.AS_SYNC_IN_BG_LOGS, false)

                    }
//                    requestCount++
//
//                    val responseCode =  DataWorker.doPostData(postData)
//                    val isSuccess = responseCode == HttpURLConnection.HTTP_OK
//                    if (isSuccess) {
//                        // CLEAR DATA ON SYNC REQUEST
//                        Log.d(tag, "list trc khi remove $list")
//                        if (callLogListPost != null && !list.isEmpty()) {
//                            synchronized(list) {
//                                for (callLog in callLogListPost) {
//                                    var foundState = list.findLast { it.phone == callLog.PhoneNumber }
//                                    var findIndex = list.indexOf(foundState)
//                                    list.removeAt(findIndex)
//                                }
//                            }
//                        }
//
//                        if (isSync) {
//                            Log.d(tag, "Sync success !!!")
//                            AppInstance.helper.putString(Constants.AS_SYNC_LOGS_STR, "")
//                        }else{
//                            if (id != 0) {
//                                lastSyncId = id
//                                AppInstance.helper.putInt(AppInstance.LAST_SYNC_ID_STR, id)
//                                AppInstance.helper.putString(AppInstance.LAST_SYNC_TIME_STR, startAt.toString())
//                                Log.d(tag, "HTTP OK")
//                            }
//                        }
//                        Log.d(tag, "list sau khi remove $list")
//                        // END
//                        isError = false
//                        isErrorOnServer = false
//
//                        // TODO: need to notify and update view here
//                        //  updateView()
//
//                        break
//                    } else {
//                        isErrorOnServer = true
//                        Log.d(tag, "HTTP NOT OK $responseCode")
//                    }

                } catch (e: Exception) {
                    isError = true
                    Log.d(tag,  e.message + " " + e.cause)
                    e.printStackTrace()
                } finally{
                    retryCount++
                    if(retryCount == 2 && callLogListPost != null){
                        if(isError){
                            Log.d(tag, "ISErorr AS_SYNC_LOGS_STR")
                            saveData(callLogListPost,Constants.AS_SYNC_LOGS_STR, false)
                        }
                        if(isErrorOnServer){
                            Log.d(tag, "isErrorOnServer AS_CALL_LOGS_STR")
                            saveData(callLogListPost,Constants.AS_CALL_LOGS_STR, isErrorOnServer)
                        }
                    }
                }
            }
        }
    }

    private fun saveData(callLogs: MutableList<CallHistory>, name: String, isErrorFromSerVer: Boolean){

//        val callLogJSONString: String? = AppInstance.helper.getString(name, "")
//        var callLogsQueList = mutableListOf<CallHistory>()
//        if(callLogJSONString != ""){
//            callLogsQueList = AppInstance.helper.parseCallLogCacheJSONString(callLogJSONString ?: "")
//        }
//        callLogsQueList.addAll(callLogs)
//
//        val jsonArrayTemp = JSONArray()
//        for (callLog in callLogsQueList) {
//            val jsonObject = AppInstance.helper.createJsonObject(callLog)
//            jsonArrayTemp.put(jsonObject)
//        }
//
//        Log.d(tag, "SaveData CallLog $jsonArrayTemp")
//        AppInstance.helper.putString(name,jsonArrayTemp.toString())
//        // start small service to handler data
//        if(isErrorFromSerVer){
//            DataWorker.startDataHandler(context, name)
//        }
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