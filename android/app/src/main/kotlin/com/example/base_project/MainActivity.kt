package com.example.base_project

import android.Manifest.permission.READ_CALL_LOG
import android.Manifest.permission.READ_PHONE_STATE
import android.app.ActivityManager
import android.content.Context
import android.content.Intent
import android.os.Build.VERSION
import android.os.Build.VERSION_CODES
import android.os.Bundle
import android.os.Handler
import android.util.Log
import androidx.annotation.NonNull
import io.flutter.embedding.android.FlutterActivity
import io.flutter.embedding.engine.FlutterEngine
import io.flutter.plugin.common.MethodChannel
import android.content.pm.PackageManager
import android.os.Build
import android.os.Looper
import androidx.annotation.RequiresApi
import androidx.core.app.ActivityCompat
import androidx.core.content.ContextCompat


class MainActivity: FlutterActivity() {
    companion object {
        const val SERVICE_START_DELAY_NUM : Long = 1000
        const val DELAY_NUM : Long = 500

        const val FLUTTER_ANDROID_CHANNEL = "NJN_ANDROID_CHANNEL_MESSAGES"
        const val START_SERVICES_METHOD = "START_SERVICES_METHOD"
        const val STOP_SERVICES_METHOD = "STOP_SERVICES_METHOD"
        const val SERVICES_METHOD = "SERVICES_METHOD"

    }

    override fun onCreate(savedInstanceState: Bundle?) {
        super.onCreate(savedInstanceState)

        val sharedPreferencesHelper = SharedPreferencesHelper(this)
        AppInstance.preferencesHelper = sharedPreferencesHelper
    }

    override fun onResume() {
        super.onResume()
        val handler = Handler()
        handler.postDelayed({
            if(isHavePermision()){
                startService()
            }else{
                askPermission()
            }
        }, 1000)
    }

    val PERMISSION_REQUEST_READ_PHONE_STATE: Int = 12
    private fun askPermission() {
        ActivityCompat.requestPermissions(
            this,
            arrayOf(READ_PHONE_STATE,READ_CALL_LOG),
            PERMISSION_REQUEST_READ_PHONE_STATE
        )
    }

    private fun isHavePermision(): Boolean {
        if (ContextCompat.checkSelfPermission(this, READ_PHONE_STATE)
            == PackageManager.PERMISSION_GRANTED &&
            ContextCompat.checkSelfPermission(this, READ_CALL_LOG)
            == PackageManager.PERMISSION_GRANTED
        ) {
            // Permission is granted
            return true
            Log.d("Permission", "READ_PHONE_STATE permission is granted")
        }
        return false
    }

    private fun stopService(){
        val isMyServiceRunning = isServiceRunning(this, PhoneStateService::class.java)
        if (isMyServiceRunning) {
            // Stop Phone Service via AppSharePreferences
            Log.d("Flutter Android","Stop Foreground Service")
            val serviceIntent = Intent( context,PhoneStateService::class.java)
            stopService(serviceIntent)
        } else {
            Log.d("Flutter Android","Flutter Android was Stopped")
        }
    }

    private fun startService(){
        val isMyServiceRunning = isServiceRunning(this, PhoneStateService::class.java)
        if(!isMyServiceRunning && isLogin()){
            val handler = Handler()
            handler.postDelayed({
                val serviceIntent = Intent( context,PhoneStateService::class.java)
                if (VERSION.SDK_INT >= VERSION_CODES.O) {
                    context.startForegroundService(serviceIntent)
                    Log.d("Flutter Android","Start Foreground Service")
                } else {
                    context.startService(serviceIntent)
                    Log.d("Flutter Android","Start Service")
                }
            }, DELAY_NUM)
        }
    }

    fun isLogin(): Boolean{
        return !AppInstance.preferencesHelper.getString("flutter.access_token","").equals("")
    }

    override fun onPause(){
        super.onPause()
        Log.d("Flutter Android","onPause")
    }

    override fun onDestroy() {
        super.onDestroy()
        Log.d("Flutter Android","onDestroy")
    }

    @RequiresApi(Build.VERSION_CODES.M)
    override fun onRequestPermissionsResult(
        requestCode: Int,
        permissions: Array<String>,
        grantResults: IntArray
    ) {
        if (requestCode == PERMISSION_REQUEST_READ_PHONE_STATE) {
            if (grantResults.isNotEmpty() && grantResults[0] == PackageManager.PERMISSION_GRANTED) {
                // Permission was granted
                Log.d("Permission", "READ_PHONE_STATE permission granted by the user")
                startService()
            } else {
                // Permission denied
                Log.d("Permission", "READ_PHONE_STATE permission denied by the user")
            }
        }

        super.onRequestPermissionsResult(requestCode, permissions, grantResults)
    }

    private fun isServiceRunning(context: Context, serviceClass: Class<*>): Boolean {
        val activityManager: ActivityManager =
            context.getSystemService(Context.ACTIVITY_SERVICE) as ActivityManager
        if (activityManager != null) {
            val runningServices: List<ActivityManager.RunningServiceInfo> =
                activityManager.getRunningServices(Int.MAX_VALUE)
            for (serviceInfo in runningServices) {
                if (serviceInfo.service.getClassName() == serviceClass.getName()) {
                    // The service is running
                    return true
                }
            }
        }
        // The service is not running
        return false
    }

    override fun configureFlutterEngine(@NonNull flutterEngine: FlutterEngine) {
        super.configureFlutterEngine(flutterEngine)
        MethodChannel(flutterEngine.dartExecutor.binaryMessenger, FLUTTER_ANDROID_CHANNEL).setMethodCallHandler {
            // This method is invoked on the main thread.
                call, result ->

            when (call.method) {
                SERVICES_METHOD -> {
                    startService()
                }

                START_SERVICES_METHOD ->{
                    val mainHandler = Handler(Looper.getMainLooper())
                    try {
                        mainHandler.postDelayed({
                            // New Map
                            startService()
                            Log.d("Flutter Android", "START_SERVICES_METHOD")

                        }, SERVICE_START_DELAY_NUM)
                    }catch (e : Exception){ }
                }

                STOP_SERVICES_METHOD ->{
                    stopService()
                    Log.d("Flutter Android", "STOP_SERVICES_METHOD")
                }

                else -> { // Note the block
                    result.notImplemented()
                }
            }
        }
    }
}
