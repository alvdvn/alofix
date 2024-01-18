package com.njv.prod

import android.annotation.SuppressLint
import android.content.ContentResolver
import android.content.Context
import android.content.Intent
import android.content.pm.PackageManager
import android.database.Cursor
import android.graphics.Color
import android.media.AudioManager
import android.net.Uri
import android.os.Build
import android.os.Bundle
import android.os.Handler
import android.os.Looper
import android.provider.ContactsContract
import android.telecom.Call
import android.telecom.CallAudioState
import android.telecom.PhoneAccountHandle
import android.telecom.TelecomManager
import android.util.Log
import android.view.View
import android.view.Window
import android.view.WindowManager
import android.widget.*
import androidx.annotation.RequiresApi
import androidx.core.app.ActivityCompat
import androidx.core.view.isVisible
import com.google.gson.Gson
import io.flutter.embedding.android.FlutterActivity
import io.flutter.plugin.common.MethodChannel
import io.reactivex.disposables.CompositeDisposable
import io.reactivex.rxkotlin.addTo

class CallActivity : FlutterActivity() {

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

    private lateinit var progressBar: ProgressBar

    private lateinit var number: String
    private val disposables = CompositeDisposable()
    lateinit var mainHandler: Handler
    private val tag = AppInstance.TAG
    private var isSpeaker = false

    private var userId: String? = ""
    private var audioManager: AudioManager? = null
    private var audioState: Int = CallAudioState.ROUTE_EARPIECE
    private var callLog: CallLogData? = null

    private val updateTextTask = object : Runnable {
        override fun run() {
            minusOneSecond()
            mainHandler.postDelayed(this, 1000)
        }
    }
    private var secondsLeft: Int = 0

    @RequiresApi(Build.VERSION_CODES.O)
    @Suppress("DEPRECATION")
    override fun onCreate(savedInstanceState: Bundle?) {
        super.onCreate(savedInstanceState)
        Log.d(tag, "onCreate DF")
        audioManager = this.getSystemService(AUDIO_SERVICE) as AudioManager
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
    }

    override fun onResume() {
        super.onResume()
        Log.d(tag, "onResume CallActivity")
    }


    override fun onPause() {
        super.onPause()
//        mainHandler.removeCallbacks(updateTextTask)
    }

    override fun onStop() {
        super.onStop()
        Log.d(tag, "onStop CallActivity")
        disposables.clear()
    }

    @RequiresApi(Build.VERSION_CODES.M)
    override fun onDestroy() {
        Log.d(tag, "onDestroy CallActivity")
        if (OngoingCall.call != null) {
            OngoingCall.hangup()
        }
        disposables.clear()
        super.onDestroy()
    }

    override fun onDetachedFromWindow() {
        super.onDetachedFromWindow()
        Log.d(tag, "onDetachedFromWindow CallActivity")
    }

    override fun onBackPressed() {
//        super.onBackPressed()
//        return;
    }

    @RequiresApi(Build.VERSION_CODES.O)
    @SuppressLint("SetTextI18n")
    private fun updateUi(callObject: Call) {
        if (userId.isNullOrEmpty()) {
            userId = AppInstance.helper.getString("flutter.user_name", "")
            Log.d(tag, "user_name  ========================= $userId")
        }
        Log.d("Activity UpdateUI", { callObject.state.asString() }.toString())
        tvNameCaller.text = callObject.state.asString().toLowerCase().capitalize()
        tvNumber.text = getContactName(number)

        val current = System.currentTimeMillis()
        val currentBySeconds = current / 1000

        when (callObject.state) {

            Call.STATE_ACTIVE -> {
                Log.d(tag, "LOG: STATE_ACTIVE")
                mainHandler.post(updateTextTask)
                llAction.isVisible = false
                llOnlyDecline.isVisible = true
            }

            Call.STATE_RINGING -> {
                Log.d(tag, "LOG: STATE_RINGING $current")

                llAction.isVisible = true
                llOnlyDecline.isVisible = false
                //incoming call
                callLog = CallLogData()
                callLog?.id = "$currentBySeconds&${userId}"
                callLog?.type = 2
                callLog?.startAt = current
                callLog?.phoneNumber = number
                callLog?.syncBy = 1
                callLog?.callBy = 1
            }

            Call.STATE_SELECT_PHONE_ACCOUNT -> {
                try {
                    if (ActivityCompat.checkSelfPermission(
                            this,
                            android.Manifest.permission.CALL_PHONE
                        ) === PackageManager.PERMISSION_GRANTED
                    ) {
                        @SuppressLint("ServiceCast")
                        val telecomManager: TelecomManager =
                            getSystemService(Context.TELECOM_SERVICE) as TelecomManager

                        val list: List<PhoneAccountHandle> = telecomManager.callCapablePhoneAccounts
                        if (list.count() >= 2) {
                            val simIndex: Int =
                                AppInstance.helper.getLong(Constants.valueSimChoose, -1).toInt()

                            if (simIndex != -1) {
                                callObject.phoneAccountSelected(list[simIndex], false)
                            } else {
                                val alert = ViewDialog()
                                alert.showDialog(activity, { index ->
                                    callObject.phoneAccountSelected(list[index], false)
                                }, onCancel = {
                                    callObject.disconnect()
                                    onDeclineClick()
                                })
                            }
                        }
                    }
                } catch (e: Exception) {
                    e.printStackTrace()
                }
            }

            Call.STATE_DIALING -> {
                Log.d(tag, "LOG: STATE_DIALING $current")
                //outgoing call
                llAction.isVisible = false
                llOnlyDecline.isVisible = true

                //outgoing call
                callLog = CallLogData()
                callLog?.id = "$currentBySeconds&${userId}"
                callLog?.type = 1
                callLog?.startAt = current
                callLog?.phoneNumber = number
                callLog?.syncBy = 1
                callLog?.callBy = 1
            }

//            Call.REJECT_REASON_DECLINED -> {
//                Log.d(tag, "LOG: REJECT_REASON_DECLINED")
//            }

//            Call.STATE_CONNECTING -> {
//                Log.d(tag, "LOG: STATE_CONNECTING $current")
//            }

            Call.STATE_DISCONNECTED -> {
                Log.d(tag, "LOG: STATE_DISCONNECTED")

                if (callLog != null) {
                    endCall()
//                    if(!AppInstance.helper.getBool("flutter.is_login",false)){
//                        callLog!!.id = callLog!!.id.split("&").first() + "&"
//                    }
                    callLog?.endedAt = current
                    sendDataToFlutter(callLog)
                    callLog = null
                }

            }

            else -> {
                Log.d(tag, "Number is not between 1 and 3")
            }
        }
    }

