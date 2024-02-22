package com.njv.prod

import android.os.Build
import android.telecom.Call
import android.telecom.VideoProfile
import android.util.Log
import androidx.annotation.RequiresApi
import io.reactivex.subjects.BehaviorSubject



object OngoingCall {
    val state: BehaviorSubject<List<Call>> = BehaviorSubject.createDefault(emptyList())
    private val tag = AppInstance.TAG
    private val callback = object : Call.Callback() {
        override fun onStateChanged(call: Call, newState: Int) {
            Log.d(tag, "Native OngoingCall")
            state.onNext(state.value.orEmpty().filter { it != call })
        }
    }

    var calls: MutableList<Call> = mutableListOf()
        @RequiresApi(Build.VERSION_CODES.M)
        set(value) {
            field.forEach { it.unregisterCallback(callback) }
            value.forEach { it.registerCallback(callback) }
            state.onNext(value)
            field = value
        }

    fun answer(call: Call) {
        call.answer(VideoProfile.STATE_AUDIO_ONLY)
    }

    fun hangup(call: Call) {
        call.disconnect()
    }

    fun rejectWithMessage(call: Call, reject: Boolean = true, message: String = "") {
        call.reject(reject, message)
    }

    fun hold(call: Call) {
        call.hold()
    }

    fun unhold(call: Call) {
        call.unhold()
    }

    fun playDtmfTone(call: Call, c: Char) {
        call.playDtmfTone(c)
        call.stopDtmfTone()
    }
}