import 'dart:async';
import 'dart:math';

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
import 'package:flutter/services.dart';
import 'package:flutter_phone_direct_caller/flutter_phone_direct_caller.dart';
import 'package:g_json/g_json.dart';
import 'package:get/get.dart';
import 'package:intl/intl.dart';
import 'package:permission_handler/permission_handler.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'package:url_launcher/url_launcher.dart';

class CallLogController extends GetxController {
  final service = HistoryRepository();
  DateTime now = DateTime.now();
  AccountController? accountController;
  RxList<CallLogEntry> callLogEntries = <CallLogEntry>[].obs;
  RxList<CallLogModel> callLogSv = <CallLogModel>[].obs;
  RxList<CallLogModel> callLogLocal = <CallLogModel>[].obs;
  RxList<CallLogModel> callLogLocalSearch = <CallLogModel>[].obs;
  RxList<HistoryCallLogModel> callLogDetailSv = <HistoryCallLogModel>[].obs;
  RxList<HistoryCallLogModel> callLogLocalDetailSv = <HistoryCallLogModel>[].obs;
  List<SyncCallLogModel> mapCallLog = [];
  int secondCall = 0;
  Timer? timer;
  RxBool isShowSearch = false.obs;
  RxBool isShowSearchLocal = false.obs;
  RxBool isShowCalender = false.obs;
  RxBool loadDataLocal = false.obs;
  RxBool loadDetailLocal = false.obs;
  RxBool isFilter = false.obs;
  RxBool loading = false.obs;
  RxString timePicker = ''.obs;
  RxBool isDisable = false.obs;
  RxInt page = 1.obs;
  RxString searchCallLog = ''.obs;
  RxBool loadingLoadMore = false.obs;
  bool isEmpty = false;

  void initData({int? timeRing}) async {
    callLogSv.clear();
    callLogLocal.clear();
    callLogLocalSearch.clear();

    final isHasPhonePermission = await Permission.phone.status == PermissionStatus.granted;
    if (!isHasPhonePermission) {
      final askStatus = await Permission.phone.request();
      if (askStatus == PermissionStatus.granted) {
        doGetData();
      }

      if (askStatus == PermissionStatus.denied) {
        final askStatus = await Permission.phone.request();
        if (askStatus == PermissionStatus.granted) {
          doGetData();
        }

        if (askStatus == PermissionStatus.permanentlyDenied) {
          // TODO: show alert
          // alertPermission();
        }
      }
    } else {
      doGetData();
    }
  }

