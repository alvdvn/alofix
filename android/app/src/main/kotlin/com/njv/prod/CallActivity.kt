package com.njv.prod

import android.annotation.SuppressLint
import android.app.Activity
import android.content.Context
import android.content.Intent
import android.graphics.Color
import android.media.AudioManager
import android.os.Build
import android.os.Bundle
import android.os.Handler
import android.os.Looper
import android.telecom.Call
import android.telecom.CallAudioState
import android.util.Log
import android.view.View
import android.view.Window
import android.view.WindowManager
import android.widget.ImageView
import android.widget.LinearLayout
import android.widget.RelativeLayout
import android.widget.TextView
import androidx.annotation.RequiresApi
import androidx.core.view.isVisible
import io.flutter.embedding.android.FlutterActivity
import io.reactivex.disposables.CompositeDisposable
import io.reactivex.rxkotlin.addTo
import org.json.JSONArray
import java.util.concurrent.TimeUnit

class CallActivity: FlutterActivity() {

    private lateinit var ivBackground: ImageView
    private lateinit var rlBackgroundAnimation: RelativeLayout

    private lateinit var ivAvatar: ImageView
    private lateinit var tvNameCaller: TextView
    private lateinit var tvNumber: TextView
    private lateinit var tvCallDuration: TextView

    private lateinit var llAction: LinearLayout
    private lateinit var ivAcceptCall: ImageView
    private lateinit var tvAccept: TextView

    private lateinit var ivDeclineCall: ImageView
    private lateinit var tvDecline: TextView

    private lateinit var llOnlyDecline: LinearLayout
    private lateinit var ivOnlyDeclineCall: ImageView
    private lateinit var tvOnlyDecline: TextView

    private lateinit var llActionLoudSpeaker: LinearLayout
    private lateinit var ivLoudSpeaker: ImageView

    private lateinit var number: String
    private val disposables = CompositeDisposable()
    lateinit var mainHandler: Handler
    private val tag = AppInstance.TAG
    private var isSpeaker = false
    private var isRiderCancel = false

    private val updateTextTask = object : Runnable {
        override fun run() {
            minusOneSecond()
            mainHandler.postDelayed(this, 1000)
        }
    }
    private var secondsLeft: Int = 0
    private val collectTimeout : Long = 1500

    @RequiresApi(Build.VERSION_CODES.M)
    @Suppress("DEPRECATION")
    override fun onCreate(savedInstanceState: Bundle?) {
        super.onCreate(savedInstanceState)
        window.addFlags(WindowManager.LayoutParams.FLAG_KEEP_SCREEN_ON)
        if (Build.VERSION.SDK_INT >= Build.VERSION_CODES.O_MR1) {
            window.addFlags(WindowManager.LayoutParams.FLAG_KEEP_SCREEN_ON)
            setTurnScreenOn(true)
            setShowWhenLocked(true)
        } else {
            window.addFlags(WindowManager.LayoutParams.FLAG_KEEP_SCREEN_ON)
            window.addFlags(WindowManager.LayoutParams.FLAG_TURN_SCREEN_ON)
            window.addFlags(WindowManager.LayoutParams.FLAG_SHOW_WHEN_LOCKED)
            window.addFlags(WindowManager.LayoutParams.FLAG_DISMISS_KEYGUARD)
        }
        transparentStatusAndNavigation()
        setContentView(R.layout.layout_custom_call)
        number = intent.data?.schemeSpecificPart ?: "0"
        initView()
        bidingData()
        mainHandler = Handler(Looper.getMainLooper())

        OngoingCall.state
            .subscribe(::updateUi)
            .addTo(disposables)

        OngoingCall.state
            .filter { it == Call.STATE_DISCONNECTED }
            .delay(1, TimeUnit.SECONDS)
            .firstElement()
            .subscribe { finishTask() }
            .addTo(disposables)
    }

    override fun onResume() {
        super.onResume()
        Log.d(tag,"onResume CallActivity")
    }

    override fun onPause() {
        super.onPause()
        Log.d(tag,"onPause CallActivity")
//        mainHandler.removeCallbacks(updateTextTask)
    }

    override fun onStop() {
        super.onStop()
        Log.d(tag,"onStop CallActivity")
//        disposables.clear()
    }

