package com.njv.prod

import android.Manifest.permission.READ_CALL_LOG
import android.Manifest.permission.READ_PHONE_STATE
import android.annotation.SuppressLint
import android.content.Context
import android.content.SharedPreferences
import android.content.pm.PackageManager
import android.os.Build
import android.provider.CallLog
import android.util.Log
import androidx.core.content.ContextCompat
import com.njv.prod.AppInstance.contentResolver
import org.json.JSONArray
import org.json.JSONObject
import java.text.SimpleDateFormat
import java.time.ZoneId
import java.time.format.DateTimeFormatter
import java.util.Date
import java.util.Locale

class SharedHelper(private val context: Context) {
    private val tag = AppInstance.TAG
    private val defaultVersion :String = "13"
    private val defaultDomain :String = "alo-beta.njv.vn"
    private val defaultUrl :String = "https://$defaultDomain/api/calllogs"

    private val preferences: SharedPreferences by lazy {
        context.getSharedPreferences("FlutterSharedPreferences", Context.MODE_PRIVATE)
    }

    fun createJsonObject(callLog: CallHistory): JSONObject {

        val jsonObject = JSONObject()
        jsonObject.put("Id", callLog.Id)
        jsonObject.put("PhoneNumber", callLog.PhoneNumber)
        jsonObject.put("RingAt", callLog.RingAt)
        jsonObject.put("StartAt", callLog.StartAt)
        jsonObject.put("EndedAt", callLog.EndedAt)
        jsonObject.put("AnsweredAt", callLog.AnsweredAt)
        jsonObject.put("Type", callLog.Type)
        jsonObject.put("CallDuration", callLog.CallDuration)
        jsonObject.put("EndedBy", callLog.EndedBy)
        jsonObject.put("AnsweredDuration", callLog.AnsweredDuration)
        jsonObject.put("TimeRinging", callLog.TimeRinging)
        jsonObject.put("SyncBy", callLog.SyncBy)
        if(callLog.CustomData !== null){
            val customDataObj = JSONObject()
            customDataObj.put("ID", callLog.CustomData?.ID)
            customDataObj.put("type", callLog.CustomData?.type)
            customDataObj.put("routeId", callLog.CustomData?.routeId)
            customDataObj.put("phoneNumber", callLog.CustomData?.phoneNumber)
            jsonObject.put("CustomData", customDataObj)
        }

        jsonObject.put("Method", callLog.Method)
        jsonObject.put("CallBy", callLog.CallBy)
        jsonObject.put("CallLogValid", callLog.CallLogValid)
        jsonObject.put("Date", callLog.Date)


        val formatter = if (Build.VERSION.SDK_INT >= Build.VERSION_CODES.O) {
            DateTimeFormatter.ofPattern("yyyy-MM-dd'T'HH:mm:ss.SSS'Z'").withZone(
                ZoneId.of("UTC"))
        } else {
            TODO("VERSION.SDK_INT < O")
        }
        return jsonObject
    }

    fun parseDeepLinkObject(deepLinkJSONStr: String) : DeepLink {
        val jsonObject = JSONObject(deepLinkJSONStr)
        val Id = jsonObject.optString("Id","")
        val type = jsonObject.optString("type","")
        val routeId = jsonObject.optString("routeId","")
        val phoneNumber = jsonObject.optString("phoneNumber","")
        return DeepLink(Id, routeId, type, phoneNumber)
    }

    fun parseCallLogCacheJSONString(callLogJSONString: String): MutableList<CallHistory> {
        val callLogsList = mutableListOf<CallHistory>()
        Log.d("PSV", "parseCallLogCacheJSONString $callLogJSONString")
        if (callLogJSONString.isNotEmpty()) {
            val jsonArray = JSONArray(callLogJSONString)
            for (i in 0 until jsonArray.length()) {
                val jsonObject = jsonArray.getJSONObject(i)

                val mId: String = jsonObject.optString("Id", "")
                val mPhoneNumber: String = jsonObject.optString("PhoneNumber", "empty")
                val mRingAt: String = jsonObject.optString("RingAt", "empty")
                val mStartAt: String = jsonObject.optString("StartAt", "")
                val mEndedAt: String = jsonObject.optString("EndedAt", "")
                val mAnsweredAt: String = jsonObject.optString("AnsweredAt", "")
                val mType: Int = jsonObject.optInt("Type", 0)
                val mCallDuration: Int = jsonObject.optInt("CallDuration", 0)
                val mDuration: Int = jsonObject.optInt("AnsweredDuration", 0)
                val mEndedBy: Int = jsonObject.optInt("EndedBy", 0)
                val mSyncBy: Int = jsonObject.optInt("SyncBy", 0)
                val mTimeRinging: Long = jsonObject.optLong("TimeRinging", 0)

                val jsonObjectDeepLinkStr = jsonObject.optString("CustomData","")
                var mDeepLink: DeepLink? = null
                if(!jsonObjectDeepLinkStr.equals("") ){
                     mDeepLink = parseDeepLinkObject(jsonObjectDeepLinkStr)
                }

                val mMethod: Int = jsonObject.optInt("Method", 0)
                val mSyncAt: String = jsonObject.optString("SyncAt", "")
                val mDate: String = jsonObject.optString("Date", "")
                val mCallBy: Int = jsonObject.optInt("CallBy", 0)
                val mCallLogValid: Int = jsonObject.optInt("CallLogValid", 0)

                val callHistory = CallHistory(
                    mId, // startAt&phoneNumber
                    mPhoneNumber,
                    mRingAt,
                    mStartAt,
                    mEndedAt,
                    mAnsweredAt,
                    mType,
                    mCallDuration,
                    mEndedBy,
                    mSyncBy,
                    mDuration,
                    mTimeRinging,
                    mDeepLink,
                    mMethod,
                    mSyncAt,
                    mCallBy,
                    mCallLogValid,
                    mDate,
                )

                callLogsList.add(callHistory)
            }
        }
        return callLogsList
    }

