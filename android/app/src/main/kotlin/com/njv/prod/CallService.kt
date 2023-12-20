package com.njv.prod

import android.os.Build
import android.telecom.Call
import android.telecom.CallAudioState
import android.telecom.InCallService
import androidx.annotation.RequiresApi
import androidx.lifecycle.ViewModelProvider.NewInstanceFactory.Companion.instance
import android.app.KeyguardManager
import android.view.WindowManager
import android.content.Context
import android.os.PowerManager

@RequiresApi(Build.VERSION_CODES.M)
class CallService : InCallService() {

    private var instance: CallService? = null
    private var wakeLock: PowerManager.WakeLock? = null
    private var keyguardLock: KeyguardManager.KeyguardLock? = null
    private val tag = AppInstance.TAG
    override fun onCreate() {
        super.onCreate()
        instance = this;
    }

    override fun onCallAdded(call: Call) {
        OngoingCall.call = call
        // Acquire wake lock to wake up the device
        acquireWakeLock();

        // Disable the keyguard to turn on the screen
        disableKeyguard();
        CallActivity.start(this, call)
    }

    override fun onCallRemoved(call: Call) {
        OngoingCall.call = null
        // Release the wake lock when the call is disconnected
        releaseWakeLock();

        // Re-enable the keyguard
        enableKeyguard();
    }

    private fun acquireWakeLock() {
        val powerManager = getSystemService(Context.POWER_SERVICE) as PowerManager?

        if (powerManager != null) {
            wakeLock = powerManager.newWakeLock(
                PowerManager.FULL_WAKE_LOCK or PowerManager.ACQUIRE_CAUSES_WAKEUP,
                "$tag::InCallWakeLock"
            )
            wakeLock?.acquire()
        }
    }

    private fun releaseWakeLock() {
        if (wakeLock?.isHeld == true) {
            wakeLock?.release()
            wakeLock = null
        }
    }

    private fun disableKeyguard() {
        val keyguardManager = getSystemService(Context.KEYGUARD_SERVICE) as KeyguardManager?

        if (keyguardManager != null) {
            keyguardLock = keyguardManager.newKeyguardLock(tag)
            keyguardLock?.disableKeyguard()
        }
    }

    private fun enableKeyguard() {
        keyguardLock?.reenableKeyguard()
        keyguardLock = null
    }

    companion object {
        val instance = CallService()
    }
}