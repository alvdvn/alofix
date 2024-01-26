// ignore_for_file: depend_on_referenced_packages
import 'dart:async';
import 'package:app_settings/app_settings.dart';
import 'package:base_project/common/utils/global_app.dart';
import 'package:base_project/database/db_context.dart';
import 'package:base_project/database/enum.dart';
import 'package:base_project/database/models/job.dart';
import 'package:base_project/extension.dart';
import 'package:base_project/screens/call/call_controller.dart';
import 'package:base_project/screens/call_log_screen/call_log_controller.dart';
import 'package:base_project/services/SyncDb.dart';
import 'package:base_project/services/local/app_share.dart';
import 'package:base_project/services/queue_process.dart';
import 'package:connectivity_plus/connectivity_plus.dart';
import 'package:firebase_crashlytics/firebase_crashlytics.dart';
import 'package:flutter/cupertino.dart';
import 'package:flutter/services.dart';
import 'package:flutter_background_service_android/flutter_background_service_android.dart';
import 'package:flutter_background_service/flutter_background_service.dart';
import 'package:flutter_local_notifications/flutter_local_notifications.dart';
import 'package:get/get.dart';
import 'package:permission_handler/permission_handler.dart';
import '../../common/utils/alert_dialog_utils.dart';
import '../account/account_controller.dart';
import '../../common/constance/strings.dart';

class HomeController extends GetxController with WidgetsBindingObserver {
  Map<Permission, PermissionStatus> permissionStatuses =
      <Permission, PermissionStatus>{
    Permission.phone: PermissionStatus.denied,
    Permission.contacts: PermissionStatus.denied
  };
  int retryRequestPermission = 0;
  final CallLogController callLogController = Get.put(CallLogController());
  final CallController callController = Get.put(CallController());
  final AccountController _controller = Get.put(AccountController());
  final dbService = SyncCallLogDb();
  final queueProcess = QueueProcess();
  final AppShared pref = AppShared();
  late Connectivity _connectivity;
  static const platform = MethodChannel(AppShared.FLUTTER_ANDROID_CHANNEL);

  @override
  void onInit() {
    super.onInit();
    WidgetsBinding.instance.addObserver(this);
    validatePermission();
    QueueProcess().addFromDb();
  }

  Future<void> validatePermission({bool withRetry = true}) async {
    permissionStatuses =
        await [Permission.phone, Permission.contacts].request();

    pprint("Validate validatePermission");
    if (permissionStatuses.values.any((element) => !element.isGranted)) {
      if (permissionStatuses.values
              .any((element) => !element.isGranted && element.isLimited) ||
          retryRequestPermission >= 1) {
        showDialogNotification(
            title: AppStrings.alertTitle,
            AppStrings.missingPermission,
            titleBtn: AppStrings.settingButtonTitle, action: () async {
          AppSettings.openAppSettings();
          Get.back();
        }, showBack: true);
      } else if (withRetry) {
        retryRequestPermission++;
        await validatePermission();
      }
    } else {
      platform.invokeMethod(AppShared.SET_DEFAULT_DIALER);
    }
  }

  Future<dynamic> handle(MethodCall call) async {
    switch (call.method) {
      case "destroy_bg":
        Future.delayed(const Duration(seconds: 5), () async {
          print("Start background service on destroy");
          startBg();
        });
        break;
      case "save_call_log":
        pprint("save_call_log");
        try {
          final db = await DatabaseContext.instance();
          await db.jobs.insertJob(
              JobQueue(payload: call.arguments, type: JobType.mapCall));
          await QueueProcess().addFromDb();

          // if (await queue.remainingItems.isEmpty) {
          //   await callLogController.loadDataFromDb();
          // }
        } catch (e) {
          e.printError(logFunction: pprint, info: "Save");
        }
        break;

      case "clear_phone":
        callController.phoneNumber.value = '';
        break;
      default:
        break;
    }

    return true;
  }

  Future<void> startBg() async {
    await platform.invokeMethod(AppShared.START_SERVICES_METHOD);
  }

  Future<void> stopBG() async {
    await platform.invokeListMethod(AppShared.STOP_SERVICES_METHOD);
  }

  @override
  void didChangeAppLifecycleState(AppLifecycleState state) {
    print('home controller AppLifecycleState.resumed $state');
    if (state == AppLifecycleState.resumed) {
      // Xử lý khi ứng dụng quay lại foreground (chạy phía trước)
      addCallbackListener();
    }
  }

  @override
  void onClose() {
    Future.delayed(Duration(seconds: 1), () {
      WidgetsBinding.instance.removeObserver(this);
      super.onClose();
    });
  }

  Future<void> initData() async {
    // final db = await DatabaseContext.instance();
    // db.reset();
    // dbService.syncFromServer();
    await _controller.getUserLogin();
    addCallbackListener();
    await dbService.syncToServer(loadDevice: false);
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
    pprint("initService");
    await initializeService();
    FlutterBackgroundService().invoke("setAsForeground");
    _connectivity = Connectivity();
    _connectivity.onConnectivityChanged.listen(_updateConnectionStatus);
  }

  Future<void> _updateConnectionStatus(ConnectivityResult result) async {
    if (result == ConnectivityResult.wifi) {
      FirebaseCrashlytics.instance.sendUnsentReports();
    }
    if (result == ConnectivityResult.wifi ||
        result == ConnectivityResult.mobile) {
      pprint("sync by connection");
      Future.delayed(const Duration(seconds: 10), () async {
        QueueProcess.queue
            .add(() async => await dbService.syncToServer(loadDevice: false));
      });
    }
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
  final dbService = SyncCallLogDb();
  final db = await DatabaseContext.instance();
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
  Timer.periodic(const Duration(minutes: 1), (timer) async {
    var pref = AppShared();
    String value = await pref.getLastDateCalLogSync();
    print('lastDateCalLogSync Home $value');
    int lastCallLogSync =
        value == 'null' || value.isEmpty ? 0 : int.parse(value);
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

    var jobCount = await db.jobs.countJob();
    if (jobCount == null || jobCount == 0) {
      await dbService.syncToServer();
    } else {
      await QueueProcess().addFromDb();
    }
  });
}
