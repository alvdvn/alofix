import 'package:base_project/common/utils/global_app.dart';
import 'package:base_project/models/history_call_log_app_model.dart';
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
import 'package:url_launcher/url_launcher.dart';

class CallLogController extends GetxController {
  final service = HistoryRepository();
  DateTime now = DateTime.now();
  AccountController? accountController;
  List<CallLogEntry> callLogEntries = [];
  RxList<CallLogModel> callLogSv = <CallLogModel>[].obs;
  List<SyncCallLogModel> mapCallLog = [];
  RxBool isShowSearch = false.obs;
  RxBool isShowCalender = false.obs;
  RxBool loadDataLocal = false.obs;
  RxBool loading = false.obs;
  RxString timePicker = ''.obs;
  RxBool isDisable = false.obs;
  RxInt page = 1.obs;
  RxString searchCallLog = ''.obs;

  void initData() async {
    final connectivityResult = await Connectivity().checkConnectivity();
    if (ConnectivityResult.none != connectivityResult) {
      callLogSv.clear();
      getCallLog();
      page.value = 1;
      getCallLogFromServer(page: page.value, showLoading: true);
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

  Future<Map<String, String>?> handlerCustomData(CallLogEntry entry) async {
    String dateDeepLink = await AppShared().getDateDeepLink();
    String phoneDeepLink = await AppShared().getPhoneDeepLink();
    String idTrackDeepLink = await AppShared().getIdTrack();
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
          'type': idTrackDeepLink,
          'routeId':routeDeeplink,
          'id':idDeeplink
        };
        AppShared.jsonDeepLink = data;
        return AppShared.jsonDeepLink;
      }
      return null;
    }
    return null;
  }

  void getCallLog() async {
    await AppShared().getTimeInstallLocal();
    final connectivityResult = await Connectivity().checkConnectivity();
    Iterable<CallLogEntry> result = await CallLog.query();
    callLogEntries = result.toList();
    final dateInstall = DateTime.parse(AppShared.dateInstallApp);
    final date8HoursInstall =
        DateFormat('yyyy-MM-dd 08:00').format(dateInstall);
    int timeTamp8HoursInstall =
        DateTime.parse(date8HoursInstall).millisecondsSinceEpoch;
    for (var element in callLogEntries) {
      final date = DateTime.fromMillisecondsSinceEpoch(element.timestamp ?? 0);
      if (element.timestamp! >= timeTamp8HoursInstall) {
        mapCallLog.add(SyncCallLogModel(
            id: 'call&sim&${element.timestamp}&${AppShared.username}',
            phoneNumber: element.number,
            type: handlerCallType(element.callType),
            userId: accountController?.user?.id,
            method: 2,
            ringAt: '$date +0700',
            startAt: '$date +0700',
            endedAt: '$date +0700',
            answeredAt: '$date +0700',
            hotlineNumber: accountController?.user?.phone,
            callDuration: element.duration,
            endedBy: 1,
            customData: await handlerCustomData(element),
            answeredDuration: element.duration,
            recordUrl: ''));
      }
    }
    if (connectivityResult != ConnectivityResult.none) {
      syncCallLog();
    }
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
      Iterable<CallLogEntry> result = await CallLog.query();
      callLogEntries = result.toList();
    }
    loading.value = false;
  }

  Future<void> syncCallLog() async {
    await service.syncCallLog(listSync: mapCallLog);
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
    await getCallLogFromServer(
        page: page.value,
        search: searchCallLog.value == '' ? null : searchCallLog.value,
        startTime: startTime,
        endTime: endTime);
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
