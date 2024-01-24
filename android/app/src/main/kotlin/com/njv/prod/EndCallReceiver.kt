package com.njv.prod
import android.content.BroadcastReceiver
import android.content.Context
import android.content.Intent
import android.util.Log

class EndCallReceiver : BroadcastReceiver() {

    override fun onReceive(context: Context?, intent: Intent?) {
        if (intent?.action == "com.njv.prod.END_CALL") {
            Log.d("EndCallReceiver", "Received end call broadcast")

            // Thực hiện xử lý khi cuộc gọi kết thúc ở đây
            // Ví dụ: Khởi động một Activity, hiển thị thông báo, hoặc thực hiện các hành động cần thiết
        }
    }
}
