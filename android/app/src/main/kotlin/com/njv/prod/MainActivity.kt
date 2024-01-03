package com.njv.prod

import android.Manifest.permission.READ_CALL_LOG
import android.Manifest.permission.READ_PHONE_STATE
import android.annotation.SuppressLint
import android.app.ActivityManager
import android.app.role.RoleManager
import android.content.Context
import android.content.Intent
import android.content.pm.PackageManager
import android.net.Uri
import android.os.Build
import android.os.Build.VERSION
import android.os.Build.VERSION_CODES
import android.os.Bundle
import android.os.Handler
import android.telecom.PhoneAccountHandle
import android.telecom.TelecomManager
import android.util.Log
import android.widget.Toast
import androidx.annotation.NonNull
import androidx.annotation.RequiresApi
import androidx.core.app.ActivityCompat
import androidx.core.content.ContextCompat
import com.google.gson.Gson
import com.njv.prod.Constants.Companion.CALL_OUT_COMING_CHANNEL
import com.njv.prod.Constants.Companion.GET_SIM_INFO
import com.njv.prod.Constants.Companion.SET_DEFAULT_DIALER
import com.njv.prod.Constants.Companion.START_SERVICES_METHOD
import com.njv.prod.Constants.Companion.STOP_SERVICES_METHOD
import io.flutter.embedding.android.FlutterActivity
import io.flutter.embedding.engine.FlutterEngine
import io.flutter.plugin.common.MethodChannel
import android.telephony.SubscriptionManager


class MainActivity : FlutterActivity() {

    private val tag = AppInstance.TAG
    private var handler: Handler? = null
    private var runnable: Runnable? = null
    private val delayTime: Long = 3000
    private var running: Boolean = false
    private lateinit var telecomManager: TelecomManager

    @RequiresApi(VERSION_CODES.M)
    override fun onCreate(savedInstanceState: Bundle?) {
        super.onCreate(savedInstanceState)
        telecomManager = (getSystemService(Context.TELECOM_SERVICE) as? TelecomManager)!!
        val helper = SharedHelper(this)
        AppInstance.helper = helper
        AppInstance.contentResolver = contentResolver

        val phone = intent?.data?.schemeSpecificPart
        if (phone?.isNotEmpty() == true) {
            makeCall(phone)
        }
        Log.d("COMING CALL", "$phone")
    }

    override fun onRequestPermissionsResult(
        requestCode: Int,
        permissions: Array<out String>,
        grantResults: IntArray
    ) {
        super.onRequestPermissionsResult(requestCode, permissions, grantResults)
    }

    @RequiresApi(VERSION_CODES.M)
    override fun onResume() {
        super.onResume()
        val helper = SharedHelper(this)
        AppInstance.helper = helper
        running = isServiceRunning()
        Log.d(tag, "onResume Service running status: $running")
        startServiceRunnable()
    }

    @RequiresApi(VERSION_CODES.M)
    private fun startServiceRunnable() {
        Log.d(tag, "tryStartService")
        Log.d(tag, "Run a program after $delayTime")
        try {
            handler = Handler()
            runnable = Runnable { program() }
            handler!!.postDelayed(runnable!!, delayTime)

        } catch (e: Exception) {
            Log.d(tag, "startServiceRunnable Exception $e")
        }
    }

    @RequiresApi(VERSION_CODES.M)
    private fun program() {
        val isLogin: Boolean = isLogin()
        if (!isLogin) return
//        offerReplacingDefaultDialer();

        Log.d(tag, "Program executed after $delayTime")
        Log.d(tag, "Service status $running")
        if (!running) { // The service is NOT running
            // TODO: NOTE: Care PERMISSION outside
            if (isHavePermission()) { // check permission handler crash
                runPhoneStateService()
            }
        }
    }

