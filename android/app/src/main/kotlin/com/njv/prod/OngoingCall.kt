package com.njv.prod

import android.os.Build
import android.telecom.Call
import android.telecom.VideoProfile
import android.util.Log
import androidx.annotation.RequiresApi
import io.reactivex.subjects.BehaviorSubject



object OngoingCall {
    val state: BehaviorSubject<Call> = BehaviorSubject.create()
    private val tag = AppInstance.TAG
    private val callback = @RequiresApi(Build.VERSION_CODES.M)
    object : Call.Callback() {
        override fun onStateChanged(call: Call, newState: Int) {
            Log.d(tag, "Native OngoingCall")
            state.onNext(call)
        }
    }

    var call: Call? = null
        @RequiresApi(Build.VERSION_CODES.M)
        set(value) {
            field?.unregisterCallback(callback)
            value?.let {
                it.registerCallback(callback)
                state.onNext(it)
            }
            field = value
        }

    @RequiresApi(Build.VERSION_CODES.M)
    fun answer() {
        call!!.answer(VideoProfile.STATE_AUDIO_ONLY)
    }

    @RequiresApi(Build.VERSION_CODES.M)
    fun hangup() {
        if (call != null) {
            call!!.disconnect()
        }
    }

    @RequiresApi(Build.VERSION_CODES.M)
    fun rejectWithMessage(reject: Boolean = true, message: String = "") {
        call!!.reject(reject, message)
    }

    @RequiresApi(Build.VERSION_CODES.M)
    fun onHold() {
        call!!.hold()
    }

    @RequiresApi(Build.VERSION_CODES.M)
    fun onUnHold() {
        call!!.unhold()
    }
}