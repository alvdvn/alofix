package com.njv.prod

import OngoingCall
import android.content.Context
import android.graphics.PixelFormat
import android.os.Build
import android.os.Handler
import android.telecom.Call
import android.util.Log
import android.view.Gravity
import android.view.LayoutInflater
import android.view.View
import android.view.WindowManager
import android.widget.ImageView
import android.widget.TextView
import androidx.annotation.RequiresApi
import androidx.core.view.isVisible


class OverlayView(context: Context) {
    lateinit var callLogInstance: CallLogData
    private val windowManager: WindowManager =
        context.getSystemService(Context.WINDOW_SERVICE) as WindowManager
    private val overlayView: View =
        LayoutInflater.from(context).inflate(R.layout.custom_dialog_call, null)

    private val tvCallerName: TextView = overlayView.findViewById(R.id.tvCallerName)
    private val tvCallerNumber = overlayView.findViewById<TextView>(R.id.tvCallerNumber)
    private val buttonAccept = overlayView.findViewById<ImageView>(R.id.ivAcceptCall)
    private val buttonDecline = overlayView.findViewById<ImageView>(R.id.ivDeclineCall)

    private val overlayParams: WindowManager.LayoutParams = WindowManager.LayoutParams(
        WindowManager.LayoutParams.MATCH_PARENT,
        WindowManager.LayoutParams.WRAP_CONTENT,
        WindowManager.LayoutParams.TYPE_APPLICATION_OVERLAY,
        WindowManager.LayoutParams.FLAG_NOT_FOCUSABLE,
        PixelFormat.TRANSLUCENT
    ).apply {
        gravity = Gravity.TOP or Gravity.START
    }
   var initCall = false
    @RequiresApi(Build.VERSION_CODES.O)
    fun update(call: Call, callService: CallService) {
        initCall =true
        callLogInstance = CallLogSingleton.init()

        val current = System.currentTimeMillis()
        val currentBySeconds = current / 1000
        Log.d("alo2_", "LOG: CALL_RINGING $callLogInstance")
        callLogInstance.id = "$currentBySeconds&${call.details.handle.schemeSpecificPart}"
        callLogInstance.type = 2
        callLogInstance.startAt = current
        callLogInstance.phoneNumber = call.details.handle.schemeSpecificPart
        callLogInstance.syncBy = 1
        callLogInstance.callBy = 1
        CallLogSingleton.update(callLogInstance)
        tvCallerName.text = call.details.callerDisplayName
        tvCallerNumber.text = call.details.handle.schemeSpecificPart
        buttonAccept.setOnClickListener {
            OngoingCall.calls.forEach { call ->
                if (call != OngoingCall.incomingCall) {
                    CallLogSingleton.instances().forEach { callItem ->
                        if (callItem.phoneNumber == call.details.handle.schemeSpecificPart) {
                            callItem.endedBy = 1
                            callItem.endedAt = System.currentTimeMillis()
                        }
                    }
                    OngoingCall.hangup(call)
                }

            }
            Handler().postDelayed({
                if (call.state != Call.STATE_DISCONNECTED) {
                    CallActivity.start(callService, call)
                    OngoingCall.handleIncomingCall(call)
                }
                removeFromWindow()
            }, 1000)


        }

        buttonDecline.setOnClickListener {
            OngoingCall.hangup(call)
            callLogInstance.endedBy = 1
            callLogInstance.endedAt = System.currentTimeMillis()
            CallLogSingleton.update(callLogInstance)
            CallLogSingleton.sendDataToFlutter("OVV",callLogInstance.phoneNumber)
            removeFromWindow()
        }



        if (overlayView.isAttachedToWindow) {
            windowManager.updateViewLayout(overlayView, overlayParams)
        } else {
            windowManager.addView(overlayView, overlayParams)
        }
    }

    fun removeFromWindow() {
        if (overlayView.isAttachedToWindow) {
            initCall =false
            windowManager.removeView(overlayView)
        }
    }
}