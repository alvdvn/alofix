import 'dart:async';
import 'dart:core';

import 'package:base_project/common/utils/global_app.dart';
import 'package:base_project/database/db_context.dart';
import 'package:base_project/database/models/call_log.dart';
import 'package:base_project/extension.dart';
import 'package:base_project/screens/call/call_controller.dart';
import 'package:base_project/services/SyncDb.dart';
import 'package:base_project/screens/account/account_controller.dart';
import 'package:base_project/services/local/app_share.dart';
import 'package:base_project/services/responsitory/history_repository.dart';
import 'package:floor/floor.dart';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:get/get.dart';
import 'package:permission_handler/permission_handler.dart';
import 'package:url_launcher/url_launcher.dart';


class CallLogController extends GetxController {
  final dbService = SyncCallLogDb();
  final callLogService = HistoryRepository();
  AccountController? accountController;
  RxMap<String, List<List<CallLog>>> callLogSv =
      RxMap<String, List<List<CallLog>>>();
  RxList<CallLog> callLogDetailSv = <CallLog>[].obs;
  int secondCall = 0;
  Timer? timer;
  RxBool isShowSearch = false.obs;
  RxBool isShowCalender = false.obs;
  RxBool isFilter = false.obs;
  RxBool loading = false.obs;
  RxString timePicker = ''.obs;
  RxBool isDisable = false.obs;
  RxInt page = 1.obs;
  RxString searchCallLog = ''.obs;
  RxBool loadingLoadMore = false.obs;
  DateTimeRange? filterRange;

  void initData({int? timeRing}) async {
    callLogSv.clear();

    final isHasPhonePermission =
        await Permission.phone.status == PermissionStatus.granted;
    if (!isHasPhonePermission) {
      final askStatus = await Permission.phone.request();
      if (askStatus == PermissionStatus.granted) {
        dbService.syncFromDevice(duration: const Duration(days: 3));
      }
    }
    await loadData();
  }

  Future<void> setTime(DateTimeRange? timeDate) async {
    filterRange = timeDate;
    if (timeDate != null) {
      DateTime startTime = timeDate.start;
      DateTime endTime = timeDate.end;
      timePicker.value =
          '${ddMMYYYYSlashFormat.format(startTime)} - ${ddMMYYYYSlashFormat.format(endTime)}';
    }
    await loadData();
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
    searchCallLog.value = "";
    filterRange = null;
    loadDataFromDb();
  }

  Future<void> onClickFilter() async {
    isFilter.value = !isFilter.value;
    page.value = 1;
  }

  Future<void> loadMore() async {
    page.value = page.value + 1;
    await loadData();
  }

  DateTimeRange getDateTimeRangeForCurrentMonth() {
    DateTime now = DateTime.now();

    DateTime firstDayOfMonth = DateTime(now.year, now.month, 1);

    DateTime lastDayOfMonth =
        DateTime(now.year, now.month + 1, 0, 23, 59, 59, 999);

    return DateTimeRange(start: firstDayOfMonth, end: lastDayOfMonth);
  }
 @transaction
  Future<void> loadDataFromDb() async {

    final db = await DatabaseContext.instance();

    var callLogs =
        await db.getCallLogs(range: filterRange, search: searchCallLog.value);
    callLogSv.value = callLogs.groupBy((c) => c.date).map((key, value) {
      var result = value.groupConsecutive((p0) => p0.phoneNumber);
      return MapEntry(key, result);
    });
  }
  @transaction
  Future<void> loadData() async {
    if (page.value == 1) {
      loading.value = true;
    } else {
      loadingLoadMore.value = true;
    }

    try {
      await dbService.syncFromServer(page: page.value);
    } catch (e) {
      if (page.value > 1) page.value = page.value - 1;
    }
    if(isShowCalender.value && filterRange!= null){
      await dbService.syncSearchDataFromServer(filterRange: filterRange!);
    }
    await loadDataFromDb();

    loading.value = false;
    loadingLoadMore.value = false;
  }

  void loadDetail(String phone) async {
    callLogDetailSv.clear();
    callLogDetailSv.value = await dbService.getTopCallLogByPhone(phone: phone);
  }

  void handCall(String phoneNumber) async {
    print('LOG: handCall $phoneNumber');
    const platform = MethodChannel(AppShared.FLUTTER_ANDROID_CHANNEL);
    await platform.invokeMethod(
        AppShared.CALL_OUT_COMING_CHANNEL, {'phone_out': phoneNumber});
  }

  void handSMS(String phoneNumber) {
    launchUrl(Uri(scheme: 'sms', path: phoneNumber));
  }
}
