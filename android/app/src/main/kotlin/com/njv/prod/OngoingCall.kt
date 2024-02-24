package com.njv.prod

import android.os.Build
import android.telecom.Call
import android.telecom.VideoProfile
import android.util.Log
import androidx.annotation.RequiresApi
import io.reactivex.Observable
import io.reactivex.subjects.BehaviorSubject

object OngoingCall {
    private val state: BehaviorSubject<List<Call>> = BehaviorSubject.createDefault(emptyList())
    private val tag = AppInstance.TAG
    private val callback = object : Call.Callback() {
        override fun onStateChanged(call: Call, newState: Int) {
            Log.d(tag, "Native OngoingCall")
            state.onNext(state.value.orEmpty().filter { it != call } + call)
        }
    }
    fun observeCallState(): Observable<List<Call>> {
        return state.hide() // Ẩn sự kiện để chỉ cho phép đăng ký lắng nghe, nhưng không cho phép phát ra sự kiện từ bên ngoài
    }

    // Phương thức để cập nhật trạng thái của cuộc gọi
    fun updateCallState(calls: List<Call>) {
        state.onNext(calls)
    }


    var calls: List<Call> = emptyList()
        private set

    @RequiresApi(Build.VERSION_CODES.M)
    fun addCall(call: Call) {
        val updatedCalls = calls.toMutableList().apply {
            forEach { it.unregisterCallback(callback) }
            add(call)
            call.registerCallback(callback)
        }
        state.onNext(updatedCalls)
        calls = updatedCalls
    }

    fun removeCall(call: Call) {
        val updatedCalls = calls.toMutableList().apply {
            remove(call)
            call.unregisterCallback(callback)
        }
        state.onNext(updatedCalls)
        calls = updatedCalls
    }

    fun answer(call: Call) {
        call.answer(VideoProfile.STATE_AUDIO_ONLY)
    }

    fun hangup(call: Call) {
        call.disconnect()
    }

    fun playDtmfTone(call: Call, c: Char) {
        call.playDtmfTone(c)
        call.stopDtmfTone()
    }
}
