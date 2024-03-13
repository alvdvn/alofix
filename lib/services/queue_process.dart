import 'dart:async';
import 'dart:convert';

import 'package:base_project/database/db_context.dart';
import 'package:base_project/database/enum.dart';
import 'package:base_project/database/models/call_log.dart';
import 'package:base_project/extension.dart';
import 'package:base_project/queue.dart';
import 'package:base_project/screens/call_log_screen/call_log_controller.dart';
import 'package:base_project/services/SyncDb.dart';
import 'package:base_project/services/local/app_share.dart';
import 'package:call_log/call_log.dart' as DeviceCallLog;
import 'package:flutter/services.dart';
import 'package:get/get.dart';
import 'package:sentry_flutter/sentry_flutter.dart';
import 'package:shared_preferences/shared_preferences.dart';

import '../screens/call_log_screen/call_log_controller.dart';
import '../screens/home/home_controller.dart';

class QueueProcess {
  final dbService = SyncCallLogDb();
  static const platform = MethodChannel(AppShared.FLUTTER_ANDROID_CHANNEL);
  CallLogController callLogController = Get.put(CallLogController());
  static final queue = Queue();

  Future<void> addFromSP() async {
    var sp = await SharedPreferences.getInstance();
    await sp.reload();
    var keys =
    sp.getKeys().where((element) => element.startsWith("backup_callog"));
    if (keys.isEmpty) {
      dbService.syncFromDevice(duration: Duration(hours: 8));
      callLogController.loadDataFromDb();
      await dbService.syncToServer(loadDevice: false);
      return;
    } else {
      for (var element in keys) {
        pprint("processBackup $element");
        var payload = sp.getString(element);
        if (payload == null) continue;
        Map<String, dynamic> jsonObj = json.decode(payload);
        var callLog = CallLog.fromMap(jsonObj);
        queue.add(() => processQueue(callLog: callLog));
      }
      await queue.onComplete;
      callLogController.loadDataFromDb();
      await dbService.syncToServer(loadDevice: false);
    }
  }

  Future<void> processQueue({required CallLog callLog, int? jobId}) async {
    final transaction = Sentry.startTransaction('processQueue', 'task');
    final db = await DatabaseContext.instance();
    var backupKey = "backup_callog_${callLog.startAt}";
    CallLog dbCallLog = callLog;
    var entry = await findCallLogDevice(callLog: callLog,span: transaction);
    if (entry != null) {
      // var mTimeRinging = CallHistory.getRingTime(mCall.duration, mCall.startAt, endTime, mType)
      dbCallLog = CallLog.fromEntry(entry: entry);
      dbCallLog.endedBy = callLog.endedBy;
      dbCallLog.endedAt = callLog.endedAt;
      dbCallLog.callBy = callLog.callBy;
      dbCallLog.method = callLog.method;
      dbCallLog.type = callLog.type;
      dbCallLog.syncBy = callLog.syncBy;
      dbCallLog.callLogValid = CallLogValid.valid;

      if (callLog.endedAt != null) {
        dbCallLog.timeRinging =
        (dbCallLog.endedAt! - dbCallLog.startAt - entry.duration! * 1000);

        dbCallLog.answeredAt = entry.duration != null
            ? callLog.endedAt! - entry.duration! * 1000
            : null;
      }
      dbCallLog.callDuration = (callLog.endedAt! - callLog.startAt) ~/ 1000;
    try {
      var entry = await findCallLogDevice(callLog: callLog, span: transaction);
        dbCallLog = CallLog.fromEntry(entry: entry);
        dbCallLog.endedBy = callLog.endedBy;
        dbCallLog.endedAt = callLog.endedAt;
        dbCallLog.callBy = callLog.callBy;
        dbCallLog.method = callLog.method;
        dbCallLog.type = callLog.type;
        dbCallLog.syncBy = callLog.syncBy;
        dbCallLog.callLogValid = CallLogValid.valid;
        if (callLog.endedAt != null) {
          dbCallLog.timeRinging =
          (dbCallLog.endedAt! - dbCallLog.startAt - entry.duration! * 1000);
          dbCallLog.answeredAt = entry.duration != null
              ? callLog.endedAt! - entry.duration! * 1000
              : null;
        }
        dbCallLog.callDuration =
            (callLog.endedAt! - callLog.startAt) ~/ 1000;

        if (dbCallLog.customData == null) {
          var deepLink = await dbService.findDeepLinkByCallLog(
              callLog: callLog);
          dbCallLog.customData = deepLink?.data;
        }

      dbCallLog.callLogValid = await invalidCheck(dbCallLog);
      await db.callLogs.insertOrUpdateCallLog(dbCallLog);
      var sp = await SharedPreferences.getInstance();
      sp.remove(backupKey);
      pprint(
          "Call save ${dbCallLog.id} - ${dbCallLog.phoneNumber} - ${dbCallLog.callLogValid} - ${dbCallLog.timeRinging}- callBy: ${dbCallLog.callBy}-${dbCallLog.endedBy}");
      if (jobId != null) {
        await db.jobs.deleteJobById(jobId);
      }
      await transaction.finish();
    } catch (e) {
      transaction.throwable = e;
      transaction.status = const SpanStatus.internalError();
      await transaction.finish();
      }
    }
    dbCallLog.callLogValid = await invalidCheck(dbCallLog);
    await db.callLogs.insertOrUpdateCallLog(dbCallLog);
    var sp = await SharedPreferences.getInstance();
    sp.remove(backupKey);
    pprint(
        "Call save ${dbCallLog.id} - ${dbCallLog.phoneNumber} - ${dbCallLog
            .callLogValid} - ${dbCallLog.timeRinging}- callBy: ${dbCallLog
            .callBy}-${dbCallLog.endedBy}");
    if (jobId != null) {
      await db.jobs.deleteJobById(jobId);
    }

  }

