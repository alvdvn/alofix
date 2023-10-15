package com.example.base_project

import android.content.Context
import android.content.SharedPreferences
import android.os.Build
import android.util.Log
import org.json.JSONArray
import org.json.JSONObject
import java.time.ZoneId
import java.time.format.DateTimeFormatter

class SharedPreferencesHelper(private val context: Context) {

    private val sharedPreferences: SharedPreferences by lazy {
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
        if(callLog.CustomData !== null){
            val customDataObj = JSONObject()
            customDataObj.put("ID", callLog.CustomData?.ID)
            customDataObj.put("type", callLog.CustomData?.type)
            customDataObj.put("routeId", callLog.CustomData?.routeId)
            customDataObj.put("phoneNumber", callLog.CustomData?.phoneNumber)
            jsonObject.put("CustomData", customDataObj)
        }

        jsonObject.put("Method", callLog.Method)
        jsonObject.put("CallStatus", callLog.CallStatus)
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
        Log.d("PSV","parseCallLogCacheJSONString " + callLogJSONString)
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
                val mEndedBy: Int = jsonObject.optInt("EndedBy", 0)
                val mTimeRinging: Int = jsonObject.optInt("TimeRinging", 0)

                val jsonObjectDeepLinkStr = jsonObject.optString("CustomData","")
                var mDeepLink: DeepLink? = null
                if(!jsonObjectDeepLinkStr.equals("") ){
                     mDeepLink = parseDeepLinkObject(jsonObjectDeepLinkStr)
                }

                val mMethod: Int = jsonObject.optInt("Method", 0)
                val mSyncAt: String = jsonObject.optString("SyncAt", "")
                val mCallStatus: Int = jsonObject.optInt("CallStatus", 0)
                val mDate: String = jsonObject.optString("Date", "")

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
                    mCallDuration,
                    mTimeRinging,
                    mDeepLink,
                    mMethod,
                    mSyncAt,
                    mCallStatus,
                    mDate,
                )

                callLogsList.add(callHistory)
            }
        }
        return callLogsList
    }

    fun getString(key: String, default: String): String? {
        return sharedPreferences.getString(key,default)
    }

    fun putString(key: String, value: String) {
        val editor = sharedPreferences.edit()
        editor.putString(key,value)
        editor.apply()
    }
}
