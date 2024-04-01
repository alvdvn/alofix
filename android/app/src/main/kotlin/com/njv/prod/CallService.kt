package com.njv.prod
import OngoingCall
import android.app.KeyguardManager
import android.content.Context
import android.os.Build
import android.os.Handler
import android.os.Looper
import android.os.PowerManager
import android.telecom.Call
import android.telecom.InCallService
import android.view.WindowManager
import android.widget.Toast
import androidx.annotation.RequiresApi
@RequiresApi(Build.VERSION_CODES.O)
class CallService : InCallService() {

    private var wakeLock: PowerManager.WakeLock? = null
    private var keyguardLock: KeyguardManager.KeyguardLock? = null
    private var windowManager: WindowManager? = null
    var overlayView: OverlayView? = null
    private var tag ="alo2_"

    override fun onCreate() {
        super.onCreate()
        windowManager = getSystemService(Context.WINDOW_SERVICE) as WindowManager
        overlayView = OverlayView(this)
        instance =this
    }

    override fun onDestroy() {
        super.onDestroy()
        overlayView?.removeFromWindow()
        instance = null
    }

    @RequiresApi(Build.VERSION_CODES.R)
    override fun onCallAdded(call: Call) {
        if (OngoingCall.calls.size == 0 || (overlayView!=null && overlayView!!.initCall)) {
            if(overlayView!!.initCall){
                Toast.makeText(applicationContext,"Đang có cuộc gọi đến ",Toast.LENGTH_SHORT).show()
            }else {
                OngoingCall.addCall(call)
                OngoingCall.incomingCall = call // Acquire wake lock toå wake up the device
                acquireWakeLock()
                disableKeyguard()
                CallActivity.start(this, call)

            }
        } else {
            OngoingCall.addCall(call)
            OngoingCall.incomingCall = call
            acquireWakeLock()
            disableKeyguard()
            Handler(Looper.getMainLooper()).postDelayed({
                updateOverlay(call)
            }, 100)
        }
    }

    override fun onCallRemoved(call: Call) {
        if (overlayView?.initCall==true  && call.details.handle.schemeSpecificPart == overlayView?.callLogInstance?.phoneNumber){

            CallLogSingleton.instances().forEach { callItem ->
                if (callItem.phoneNumber == call.details.handle.schemeSpecificPart) {
                    callItem.endedAt = System.currentTimeMillis()
                    callItem.endedBy = 2
                }
            }
            CallLogSingleton.sendDataToFlutter("OVV",call.details.handle.schemeSpecificPart)
            overlayView?.removeFromWindow()
        }
        OngoingCall.removeCall(call)
        // Release the wake lock when the call is disconnected
        releaseWakeLock()
        // Re-enable the keyguard
        enableKeyguard()
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
        private var instance: InCallService? = null

        fun getInstance(): InCallService? {
            return instance
        }
    }


    @RequiresApi(Build.VERSION_CODES.R)
    private fun updateOverlay(call: Call) {
        overlayView?.update(call,this)
    }

}

