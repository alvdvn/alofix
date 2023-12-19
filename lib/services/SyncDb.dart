import 'package:base_project/database/DbContext.dart';
import 'package:base_project/database/models/call_log.dart';
import 'package:base_project/database/models/deep_link.dart';
import 'package:base_project/services/responsitory/history_repository.dart';
import 'package:call_log/call_log.dart' as DeviceCallLog;
import 'package:connectivity_plus/connectivity_plus.dart';

class SyncCallLogDb {
  final service = HistoryRepository();

  Future<List<CallLog>> syncFromServer({int page = 0}) async {
    final db = await DatabaseContext.instance();
    var data = await service.getInformation(page: page);
    db.callLogs.batchInsertOrUpdate(data);
    return data;
  }

  Future<List<CallLog>> getTopCallLogByPhone({required String phone}) async {
    final db = await DatabaseContext.instance();
    final connectivityResult = await Connectivity().checkConnectivity();
    if (ConnectivityResult.none != connectivityResult) {
      var data = await service.getDetailInformation(phone: phone);
      db.callLogs.batchInsertOrUpdate(data);
      return data;
    }
    return await db.callLogs.getTopByPhone(phone);
  }

  Future<List<CallLog>> syncFromDevice() async {
    final db = await DatabaseContext.instance();
    var lst = <CallLog>[];
    var minDate = DateTime.now().subtract(const Duration(days: 3));

    Iterable<DeviceCallLog.CallLogEntry> result =
        await DeviceCallLog.CallLog.query(dateTimeFrom: minDate);

    lst = await Future.wait(
        result.where((element) => element.timestamp != null).map((e) async {
      var callLog = CallLog.fromEntry(entry: e, isLocal: true);
      //map deepLink to CallLog
      if (callLog.customData == null || callLog.customData == "") {
        var deepLink = await findDeepLinkByCallLog(callLog: callLog, db: db);
        if (deepLink != null) {
          callLog.customData = deepLink.data;
        }
      }
      return callLog;
    }).toList());

    db.callLogs.batchInsertOrUpdate(lst);
    return lst;
  }

  Future<DeepLink?> findDeepLinkByCallLog(
      {required CallLog callLog, AppDatabase? db}) async {
    db ??= await DatabaseContext.instance();

    var timeToCheck =
        callLog.startAt - const Duration(minutes: 5).inMilliseconds;
    var found = await db.deepLinks.findDeepLinkByPhone(callLog.phoneNumber,
        callLog.startAt - timeToCheck, callLog.startAt + 2000);

    return found;
  }

  Future<void> syncToServer() async {
    final db = await DatabaseContext.instance();
    var time =
        DateTime.now().subtract(const Duration(days: 3)).microsecondsSinceEpoch;
    var lst = await db.callLogs.getCallLogToSync(time);

    var success = await service.syncCallLog(listSync: lst);
    if (success) {
      await db.callLogs.batchUpdate(lst);
    }
  }
}
