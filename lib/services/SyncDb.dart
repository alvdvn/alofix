import 'package:base_project/database/db_context.dart';
import 'package:base_project/database/models/call_log.dart';
import 'package:base_project/database/models/deep_link.dart';
import 'package:base_project/extension.dart';
import 'package:base_project/services/local/app_share.dart';
import 'package:base_project/services/responsitory/history_repository.dart';
import 'package:call_log/call_log.dart' as DeviceCallLog;
import 'package:connectivity_plus/connectivity_plus.dart';
import 'package:flutter/material.dart';

class SyncCallLogDb {
  final service = HistoryRepository();

  Future<List<CallLog>> syncFromServer(
      {int page = 0, bool saveSyncTime = true}) async {
    final db = await DatabaseContext.instance();
    var data = await service.getInformation(page: page);
    await db.callLogs.batchInsertOrUpdate(data);
    if (saveSyncTime) {
      await AppShared().saveSyncTime(data.last.syncAt!);
    }

    return data;
  }

  Future<List<CallLog>> syncCallLogFromServer(
      {int page = 0,
      required DateTimeRange filterRange,
      bool saveSyncTime = true}) async {
    final db = await DatabaseContext.instance();
    var data = await service.getSearchData(
        dateTimeRange: filterRange, isFillTer: false);
    if (data.isNotEmpty) {
      db.callLogs.batchInsertOrUpdate(data);
      if (saveSyncTime) {
        await AppShared().saveSyncTime(data.last.syncAt!);
      }
    }

    return data;
  }

  Future<List<CallLog>> syncSearchDataFromServer(
      {int page = 0,
      required DateTimeRange filterRange,
      bool saveSyncTime = true}) async {
    final db = await DatabaseContext.instance();
    var data = await service.getSearchData(dateTimeRange: filterRange);
    if (data.isNotEmpty) {
      db.callLogs.batchInsertOrUpdate(data);
    }
    if (saveSyncTime) {
      await AppShared().saveSyncTime(data.last.syncAt!);
    }

    return data;
  }

  Future<List<CallLog>> getTopCallLogByPhone({required String phone}) async {
    final db = await DatabaseContext.instance();
    final connectivityResult = await Connectivity().checkConnectivity();
    if (ConnectivityResult.none != connectivityResult) {
      var data = await service.getDetailInformation(phone: phone);
      await db.callLogs.batchInsertOrUpdate(data);
      return await db.callLogs.getTopByPhone(phone);
    }
    return await db.callLogs.getTopByPhone(phone);
  }

  Future<List<CallLog>> syncFromDevice({required Duration duration}) async {
    try {
      final db = await DatabaseContext.instance();
      var lst = <CallLog>[];
      var minDate = DateTime.now().subtract(duration);

      Iterable<DeviceCallLog.CallLogEntry> result =
          await DeviceCallLog.CallLog.query(dateTimeFrom: minDate);
      lst = await Future.wait(
          result.where((element) => element.timestamp != null).map((e) async {
        var callLog = CallLog.fromEntry(entry: e);
        //map deepLink to CallLog
        if (callLog.customData == null || callLog.customData == "") {
          var deepLink = await findDeepLinkByCallLog(callLog: callLog);
          if (deepLink != null) {
            callLog.customData = deepLink.data;
          }
        }

        return callLog;
      }).toList());

      db.callLogs.batchInsertOrUpdate(lst);
      return lst;
    } catch (e) {
      return <CallLog>[];
    }
  }

  Future<DeepLink?> findDeepLinkByCallLog({required CallLog callLog}) async {
    final db = await DatabaseContext.instance();

    var timeToCheck =
        callLog.startAt - const Duration(minutes: 5).inMilliseconds;
    var found = await db.deepLinks.findDeepLinkByPhone(callLog.phoneNumber,
        callLog.startAt - timeToCheck, callLog.startAt + 1000);

    return found;
  }

  Future<bool> syncToServer({bool loadDevice = true}) async {
    final db = await DatabaseContext.instance();
    if (loadDevice) {
      await syncFromDevice(duration: const Duration(days: 1));
    }
    var time =
        DateTime.now().subtract(const Duration(days: 3)).millisecondsSinceEpoch;
    var lst = await db.callLogs.getCallLogToSync(time);
    if (lst.isEmpty) return true;
    var isSuccess = await service.syncCallLog(listSync: lst);
    pprint("sync ${lst.length} callogs $isSuccess");

    if (isSuccess) {
      var chunkedList = lst.chunk(50);
      for (var item in chunkedList) {
        await db.callLogs.updateSyncAt(item.map((e) => e.id).toList(),
            DateTime.now().millisecondsSinceEpoch);
      }

      await db.callLogs.cleanOld(DateTime.now()
          .subtract(const Duration(days: 7))
          .millisecondsSinceEpoch);
    }

    return isSuccess;
  }
}
