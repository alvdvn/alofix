import 'dart:async';

import 'package:base_project/common/utils/global_app.dart';
import 'package:base_project/models/history_call_log_app_model.dart';
import 'package:base_project/models/history_call_log_model.dart';
import 'package:connectivity_plus/connectivity_plus.dart';
import 'package:base_project/models/call_log_model.dart';
import 'package:base_project/models/sync_call_log_model.dart';
import 'package:base_project/screens/account/account_controller.dart';
import 'package:base_project/services/local/app_share.dart';
import 'package:base_project/services/responsitory/history_repository.dart';
import 'package:call_log/call_log.dart';
import 'package:flutter/material.dart';
import 'package:flutter_phone_direct_caller/flutter_phone_direct_caller.dart';
import 'package:get/get.dart';
import 'package:intl/intl.dart';
import 'package:permission_handler/permission_handler.dart';
import 'package:url_launcher/url_launcher.dart';

class CallLogController extends GetxController {
  final service = HistoryRepository();
  DateTime now = DateTime.now();
  AccountController? accountController;
  RxList<CallLogEntry> callLogEntries = <CallLogEntry>[].obs;
  RxList<CallLogModel> callLogSv = <CallLogModel>[].obs;
  RxList<CallLogModel> callLogLocal = <CallLogModel>[].obs;
  RxList<CallLogModel> callLogLocalSearch = <CallLogModel>[].obs;
  List<SyncCallLogModel> mapCallLog = [];
  int secondCall = 0;
  Timer? timer;
  RxBool isShowSearch = false.obs;
  RxBool isShowSearchLocal = false.obs;
  RxBool isShowCalender = false.obs;
  RxBool loadDataLocal = false.obs;
  RxBool isFilter = false.obs;
  RxBool loading = false.obs;
  RxString timePicker = ''.obs;
  RxBool isDisable = false.obs;
  RxInt page = 1.obs;
  RxString searchCallLog = ''.obs;

  void onClickSearchLocal() {
    isShowSearchLocal.value = !isShowSearchLocal.value;
  }

  void onClickFilter() {
    isFilter.value = !isFilter.value;
  }

  void initData({int? timeRing}) async {
    final connectivityResult = await Connectivity().checkConnectivity();
    if (ConnectivityResult.none != connectivityResult) {
      loadDataLocal.value = false;
      callLogSv.clear();
      await getCallLog();
      page.value = 1;
      await getCallLogFromServer(
          page: page.value, showLoading: true, clearList: true);
    } else {
      loadDataLocal.value = true;
      await getCallLogFromDevice();
      callLogLocalSearch.value = callLogLocal;
    }
  }

  int handlerCallType(CallType? callType) {
    if (callType == CallType.outgoing) {
      return 1;
    }
    if (callType == CallType.incoming) {
      return 2;
    }
    if (callType == CallType.missed) {
      return 2;
    }
    return 2;
  }

  void setTime(DateTimeRange? timeDate) async {
    if (timeDate != null) {
      DateTime startTime = timeDate.start;
      DateTime endTime = timeDate.end;
      timePicker.value =
          '${ddMMYYYYSlashFormat.format(startTime)} - ${ddMMYYYYSlashFormat.format(endTime)}';
    }
  }

  Future<void> searchCallLogLocal({required String search}) async {
    if (search.isEmpty) {
      callLogLocalSearch.value = callLogLocal;
    } else {
      List<CallLogModel> filteredCallLogLocal = callLogLocal
          .where(
              (callLog) => callLog.calls!.first.phoneNumber!.contains(search))
          .toList();
      callLogLocalSearch.value = filteredCallLogLocal;
    }
  }

