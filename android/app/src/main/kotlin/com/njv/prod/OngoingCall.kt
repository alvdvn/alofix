import android.telecom.Call
import android.telecom.VideoProfile
import android.util.Log

import io.reactivex.Observable
import io.reactivex.subjects.BehaviorSubject

object OngoingCall {
    private val tag = "OngoingCall"
    val callStateMap: MutableMap<Call, Int> = mutableMapOf()
    val calls: MutableList<Call> = mutableListOf()
    lateinit var incomingCall: Call

    private val state: BehaviorSubject<List<Call>> = BehaviorSubject.createDefault(emptyList())

    private val callback = object : Call.Callback() {
        override fun onStateChanged(call: Call, newState: Int) {
            Log.d(tag, "Native OngoingCall")
            callStateMap[call] = newState
            state.onNext(calls.toList())
        }
    }

    fun observeCallState(): Observable<List<Call>> {
        return state.hide()
    }

    fun addCall(call: Call) {
        calls.add(call)
        callStateMap[call] = call.state
        call.registerCallback(callback)
        state.onNext(calls.toList())
    }

    fun removeCall(call: Call) {
        calls.remove(call)
        callStateMap.remove(call)
        call.unregisterCallback(callback)
        state.onNext(calls.toList())
    }

    fun handleIncomingCall() {
        answer(calls.first())
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