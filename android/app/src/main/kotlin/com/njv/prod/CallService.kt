package com.njv.prod

import android.os.Build
import android.telecom.Call
import android.telecom.CallAudioState
import android.telecom.InCallService
import androidx.annotation.RequiresApi
import androidx.lifecycle.ViewModelProvider.NewInstanceFactory.Companion.instance

@RequiresApi(Build.VERSION_CODES.M)
class CallService : InCallService() {

    private var instance: CallService? = null

    override fun onCreate() {
        super.onCreate()
        instance = this;
    }

    override fun onCallAdded(call: Call) {
        OngoingCall.call = call
        CallActivity.start(this, call)
    }

    override fun onCallRemoved(call: Call) {
        OngoingCall.call = null
    }

    companion object {
        val instance = CallService()
    }
}