  Future<void> getCallLogFromDevice() async {
    Iterable<CallLogEntry> result = await CallLog.query();
    callLogEntries.value = result.toList();
    callLogLocal.value = callLogEntries.map((element) {
      final dateTime =
          DateTime.fromMillisecondsSinceEpoch(element.timestamp ?? 0)
              .toString();
      List<HistoryCallLogAppModel> calls = [
        HistoryCallLogAppModel(phoneNumber: element.number, logs: [
          HistoryCallLogModel(
            phoneNumber: element.number,
            timeRinging: 0,
            answeredDuration: element.duration,
            startAt: '$dateTime +0700',
            method: 2,
            type: handlerCallType(element.callType),
            hotlineNumber: element.number,
            recoredUrl: "",
            id: element.phoneAccountId,
            syncAt: '$dateTime +0700',
          )
        ])
      ];

      final date = DateTime.parse(dateTime).toLocal();
      return CallLogModel(key: date.toString(), calls: calls);
    }).toList();
  }

  Future<Map<String, String>?> handlerCustomData(CallLogEntry entry) async {
    String dateDeepLink = await AppShared().getDateDeepLink();
    String phoneDeepLink = await AppShared().getPhoneDeepLink();
    String type = await AppShared().getType();
    String idDeeplink = await AppShared().getIdDeeplink();
    String routeDeeplink = await AppShared().getRouterDeeplink();
    var dateCallLog = DateTime.fromMillisecondsSinceEpoch(entry.timestamp ?? 0);
    if (dateDeepLink != 'null') {
      var dateTimeDeepLink = DateTime.parse(dateDeepLink);
      var dateTimeCallLogFormatter = YYYYMMddFormat.format(dateCallLog);
      var dateTimeDeepLinkFormatter = YYYYMMddFormat.format(dateTimeDeepLink);
      if (dateTimeCallLogFormatter == dateTimeDeepLinkFormatter &&
          phoneDeepLink == entry.number &&
          dateCallLog.hour - dateTimeDeepLink.hour <= 2) {
        Map<String, String> data = {
          'phoneNumber': phoneDeepLink,
          'type': type,
          'routeId': routeDeeplink,
          'id': idDeeplink
        };
        AppShared.jsonDeepLink = data;
        return AppShared.jsonDeepLink;
      }
      return null;
    }
    return null;
  }

  Future<void> syncCallLogTimeRing({required int timeRing}) async {
    if (timeRing != 0) {
      List<SyncCallLogModel> lstSync = [];
      Iterable<CallLogEntry> result = await CallLog.query();
      callLogEntries.value = result.toList();
      final String userName = await AppShared().getUserName();
      final date = DateTime.fromMillisecondsSinceEpoch(callLogEntries.first.timestamp ?? 0);
      final callTimeRing =  SyncCallLogModel(
          id: 'call&sim&${callLogEntries.first.timestamp}&$userName',
          phoneNumber: callLogEntries.first.number,
          type: handlerCallType(callLogEntries.first.callType),
          userId: accountController?.user?.id,
          method: 2,
          ringAt: '$date +0700',
          startAt: '$date +0700',
          endedAt: '$date +0700',
          answeredAt: '$date +0700',
          timeRinging: timeRing  - (callLogEntries.first.duration ?? 0) < 0
              ? (timeRing - (callLogEntries.first.duration ?? 0)) * -1
              : timeRing - (callLogEntries.first.duration ?? 0),
          hotlineNumber: accountController?.user?.phone,
          callDuration: callLogEntries.first.callType == CallType.missed
              ? 0
              : callLogEntries.first.duration,
          endedBy: 1,
          customData: await handlerCustomData(callLogEntries.first),
          answeredDuration: callLogEntries.first.callType == CallType.missed
              ? 0
              : callLogEntries.first.duration,
          recordUrl: '');
      lstSync.add(callTimeRing);
      await service.syncCallLog(listSync: lstSync);
      timer?.cancel();
      secondCall = 0;
    }
  }