    private fun runPhoneStateService() {
        Log.d(tag, "runPhoneStateService")
        val serviceIntent = Intent(context, PhoneStateService::class.java)
        if (VERSION.SDK_INT >= VERSION_CODES.O) {
            context.startForegroundService(serviceIntent)
            Log.d(tag, "Start Foreground Service")
        } else {
            context.startService(serviceIntent)
            Log.d(tag, "Start Service")
        }
    }

    override fun onDestroy() {
        super.onDestroy()
        Log.d(tag, "onDestroy")
    }

    @RequiresApi(VERSION_CODES.M)
    private fun offerReplacingDefaultDialer() {
        if (isHavePermission()) {
            if (VERSION.SDK_INT >= VERSION_CODES.Q) {
                openDefaultDialerAndroid10AndAbove()
            } else {
                openDefaultDialerBelowAndroid10()
            }
        } else {
            askRunTimePermission()
        }
    }

    @SuppressLint("NewApi", "WrongConstant")
    private fun openDefaultDialerAndroid10AndAbove() {
        val roleManager = getSystemService(Context.ROLE_SERVICE) as? RoleManager
        if (roleManager != null && roleManager.isRoleHeld(RoleManager.ROLE_DIALER)) {
            Log.d(tag, "Is Default")
            // Your app is already the default dialer
        } else {
            Log.d(tag, "Not Default")
            // Your app is not the default dialer, open the settings to prompt the user to set your app as default
            val rm = getSystemService(Context.ROLE_SERVICE) as RoleManager
            if (!rm.isRoleHeld(RoleManager.ROLE_DIALER)) {
                val intent = rm.createRequestRoleIntent(RoleManager.ROLE_DIALER)
                startActivityForResult(intent, 1)
            }
        }
    }

    @RequiresApi(VERSION_CODES.M)
    private fun openDefaultDialerBelowAndroid10() {
        if (telecomManager.defaultDialerPackage != packageName) {
            // Your app is not the default dialer, open the settings to prompt the user to set your app as default
            val intent = Intent(TelecomManager.ACTION_CHANGE_DEFAULT_DIALER)
            intent.putExtra(TelecomManager.EXTRA_CHANGE_DEFAULT_DIALER_PACKAGE_NAME, packageName)
            startActivity(intent)
        } else {
            // Your app is already the default dialer
        }
    }

    private fun askRunTimePermission() {
        ActivityCompat.requestPermissions(
            this,
            arrayOf(READ_PHONE_STATE, READ_CALL_LOG),
            REQUEST_PERMISSION
        )
    }

    private fun isHavePermission(): Boolean {
        if (ContextCompat.checkSelfPermission(this, READ_PHONE_STATE)
            == PackageManager.PERMISSION_GRANTED &&
            ContextCompat.checkSelfPermission(this, READ_CALL_LOG)
            == PackageManager.PERMISSION_GRANTED
        ) {
            // Permission is granted
            return true
        }

        return false
    }

    private fun stopService() {
        // Stop Phone Service via AppSharePreferences
        Log.d(tag, "Stop Foreground Service")
        val serviceIntent = Intent(context, PhoneStateService::class.java)
        stopService(serviceIntent)
    }


    private fun isLogin(): Boolean {
        return !AppInstance.helper.getString("flutter.access_token", "").equals("")
    }

    private fun isServiceRunning(): Boolean {
        val activityManager: ActivityManager =
            this.getSystemService(Context.ACTIVITY_SERVICE) as ActivityManager
        val runningServices: List<ActivityManager.RunningServiceInfo> =
            activityManager.getRunningServices(Int.MAX_VALUE)
        for (serviceInfo in runningServices) {
            if (serviceInfo.service.className == PhoneStateService::class.java.name) {
                // The service is running
                return true
            }
        }
        return false
    }

