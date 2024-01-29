package com.njv.prod

import android.content.Context
import android.content.SharedPreferences

class SharedHelper(private val context: Context) {

    val preferences: SharedPreferences by lazy {
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