  Future<void> getCallLog() async {
    await AppShared().getTimeInstallLocal();
    final String userName = await AppShared().getUserName();
    Iterable<CallLogEntry> result = await CallLog.query();
    callLogEntries.value = result.toList();
    final dateInstall = DateTime.parse(AppShared.dateInstallApp);
    final dateSync =
        DateTime.parse(AppShared.dateSyncApp ?? AppShared.dateInstallApp)
            .add(const Duration(minutes: -6));
    final date8HoursInstall =
        DateFormat('yyyy-MM-dd 08:00').format(dateInstall);
    int timeTamp8HoursInstall =
        DateTime.parse(date8HoursInstall).millisecondsSinceEpoch;
    int timeSyncTemp = dateSync.millisecondsSinceEpoch;
    for (var element in callLogEntries) {
      final date = DateTime.fromMillisecondsSinceEpoch(element.timestamp ?? 0);
      if (element.timestamp! >= timeTamp8HoursInstall &&
          element.timestamp! >= timeSyncTemp) {
        mapCallLog.add(SyncCallLogModel(
            id: 'call&sim&${element.timestamp}&$userName',
            phoneNumber: element.number,
            type: handlerCallType(element.callType),
            userId: accountController?.user?.id,
            method: 2,
            ringAt: '$date +0700',
            startAt: '$date +0700',
            endedAt: '$date +0700',
            answeredAt: '$date +0700',
            timeRinging: 0,
            hotlineNumber: accountController?.user?.phone,
            callDuration:
                element.callType == CallType.missed ? 0 : element.duration,
            endedBy: 1,
            customData: await handlerCustomData(element),
            answeredDuration:
                element.callType == CallType.missed ? 0 : element.duration,
            recordUrl: ''));
      }
    }
    syncCallLog();
  }

  Future<void> getCallLogFromServer(
      {required int page,
      String? search,
      DateTime? startTime,
      DateTime? endTime,
      bool clearList = false,
      bool showLoading = false}) async {
    if (showLoading) {
      loading.value = true;
    }
    if (clearList == true) {
      callLogSv.clear();
    }
    final connectivityResult = await Connectivity().checkConnectivity();
    if (connectivityResult != ConnectivityResult.none) {
      loadDataLocal.value = false;
      final res = await service.getInformation(
              page: page,
              pageSize: 20,
              searchItem: search,
              startTime: startTime,
              endTime: endTime) ??
          [];
      if (res != []) {
        callLogSv.addAll(res);
      }
    } else {
      loadDataLocal.value = true;
      await getCallLogFromDevice();
    }
    loading.value = false;
  }

  Future<void> syncCallLog() async {
    try {
      await service.syncCallLog(listSync: mapCallLog);
    } catch (_) {}
  }

  void onClickSearch() {
    isShowSearch.value = true;
    isShowCalender.value = false;
    timePicker.value = '';
  }

  void onClickCalender() {
    isShowSearch.value = false;
    isShowCalender.value = true;
    isDisable.value = false;
    timePicker.value = 'Vui lòng chọn ngày';
  }

  void onClickClose() async {
    isShowSearch.value = false;
    isShowCalender.value = false;
    callLogSv.clear();
    page.value = 1;
    searchCallLog.value = '';
    await getCallLogFromServer(
        page: page.value, showLoading: true, clearList: true);
  }

  void loadMore(
      {String? search, DateTime? startTime, DateTime? endTime}) async {
    await getCallLogFromServer(
        page: page.value += 1,
        search: search,
        startTime: startTime,
        endTime: endTime);
  }

  void onRefresh(
      {String? search, DateTime? startTime, DateTime? endTime}) async {
    callLogSv.clear();
    page.value = 1;
    loading.value = true;
    await getCallLogFromServer(
        page: page.value,
        search: searchCallLog.value == '' ? null : searchCallLog.value,
        startTime: startTime,
        endTime: endTime);
    loading.value = false;
  }

  void handCall(String phoneNumber) {
    switch (AppShared.callTypeGlobal) {
      case '1':
        FlutterPhoneDirectCaller.callNumber(phoneNumber);
        break;
      case '2':
        launchUrl(
            Uri(scheme: 'https://zalo.me/$phoneNumber', path: phoneNumber));
        break;
      case '3':
        FlutterPhoneDirectCaller.callNumber(phoneNumber);
        break;
      default:
        FlutterPhoneDirectCaller.callNumber(phoneNumber);
        break;
    }
  }

  void handSMS(String phoneNumber) {
    launchUrl(Uri(scheme: 'sms', path: phoneNumber));
  }
}
