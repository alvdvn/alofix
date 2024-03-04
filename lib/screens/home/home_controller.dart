// ignore_for_file: depend_on_referenced_packages
import 'dart:async';
import 'package:app_settings/app_settings.dart';
import 'package:base_project/common/utils/global_app.dart';
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
final dbService = SyncCallLogDb();
class HomeController extends GetxController with WidgetsBindingObserver {
  Map<Permission, PermissionStatus> permissionStatuses =
      <Permission, PermissionStatus>{
    Permission.phone: PermissionStatus.denied,
    Permission.contacts: PermissionStatus.denied
  };
  int retryRequestPermission = 0;
  final CallLogController callLogController = Get.find();
  final CallController callController = Get.find();
  final AccountController _controller = Get.find();

  final queueProcess = QueueProcess();
  final AppShared pref = AppShared();
  late Connectivity _connectivity;
  static const platform = MethodChannel(AppShared.FLUTTER_ANDROID_CHANNEL);

  @override
  void onInit() {
    super.onInit();
    WidgetsBinding.instance.addObserver(this);
    validatePermission();
    sync();
  }

  Future<void> validatePermission() async {
    permissionStatuses =
    await [Permission.phone, Permission.contacts].request();

    pprint("Validate validatePermission");
    if (permissionStatuses.values.any((element) => !element.isGranted)) {
      if (permissionStatuses.values
          .any((element) => !element.isGranted && element.isLimited) ||
          retryRequestPermission == 3) {
        showDialogNotification(
            title: AppStrings.alertTitle,
            AppStrings.missingPermission,
            titleBtn: AppStrings.settingButtonTitle,
            action: () async {
              await AppSettings.openAppSettings();
              Get.back();
            }, showBack: true);
      } else {
        retryRequestPermission++;
        await validatePermission();
      }
    } else {
      try {
        await platform.invokeMethod('SET_DEFAULT_DIALER');
      } on PlatformException catch (e) {
        pprint(e);
      }
    }
  }

  Future<dynamic> handle(MethodCall call) async {
    switch (call.method) {
      case "destroy_bg":
        Future.delayed(const Duration(seconds: 5), () async {
          pprint("Start background service on destroy");
          await startBg();
        });
        break;
      case "save_call_log":
        pprint("save_call_log");
        await QueueProcess().addFromSP();
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
    Future.delayed(const Duration(seconds: 1), () {
      WidgetsBinding.instance.removeObserver(this);
      super.onClose();
    });
  }

  Future<void> initData() async {
    await Get.find<AccountController>().getUserLogin();
    addCallbackListener();
    await sync();
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
    if (result == ConnectivityResult.wifi ||
        result == ConnectivityResult.mobile) {
      pprint("sync by connection");
      Future.delayed(const Duration(seconds: 10), () async {
        await sync();
      });
    }
    if (result == ConnectivityResult.wifi) {
      await FirebaseCrashlytics.instance.sendUnsentReports();
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

  await service.startService();
}

@pragma('vm:entry-point')
void onStart(ServiceInstance service) async {
  final FlutterLocalNotificationsPlugin flutterLocalNotificationsPlugin =
      FlutterLocalNotificationsPlugin();
  if (service is AndroidServiceInstance) {
    service.on('setAsForeground').listen((event) async {
      await service.setAsForegroundService();
    });

    service.on('setAsBackground').listen((event) async {
      await service.setAsBackgroundService();
    });
  }
  Timer.periodic(const Duration(minutes: 5), (timer) async {
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




    await sync();
  });
}

Future<void> sync() async {
  await QueueProcess().addFromSP();
}