    private fun sendDataToFlutter(callLog: CallLogData?) {
        Log.d(tag, "SendFlutter DF $callLog")
        if (callLog != null) {
            val json = Gson().toJson(callLog)
            AppInstance.helper.putString("backup_df", json)
            AppInstance.methodChannel.invokeMethod(
                "save_call_log",
                json,
                object : MethodChannel.Result {
                    override fun success(result: Any?) {
                        AppInstance.helper.remove("backup_df")
                        Log.d(tag, "remove backup df")
                    }

                    override fun error(
                        errorCode: String,
                        errorMessage: String?,
                        errorDetails: Any?
                    ) {
                    }

                    override fun notImplemented() {

                    }
                })
        }
    }

    @RequiresApi(Build.VERSION_CODES.O)
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
//            isSpeaker = !isSpeaker
            speakerOnOff()
        }
        progressBar = findViewById(R.id.progressBar)
        progressBar.max = 10
    }

    private fun bidingData() {
        tvNumber.text = getContactName(number)
        AppInstance.methodChannel.invokeMethod("clear_phone", null)
    }

    @RequiresApi(Build.VERSION_CODES.M)
    private fun speakerOnOff() {
        Log.d(tag, "SPEAKER  is $isSpeaker")
        try {
            val inCallService = CallService.getInstance()

            if (isSpeaker) {
                isSpeaker = false
                ivLoudSpeaker.setImageResource(R.drawable.icon_loudspeaker_off)
                if (audioManager != null) {
                    if (audioManager!!.isSpeakerphoneOn) audioManager!!.isSpeakerphoneOn = false
                    audioManager!!.mode = AudioManager.MODE_IN_COMMUNICATION
                }
                inCallService?.setAudioRoute(audioState)

//            closeSpeakerOn()
            } else {
                audioState = inCallService!!.getCallAudioState().route
                isSpeaker = true
                if (!audioManager!!.isSpeakerphoneOn) audioManager!!.isSpeakerphoneOn = true
                audioManager!!.mode = AudioManager.MODE_IN_COMMUNICATION
                inCallService.setAudioRoute(CallAudioState.ROUTE_SPEAKER)
                ivLoudSpeaker.setImageResource(R.drawable.icon_loudspeaker_on)
//            openSpeakerOn();
            }

        } catch (e: Exception) {
            e.printStackTrace()
        }
    }

    @RequiresApi(Build.VERSION_CODES.M)
    private fun onAcceptClick() {
        OngoingCall.answer()
    }

    @RequiresApi(Build.VERSION_CODES.O)
    private fun onDeclineClick() {
        if (callLog != null) {
            callLog?.endedBy = 1
        }
        endCall()
    }

    private fun endCall() {
        if (OngoingCall.call != null) {
            OngoingCall.hangup()
        }
        progressBar.visibility = View.VISIBLE

        mainHandler.removeCallbacks(updateTextTask)
        sendBroadcast(intent)
        val mainHandlerLoading = Handler(Looper.getMainLooper())
        try {
            mainHandlerLoading.postDelayed({
                progressBar.visibility = View.GONE
                ivDeclineCall.setOnClickListener { }
                ivDeclineCall.isClickable = false

                ivOnlyDeclineCall.setOnClickListener { }
                ivOnlyDeclineCall.isClickable = false

                finishTask()
            }, 1000)
        } catch (e: Exception) {
            Log.d(tag, e.toString())
            e.printStackTrace()
        }
    }

    private fun finishTask() {
        if (Build.VERSION.SDK_INT >= Build.VERSION_CODES.LOLLIPOP) {
            finishAndRemoveTask()
        } else {
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
        val formatted = "${(secondsLeft / 60).toString().padStart(2, '0')} : ${
            (secondsLeft % 60).toString().padStart(2, '0')
        }"
        tvCallDuration.text = formatted
    }

    private fun getContactName(phoneNumber: String): String {
        if (!phoneNumber.isNullOrBlank()) {
            val contactName = getContactNameFromPhoneNumber(phoneNumber)
            if (contactName.isNullOrEmpty()) {
                return phoneNumber
            } else {
                return contactName
            }
        }
        return phoneNumber
    }

    private fun getContactNameFromPhoneNumber(phoneNumber: String): String {
        val resolver: ContentResolver = context.contentResolver
        val uri: Uri = Uri.withAppendedPath(
            ContactsContract.PhoneLookup.CONTENT_FILTER_URI,
            Uri.encode(phoneNumber)
        )
        val projection = arrayOf<String>(ContactsContract.PhoneLookup.DISPLAY_NAME)
        var contactName = ""
        val cursor: Cursor? = resolver.query(uri, projection, null, null, null)
        if (cursor != null) {
            if (cursor.moveToFirst()) {
                contactName = cursor.getString(0)
            }
            cursor.close()
        }
        return contactName
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