  Future<void> doGetData() async {
    final connectivityResult = await Connectivity().checkConnectivity();
    if (ConnectivityResult.none != connectivityResult) {
      loadDataLocal.value = false;
      await getCallLog();
      page.value = 1;
      await getCallLogFromServer(page: page.value, showLoading: true, clearList: true);
    } else {
      loadDataLocal.value = true;
      loading.value = true;
      await getCallLogFromDevice();
      loading.value = false;
      callLogLocalSearch.value = callLogLocal;
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
    loadDataLocal.value = false;
    var res = await service.getInformation(
            page: page,
            pageSize: 20,
            searchItem: search,
            startTime: startTime,
            endTime: endTime) ?? [];
    print("LOG: data res ban dau $res");
    if (res != []) {
      if (page == 1) {
        String valueLastSync = await AppShared().getLastDateCalLogSync();
        // print('LOG: valueLastSync $valueLastSync');
        int lastCallLogSync = valueLastSync == 'null' || valueLastSync.isEmpty ? 0 : int.parse(valueLastSync);
        var callLogInBGService = await AppShared().getCallLogBGSync();
        print("LOG: callLogInBGService $callLogInBGService");
        final listCache = JSON.parse(callLogInBGService).list?.map((e) => SyncCallLogModel.fromJson(e)).toList() ?? [];
        final String userName = await AppShared().getUserName();

        var arrayCalls = res.first.calls ?? [];
        for (var e in arrayCalls) {
          var logs = e.logs ?? [];
          for (int i = 0; i < logs.length; i++) {
            var startAt = DateTime.parse(logs[i].startAt ?? '').millisecondsSinceEpoch;
            // print('LOG: id compare ${logs[i].id.toString()} startAt ${DateTime.parse(logs[i].startAt ?? '').toLocal()} lastCallLogSync ${DateTime.fromMillisecondsSinceEpoch(lastCallLogSync)}}');
            if (startAt < lastCallLogSync) break;
              final id = 'call&sim&$startAt&$userName';
              var foundIndex = listCache.indexWhere((element) => element.id == logs[i].id || element.id == id);
              if (foundIndex != -1) {
                print('LOG: update gia tri ${logs[i].id.toString()}');
                logs[i].endedBy = listCache[foundIndex].endedBy;
              }
            logs[i].callLogValid = covedInvaidCall(logs[i]);
          }
        }
      }

      print("LOG: data res sau khi update $res");
      callLogSv.addAll(res);
    }
    isEmpty = callLogSv.isEmpty;
    loading.value = false;
  }

  int handlerCallType(CallType? callType) {
    if (callType == CallType.outgoing) {
      return 1;
    }
    return 2;
    // Todo: return 1 - Out và 2 - In, WTF ngược
  }

  void setTime(DateTimeRange? timeDate) async {
    if (timeDate != null) {
      DateTime startTime = timeDate.start;
      DateTime endTime = timeDate.end;
      timePicker.value = '${ddMMYYYYSlashFormat.format(startTime)} - ${ddMMYYYYSlashFormat.format(endTime)}';
    }
  }

  Future<void> onFilterCalenderLocal(
      {DateTime? startTime, DateTime? endTime, bool clearList = false}) async {
    debugPrint('onFilterCalenderLocal String tartTime $startTime');
    debugPrint('onFilterCalenderLocal String endTime$endTime');
    debugPrint('onFilterCalenderLocal startTime${DateFormat("dd-MM-yyyy").format(startTime!)}');
    debugPrint('onFilterCalenderLocal endTime${DateFormat("dd-MM-yyyy").format(endTime!)}');
    DateFormat("dd-MM-yyyy").format(endTime!);

    if (startTime == null && endTime == null) {
      callLogLocalSearch.value = callLogLocal;
    } else {
      List<CallLogModel> filteredCallLogLocal = callLogLocal.where((callLog) {
        final currentDate = DateTime.parse(callLog.key ?? "");
        return currentDate != null &&
            (currentDate.isAfter(startTime) ||
                currentDate.isAtSameMomentAs(startTime)) &&
            (currentDate.isBefore(endTime) ||
                currentDate.isAtSameMomentAs(endTime));
      }).toList();
      print('LOG: Filter Calender ${filteredCallLogLocal.obs.value}');
      callLogLocalSearch.value = filteredCallLogLocal;
      isEmpty = filteredCallLogLocal.isEmpty;
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
      isEmpty = filteredCallLogLocal.isEmpty;
    }
  }

  Future<void> getCallLogFromDevice() async {
    final prefs = await SharedPreferences.getInstance();
    await prefs.reload();
    var callLogInBGService = await AppShared().getCallLogBGSync();
    print("LOG: callLogInBGService $callLogInBGService");
    final listCache = JSON.parse(callLogInBGService).list?.map((e) => SyncCallLogModel.fromJson(e)).toList() ?? [];

    List<CallLogModel> data = listCache.map((element) {
      print("LOG: getCallLogFromDevice number: $element");
      var callLogValid = 0;
      var startAt = (element.startAt?.isEmpty ?? false) ? element.ringAt : element.startAt;
      final dateTime = DateTime.parse(startAt ?? '').toLocal().toString();
      callLogValid = covedInvaidCallSync(element);
      List<HistoryCallLogAppModel> calls = [HistoryCallLogAppModel(phoneNumber: element.phoneNumber, logs: [
          HistoryCallLogModel(
            phoneNumber: element.phoneNumber,
            timeRinging: element.timeRinging,
            answeredDuration: element.answeredDuration,
            startAt: '$dateTime +0700',
            method: element.method,
            type: element.type,
            hotlineNumber: element.hotlineNumber,
            recoredUrl: element.recordUrl,
            id: element.id,
            syncAt: '$dateTime +0700',
            endedBy: element.endedBy,
            callLogValid: callLogValid
          )
        ])
      ];

      final date = DateTime.parse(dateTime).toLocal();
      return CallLogModel(key: date.toString(), calls: calls);
    }).toList();

    print("LOG: data cache $data");

    callLogLocal.value = data;
    isEmpty = data.isEmpty;
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
        print('handlerCustomData $data');
        return AppShared.jsonDeepLink;
      }
      return null;
    }
    return null;
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

  void onClickCloseOffline() async {
    isShowSearch.value = false;
    isShowCalender.value = false;
    page.value = 1;
    searchCallLog.value = '';
    callLogLocalSearch.value = callLogLocal;
  }

  void onClickSearchLocal() {
    isShowSearchLocal.value = !isShowSearchLocal.value;
  }

  void onClickFilter() {
    isFilter.value = !isFilter.value;
  }