    fun getString(key: String, default: String): String? {
        return preferences.getString(key,default)
    }

    fun getInt(key: String, default: Int): Int {
        return preferences.getInt(key, default)
    }

    fun getLong(key: String, default: Long): Long {
        return preferences.getLong(key, default)
    }

    fun getBool(key: String, default: Boolean): Boolean {
        return preferences.getBoolean(key, default)
    }

    fun putBool(key: String, value: Boolean) {
        val editor = preferences.edit()
        editor.putBoolean(key,value)
        editor.apply()
    }

    fun putString(key: String, value: String) {
        val editor = preferences.edit()
        editor.putString(key,value)
        editor.apply()
    }

    fun putInt(key: String, value: Int) {
        val editor = preferences.edit()
        editor.putInt(key,value)
        editor.apply()
    }

    fun putLong(key: String, value: Long) {
        val editor = preferences.edit()
        editor.putLong(key,value)
        editor.apply()
    }

    fun getUrl(): String {
        val apiDomain = preferences.getString("flutter.api_domain", "default_url")
        val url: String = if(apiDomain.equals("default_url") || apiDomain == ""){
            preferences.getString("flutter.alo_url", defaultUrl).toString()
        }else{
            "https://$apiDomain/"
        }
        return url
    }

    fun getVersionStr(): String? {
        return  preferences.getString("flutter.alo_version", defaultVersion)
    }

    private fun getFormattedTime(timestamp: Long): String {
        val sdf = SimpleDateFormat("yyyy-MM-dd HH:mm:ss", Locale.getDefault())
        return sdf.format(Date(timestamp))
    }

    @SuppressLint("Range")
    fun getCallLogsById(id: Int) : ArrayList<CallLogStore> {
        if(!isHavePermission()) return ArrayList()

        val projection = arrayOf(
            CallLog.Calls._ID,
            CallLog.Calls.NUMBER,
            CallLog.Calls.DURATION,
            CallLog.Calls.TYPE,
            CallLog.Calls.DATE
        )

        val sortOrder = CallLog.Calls.DATE + " DESC"
        val results: ArrayList<CallLogStore> = ArrayList()
        val queryUri = CallLog.Calls.CONTENT_URI
        val selection = "${CallLog.Calls._ID} = ?" // Selection to filter by _ID
        val selectionArgs = arrayOf(id.toString())

        contentResolver.query(
            queryUri,
            projection,
            selection,
            selectionArgs,
            sortOrder
        )?.use { cursor ->
            if (cursor.moveToFirst()) {
                do {
                    val id = cursor.getString(cursor.getColumnIndex(CallLog.Calls._ID))
                    val callNumber = cursor.getString(cursor.getColumnIndex(CallLog.Calls.NUMBER))
                    var callDuration = cursor.getInt(cursor.getColumnIndex(CallLog.Calls.DURATION))
                    val callType = cursor.getInt(cursor.getColumnIndex(CallLog.Calls.TYPE))
                    val startTime = cursor.getLong(cursor.getColumnIndex(CallLog.Calls.DATE))

                    val callLogs = getCallLogStore(id, callDuration, startTime, callNumber, callType)

                    results.add(callLogs)

                } while (cursor.moveToNext())
            }
        }
        return results
    }

    @SuppressLint("Range")
    fun getCallLogs(limit: Int) : ArrayList<CallLogStore> {
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

                    val callLogs = getCallLogStore(id, callDuration, startTime, callNumber, callType)

                    results.add(callLogs)

                } while (cursor.moveToNext())
            }
        }
        return results
    }

    private fun getCallLogStore(id: String, callDuration: Int, startTime: Long, callNumber: String, callType: Int) : CallLogStore{
        var newCallDuration: Int
        val userId = AppInstance.helper.getString("flutter.user_name", "")
        val logString = "Call: Id: $id, Number: $callNumber, Duration: $callDuration seconds, Type: $callType, StartAt: ${getFormattedTime(startTime)}"
        Log.d(tag, logString)

        // TODO: Check this carefully for older devices ( maybe the index was wrong )
        // TODO: Bellow logic for handler missed type -> this convert duration into 0 for the logs status in business
        if( callType == CallLog.Calls.MISSED_TYPE || callType == CallLog.Calls.REJECTED_TYPE ){
            newCallDuration = 0
        }else{
            newCallDuration = callDuration
        }
        return CallLogStore(id, newCallDuration, startTime, callNumber, callType, 0)
    }

    private fun isHavePermission(): Boolean {
        if (ContextCompat.checkSelfPermission(context, READ_PHONE_STATE)
            == PackageManager.PERMISSION_GRANTED &&
            ContextCompat.checkSelfPermission(context, READ_CALL_LOG)
            == PackageManager.PERMISSION_GRANTED
        ) {
            // Permission is granted
            return true
        }
        return false
    }
}
