package com.njv.prod

import android.Manifest.permission.READ_CALL_LOG
import android.Manifest.permission.READ_PHONE_STATE
import android.app.ActivityManager
import android.content.Context
import android.content.Intent
import android.content.pm.PackageManager
import android.os.Build
import android.os.Build.VERSION
import android.os.Build.VERSION_CODES
import android.os.Bundle
import android.os.Handler
import android.util.Log
import androidx.annotation.NonNull
import androidx.annotation.RequiresApi
import androidx.core.app.ActivityCompat
import androidx.core.content.ContextCompat
import com.njv.prod.Constants.Companion.START_SERVICES_METHOD
import com.njv.prod.Constants.Companion.STOP_SERVICES_METHOD
import io.flutter.embedding.android.FlutterActivity
import io.flutter.embedding.engine.FlutterEngine
import io.flutter.plugin.common.MethodChannel


class MainActivity: FlutterActivity() {
    private val tag = AppInstance.TAG
    private var handler: Handler? = null
    private var runnable: Runnable? = null
    private val delayTime: Long = 3000
    private var running: Boolean = false;

    override fun onCreate(savedInstanceState: Bundle?) {
        super.onCreate(savedInstanceState)
        val helper = SharedHelper(this)
        AppInstance.helper = helper
        AppInstance.contentResolver = contentResolver;
    }

    override fun onResume() {
        super.onResume()
        running = isServiceRunning()
        Log.d(tag, "onResume Service running status: $running")
        startServiceRunnable()
    }

    private fun startServiceRunnable() {
        Log.d(tag, "tryStartService")
        Log.d(tag, "Run a program after $delayTime")
        try{
            handler = Handler()
            runnable = Runnable { program() }
            handler!!.postDelayed(runnable!!, delayTime)

        }catch( e: Exception){
            Log.d(tag, "startServiceRunnable Exception $e")
        }

    }

    private fun program() {

        val isLogin : Boolean = isLogin()
        if(!isLogin) return

        Log.d(tag, "Program executed after $delayTime")
        Log.d(tag, "Service status $running")

        if(!running ){ // The service is NOT running
            sendLostCallsNotify()

            // TODO: NOTE: Care PERMISSION outside
            if (isHavePermission() ) { // check permission handler crash
                runPhoneStateService()
            }
        }
    }

    private fun runPhoneStateService(){
//        if(!running){
//            val handler = Handler()
//            handler.postDelayed({
//                stopService()
//            }, 10000)
//        }

        Log.d(tag, "runPhoneStateService")
        val serviceIntent = Intent( context, PhoneStateService::class.java)
        if (VERSION.SDK_INT >= VERSION_CODES.O) {
            context.startForegroundService(serviceIntent)
            Log.d(tag,"Start Foreground Service")
        } else {
            context.startService(serviceIntent)
            Log.d(tag,"Start Service")
        }
    }

    override fun onDestroy() {
        super.onDestroy()
        Log.d(tag, "onDestroy")
    }

    private fun askRunTimePermission(){
        ActivityCompat.requestPermissions(
            this,
            arrayOf(READ_PHONE_STATE,READ_CALL_LOG),
            1234
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

    private fun askPermisionAgain() {
        ActivityCompat.requestPermissions(
            this,
            arrayOf(READ_PHONE_STATE, READ_CALL_LOG),
            123
        )
    }

    private fun stopService(){
        // Stop Phone Service via AppSharePreferences
        Log.d(tag, "Stop Foreground Service")
        val serviceIntent = Intent( context,PhoneStateService::class.java)
        stopService(serviceIntent)
    }

    private fun sendLostCallsNotify() {
        Log.d(tag,"sendLostCallsNotify")
        val helper = SharedHelper(this)
        val lastDestroyTime = helper.getLong(AppInstance.DESTROY_TIME_STR, System.currentTimeMillis())
        val lastSyncId = helper.getInt(AppInstance.LAST_SYNC_ID_STR, 0)

        val calls   = helper.getCallLogsById(lastSyncId) ;
        if(lastSyncId != 0 && calls.isNotEmpty() ){
            val lastSyncTime = calls[0].startAt
            val methodChannel: MethodChannel = AppInstance.methodChannel
            val data = mapOf(
                "lastDestroyTime" to lastDestroyTime,
                "lastSyncId" to lastSyncId,
                "lastSyncTimeOfID" to lastSyncTime )
            methodChannel.invokeMethod("sendLostCallsNotify", data)
            Log.d(tag, "sendLostCallsNotify lastSyncTime $lastSyncTime")
        }
    }

    private fun isLogin(): Boolean{
        return !AppInstance.helper.getString("flutter.access_token","").equals("")
    }

    private fun isServiceRunning(): Boolean {
        val activityManager: ActivityManager =
            this.getSystemService(Context.ACTIVITY_SERVICE) as ActivityManager
        val runningServices: List<ActivityManager.RunningServiceInfo> =
            activityManager.getRunningServices(Int.MAX_VALUE)
        for (serviceInfo in runningServices) {
            if (serviceInfo.service.className ==  PhoneStateService::class.java.name) {
                // The service is running
                return true
            }
        }
        return false
    }

    override fun configureFlutterEngine(@NonNull flutterEngine: FlutterEngine) {
        super.configureFlutterEngine(flutterEngine)

        AppInstance.methodChannel = MethodChannel(flutterEngine.dartExecutor.binaryMessenger, Constants.FLUTTER_ANDROID_CHANNEL)
        AppInstance.methodChannel.setMethodCallHandler {
            // This method is invoked on the main thread.
                call, result ->

            when (call.method) {

                START_SERVICES_METHOD ->{
                    startServiceRunnable()
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