  void loadMore({String? search, DateTime? startTime, DateTime? endTime}) async {
    loadingLoadMore.value = true;
    await getCallLogFromServer(
        page: page.value += 1,
        search: search,
        startTime: startTime,
        endTime: endTime);
    loadingLoadMore.value = false;
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

  void loadDetail(String? search) async {
    final connectivityResult = await Connectivity().checkConnectivity();
    if (ConnectivityResult.none != connectivityResult) {
      loadDetailLocal.value = false;
      callLogDetailSv.clear();
      await loadCallLogSeverDetailByPhoneNumber(search: search);
    } else {
      loadDetailLocal.value = true;
      callLogLocalDetailSv.clear();
      await getCallLogFromDevice();
      final res = callLogLocal.value;
      if (res != []) {
        List<HistoryCallLogModel>? logs = [];
        for (var e in res) {
          for (var c in e.calls ?? []) {
            for (var log in c.logs ?? []) {
              logs.add(log);
            }
          }
        }
        final data = logs.where((item) => item.phoneNumber == search).toList();
        callLogLocalDetailSv.addAll(data);
      }
    }
  }

  Future<void> loadCallLogSeverDetailByPhoneNumber({String? search, DateTime? startTime, DateTime? endTime}) async {
    loading.value = true;
    callLogDetailSv.clear();
    loadDetailLocal.value = false;
    final res = await service.getDetailInformation(searchItem: search, startTime: startTime, endTime: endTime) ?? [];
    if (res != []) {
      String valueLastSync = await AppShared().getLastDateCalLogSync();
      // print('LOG: valueLastSync $valueLastSync');
      int lastCallLogSync = valueLastSync == 'null' || valueLastSync.isEmpty ? 0 : int.parse(valueLastSync);
      var callLogInBGService = await AppShared().getCallLogBGSync();
      print("LOG: callLogInBGService $callLogInBGService");
      final listCache = JSON.parse(callLogInBGService).list?.map((e) => SyncCallLogModel.fromJson(e)).toList() ?? [];
      List<HistoryCallLogModel>? logs = [];

      for (var e in res) {
        for (var c in e.calls ?? []) {
          for (var log in c.logs ?? []) {
            logs.add(log);
          }
        }
      }
      final data = logs.where((item) => item.phoneNumber == search).toList();
      for (int i = 0; i < data.length; i++) {
        // print('id compare ${data[i].id.toString()}');
        var startAt = DateTime.parse(data[i].startAt ?? '').millisecondsSinceEpoch;
        if (startAt < lastCallLogSync) break;
        final String userName = await AppShared().getUserName();
        final id = 'call&sim&$startAt&$userName';

        var foundIndex = listCache.indexWhere((element) => element.id == id || element.id == data[i].id);
        if (foundIndex != -1) {
          // print('update gia tri ${data[i].id.toString()}');
          data[i].endedBy = listCache[foundIndex].endedBy;
        }
        data[i].callLogValid = covedInvaidCall(data[i]);
      }
      callLogDetailSv.addAll(data);
      print('LOG: loadCallLogSeverDetailByPhoneNumber callLogDetailSv $callLogDetailSv');
    }
    loading.value = false;

    var arrayCalls = res.first.calls ?? [];
    for (var e in arrayCalls) {

    }
  }

  void handCall(String phoneNumber) async {
    print('LOG: handCall $phoneNumber');
    const platform = MethodChannel(AppShared.FLUTTER_ANDROID_CHANNEL);
    await platform.invokeMethod(AppShared.CALL_OUT_COMING_CHANNEL, {'phone_out': phoneNumber});
  }

  void directCall(String phoneNumber) {
    FlutterPhoneDirectCaller.callNumber(phoneNumber);
  }

  void handSMS(String phoneNumber) {
    launchUrl(Uri(scheme: 'sms', path: phoneNumber));
  }

  int setAnsweredDuration(CallType? callType, int duration) {
    // print("LOG: setAnsweredDuration $callType");
    if ((callType == CallType.incoming || callType == CallType.outgoing) && (duration > 0)) {
      return duration;
    } else {
      return 0;
    }
  }

  int covedInvaidCall(HistoryCallLogModel element)  {
    var callLogValid = 0;
    if ((element.type == 1 && element.answeredDuration == 0 && (element.timeRinging == null) && element.endedBy == 1)
        || (element.type == 1 && element.answeredDuration == 0 && (element.timeRinging == null) && element.endedBy == null)) {
      callLogValid = 0;
    } else if (element.type == 1 && element.answeredDuration == 0 && ((element.timeRinging ?? 0) < 10000) && element.endedBy == 1) {
      callLogValid = 2;
    } else if (element.type == 1 && element.answeredDuration == 0 && ((element.timeRinging ?? 0) <= 3000) && (element.endedBy != 1 || element.endedBy == null)) {
      callLogValid = 2;
    } else {
      callLogValid = 0;
    }
    print('LOG: covedInvaidCall $callLogValid HistoryCallLogModel $element');
    return callLogValid;
  }

  int covedInvaidCallSync(SyncCallLogModel element)  {
    var callLogValid = 0;
    if ((element.type == 1 && element.answeredDuration == 0 && (element.timeRinging == null) && element.endedBy == 1)
        || (element.type == 1 && element.answeredDuration == 0 && (element.timeRinging == null) && element.endedBy == null)) {
      callLogValid = 0;
    } else if (element.type == 1 && element.answeredDuration == 0 && ((element.timeRinging ?? 0) < 10000) && element.endedBy == 1) {
      callLogValid = 2;
    } else if (element.type == 1 && element.answeredDuration == 0 && ((element.timeRinging ?? 0) <= 3000) && (element.endedBy != 1 || element.endedBy == null)) {
      callLogValid = 2;
    } else {
      callLogValid = 0;
    }
    print('LOG: covedInvaidCallSync $callLogValid HistoryCallLogModel $element');
    return callLogValid;
  }


  Future<void> getCallLog() async {
    final prefs = await SharedPreferences.getInstance();
    await prefs.reload();
    await AppShared().getTimeInstallLocal();
    String valueLastDateSync = await AppShared().getLastDateCalLogSync();
    // print('LOG: LastDateSync CallLogController $valueLastDateSync');
    final String userName = await AppShared().getUserName();
    Iterable<CallLogEntry> result = await CallLog.query();
    callLogEntries.value = result.toList();
    final int lastCallLogSync = valueLastDateSync == 'null' || valueLastDateSync.isEmpty ? 0 : int.parse(valueLastDateSync);
    final thirdDaysAgo = DateTime.now().subtract(const Duration(days: 3)).millisecondsSinceEpoch;
    // print('LOG: lastCallLogSync $lastCallLogSync');
    // print('LOG: userName $userName');
    // print('LOG: thirdDaysAgo $thirdDaysAgo');
    mapCallLog.clear();
    for (var element in callLogEntries) {
      final date = DateTime.fromMillisecondsSinceEpoch(element.timestamp ?? 0);
      final isAddToSync = lastCallLogSync == 0
          ? element.timestamp! >= thirdDaysAgo
          : element.timestamp! > lastCallLogSync;
      // print('LOG: Element Object in for ${element.timestamp.toString()} phoneNumber ${element.number.toString()} hotlineNumber ${accountController?.user?.phone.toString()}');
      // print('LOG: date in Element $date');
      // time cua callLog >= time dong bo tu luc 8h cai app VA time cua callLog >=
      if (isAddToSync && userName.isNotEmpty) {
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
            timeRinging: null,
            hotlineNumber: (accountController?.user?.phone?.isNotEmpty ?? false) ? accountController?.user?.phone : "",
            callDuration: element.callType == CallType.incoming || element.callType == CallType.rejected ? 0 : element.duration,
            endedBy: null, // EndBy: 1: Rider, 2: Khách
            customData: await handlerCustomData(element),
            answeredDuration: setAnsweredDuration(element.callType, element.duration ?? 0),
            recordUrl: '',
            time1970: element.timestamp!,
            syncBy: 2, // syncBy, 1: Đồng bộ bằng BG service, 2: Đồng bộ bằng các luồng khác
            callBy: 2, // callBy, 1: Cuộc gọi được thực hiện qua Alo2, 2: Bên ngoài Alo2
            callLogValid: 0)); // callLogValid, 1: Hợp lệ, 2: Không hợp lệ,
      }
    }
    var callLogInBGService = await AppShared().getCallLogBGSync();
    print("LOG: SYNC getCallLogBGSync $callLogInBGService");
    final listCache = JSON.parse(callLogInBGService).list?.map((e) => SyncCallLogModel.fromJson(e)).toList() ?? [];

    for (int i = 0; i < mapCallLog.length; i++) {
      for (var item in listCache) {
        var startAt = DateTime.parse(item.startAt ?? '').millisecondsSinceEpoch;
        final id = 'call&sim&$startAt&$userName';
        print('LOG: getCall id listCache $id && idMap ${mapCallLog[i].id}');
        if (id == mapCallLog[i].id || item.id == mapCallLog[i].id) {
          print('LOG: SYNC getCall First datasCLEndBy $id item $item');
          mapCallLog[i].endedBy = item.endedBy;
          mapCallLog[i].timeRinging = item.timeRinging;
          if (mapCallLog[i].endedBy == 1) {
            mapCallLog[i].callBy = 1;
          }
          break;
        }
      }
      mapCallLog[i].callLogValid = covedInvaidCallSync(mapCallLog[i]);
    }

    syncCallLog();
  }


  Future<void> syncCallLog() async {
    try {
      await service.syncCallLog(listSync: mapCallLog);
    } catch (_) {}
  }
}
