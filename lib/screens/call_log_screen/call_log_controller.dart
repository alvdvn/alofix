import 'package:base_project/common/utils/global_app.dart';
import 'package:base_project/common/utils/progress_h_u_d.dart';
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
  List<CallLogEntry> callLogEntries = [];
  final service = HistoryRepository();
  AccountController? accountController;
  RxList<CallLogModel> callLogSv = <CallLogModel>[].obs;
  List<SyncCallLogModel> mapCallLog = [];
  RxBool isShowSearch = false.obs;
  RxBool isShowCalender = false.obs;
  RxBool loading = false.obs;
  DateTime now = DateTime.now();
  RxString timePicker = ''.obs;
  RxBool isDisable = false.obs;
  RxInt page = 1.obs;
  RxString searchCallLog = ''.obs;
  DateTime? _startTime;
  DateTime? _endTime;


  void initData() async {
    callLogSv.clear();
    getCallLog();
    page.value = 1;
    getCallLogFromServer(page: page.value);
  }

  // void dataInitial() async {
  //   Iterable<CallLogEntry> result = await CallLog.query();
  //   result.toList().forEach((element) {
  //     // print('');
  //   });
  //   // callcallsv.addAll(result);
  // }
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

  void setTime(DateTimeRange timeDate) async {
    DateTime startTime = timeDate.start;
    DateTime endTime = timeDate.end;
    _startTime = startTime;
    _endTime = endTime;
    timePicker.value =
        '${ddMMYYYYSlashFormat.format(startTime)} - ${ddMMYYYYSlashFormat.format(endTime)}';
    await getCallLogFromServer(
        page: page.value,
        search: searchCallLog.value,
        startTime: _startTime,
        endTime: _endTime,clearList: true);
  }

  Future<Map<String, String>?> handlerCustomData(CallLogEntry entry) async {
    String dateDeepLink = await AppShared().getDateDeepLink();
    String phoneDeepLink = await AppShared().getPhoneDeepLink();
    String idTrackDeepLink = await AppShared().getIdTrack();
    var dateCallLog = DateTime.fromMillisecondsSinceEpoch(entry.timestamp ?? 0);
    if (dateDeepLink != 'null') {
      var dateTimeDeepLink = DateTime.parse(dateDeepLink);
      var dateTimeCallLogFormatter =
          DateFormat('yyyy-MM-dd').format(dateCallLog);
      var dateTimeDeepLinkFormatter =
          DateFormat('yyyy-MM-dd').format(dateTimeDeepLink);
      if (dateTimeCallLogFormatter == dateTimeDeepLinkFormatter &&
          phoneDeepLink == entry.number &&
          dateCallLog.hour - dateTimeDeepLink.hour <= 2) {
        Map<String, String> data = {
          'phoneNumber': phoneDeepLink,
          'idTrack': idTrackDeepLink
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
    syncCallLog();
  }

  Future<void> getCallLogFromServer(
      {required int page,
      String? search,
      DateTime? startTime, DateTime? endTime,bool clearList = false}) async {
   loading.value = true;
    if(clearList == true) {
      callLogSv.clear();
    }
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
    await getCallLogFromServer(page: page.value);
  }

  void loadMore() async {
    await getCallLogFromServer(
        page: page.value += 1,
        search: searchCallLog.value,
        startTime: _startTime,
        endTime: _endTime);
  }

  void onRefresh() async {
    callLogSv.clear();
    page.value = 1;
    await getCallLogFromServer(
        page: page.value,
        search: searchCallLog.value == '' ? null : searchCallLog.value,
        startTime: _startTime,
        endTime: _endTime);
  }

  void handCall(String phoneNumber) {
    switch (AppShared.callTypeGlobal) {
      case '1':
        launchUrl(Uri(scheme: 'tel', path: phoneNumber));
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
