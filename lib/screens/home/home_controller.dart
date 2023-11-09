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
import '../../services/local/logs.dart';
import '../../services/remote/api_provider.dart';
import '../../services/responsitory/history_repository.dart';
import '../account/account_controller.dart';
import '../../common/constance/strings.dart';

import '../../models/sync_call_log_model.dart';

class HomeController extends GetxController with  WidgetsBindingObserver {
  final RxBool isPermissionGranted = true.obs;
  final _provider = ApiProvider();
  final  historyRepository = HistoryRepository();

  // TODO: inject instance
  // final CallLogController callLogController = Get.put(CallLogController(service));
  // final AccountController _controller = Get.put(AccountController(service));

  final CallLogController callLogController = Get.put(CallLogController());
  final AccountController _controller = Get.put(AccountController());

  Future<void> initService() async {
    await initializeService();
    FlutterBackgroundService().invoke("setAsForeground");
  }

  @override
  void onInit() {
    super.onInit();
    WidgetsBinding.instance.addObserver(this);
    // TODO: this for event pers change
    // ever(isPermissionGranted, (isGranted) {
    //   if (!isGranted) {
    //     debugPrint('Permissions Denied');
    //     showDialogNotification(
    //         title: AppStrings.alertTitle,
    //         AppStrings.missingPermission,
    //         titleBtn: AppStrings.settingButtonTitle, action: () async {
    //       AppSettings.openAppSettings();
    //       Get.back();
    //     }, showBack: true);
    //   }
    // });
  }

  static const platform = MethodChannel(AppShared.FLUTTER_ANDROID_CHANNEL);
  Future<dynamic> handle(MethodCall call) async {
    switch (call.method) {
      case "sendLostCallsNotify":
        try {
          final data = call.arguments;
          final lastPostId = data["lastSyncId"];
          final lastSyncTimeOfID = int.tryParse(data["lastSyncTimeOfID"].toString());
          final string = await AppShared().getLastRecoveredTimeStamp();
          final lastOfService = int.tryParse(string);
          final lastTime = data["lastDestroyTime"];
          final diedTime = DateTime.fromMillisecondsSinceEpoch(lastTime);
          final diedTimeStr = DateFormat("HH:mm:ss dd-MM-yyyy").format(diedTime);

          String message = "";
          if (lastPostId != 0) {
            debugPrint("Received sendLostCallsNotify $lastPostId");

            if (lastOfService != null) {
              debugPrint('Received sendLostCallsNotify lastOfService: $lastOfService');
              message = "Received sendLostCallsNotify lastOfService: $lastOfService";
              DateTime filterTime = DateTime.fromMillisecondsSinceEpoch(lastOfService);
              Iterable<CallLogEntry> result = await getCallLogsAfter(time: filterTime);

              if (result.isEmpty && lastSyncTimeOfID != null) {
                reSyncData(lastSyncTimeOfID, diedTimeStr);
                debugPrint('Received sendLostCallsNotify lastOfService: $lastOfService reSyncData lastSyncTimeOfID $lastSyncTimeOfID');
                message = "Received sendLostCallsNotify lastOfService: $lastOfService reSyncData lastSyncTimeOfID $lastSyncTimeOfID";
              } else {
                reSyncData(lastOfService, diedTimeStr);
                message = "Received sendLostCallsNotify lastOfService: $lastOfService";
                debugPrint('Received sendLostCallsNotify lastOfService: $lastOfService');
              }
            } else {
              reSyncData(lastSyncTimeOfID!, diedTimeStr);
            }
          } else {
            // hardly happened
            debugPrint("Received sendLostCallsNotify getCallLogs before 3 days");
            message = "Received sendLostCallsNotify getCallLogs before 3 days";
            int threeDaysAgo = DateTime.now().subtract(const Duration(days: 3)).millisecondsSinceEpoch;
            reSyncData(threeDaysAgo, diedTime);
          }

          Logs().sendMessage(message);
        } catch (e, stackTrace) {
          final errorString = "Received sendLostCallsNotify Caught exception $e  $stackTrace";
          debugPrint('Caught exception: $e $stackTrace');
          Logs().sendError(errorString);
        }

        // TODO: Check response API with latest case on phone
        // TODO: Compare StartAt to detect is synchronization
        // TODO: Do after get histories when activate the view

        break;
      default:
    }

    return true;
  }

