import 'dart:io';
import 'package:base_project/models/history_call_log_model.dart';
import 'package:base_project/models/sync_call_log_model.dart';
import 'package:base_project/services/responsitory/history_repository.dart';
import 'package:call_log/call_log.dart';
import 'package:get/get.dart';
import 'package:intl/intl.dart';

class CallLogController extends GetxController {
  RxList<CallLogEntry> callLogEntries = <CallLogEntry>[].obs;
  final service = HistoryRepository();
  List<HistoryCallLogModel> callLogSv = [];
  List<SyncCallLogModel> mapCallLog = [];
  RxBool isShowSearch = false.obs;
  RxBool isShowCalender = false.obs;
  DateTime now = DateTime.now();
  RxString timePicker = ''.obs;
  RxBool isDisable = false.obs;

  void initData() async {
    getCallLog();
    getCallLogFromServer();
  }

  void getCallLog() async {
    Iterable<CallLogEntry> result = await CallLog.query(
      // dateFrom: now.millisecondsSinceEpoch,
      // dateTo: now.millisecondsSinceEpoch,
    );
    callLogEntries.value = result.toList();
    for (var element in callLogEntries) {
      final date = DateTime.fromMillisecondsSinceEpoch(element.timestamp ?? 0);
      var d24 = DateFormat('yyyy-MM-dd HH:mm').format(date);
      mapCallLog.add(SyncCallLogModel(
          id: 'call- ${element.timestamp}',
          phoneNumber: element.number,
          type: element.callType == CallType.missed ? 1 : 2,
          userId: 2,
          method: 2,
          ringAt: '$d24 +0700',
          startAt: '$d24 +0700',
          endedAt: '$d24 +0700',
          answeredAt: '${element.duration}',
          hotlineNumber: element.number,
          callDuration: element.duration,
          endedBy: 1,
          answeredDuration: element.cachedNumberType,
          recordUrl: ''));
    }
    syncCallLog();
    getCallLogFromServer();
  }

  Future<void> getCallLogFromServer() async {
    final res = await service.getInformation();
    callLogSv = res ?? [];
    update();
  }

  Future<void> syncCallLog() async {
    final res = await service.syncCallLog(listSync: mapCallLog);
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
}
