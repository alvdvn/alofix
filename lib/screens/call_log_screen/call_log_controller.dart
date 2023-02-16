import 'package:base_project/models/history_call_log_model.dart';
import 'package:base_project/models/sync_call_log_model.dart';
import 'package:base_project/screens/account/account_controller.dart';
import 'package:base_project/services/local/app_share.dart';
import 'package:base_project/services/responsitory/history_repository.dart';
import 'package:call_log/call_log.dart';
import 'package:flutter/cupertino.dart';
import 'package:flutter_phone_direct_caller/flutter_phone_direct_caller.dart';
import 'package:get/get.dart';
import 'package:intl/intl.dart';
import 'package:url_launcher/url_launcher.dart';

class CallLogController extends GetxController {
  List<CallLogEntry> callLogEntries = [];
  final service = HistoryRepository();
  AccountController? accountController;
  RxList<HistoryCallLogModel> callLogSv = <HistoryCallLogModel>[].obs;
  List<SyncCallLogModel> mapCallLog = [];
  RxBool isShowSearch = false.obs;
  RxBool isShowCalender = false.obs;
  DateTime now = DateTime.now();
  RxString timePicker = ''.obs;
  RxBool isDisable = false.obs;
  int page = 1;

  void initData() async {
    callLogSv.clear();
    getCallLog();
    getCallLogFromServer(page: page);
  }

  void getCallLog() async {
    await AppShared().getTimeInstallLocal();
    Iterable<CallLogEntry> result = await CallLog.query();
    callLogEntries = result.toList();
    final dateInstall = DateTime.parse(AppShared.dateInstallApp);
    final date8HoursInstall = DateFormat('yyyy-MM-dd 08:00').format(dateInstall);
    int timeTamp8HoursInstall = DateTime.parse(date8HoursInstall).millisecondsSinceEpoch;
    for (var element in callLogEntries) {
      final date = DateTime.fromMillisecondsSinceEpoch(element.timestamp ?? 0);
      if (element.timestamp! >= timeTamp8HoursInstall) {
        mapCallLog.add(SyncCallLogModel(
            id: 'call- ${element.timestamp}',
            phoneNumber: element.number,
            type: element.callType == CallType.incoming ? 1 : 2,
            userId: 2,
            method: 2,
            ringAt: "${date.toLocal().toString()} ",
            startAt: "${date.toLocal().toString()} ",
            endedAt: "${date.toLocal().toString()} ",
            answeredAt: "${date.toLocal().toString()} ",
            hotlineNumber: accountController?.user?.phone,
            callDuration: element.duration,
            endedBy: 1,
            answeredDuration: element.duration ?? 0,
            recordUrl: ''));
      }
    }
    syncCallLog();
  }

  Future<void> getCallLogFromServer({required int page}) async {
    final res = await service.getInformation(page: page , pageSize: 20) ?? [];
    if (res != []) {
      callLogSv.addAll(res);
    }
  }


  Future<void> syncCallLog() async {
    if (AppShared.jsonDeepLink == "") {
      await service.syncCallLog(listSync: mapCallLog);
    } else {
      List<SyncCallLogModel> listSync = [];
      final date = DateTime.fromMillisecondsSinceEpoch(
          callLogEntries.first.timestamp ?? 0);
      listSync.add(SyncCallLogModel(
          id: 'call-${callLogEntries.first.timestamp}',
          phoneNumber: callLogEntries.first.number,
          type: callLogEntries.first.callType == CallType.incoming ? 1 : 2,
          userId: 2,
          method: 2,
          ringAt: date.toString(),
          startAt: date.toString(),
          endedAt: date.toString(),
          answeredAt: '${callLogEntries.first.duration}',
          hotlineNumber: accountController?.user?.phone,
          callDuration: callLogEntries.first.duration,
          endedBy: 1,
          customData: AppShared.jsonDeepLink,
          answeredDuration: callLogEntries.first.duration,
          recordUrl: ""));
      await service.syncCallLog(listSync: listSync);
      AppShared.jsonDeepLink = "";
    }
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
    String timeFirst = DateFormat('dd/MM/yyyy').format(now);
    String timeSecond = '15/09/2022';
    timePicker.value = '$timeFirst - $timeSecond';
  }

  void onClickClose() {
    isShowSearch.value = false;
    isShowCalender.value = false;
  }

  void loadMore() async {
    await getCallLogFromServer(page: page+=1);
  }

  void onRefresh() async {
    callLogSv.clear();
    page = 1;
    await getCallLogFromServer(page: page);
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