    @RequiresApi(Build.VERSION_CODES.M)
    override fun onDestroy() {
        Log.d(tag,"onDestroy CallActivity")
        if (isRiderCancel) {
            isRiderCancel = false
            super.onDestroy()
            return
        }
        OngoingCall.hangup()
        val mainHandler = Handler(Looper.getMainLooper())
        try {
            mainHandler.postDelayed({
                val calls = AppInstance.helper.getCallLogs(1);
                var mCall: CallLogStore = calls[0]
                var endAtNow =  System.currentTimeMillis()
                mCall.endAt = endAtNow
                Log.d(tag, "onDestroy mCall  $mCall");

                val callLogJSONString: String? = AppInstance.helper.getString(Constants.AS_ENDBY_SYNC_LOGS_STR, "")
                var callLogsQueList = mutableListOf<CallLogStore>()
                if(callLogJSONString != ""){
                    callLogsQueList = AppInstance.helper.parseCallLogEndByCacheJSONString(callLogJSONString ?: "")
                }
                callLogsQueList.add(mCall)

                val arrayTemp = JSONArray()
                for (callLog in callLogsQueList) {
                    val jsonObject = AppInstance.helper.createEndByJsonObject(callLog)
                    arrayTemp.put(jsonObject)
                }
                val stringToPost = arrayTemp.toString()
                Log.d(tag, "onDestroy stringToPost $stringToPost")
                AppInstance.helper.putString(Constants.AS_ENDBY_SYNC_LOGS_STR, stringToPost)
            }, collectTimeout)
        } catch (e: Exception) {
            Log.d(tag, e.toString())
            e.printStackTrace()
        }
        super.onDestroy()
    }

    override fun onDetachedFromWindow() {
        super.onDetachedFromWindow()
        Log.d(tag,"onDetachedFromWindow CallActivity")
    }

    override fun onBackPressed() {
//        super.onBackPressed()
//        return;
    }

    @SuppressLint("SetTextI18n")
    private fun updateUi(state: Int) {
        Log.d("Activity UpdateUI", {state.asString()}.toString())
        tvNameCaller.text = state.asString().toLowerCase().capitalize()
        tvNumber.text = number
//        if (state == Call.STATE_RINGING) {
//            i_am_receiver = true
//            binding.callingType.setText("Ringing Mobile")
//        } else if (state == Call.STATE_DIALING) {
//            i_am_receiver = false
//            binding.callingType.setText("Calling Mobile")
//        } else if (state == Call.STATE_ACTIVE) {
//            binding.callingType.setText("Active")
//        } else if (state == Call.STATE_CONNECTING) {
//            binding.callingType.setText("Connecting...")
//        } else if (state == Call.STATE_DISCONNECTED) {
//            binding.callingType.setText("Disconnected")
//        } else if (state == Call.STATE_CONNECTING) {
//            binding.callingType.setText("Connecting...")
//        } else if (state == Call.STATE_DISCONNECTING) {
//            binding.callingType.setText("DisConnecting...")
//        } else if (state == Call.STATE_HOLDING) {
//            binding.callingType.setText("On Hold ")
//        } else if (state == Call.REJECT_REASON_DECLINED) {
//            binding.callingType.setText("Rejected")
//        }
        when (state) {
            Call.STATE_NEW -> println("LOG: STATE_NEW")
            Call.STATE_ACTIVE -> {
                println("LOG: STATE_ACTIVE")
                mainHandler.post(updateTextTask)
                llAction.isVisible = false
                llOnlyDecline.isVisible = true
            }
            Call.STATE_RINGING -> {
                println("LOG: STATE_RINGING")
                llAction.isVisible = true
                llOnlyDecline.isVisible = false
            }
            Call.STATE_DIALING -> {
                println("LOG: STATE_DIALING")
                llAction.isVisible = false
                llOnlyDecline.isVisible = true
            }
            Call.REJECT_REASON_DECLINED -> println("LOG: REJECT_REASON_DECLINED")
            Call.STATE_CONNECTING -> println("LOG: STATE_CONNECTING")
            Call.STATE_DISCONNECTED -> println("LOG: STATE_DISCONNECTED")
            else -> println("Number is not between 1 and 3")
        }
    }

    @RequiresApi(Build.VERSION_CODES.M)
    private fun initView() {
        ivBackground = findViewById(R.id.ivBackground)
        rlBackgroundAnimation = findViewById(R.id.rlBackgroundAnimation)

        tvNameCaller = findViewById(R.id.tvNameCaller)
        tvNumber = findViewById(R.id.tvNumber)
        ivAvatar = findViewById(R.id.ivAvatar)
        tvCallDuration = findViewById(R.id.tvCallDuration)

        llAction = findViewById(R.id.llAction)

        ivAcceptCall = findViewById(R.id.ivAcceptCall)
        tvAccept = findViewById(R.id.tvAccept)
        ivDeclineCall = findViewById(R.id.ivDeclineCall)
        tvDecline = findViewById(R.id.tvDecline)

        ivAcceptCall.setOnClickListener {
            onAcceptClick()
        }
        ivDeclineCall.setOnClickListener {
            onDeclineClick()
        }

        llOnlyDecline = findViewById(R.id.llOnlyDecline)
        ivOnlyDeclineCall = findViewById(R.id.ivOnlyDeclineCall)
        tvOnlyDecline = findViewById(R.id.tvOnlyDecline)
        ivOnlyDeclineCall.setOnClickListener {
            onDeclineClick()
        }

        llActionLoudSpeaker = findViewById(R.id.llActionLoudSpeaker)
        ivLoudSpeaker = findViewById(R.id.ivLoudSpeaker)
        ivLoudSpeaker.setOnClickListener {
            isSpeaker = !isSpeaker
            speakerOnOff(isSpeaker)
        }

//        binding.hold.setOnClickListener {
//            if(onHold){
//                binding.hold.setImageResource(R.drawable.hold_off)
//                onHold=false
//                OngoingCall.onUnHold()
//            }else{
//                binding.hold.setImageResource(R.drawable.hold_on)
//                onHold=true
//                OngoingCall.onHold()
//            }
//        }
    }

