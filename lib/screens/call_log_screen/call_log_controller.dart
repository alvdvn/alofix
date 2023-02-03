import 'dart:io';
import 'package:base_project/models/history_call_log_model.dart';
import 'package:base_project/services/responsitory/history_repository.dart';
import 'package:call_log/call_log.dart';
import 'package:get/get.dart';

class CallLogController extends GetxController {
  List<CallLogEntry> callLogEntries = <CallLogEntry>[].obs;
  final service = HistoryRepository();
  List<HistoryCallLogModel>? callLogSv;
  RxBool isShowSearch = false.obs;
  RxBool isShowCalender = false.obs;

  @override
  void onInit() {
    super.onInit();
    getCallLogFromServer();
    if (Platform.isAndroid) {
      getCallLog();
    }
  }

  void getCallLog() async {
    Iterable<CallLogEntry> result = await CallLog.query();
    callLogEntries = result.toList();
    update();
  }

  Future<void> getCallLogFromServer() async {
    final res = await service.getInformation();
    callLogSv = res;
  }

  void onClickSearch() {
    isShowSearch.value = true;
    isShowCalender.value = false;
  }

  void onClickCalender() {
    isShowSearch.value = false;
    isShowCalender.value = true;
  }

  void onClickClose() {
    isShowSearch.value = false;
    isShowCalender.value = false;
  }
}
