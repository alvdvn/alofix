package com.njv.prod

import android.annotation.SuppressLint
import android.content.ContentResolver
import android.content.Context
import android.content.Intent
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
import android.util.Log
import android.view.View
import android.view.Window
import android.view.WindowManager
import android.widget.*
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

    private lateinit var progressBar: ProgressBar

    private lateinit var number: String
    private val disposables = CompositeDisposable()
    lateinit var mainHandler: Handler
    private val tag = AppInstance.TAG
    private var isSpeaker = false
    var isAlreadyDoing = false

    protected var audioManager: AudioManager? = null

    private val updateTextTask = object : Runnable {
        override fun run() {
            minusOneSecond()
            mainHandler.postDelayed(this, 1000)
        }
    }
    private var secondsLeft: Int = 0
    private val collectTimeout : Long = 2500

    @RequiresApi(Build.VERSION_CODES.O)
    @Suppress("DEPRECATION")
    override fun onCreate(savedInstanceState: Bundle?) {
        super.onCreate(savedInstanceState)
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

        OngoingCall.state
            .filter { it == Call.STATE_DISCONNECTED }
            .delay(1, TimeUnit.SECONDS)
            .firstElement()
            .subscribe {
                Log.d(tag,"STATE_DISCONNECTED STATE_DISCONNECTED")
                if (!isAlreadyDoing) {
                    finishTask()
                }
            }
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
        OngoingCall.hangup()
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
        tvNumber.text = getContactName(number)
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
            speakerOnOff(isSpeaker)
        }
        progressBar = findViewById(R.id.progressBar)
        progressBar.max = 10
    }

    private fun bidingData() {
        tvNumber.text = getContactName(number)
        AppInstance.methodChannel.invokeMethod("clear_phone", null)
    }

    private fun speakerOnOff(isOn: Boolean) {
        Log.d(tag, "SPEAKER  is $isOn")
        if (isOn) {
            isSpeaker = false;
            closeSpeakerOn()
        } else {
            isSpeaker = true;
            openSpeakerOn();
        }
        if (isOn) {
            ivLoudSpeaker.setImageResource(R.drawable.icon_loudspeaker_on)
        } else {
            ivLoudSpeaker.setImageResource(R.drawable.icon_loudspeaker_off)
        }
    }

    private fun openSpeakerOn() {
        try {
            if (!audioManager!!.isSpeakerphoneOn) audioManager!!.isSpeakerphoneOn = true
            audioManager!!.mode = AudioManager.MODE_IN_COMMUNICATION
        } catch (e: Exception) {
            e.printStackTrace()
        }
    }

    private fun closeSpeakerOn() {
        try {
            if (audioManager != null) {
                if (audioManager!!.isSpeakerphoneOn) audioManager!!.isSpeakerphoneOn = false
                audioManager!!.mode = AudioManager.MODE_IN_COMMUNICATION
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
        progressBar.visibility = View.VISIBLE;
        OngoingCall.hangup()
        isAlreadyDoing = true
        mainHandler.removeCallbacks(updateTextTask)
        sendBroadcast(intent)
        val mainHandler = Handler(Looper.getMainLooper())
        try {
            mainHandler.postDelayed({
                val userName: String? = AppInstance.helper.getString("flutter.user_name", "")
                val calls = AppInstance.helper.getCallLogs(1);
                var mCall: CallLogStore = calls[0]
//                var id = "call&sim&" + mCall.startAt.toString() + "&" + userName
                var id = mCall.startAt.toString() + "&" + userName
                Log.d(tag, "onDestroy mCall  $mCall");

                val callLogBGJSONString: String? = AppInstance.helper.getString(Constants.AS_SYNC_IN_BG_LOGS, "")
                Log.d(tag, "onDestroy 0. string callLogBGJSONString $callLogBGJSONString")
                var callLogsBGQueList = mutableListOf<CallHistory>()
                if(callLogBGJSONString != ""){
                    callLogsBGQueList = AppInstance.helper.parseCallLogCacheJSONString(callLogBGJSONString ?: "")
                }
                Log.d(tag, "onDestroy 1. callLogsBGQueList $callLogsBGQueList")

                for (i in 0 until callLogsBGQueList.size) {
                    if (id == callLogsBGQueList[i].Id) {
                        callLogsBGQueList[i].EndedBy = 1
                        callLogsBGQueList[i].CallBy = 1
                    }
                }

                val arrayLogBG = JSONArray()
                for (callLog in callLogsBGQueList) {
                    val jsonObject = AppInstance.helper.createJsonObject(callLog)
                    arrayLogBG.put(jsonObject)
                }
                Log.d(tag, "onDestroy 2. stringToCLBGToPost $arrayLogBG")

                AppInstance.helper.putString(Constants.AS_SYNC_IN_BG_LOGS, arrayLogBG.toString())
            }, collectTimeout)
        } catch (e: Exception) {
            Log.d(tag, e.toString())
            e.printStackTrace()
        }

        val mainHandlerLoading = Handler(Looper.getMainLooper())
        try {
            mainHandlerLoading.postDelayed({
                progressBar.visibility = View.GONE
                ivDeclineCall.setOnClickListener { null }
                ivDeclineCall.isClickable = false

                ivOnlyDeclineCall.setOnClickListener { null }
                ivOnlyDeclineCall.isClickable = false

                finishTask()
                isAlreadyDoing = false
            }, 3000)
        } catch (e: Exception) {
            Log.d(tag, e.toString())
            e.printStackTrace()
        }

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

    private fun getContactName(phoneNumber: String): String {
        if (!phoneNumber.isNullOrBlank()) {
            val contactName = getContactNameFromPhoneNumber(phoneNumber)
            if (contactName == null || contactName.isEmpty()) {
                return phoneNumber
            } else {
                return contactName
            }
        }
        return phoneNumber;
    }
    private fun getContactNameFromPhoneNumber(phoneNumber: String): String? {
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