import 'package:base_project/models/history_call_log_model.dart';
import 'package:base_project/models/sync_call_log_model.dart';
import 'package:base_project/screens/account/account_controller.dart';
import 'package:base_project/services/local/app_share.dart';
import 'package:base_project/services/responsitory/history_repository.dart';
import 'package:call_log/call_log.dart';
import 'package:get/get.dart';
import 'package:intl/intl.dart';

class CallLogController extends GetxController {
  RxList<CallLogEntry> callLogEntries = <CallLogEntry>[].obs;
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
    getCallLogFromServer();
  }

  void getCallLog() async {
    await AppShared().getTimeInstallLocal();
    int now = DateTime.now().millisecondsSinceEpoch;
    print('time install --> ${AppShared.dateInstallApp}');
    // int installApp =
    //     DateTime.parse(AppShared.dateInstallApp).microsecondsSinceEpoch;
    Iterable<CallLogEntry> result = await CallLog.query(
      // dateFrom: installApp,
      // dateTo: now,
    );
    callLogEntries.value = result.toList();
    for (var element in callLogEntries) {
      final date = DateTime.fromMillisecondsSinceEpoch(element.timestamp ?? 0);
      mapCallLog.add(SyncCallLogModel(
          id: 'call- ${element.timestamp}',
          phoneNumber: element.number,
          type: element.callType == CallType.incoming ? 1 : 2,
          userId: 2,
          method: 2,
          ringAt: date.toString(),
          startAt: date.toString(),
          endedAt: date.toString(),
          answeredAt: '${element.duration}',
          hotlineNumber: accountController?.user?.phone,
          callDuration: element.duration,
          endedBy: 1,
          answeredDuration: element.duration,
          recordUrl: ''));
    }
    syncCallLog();
  }

  Future<void> getCallLogFromServer({int? page}) async {
    final res =
        await service.getInformation(page: page ?? 1, pageSize: 20) ?? [];
    if (res != []) {
      callLogSv.addAll(res);
    }
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
    String timeFirst = DateFormat('dd/MM/yyyy').format(now);
    String timeSecond = '15/09/2022';
    timePicker.value = '$timeFirst - $timeSecond';
  }

  void onClickClose() {
    isShowSearch.value = false;
    isShowCalender.value = false;
  }

  void loadMore() async {
    await getCallLogFromServer(page: page++);
  }

  void onRefresh() async {
    callLogSv.clear();
    page = 1;
    await getCallLogFromServer(page: page);
  }
}
