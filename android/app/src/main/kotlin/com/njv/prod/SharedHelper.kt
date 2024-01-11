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
import io.reactivex.annotations.Nullable
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
        return preferences.getString(key, default)
    }

    fun getInt(key: String, default: Int = -1): Int {
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
        editor.putBoolean(key, value)
        editor.apply()
    }

    fun putString(key: String, value: String) {
        val editor = preferences.edit()
        editor.putString(key, value)
        editor.apply()
    }


    fun remove(key: String) {
        val editor = preferences.edit()
        editor.remove(key)
        editor.apply()
    }

    fun putInt(key: String, value: Int) {
        val editor = preferences.edit()
        editor.putInt(key, value)
        editor.apply()
    }

    fun putLong(key: String, value: Long) {
        val editor = preferences.edit()
        editor.putLong(key, value)
        editor.apply()
    }

}