  Future<CallLogValid> invalidCheck(CallLog dbCallLog) async {
    if (dbCallLog.type == CallType.incomming ||
        (dbCallLog.answeredDuration != null &&
            dbCallLog.answeredDuration! > 0)) {
      return CallLogValid.valid;
    } else if (dbCallLog.type == CallType.outgoing &&
        dbCallLog.answeredDuration == 0) {
      if ((dbCallLog.endedBy == EndBy.rider &&
          dbCallLog.timeRinging! < 10000) ||
          (dbCallLog.endedBy == EndBy.other &&
              dbCallLog.timeRinging! <= 3000)) {
        return CallLogValid.invalid;
      }
    }
    return CallLogValid.valid;
  }

  Future<DeviceCallLog.CallLogEntry> findCallLogDevice({
    required CallLog callLog,
    required ISentrySpan span,
    int retry = 0,
  }) async {
    String callNumber =
    callLog.phoneNumber.replaceAll(RegExp(r'[^0-9*#+]'), '');

    Completer<DeviceCallLog.CallLogEntry> completer = Completer();

    Future.delayed(const Duration(milliseconds: 500), () async {
      final innerSpan =
      span.startChild('task', description: 'find call log retry $retry');
      innerSpan.setData("callLog", callLog);
      try {
        Iterable<DeviceCallLog.CallLogEntry> result =
        await DeviceCallLog.CallLog.query(
          dateFrom: callLog.startAt - ((retry + 1) * 500),
          dateTo: callLog.endedAt == null
              ? null
              : callLog.endedAt! + ((retry + 1) * 500),
          number: callNumber,
        );

        if (result.isEmpty) {
          if (retry == 20) {
            var allCallInHour = await DeviceCallLog.CallLog.query(
              dateFrom: callLog.startAt - Duration.millisecondsPerHour,
            );
            innerSpan.setData("allCall", allCallInHour);
            completer.completeError(
                "CallLog ${callLog.phoneNumber} at ${callLog.startAt} not found");
            return completer.future;
          }
          retry++;
          pprint(
              "findCallLog ${callLog.phoneNumber} - ${callLog.startAt} - $retry");
          DeviceCallLog.CallLogEntry entry = await findCallLogDevice(
              callLog: callLog, retry: retry, span: innerSpan);

          if (callLog.endedAt != null && entry.timestamp! < callLog.endedAt!) {
            retry++;
            entry = await findCallLogDevice(
                callLog: callLog, retry: retry, span: innerSpan);
            await innerSpan.finish();
            completer.complete(entry);
            return completer.future;
          }
          await innerSpan.finish();
          pprint("found $entry");
          completer.complete(entry);
        } else {
          completer.complete(result.first);
        }
      } catch (e) {
        pprint("Lỗi khi tìm calllog ${e.toString()}");
        // Handle any exceptions that may occur during the async operations
        completer.completeError(e);
      }
    });

    // Return the Future from the Completer
    return completer.future;
  }
}