    private fun bidingData() {
//        val phone = intent.getStringExtra("phone_out")
//        Log.d("Flutter phone_out", "$phone")
        tvNumber.text = number
    }

    private fun speakerOnOff(on: Boolean) {
        Log.d(tag, "SPEAKER  is$on")
        val audioManager: AudioManager = this.getSystemService(AUDIO_SERVICE) as AudioManager
        val isSpeakerOn: Boolean = audioManager.isSpeakerphoneOn()
        val earpiece: Int = CallAudioState.ROUTE_WIRED_OR_EARPIECE
        val speaker: Int = CallAudioState.ROUTE_SPEAKER
        if (Build.VERSION.SDK_INT > Build.VERSION_CODES.P) {
            val getInstance = CallService.instance
            getInstance.setAudioRoute(if (isSpeakerOn) earpiece else speaker)
        } else {
            audioManager.setSpeakerphoneOn(!isSpeakerOn)
        }
        if (on) {
            ivLoudSpeaker.setImageResource(R.drawable.icon_loudspeaker_on)
        } else {
            ivLoudSpeaker.setImageResource(R.drawable.icon_loudspeaker_off)
        }
    }

    @RequiresApi(Build.VERSION_CODES.M)
    private fun onAcceptClick() {
        OngoingCall.answer()
    }

    @RequiresApi(Build.VERSION_CODES.M)
    private fun onDeclineClick() {
        isRiderCancel = true
        OngoingCall.hangup()
        mainHandler.removeCallbacks(updateTextTask)
        var endAtNow =  System.currentTimeMillis()
        val data = mapOf(
            "endAt" to endAtNow,
            "phoneNumber" to number)
        AppInstance.methodChannel.invokeMethod("end_call", data)
        sendBroadcast(intent)
        finishTask()
    }

    private fun finishTask() {
        Log.d(tag,"finishTask CallActivity")
        if (Build.VERSION.SDK_INT >= Build.VERSION_CODES.LOLLIPOP) {
            Log.d(tag,"finishTask finishAndRemoveTask")
            finishAndRemoveTask()
        } else {
            Log.d(tag,"finishTask finish")
            finish()
        }
    }

    private fun transparentStatusAndNavigation() {
        if (Build.VERSION.SDK_INT >= Build.VERSION_CODES.KITKAT && Build.VERSION.SDK_INT < Build.VERSION_CODES.LOLLIPOP) {
            setWindowFlag(
                WindowManager.LayoutParams.FLAG_TRANSLUCENT_STATUS
                        or WindowManager.LayoutParams.FLAG_TRANSLUCENT_NAVIGATION, true
            )
        }
        if (Build.VERSION.SDK_INT >= Build.VERSION_CODES.KITKAT) {
            window.decorView.systemUiVisibility = (View.SYSTEM_UI_FLAG_LAYOUT_STABLE
                    or View.SYSTEM_UI_FLAG_LAYOUT_FULLSCREEN
                    or View.SYSTEM_UI_FLAG_LAYOUT_HIDE_NAVIGATION)
        }
        if (Build.VERSION.SDK_INT >= Build.VERSION_CODES.LOLLIPOP) {
            setWindowFlag(
                (WindowManager.LayoutParams.FLAG_TRANSLUCENT_STATUS
                        or WindowManager.LayoutParams.FLAG_TRANSLUCENT_NAVIGATION), false
            )
            window.statusBarColor = Color.TRANSPARENT
            window.navigationBarColor = Color.TRANSPARENT
        }
    }

    private fun setWindowFlag(bits: Int, on: Boolean) {
        val win: Window = window
        val winParams: WindowManager.LayoutParams = win.attributes
        if (on) {
            winParams.flags = winParams.flags or bits
        } else {
            winParams.flags = winParams.flags and bits.inv()
        }
        win.attributes = winParams
    }

    fun minusOneSecond() {
        secondsLeft += 1
        val formatted = "${(secondsLeft / 60).toString().padStart(2, '0')} : ${(secondsLeft % 60).toString().padStart(2, '0')}"
        tvCallDuration.text = formatted.toString()
    }

    companion object {
        @RequiresApi(Build.VERSION_CODES.M)
        fun start(context: Context, call: Call) {
            Intent(context, CallActivity::class.java)
                .setFlags(Intent.FLAG_ACTIVITY_NEW_TASK)
                .setData(call.details.handle)
                .let(context::startActivity)
        }
    }

}