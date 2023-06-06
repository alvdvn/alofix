// ignore_for_file: depend_on_referenced_packages
import 'dart:async';
import 'package:base_project/common/utils/global_app.dart';
import 'package:base_project/screens/call_log_screen/call_log_controller.dart';
import 'package:base_project/services/local/app_share.dart';
import 'package:flutter/cupertino.dart';
import 'package:flutter_background_service_android/flutter_background_service_android.dart';
import 'package:flutter_background_service/flutter_background_service.dart';
import 'package:flutter_local_notifications/flutter_local_notifications.dart';
import 'package:get/get.dart';
import 'package:permission_handler/permission_handler.dart';

class HomeController extends GetxController {
  Future<void> initService() async {
    await initializeService();
    FlutterBackgroundService().invoke("setAsForeground");
  }
}

Future<void> initializeService() async {
  final service = FlutterBackgroundService();

  const AndroidNotificationChannel channel = AndroidNotificationChannel(
    'my_foreground',
    'MY FOREGROUND SERVICE',
    description: 'This channel is used for important notifications.',
    importance: Importance.low,
  );

  final FlutterLocalNotificationsPlugin flutterLocalNotificationsPlugin =
      FlutterLocalNotificationsPlugin();
  await flutterLocalNotificationsPlugin
      .resolvePlatformSpecificImplementation<
          AndroidFlutterLocalNotificationsPlugin>()
      ?.createNotificationChannel(channel);
  await service.configure(
    androidConfiguration: AndroidConfiguration(
        onStart: onStart,
        autoStart: true,
        isForegroundMode: true,
        notificationChannelId: 'my_foreground',
        initialNotificationTitle: 'Alo Ninja van',
        initialNotificationContent: 'Bắt đầu đồng bộ lịch sử cuộc gọi',
        foregroundServiceNotificationId: 888),
    iosConfiguration: IosConfiguration(),
  );

  service.startService();
}

@pragma('vm:entry-point')
void onStart(ServiceInstance service) async {
  CallLogController callLogController = Get.put(CallLogController());
  final FlutterLocalNotificationsPlugin flutterLocalNotificationsPlugin =
      FlutterLocalNotificationsPlugin();
  if (service is AndroidServiceInstance) {
    service.on('setAsForeground').listen((event) {
      service.setAsForegroundService();
    });

    service.on('setAsBackground').listen((event) {
      service.setAsBackgroundService();
    });
  }
  Timer.periodic(const Duration(minutes: 5), (timer) async {
    String value = await AppShared().getLastDateCalLogSync();
    print('TA LastDateCalLogSync Home ${value}');
    int lastCallLogSync = value == 'null' ? 0 : int.parse(value);
    final dateString = lastCallLogSync == 0 ? DateTime.now() : DateTime.fromMillisecondsSinceEpoch(lastCallLogSync);
    flutterLocalNotificationsPlugin.show(
      888,
      'Alo Ninja',
      'Đã đồng bộ lịch sử cuộc gọi lúc ${ddMMYYYYTimeSlashFormat.format(dateString)}',
      const NotificationDetails(
        android: AndroidNotificationDetails(
            'my_foreground', 'MY FOREGROUND SERVICE',
            icon: 'icon_notification', ongoing: true),
      ),
    );
    try {
      await callLogController.getCallLog();
    } catch (e) {
      await callLogController.getCallLog();
    }
  });
}
