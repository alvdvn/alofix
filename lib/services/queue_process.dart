import 'dart:async';
import 'dart:convert';

import 'package:base_project/database/db_context.dart';
import 'package:base_project/database/enum.dart';
import 'package:base_project/database/models/call_log.dart';
import 'package:base_project/extension.dart';
import 'package:base_project/queue.dart';
import 'package:base_project/services/SyncDb.dart';
import 'package:base_project/services/local/app_share.dart';
import 'package:call_log/call_log.dart' as DeviceCallLog;
import 'package:flutter/services.dart';

class QueueProcess {
  final dbService = SyncCallLogDb();
  static const platform = MethodChannel(AppShared.FLUTTER_ANDROID_CHANNEL);
  static final queue = Queue();

  Future<void> addFromDb() async {
    final db = await DatabaseContext.instance();
    var jobs = await db.jobs.getJobs();
    for (var element in jobs) {
      if (element.type == JobType.mapCall) {
        Map<String, dynamic> jsonObj = json.decode(element.payload);
        var callLog = CallLog.fromMap(jsonObj);
        queue.add(() => processQueue(callLog, element.id!));
      }
    }
  }

  Future<void> processQueue(CallLog callLog, int jobId) async {
    pprint("start queue");
    final db = await DatabaseContext.instance();
    CallLog dbCallLog = callLog;
    var entry = await findCallLogDevice(callLog: callLog);
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

      if (dbCallLog.type == CallType.incomming ||
          (dbCallLog.answeredDuration != null &&
              dbCallLog.answeredDuration! > 0)) {
        dbCallLog.callLogValid = CallLogValid.valid;
      } else if (dbCallLog.type == CallType.outgoing &&
          dbCallLog.answeredDuration == 0) {
        if ((dbCallLog.endedBy == EndBy.rider &&
                dbCallLog.timeRinging! < 10000) ||
            (dbCallLog.endedBy == EndBy.other &&
                dbCallLog.timeRinging! < 3000)) {
          dbCallLog.callLogValid = CallLogValid.invalid;
        }
      }

      if (dbCallLog.customData == null) {
        var deepLink = await dbService.findDeepLinkByCallLog(callLog: callLog);
        if (deepLink != null) {
          dbCallLog.customData = deepLink.data;
        }
      }
    }

    await db.callLogs.insertOrUpdateCallLog(dbCallLog);

    pprint(
        "Call save ${dbCallLog.id} - ${dbCallLog.phoneNumber} - ${dbCallLog.callLogValid} - ${dbCallLog.timeRinging} ${dbCallLog.callBy} ${dbCallLog.endedBy}");
    await db.jobs.deleteJobById(jobId);
    // await callLogController.loadDataFromDb();
    if (await queue.remainingItems.isEmpty) {
      await dbService.syncToServer();
    }
  }

  Future<DeviceCallLog.CallLogEntry?> findCallLogDevice({
    required CallLog callLog,
    int retry = 0,
  }) async {
    String callNumber = callLog.phoneNumber.replaceAll(RegExp(r'[^0-9]'), '');

    // Use Completer to handle the asynchronous result
    Completer<DeviceCallLog.CallLogEntry?> completer = Completer();

    // Use Future.delayed to introduce a delay
    Future.delayed(const Duration(milliseconds: 300), () async {
      try {
        Iterable<DeviceCallLog.CallLogEntry> result =
            await DeviceCallLog.CallLog.query(
          dateFrom: callLog.startAt - ((retry + 1) * 1000),
          dateTo: callLog.endedAt == null
              ? callLog.startAt + (Duration.secondsPerMinute * 5)
              : callLog.endedAt! + ((retry + 1) * 500),
          number: callNumber,
        );

        if (result.isEmpty) {
          if (retry == 20) {
            Iterable<DeviceCallLog.CallLogEntry> all =
                await DeviceCallLog.CallLog.query(
              dateFrom: callLog.startAt - 10000,
              number: callNumber,
            );
            completer.complete(all.first);
            return completer.future;
          }

          retry++;
          pprint(
              "findCallLog ${callLog.phoneNumber} - ${callLog.startAt} - $retry");

          // Recursively call the function and await the result
          DeviceCallLog.CallLogEntry? entry = await findCallLogDevice(
            callLog: callLog,
            retry: retry,
          );
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
