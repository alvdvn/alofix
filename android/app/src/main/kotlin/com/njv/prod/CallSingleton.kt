package com.njv.prod

import android.content.Context
import android.util.Log
import androidx.room.Room
import com.google.gson.Gson
import java.util.concurrent.Executors

class CallLogSingleton {
    companion object {
        private var instance: CallLogData? = null
        lateinit var context: Context

        fun instance(): CallLogData? {
            return instance
        }

        fun init(appContext: Context) {
            context = appContext
        }

        fun init(): CallLogData {
            if (instance == null) {
                instance = CallLogData()
            }
            return instance as CallLogData
        }

        fun sendDataToFlutter(sendBy: String) {
            if (instance == null) return
            val json = Gson().toJson(instance)
            val executor = Executors.newSingleThreadExecutor()
            executor.execute {
                val db = Room.databaseBuilder(
                    context.applicationContext,
                    AppDatabase::class.java,
                    "app_database.db"
                ).addMigrations(migration1to2) // If manua
                    .build()
                db.jobDao().insertAll(JobQueue(payload = json, type = 1))
                Log.d("alo2_", "sendDataToFlutter $sendBy $instance")

            }
            val handler = android.os.Handler()
            handler.postDelayed({
                AppInstance.methodChannel.invokeMethod(
                    "process_call_log", null
                )
            }, 500)


            instance = null
        }
    }
}