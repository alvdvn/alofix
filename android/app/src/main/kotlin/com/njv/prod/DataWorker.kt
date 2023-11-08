package com.njv.prod

import android.content.Context
import android.util.Log
import androidx.work.PeriodicWorkRequest
import androidx.work.WorkManager
import androidx.work.Worker
import androidx.work.WorkerParameters
import org.json.JSONArray
import java.net.HttpURLConnection
import java.net.URL
import java.util.concurrent.TimeUnit

class DataWorker(appContext: Context, workerParams: WorkerParameters) :
    Worker(appContext, workerParams) {
    override fun doWork(): Result {
        Log.d(tag, "MyWorker doWork retry send error data")
        val callLogJSONString: String? = AppInstance.helper.getString(Constants.AS_CALL_LOGS_STR, "")
        var callLogsQueList = mutableListOf<CallHistory>()
        if(callLogJSONString != ""){

            callLogsQueList = AppInstance.helper.parseCallLogCacheJSONString(callLogJSONString ?: "")
            if(callLogsQueList.isNotEmpty()){
                val jsonArrayTemp = JSONArray()
                for (callLog in callLogsQueList) {
                    val jsonObject = AppInstance.helper.createJsonObject(callLog)
                    jsonArrayTemp.put(jsonObject)
                }
                val responseCode  = doPostData(jsonArrayTemp.toString())
                return if (responseCode == HttpURLConnection.HTTP_OK) {
                    // CLEAR DATA CACHE
                    AppInstance.helper.putString(Constants.AS_CALL_LOGS_STR,"")
                    Result.success()
                }else{
                    Result.retry()
                }
            }
        }
        return Result.retry()
    }

    companion object {
        // TODO: move it to configuration
        private const val tag : String = AppInstance.TAG
        private const val DEFAULT_TOKEN  = "aeyJhbGciOiJIUzI1NiIsInR5cCI6IkpXVCJ9.eyJFY3JtLlVzZXIuSWQiOiIxNjQwIiwiRWNybS5Vc2VyLkZ1bGxOYW1lIjoiS2hhaSB0ZXN0IiwiQXNwTmV0LklkZW50aXR5LlNlY3VyaXR5U3RhbXAiOlsiTkpONzQ1RVpIVU03VFlUWElOR1dLTUhYNDVFTkxKWlciLCJOSk43NDVFWkhVTTdUWVRYSU5HV0tNSFg0NUVOTEpaVyJdLCJ1bmlxdWVfbmFtZSI6IjA5MTgwMzIwMDAiLCJzdWIiOiIwOTE4MDMyMDAwIiwianRpIjoiOWZkZmMxOWMtNmEwYS00Y2Q5LThjN2YtMjk5N2NiMWJiMDcyIiwiaWF0IjoxNjk0MTM2ODY4LCJodHRwOi8vc2NoZW1hcy54bWxzb2FwLm9yZy93cy8yMDA1LzA1L2lkZW50aXR5L2NsYWltcy9uYW1laWRlbnRpZmllciI6IjE2NDAiLCJodHRwOi8vc2NoZW1hcy54bWxzb2FwLm9yZy93cy8yMDA1LzA1L2lkZW50aXR5L2NsYWltcy9uYW1lIjoiMDkxODAzMjAwMCIsImh0dHA6Ly9zY2hlbWFzLm1pY3Jvc29mdC5jb20vd3MvMjAwOC8wNi9pZGVudGl0eS9jbGFpbXMvcm9sZSI6IlJpZGVyIiwiUnNDYXAiOiJSZWNvcmQuU2VsZk1hbmFnZSIsIm5iZiI6MTY5NDEzNjg2OCwiZXhwIjoxNjk2NzI4ODY4LCJpc3MiOiJSUyIsImF1ZCI6IlJTIn0.JB5YzYli7HGwieV3KCk1Frr0aQN5jOEW4D_2YiFljdQ"

        fun startDataHandler(context: Context, name: String, ) {
            val repeatInterval = 5L
            val repeatIntervalTimeUnit = TimeUnit.MINUTES
            val workRequest = PeriodicWorkRequest.Builder(
                DataWorker::class.java,
                repeatInterval, repeatIntervalTimeUnit
            ).build()
            WorkManager.getInstance(context).enqueue(workRequest)
        }

        fun doPostData(postData: String?): Any {
            val url = URL(AppInstance.helper.getUrl() + "api/calllogs")
            Log.d(tag, "doPostData $url")
            val connection = url.openConnection() as HttpURLConnection
            connection.requestMethod = "POST"
            connection.setRequestProperty("Content-Type", "application/json")
            connection.setRequestProperty("x-version", AppInstance.helper.getVersionStr())
            val token = AppInstance.helper.getString(
                "flutter.access_token",
                DEFAULT_TOKEN
            )
            connection.setRequestProperty("Authorization", "Bearer $token")
            connection.doOutput = true
            val outputStream = connection.outputStream
            outputStream.write(postData?.toByteArray(charset("UTF-8")))
            outputStream.close()

            if (connection.responseCode != HttpURLConnection.HTTP_OK) {
                val errorStream = connection.errorStream
                if (errorStream != null) {
                    val errorResponse = errorStream.bufferedReader().readText()
                    println("Error response from server: $errorResponse")
                }
            }
            return connection.responseCode
        }
    }
}