  int choiceSoonTime(int lastSyncTimeOfID, int lastTime) {
    return lastSyncTimeOfID < lastTime ? lastSyncTimeOfID : lastTime;
  }

  void showNotify(diedTimeStr) {
    AppShared().saveLastShowNotify(diedTimeStr);
    showDialogNotification(
        title: "Vui lòng kiểm tra lại!",
        "Dịch vụ ghi nhận cuộc gọi bị gián đoạn từ $diedTimeStr. Vui lòng kiểm tra lại nhật ký cuộc gọi trong khung giờ trên.",
        action: () => {Get.back()});
  }

  Future<Iterable<CallLogEntry>> getCallLogsAfter({required DateTime time}) async {
    Iterable<CallLogEntry> callLogEntries = [];
    if (await Permission.phone.status == PermissionStatus.granted) {
      callLogEntries = await CallLog.query(
        dateFrom: time.millisecondsSinceEpoch,
      );
    }
    Iterable<CallLogEntry> filteredEntries = callLogEntries.where((entry) {
      DateTime callDateTime = DateTime.fromMillisecondsSinceEpoch(entry.timestamp ?? 0);
      return callDateTime.isAfter(time);
    });
    return filteredEntries;
  }

  Future<void> reSyncData(int lastSyncTime, diedTimeStr) async {
    List<SyncCallLogModel> data = [];
    Iterable<CallLogEntry> result;

    DateTime filterTime = DateTime.fromMillisecondsSinceEpoch(lastSyncTime);
    result = await getCallLogsAfter(time: filterTime);

    bool isChange = await isDifferenceTimeNotify(diedTimeStr);
    if (result.isNotEmpty && isChange) {
      showNotify(diedTimeStr);
      data = await getSyncCallLogs(result);
      debugPrint("Resend Call from last: $lastSyncTime Data Length: ${data.length}");
      syncCallLogService(listSync: data);
    }
  }

  Future<bool> isDifferenceTimeNotify(String diedTimeStr) async {
    final time = await AppShared().getLastShowNotify();
    return time == diedTimeStr;
  }

  Future syncCallLogService({required List<SyncCallLogModel> listSync}) async {
    if (listSync.isEmpty) {
      debugPrint("Empty Logs");
      return;
    }

    List<Map<String, dynamic>> listItem = <Map<String, dynamic>>[];
    for (var e in listSync) {
      Map<String, dynamic> params = {
        "Id": e.id.toString(),
        "PhoneNumber": e.phoneNumber.toString(),
        "Type": e.type,
        "UserId": e.userId,
        "Method": e.method,
        "RingAt": e.ringAt,
        "StartAt": e.startAt,
        "EndedAt": e.endedAt,
        "AnsweredAt": e.endedAt,
        "HotlineNumber": e.hotlineNumber.toString(),
        "CallDuration": e.callDuration,
        "timeRinging": null,
        "EndedBy": e.endedBy,
        "customData": e.customData,
        "AnsweredDuration": e.answeredDuration,
        "RecordUrl": e.recordUrl,
        "Onlyme": true
      };
      listItem.add(params);
    }
    final params = listItem;
    debugPrint('Sync CallLogs with prams: ${params.toList()}');
    try {
      final data = await _provider.postListString('api/calllogs', params, isRequireAuth: true);
      Map<String, dynamic> response = jsonDecode(data.toString());
      final isSuccess = response['success'] as bool;
      debugPrint('Sync status ${isSuccess.toString()} lastSync: ${listSync.first.id}');
      if (isSuccess) {
        final lastTime = listSync.first.time1970;
        AppShared().saveLastRecoveredTimeStamp(lastTime.toString());
        callLogController.onRefresh();
      }
    } catch (error, r) {
      debugPrint(error.toString());
      debugPrint(r.toString());
    }
  }

