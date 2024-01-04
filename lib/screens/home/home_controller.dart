// ignore_for_file: depend_on_referenced_packages
import 'dart:async';
import 'dart:convert';
import 'package:app_settings/app_settings.dart';
import 'package:base_project/common/utils/global_app.dart';
import 'package:base_project/database/DbContext.dart';
import 'package:base_project/database/models/call_log.dart';
import 'package:base_project/extension.dart';
import 'package:base_project/queue.dart';
import 'package:base_project/screens/call/call_controller.dart';
import 'package:base_project/screens/call_log_screen/call_log_controller.dart';
import 'package:base_project/services/SyncDb.dart';
import 'package:base_project/services/local/app_share.dart';
import 'package:base_project/services/responsitory/history_repository.dart';
import 'package:collection/collection.dart';
import 'package:connectivity_plus/connectivity_plus.dart';
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
import 'package:call_log/call_log.dart' as DeviceCallLog;

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
  final queue = FunctionQueue();
  late Connectivity _connectivity;
  static const platform = MethodChannel(AppShared.FLUTTER_ANDROID_CHANNEL);

  @override
  void onInit() {
    super.onInit();
    WidgetsBinding.instance.addObserver(this);
    validatePermission();
  }

  Future<void> validatePermission({bool withRetry = true}) async {
    permissionStatuses =
        await [Permission.phone, Permission.contacts].request();

    print("Validate validatePermission");
    if (permissionStatuses.values.any((element) => !element.isGranted)) {
      if (permissionStatuses.values
              .any((element) => !element.isGranted && element.isLimited) ||
          retryRequestPermission == 5) {
        print("validatePermission limited");
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
        Future.delayed(const Duration(milliseconds: 1000), () async {
          print("Start background service on destroy");
          startBg();
        });
        break;
      case "save_call_log":
        Map<String, dynamic> jsonObj = json.decode(call.arguments.toString());
        CallLog callLog = CallLog.fromMap(jsonObj);
        queue.enqueueAsyncWithParameters(
            (param) async => processQueue(param), callLog);
        break;
      case "clear_phone":
        callController.phoneNumber.value = '';
        break;
      default:
        break;
    }

    return true;
  }

  Future<DeviceCallLog.CallLogEntry?> findCallLogDevice({
    required CallLog callLog,
    int retry = 0,
  }) async {
    // Use Completer to handle the asynchronous result
    Completer<DeviceCallLog.CallLogEntry?> completer = Completer();

    // Use Future.delayed to introduce a delay
    Future.delayed(const Duration(milliseconds: 500), () async {
      try {
        Iterable<DeviceCallLog.CallLogEntry> result =
            await DeviceCallLog.CallLog.query(
          dateFrom: callLog.startAt - 1000,
          number: callLog.phoneNumber,
        );

        if (result.isEmpty) {
          if (retry == 20) {
            Iterable<DeviceCallLog.CallLogEntry> all =
            await DeviceCallLog.CallLog.query(
              number: callLog.phoneNumber,
            );
            pprint("All by number ${all.first}");
            completer.complete(null);
            return;
          }

          retry++;
          pprint("findCallLog ${callLog.phoneNumber} - ${callLog.startAt} - $retry");

          // Recursively call the function and await the result
          DeviceCallLog.CallLogEntry? entry = await findCallLogDevice(
            callLog: callLog,
            retry: retry,
          );
          completer.complete(entry);
        } else {
          pprint("found call log after $retry");
          // Sort the result
          List<DeviceCallLog.CallLogEntry> sortedResult = result.toList()
            ..sort((a, b) => a.timestamp!.compareTo(b.timestamp!));

          // Get the last entry from the sorted list
          DeviceCallLog.CallLogEntry? lastEntry =
              sortedResult.isNotEmpty ? sortedResult.last : null;

          completer.complete(lastEntry);
        }
      } catch (e) {
        // Handle any exceptions that may occur during the async operations
        completer.completeError(e);
      }
    });

    // Return the Future from the Completer
    return completer.future;
  }

  Future<void> processQueue(CallLog callLog) async {
    final db = await DatabaseContext.instance();

    CallLog dbCallLog = callLog;
    var entry = await findCallLogDevice(callLog: callLog);
    if (entry != null) {
      // var mTimeRinging = CallHistory.getRingTime(mCall.duration, mCall.startAt, endTime, mType)
      dbCallLog = CallLog.fromEntry(entry: entry);
      dbCallLog.endedBy = callLog.endedBy;
      dbCallLog.endedAt = callLog.endedAt;
      dbCallLog.callBy = callLog.callBy;
      dbCallLog.method = callLog.method;
      dbCallLog.type = callLog.type;
      dbCallLog.syncBy = callLog.syncBy;

      dbCallLog.id = callLog.id
          .replaceFirst(RegExp(r'^.*?&'), "${dbCallLog.startAt ~/ 1000}&");

      if (callLog.endedAt != null) {
        dbCallLog.timeRinging =
            (dbCallLog.endedAt! - dbCallLog.startAt - entry.duration! * 1000);

        dbCallLog.answeredAt = entry.duration != null
            ? callLog.endedAt! - entry.duration! * 1000
            : null;
      }
      dbCallLog.callDuration = (callLog.endedAt! - callLog.startAt) ~/ 1000;

      // #1: Type = Outgoing && AnswerDuration = 0 && RingDuration < 10s && EndBy = “Rider”
      // #2: Type = Outgoing && AnswerDuration = 0 && RingDuration =< 3.5s && Endby = N/A

      if (dbCallLog.type == CallType.outgoing &&
          dbCallLog.answeredDuration == 0) {
        if ((dbCallLog.endedBy == EndBy.rider &&
                dbCallLog.timeRinging! < 10000) ||
            (dbCallLog.endedBy == EndBy.other &&
                dbCallLog.timeRinging! < 3000)) {
          dbCallLog.callLogValid = CallLogValid.invalid;
        }
      }
    }

    if (dbCallLog.customData == null) {
      var deepLink = await dbService.findDeepLinkByCallLog(callLog: callLog);
      if (deepLink != null) {
        dbCallLog.customData = deepLink.data;
      }
    }

    dbCallLog = await db.callLogs.insertOrUpdate(dbCallLog);
    pprint(
        "Call save ${dbCallLog.id} - ${dbCallLog.phoneNumber} - ${dbCallLog.callLogValid}");
    await callLogController.loadDataFromDb();

    var found = await db.callLogs.find(dbCallLog.id);
    final service = HistoryRepository();
    var lst = <CallLog>{found!}.toList();
    await service.syncCallLog(listSync: lst);
  }

  void startBg() async {
    // await callLogController.getCallLog();
    await platform.invokeMethod(AppShared.START_SERVICES_METHOD);
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
    WidgetsBinding.instance.removeObserver(this);
    super.onClose();
  }

  Future<void> initData() async {
    var minDate = DateTime.now().subtract(const Duration(hours: 2));
    Iterable<DeviceCallLog.CallLogEntry> result =
        await DeviceCallLog.CallLog.query(dateTimeFrom: minDate);

    // final db = await DatabaseContext.instance();
    // db.reset();
    // dbService.syncToServer();
    await _controller.getUserLogin();
    addCallbackListener();
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
    _connectivity = Connectivity();
    _connectivity.onConnectivityChanged.listen(_updateConnectionStatus);
    _updateConnectionStatus(await _connectivity.checkConnectivity());
  }

  void _updateConnectionStatus(ConnectivityResult result) {
    if (result == ConnectivityResult.wifi ||
        result == ConnectivityResult.mobile) {
      dbService.syncToServer();
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
    await dbService.syncToServer();
  });
}