    private fun getListSIM(): List<SimInfo> {
        val lst: List<SimInfo> = emptyList()

        if (ContextCompat.checkSelfPermission(this, READ_PHONE_STATE)
            == PackageManager.PERMISSION_GRANTED
        ) {
            val subscriptionManager = activity.getSystemService(
                TELEPHONY_SUBSCRIPTION_SERVICE
            ) as SubscriptionManager
            val subscriptions = subscriptionManager.activeSubscriptionInfoList
            subscriptions.map { el -> SimInfo(el.number, el.simSlotIndex) }
        }
        return lst
    }

    @RequiresApi(VERSION_CODES.M)
    override fun configureFlutterEngine(@NonNull flutterEngine: FlutterEngine) {
        super.configureFlutterEngine(flutterEngine)

        AppInstance.methodChannel = MethodChannel(
            flutterEngine.dartExecutor.binaryMessenger,
            Constants.FLUTTER_ANDROID_CHANNEL
        )
        AppInstance.methodChannel.setMethodCallHandler { call, result ->
            // This method is invoked on the main thread.
            Log.d("Flutter Android", "Method ${call.method}")
            when (call.method) {

                START_SERVICES_METHOD -> {
                    Log.d("Flutter Android", "START_SERVICES_METHOD")
                    startServiceRunnable()
                }

                STOP_SERVICES_METHOD -> {
                    Log.d("Flutter Android", "STOP_SERVICES_METHOD")
                    stopService()
                }

                CALL_OUT_COMING_CHANNEL -> {
                    try {
                        Log.d("CALL_OUT_COMING_CHANNEL", "CALL_OUT_COMING_CHANNEL")
                        val phone = call.argument<String>("phone_out")
                        Log.d("CALL_OUT_COMING_CHANNEL", "$phone")
                        makeCall(phone)
                    } catch (e: Exception) {
                        Log.d("Flutter Error", "$e")
                    }
                    result.success(true)
                }

                SET_DEFAULT_DIALER -> {
                    offerReplacingDefaultDialer()
                }

                GET_SIM_INFO -> {
                    val lstSIM = getListSIM()
                    result.success(Gson().toJson(lstSIM))
                }

                else -> { // Note the block
                    result.notImplemented()
                }
            }
        }
    }

    @SuppressLint("MissingPermission")
    @RequiresApi(VERSION_CODES.M)
    private fun makeCall(phone: String?) {
        if (phone.isNullOrEmpty()) {
            Toast.makeText(this, "Phone number error!", Toast.LENGTH_SHORT).show()
            return
        }
        @SuppressLint("ServiceCast")
        val telecomManager: TelecomManager =
            getSystemService(Context.TELECOM_SERVICE) as TelecomManager

        if (ActivityCompat.checkSelfPermission(
                this,
                android.Manifest.permission.CALL_PHONE
            ) !== PackageManager.PERMISSION_GRANTED
        ) {
            Toast.makeText(this, "Please allow permission", Toast.LENGTH_SHORT).show()
            return
        }

        val extras = Bundle()
        extras.putBoolean(TelecomManager.EXTRA_START_CALL_WITH_SPEAKERPHONE, false)

        val simSlotIndex: Int =
            AppInstance.helper.getInt(Constants.valueSimChoose, -1)

        val list: List<PhoneAccountHandle> = telecomManager.callCapablePhoneAccounts
        val uri: Uri = Uri.fromParts("tel", phone, null)
        if (list.count() < 2) {
            telecomManager.placeCall(uri, extras)
            return
        }

        if (simSlotIndex == -1) {
            val alert = ViewDialog()
            alert.showDialog(activity, { index ->
                extras.putParcelable(
                    TelecomManager.EXTRA_PHONE_ACCOUNT_HANDLE,
                    list[index]
                )
                telecomManager.placeCall(uri, extras)
            })
        } else {
            extras.putParcelable(
                TelecomManager.EXTRA_PHONE_ACCOUNT_HANDLE,
                list[simSlotIndex]
            )
            telecomManager.placeCall(uri, extras)
        }
    }

    companion object {
        const val REQUEST_PERMISSION = 0
    }
}
