// ignore_for_file: depend_on_referenced_packages
import 'dart:async';
import 'dart:convert';
import 'package:app_settings/app_settings.dart';
import 'package:base_project/common/utils/global_app.dart';
import 'package:base_project/screens/call_log_screen/call_log_controller.dart';
import 'package:base_project/services/local/app_share.dart';
import 'package:call_log/call_log.dart';
import 'package:flutter/cupertino.dart';
import 'package:flutter/services.dart';
import 'package:flutter_background_service_android/flutter_background_service_android.dart';
import 'package:flutter_background_service/flutter_background_service.dart';
import 'package:flutter_local_notifications/flutter_local_notifications.dart';
import 'package:get/get.dart';
import 'package:intl/intl.dart';
import 'package:permission_handler/permission_handler.dart';

import '../../common/utils/alert_dialog_utils.dart';
import '../../services/remote/api_provider.dart';
import '../../services/responsitory/history_repository.dart';
import '../account/account_controller.dart';
import '../../common/constance/strings.dart';

import '../../models/sync_call_log_model.dart';

class HomeController extends GetxController with WidgetsBindingObserver {
  final RxBool isPermissionGranted = true.obs;
  final historyRepository = HistoryRepository();
  final CallLogController callLogController = Get.put(CallLogController());
  final AccountController _controller = Get.put(AccountController());

  @override
  void onInit() {
    super.onInit();
    WidgetsBinding.instance.addObserver(this);
    // TODO: this for event pers change
    ever(isPermissionGranted, (isGranted) {
      if (!isGranted) {
        debugPrint('Permissions Denied');
        showDialogNotification(
            title: AppStrings.alertTitle,
            AppStrings.missingPermission,
            titleBtn: AppStrings.settingButtonTitle, action: () async {
          AppSettings.openAppSettings();
          Get.back();
        }, showBack: true);
      }
    });
  }

  static const platform = MethodChannel(AppShared.FLUTTER_ANDROID_CHANNEL);
  Future<dynamic> handle(MethodCall call) async {
    switch (call.method) {
      // case "sendLostCallsNotify":
      //   try {
      //     syncCallLog();
      //   } catch (e, stackTrace) {
      //     final errorString = "Received sendLostCallsNotify Caught exception $e  $stackTrace";
      //     print('Caught exception: $e $stackTrace');
      //     print('message hanlder in Home_controller errorString $errorString');
      //   }
      //   break;
      case "destroyBg":
        Future.delayed(const Duration(milliseconds: 1000), () {});
        print("Start background service on destroy");
        syncCallLog();
        break;
      default: break;
    }

    return true;
  }

  void syncCallLog() async {
    await callLogController.getCallLog();
    await platform.invokeMethod(AppShared.START_SERVICES_METHOD);
  }
  
  @override
  void didChangeAppLifecycleState(AppLifecycleState state) {
    print('home controller AppLifecycleState.resumed $state');
    if (state == AppLifecycleState.resumed) {
      // Xử lý khi ứng dụng quay lại foreground (chạy phía trước)
      checkPermission();
      addCallbackListener();
    }
  }

  @override
  void onClose() {
    WidgetsBinding.instance.removeObserver(this);
    super.onClose();
  }

  Future<void> checkPermission() async {
    // Assume false
    isPermissionGranted.value = await getGrandStatus();
  }

  Future<bool> getGrandStatus() async {
    var contactStatus = await Permission.contacts.status;
    var phoneStatus = await Permission.phone.status;
    debugPrint("getGrandStatus $contactStatus $phoneStatus");
    if (phoneStatus.isGranted || contactStatus.isGranted) {
      return true;
    }
    return false;
  }

  Future<void> initData() async {
    // TODO : block specific user
    if (_controller.user?.phone.toString().removeAllWhitespace == "0900000003") {
      return;
    }
    await _controller.getUserLogin();
    addCallbackListener();

    final isFirst = await AppShared().getFirstTimeSyncCallLog();
    print("isFirst $isFirst");
    if (isFirst == 'false' || isFirst == 'null' || isFirst.isEmpty) {
      final phoneStatus = await Permission.phone.status;
      if (phoneStatus == PermissionStatus.granted) {
        await callLogController.getCallLog();
        AppShared().setFirstTimeSyncCallLog(true);
      }
    }
  }

  void addCallbackListener() {
    try {
      platform.setMethodCallHandler(handle);
      print("setMethodCallHandler");
    } catch (e, stackTrace) {
      print('Caught exception: $e');
      print('Stack trace: $stackTrace');
    }
  }

  Future<void> initService() async {
    await initializeService();
    FlutterBackgroundService().invoke("setAsForeground");
  }
}

Future<void> initializeService() async {
  final service = FlutterBackgroundService();

  const AndroidNotificationChannel channel = AndroidNotificationChannel(
    'my_foreground',
    'Cần ở trạng thái ON để đồng bộ cuộc gọi',
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
  final FlutterLocalNotificationsPlugin flutterLocalNotificationsPlugin = FlutterLocalNotificationsPlugin();
  if (service is AndroidServiceInstance) {
    service.on('setAsForeground').listen((event) {
      service.setAsForegroundService();
    });

    service.on('setAsBackground').listen((event) {
      service.setAsBackgroundService();
    });
  }
  Timer.periodic(const Duration(minutes: 5), (timer) async {
    print('lastDateCalLogSync');
    String value = await AppShared().getLastDateCalLogSync();
    print('lastDateCalLogSync Home $value');
    int lastCallLogSync = value == 'null' || value.isEmpty ? 0 : int.parse(value);
    final dateString = lastCallLogSync == 0
        ? DateTime.now()
        : DateTime.fromMillisecondsSinceEpoch(lastCallLogSync);
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