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
import org.json.JSONArray
import java.util.concurrent.TimeUnit

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
    private var isOpenKeyboard = false
    private var userId: String? = ""
    private var audioManager: AudioManager? = null
    private var audioState: Int = CallAudioState.ROUTE_EARPIECE
    private lateinit var buttonMap: Map<Char, Button?>
    private lateinit var tvKeypadDialog: EditText
    private lateinit var ivKeyboard: ImageView
    private lateinit var llKeyboard: LinearLayout
    private lateinit var rlKeyboard: RelativeLayout
    private lateinit var tvKeyboard: TextView


    var keypadDialogTextViewText = ""

    private val updateTextTask = object : Runnable {
        override fun run() {
            minusOneSecond()
            mainHandler.postDelayed(this, 1000)
        }
    }
    private var secondsLeft: Int = 0
    private val collectTimeout: Long = 3000

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

//        OngoingCall.state
//            .filter { it.state == Call.STATE_DISCONNECTED }
//            .delay(1, TimeUnit.SECONDS)
//            .firstElement()
//            .subscribe {
//                Log.d(tag, "STATE_DISCONNECTED LISTEN")
//                if (!isAlreadyDoing) {
//                    Log.d(tag, "STATE_DISCONNECTED DONE")
//                    runOnUiThread {
//                        // call the invalidate()
//                        onDeclineClick()
//                    }
//                }
//
//            }
//            .addTo(disposables)
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
    }


    override fun onDestroy() {
        Log.d(tag, "onDestroy CallActivity")
        val callLogInstance = CallLogSingleton.instance()
        if (callLogInstance != null) {
//            Log.d(tag, "end by rider on stop")
            //todo : vuốt kill app
            callLogInstance.endedBy = 2
            callLogInstance.endedAt = System.currentTimeMillis()
            CallLogSingleton.sendDataToFlutter()
        }
        endCall()
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

                val callLogInstance = CallLogSingleton.init()
                callLogInstance.id = "$currentBySeconds&$number"
                callLogInstance.type = 2
                callLogInstance.startAt = current
                callLogInstance.phoneNumber = number
                callLogInstance.syncBy = 1
                callLogInstance.callBy = 1
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
                val callLogInstance = CallLogSingleton.init()
                callLogInstance.id = "$currentBySeconds&${number}"
                callLogInstance.type = 1
                callLogInstance.startAt = current
                callLogInstance.phoneNumber = number
                callLogInstance.syncBy = 1
                callLogInstance.callBy = 1
            }

//            Call.REJECT_REASON_DECLINED -> {
//                Log.d(tag, "LOG: REJECT_REASON_DECLINED")
//            }

//            Call.STATE_CONNECTING -> {
//                Log.d(tag, "LOG: STATE_CONNECTING $current")
//            }

            Call.STATE_DISCONNECTED -> {
                Log.d(tag, "LOG: STATE_DISCONNECTED")
                if (isOpenKeyboard) {
                    keyboardOnOff()
                }
                endCall()

                val callLogInstance = CallLogSingleton.instance()
                if (callLogInstance != null) {
                    callLogInstance.endedAt = current
                    CallLogSingleton.sendDataToFlutter()
                }

            }

            else -> {
                Log.d(tag, "Number is not between 1 and 3")
            }
        }
    }

    private fun initializeButtons() {
        buttonMap = mapOf<Char, Button>(
            '0' to findViewById(R.id.btn0),
            '1' to findViewById(R.id.btn01),
            '2' to findViewById(R.id.btn02),
            '3' to findViewById(R.id.btn03),
            '4' to findViewById(R.id.btn04),
            '5' to findViewById(R.id.btn05),
            '6' to findViewById(R.id.btn06),
            '7' to findViewById(R.id.btn07),
            '8' to findViewById(R.id.btn08),
            '9' to findViewById(R.id.btn09),
            '*' to findViewById(R.id.btnKyTuSao),
            '#' to findViewById(R.id.btnKyTuThang)
        )
    }

    @RequiresApi(Build.VERSION_CODES.O)
    private fun initView() {
        initializeButtons()
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

        tvKeypadDialog = findViewById(R.id.keypadDialogEditText)
        ivKeyboard = findViewById(R.id.ivKeyboard)

        llKeyboard = findViewById(R.id.llKeyboard)
        rlKeyboard = findViewById(R.id.rlKeyboard)
        tvKeyboard = findViewById(R.id.tvKeyboard)

        rlKeyboard.setOnClickListener {
            keyboardOnOff()
        }

        buttonMap.forEach { (key, button) ->
            // Do something with the key and button
            button!!.setOnClickListener { v: View? ->
                OngoingCall.playDtmfTone(key)
                keypadDialogTextViewText = tvKeypadDialog.text.toString()
                tvKeypadDialog.setText(keypadDialogTextViewText + key)
                tvKeypadDialog.setSelection(tvKeypadDialog.text.length)
            }
        }
    }

//    private fun bidingData() {
//        tvNumber.text = getContactName(number)
//    }

    private fun keyboardOnOff() {
        Log.d(tag, "KeyBoard  is $isOpenKeyboard")
        if (isOpenKeyboard) {
            isOpenKeyboard = false
            ivAvatar.visibility = View.VISIBLE
            llKeyboard.visibility = View.GONE
            tvNameCaller.visibility = View.VISIBLE
            tvKeyboard.text = "Ẩn"
            ivKeyboard.setImageResource(R.drawable.ic_keyborad_normal)
        } else {
            isOpenKeyboard = true
            ivAvatar.visibility = View.GONE
            llKeyboard.visibility = View.VISIBLE
            tvNameCaller.visibility = View.GONE
            tvKeyboard.text = "Bàn phím"
            ivKeyboard.setImageResource(R.drawable.ic_keyborad_enable)
        }
    }

    private fun bidingData() {
        tvNumber.text = getContactName(number)
        AppInstance.methodChannel.invokeMethod("clear_phone", null)
    }

    @RequiresApi(Build.VERSION_CODES.O)
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
        if (isOpenKeyboard) {
            keyboardOnOff()
        }
        val callLogInstance = CallLogSingleton.instance()
        if (callLogInstance != null) {
            callLogInstance.endedBy = 1
            callLogInstance.endedAt = System.currentTimeMillis()
        }
        CallLogSingleton.sendDataToFlutter()

        endCall()
    }

    private fun endCall() {

        OngoingCall.hangup()

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
        finishAndRemoveTask()
    }

    @RequiresApi(Build.VERSION_CODES.O)
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
        @RequiresApi(Build.VERSION_CODES.O)
        fun start(context: Context, call: Call) {
            Intent(context, CallActivity::class.java)
                .setFlags(Intent.FLAG_ACTIVITY_NEW_TASK)
                .setData(call.details.handle)
                .let(context::startActivity)
        }
    }
}