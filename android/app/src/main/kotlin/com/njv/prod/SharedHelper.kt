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

    private val preferences: SharedPreferences by lazy {
        context.getSharedPreferences("FlutterSharedPreferences", Context.MODE_PRIVATE)
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

    private fun getFormattedTime(timestamp: Long): String {
        val sdf = SimpleDateFormat("yyyy-MM-dd HH:mm:ss", Locale.getDefault())
        return sdf.format(Date(timestamp))
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
