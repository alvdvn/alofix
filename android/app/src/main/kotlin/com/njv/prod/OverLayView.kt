package com.njv.prod

import OngoingCall
import android.content.Context
import android.graphics.PixelFormat
import android.os.Build
import android.os.Handler
import android.telecom.Call
import android.view.Gravity
import android.view.LayoutInflater
import android.view.View
import android.view.WindowManager
import android.widget.ImageView
import android.widget.TextView
import androidx.annotation.RequiresApi

@RequiresApi(Build.VERSION_CODES.O)
class OverlayView(context: Context) {

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

    fun update(call: Call, callService: CallService) {
        tvCallerName.text = call.details.handle.schemeSpecificPart
        tvCallerName.text = call.details.callerDisplayName //
        tvCallerNumber.text = call.details.handle.schemeSpecificPart
        buttonAccept.setOnClickListener {
            OngoingCall.calls.forEach { call ->
                if (call != OngoingCall.incomingCall) {
                    OngoingCall.hangup(call)
                }

            }
            Handler().postDelayed({
                CallActivity.start(callService, call)
                OngoingCall.answer(call)
            }, 1000)

          removeFromWindow()
        }

        buttonDecline.setOnClickListener {
            OngoingCall.hangup(call)
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
            windowManager.removeView(overlayView)
        }
    }
}