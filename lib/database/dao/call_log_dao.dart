import 'package:base_project/database/enum.dart';
import 'package:base_project/database/models/call_log.dart';
import 'package:base_project/extension.dart';
import 'package:floor/floor.dart';

@dao
abstract class CallLogDao {
  @Query('SELECT * FROM CallLog order by startAt desc')
  Future<List<CallLog>> getAllCallLogs();

  @Query('SELECT * FROM CallLog where date = :date order by startAt desc')
  Future<List<CallLog>> getCallLogsByDate(String date);

  @Query('SELECT * FROM CallLog WHERE id = :id')
  Future<CallLog?> find(String id);

  @Query('delete from CallLog')
  Future<void> clean();

  @Query('delete from CallLog where startAt < :maxTime')
  Future<void> cleanOld(int maxTime);

  @Query(
      "select * from CallLog where phoneNumber = :phone order by startAt desc limit 100")
  Future<List<CallLog>> getTopByPhone(String phone);

  @Query('select * from CallLog where syncAt is null and startAt >= :minStartAt')
  Future<List<CallLog>> getCallLogToSync(int minStartAt);

  @Query('SELECT * FROM CallLog WHERE id in (:ids)')
  Future<List<CallLog>> findByIds(List<String> ids);
  @Query("SELECT * FROM CallLog WHERE syncAt IS NOT NULL ORDER BY syncAt DESC LIMIT 1")
  Future<List<CallLog>> getLastSyncCallLog();
  @Query(
      "SELECT startAt FROM CallLog where startAt < :maxTime ORDER BY startAt DESC LIMIT 1")
  Future<int?> getLastStartAt(int maxTime);

  @insert
  Future<void> insertCallLog(CallLog callLog);

  @update
  Future<void> updateCallLog(CallLog callLog);

  @transaction
  Future<void> batchUpdate(List<CallLog> callLogs) async {
    for (var item in callLogs) {
      await updateCallLog(item);
    }
  }

  @transaction
  Future<CallLog> insertOrUpdateCallLog(CallLog callLog) async {
    var found = await find(callLog.id);
    if (found == null) {
      await insertCallLog(callLog);

      return callLog;
    }

    if ((found.endedBy == null && callLog.endedBy != null) ||
        (found.endedAt == null && callLog.endedAt != null) ||
        (found.customData == null && callLog.customData != null) ||
        (found.callBy == CallBy.other && callLog.callBy == CallBy.alo) ||
        (found.syncAt == null && callLog.syncAt != null)) {
      if (found.endedBy == null && callLog.endedBy != null) {
        found.endedBy = callLog.endedBy;
      }

      if (found.endedAt == null && callLog.endedAt != null) {
        found.endedAt = callLog.endedAt;
      }
      if (found.callBy == CallBy.other && callLog.callBy == CallBy.alo) {
        found.callBy = callLog.callBy;
      }
      if (found.customData == null && callLog.customData != null) {
        found.customData = callLog.customData;
      }

      if (found.syncAt == null && callLog.syncAt != null) {
        found.syncAt = callLog.syncAt;
      }
      if (callLog.type == CallType.incomming ||
          (callLog.answeredDuration != null && callLog.answeredDuration! > 0)) {
        found.callLogValid = CallLogValid.valid;
      } else if (callLog.type == CallType.outgoing &&
          callLog.answeredDuration == 0) {
        if ((callLog.endedBy == EndBy.rider && callLog.timeRinging! < 10000) ||
            (callLog.endedBy == EndBy.other && callLog.timeRinging! < 3000)) {
          found.callLogValid = CallLogValid.invalid;
        }
      }
      if (found.timeRinging == null && callLog.timeRinging != null) {
        found.timeRinging = callLog.timeRinging;
      }
      await updateCallLog(found);
    }
    return found;
  }

  @transaction
  Future<void> batchInsertOrUpdate(List<CallLog> callLogs) async {
    var chunks = callLogs.chunk(50);

    for (var lst in chunks) {
      var ids = lst.map((e) => e.id).toList(); //  id array in list from device
      var founds = await findByIds(ids); // call_log array in db

      var missing = lst.where((item) => !founds.any((f) => f.id == item.id));
      for (var found in founds) {
        var item = lst.where((element) => element.id == found.id).first;
        if ((found.endedBy == EndBy.other && item.endedBy != null) ||
            (found.endedAt == null && item.endedAt != null) ||
            (item.syncAt != null)) {
          if(found.callLogValid == CallLogValid.valid && item.callLogValid != null){
            found.callLogValid = item.callLogValid;
          }
          if (found.endedBy == EndBy.other && item.endedBy != null) {
            found.endedBy = item.endedBy;
          }
          if (found.endedAt == null && item.endedAt != null) {
            found.endedAt = item.endedAt;
          }

          if (item.syncAt != null) {
            found.syncAt = item.syncAt;
          }
          if (found.timeRinging == null && item.timeRinging != null) {
            found.timeRinging = item.timeRinging;
          }
          await updateCallLog(found);
        }
      }

      for (var m in missing) {
        await insertCallLog(m);
      }
    }
  }
}