  @override
  void didChangeAppLifecycleState(AppLifecycleState state) {
    if (state == AppLifecycleState.resumed) {
      // Xử lý khi ứng dụng quay lại foreground (chạy phía trước)
      debugPrint('AppLifecycleState.resumed');
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
    await _controller.getUserLogin();
    addCallbackListener();

    final isFirst = await AppShared().getFirstTimeSyncCallLog();

    if (isFirst == 'false') {
      final phoneStatus = await Permission.phone.status;
      if (phoneStatus == PermissionStatus.granted) {
        await callLogController.getCallLog();
        AppShared().setFirstTimeSyncCallLog(true);
        addCallbackListener();
      }
    }

    // TODO : block specific user
    if (_controller.user?.phone.toString().removeAllWhitespace == "0900000003") {
      return;
    }
  }

  void addCallbackListener() {
    try {
      platform.setMethodCallHandler(handle);
      debugPrint("setMethodCallHandler");
    } catch (e, stackTrace) {
      debugPrint('Caught exception: $e');
      debugPrint('Stack trace: $stackTrace');
    }
  }

  Future<List<SyncCallLogModel>> pushBefore(DateTime time) async {
    Iterable<CallLogEntry> dataEntry = await getCallLogsAfter(time: time);
    if (dataEntry.isNotEmpty) {
      List<SyncCallLogModel> data = await getSyncCallLogs(dataEntry);
      // TODO: set push here
      // await historyRepository.syncCallLog(listSync: data);
      //
      return data;
    }
    return [];
  }

  Future<List<SyncCallLogModel>> getSyncCallLogs(Iterable<CallLogEntry> result) async {
    final String userName = await AppShared().getUserName();

    List<SyncCallLogModel> data = [];
    for (CallLogEntry element in result.toList()) {
      final date = DateTime.fromMillisecondsSinceEpoch(element.timestamp ?? 0);
      final call = SyncCallLogModel(
          id: '${element.timestamp}&$userName',
          phoneNumber: element.number,
          type: callLogController.handlerCallType(element.callType),
          userId: _controller.user?.id,
          method: 2,
          ringAt: '$date +0700',
          startAt: '$date +0700',
          endedAt: '$date +0700',
          answeredAt: '$date +0700',
          timeRinging: null,
          hotlineNumber: _controller.user?.phone,
          callDuration: element.callType == CallType.missed ? 0 : element.duration,
          customData: await callLogController.handlerCustomData(element),
          answeredDuration: (element.callType == CallType.missed || element.callType == CallType.rejected) ? 0 : element.duration,
          recordUrl: '',
          time1970: element.timestamp!);

      debugPrint("Resend Call ${call.toString()}");
      data.add(call);
    }
    return data;
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

  final FlutterLocalNotificationsPlugin flutterLocalNotificationsPlugin = FlutterLocalNotificationsPlugin();
  await flutterLocalNotificationsPlugin
      .resolvePlatformSpecificImplementation<AndroidFlutterLocalNotificationsPlugin>()
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
    String value = await AppShared().getLastDateCalLogSync();
    print('lastDateCalLogSync Home $value');
    int lastCallLogSync = value == 'null' || value.isEmpty ? 0 : int.parse(value);
    final dateString = lastCallLogSync == 0 ? DateTime.now() : DateTime.fromMillisecondsSinceEpoch(lastCallLogSync);
    flutterLocalNotificationsPlugin.show(
      888,
      'Alo Ninja',
      'Đã đồng bộ lịch sử cuộc gọi lúc ${ddMMYYYYTimeSlashFormat.format(dateString)}',
      const NotificationDetails(
        android: AndroidNotificationDetails('my_foreground', 'MY FOREGROUND SERVICE', icon: 'icon_notification', ongoing: true),
      ),
    );
    try {
      await callLogController.getCallLog();
    } catch (e) {
      await callLogController.getCallLog();
    }
  });
}