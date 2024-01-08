import 'dart:convert';
import 'dart:core';

import 'package:base_project/common/utils/global_app.dart';
import 'package:base_project/database/enum.dart';
import 'package:base_project/models/custom_data_model.dart';
import 'package:base_project/services/local/app_share.dart';
import 'package:call_log/call_log.dart' as DeviceCallLog;
import 'package:floor/floor.dart';
import 'package:g_json/g_json.dart';
import 'package:intl/intl.dart';

@entity
class CallLog {
  @primaryKey
  String id = "";
  String phoneNumber = "";
  String? hotlineNumber = "";
  int startAt = 0;
  int? endedAt;
  int? answeredAt;
  CallType? type; // 1 Out 2 In - replace callType
  int? callDuration;
  EndBy? endedBy;
  SyncBy?
      syncBy; // syncBy, 1: Đồng bộ bằng BG service, 2: Đồng bộ bằng các luồng khác
  int? answeredDuration;
  int? timeRinging;

  // final CustomData: DeepLink?,
  CallMethod method = CallMethod.sim;
  CallBy callBy = CallBy.other;
  int? syncAt;
  String date = "";
  bool? isLocal;
  CallLogValid? callLogValid;
  String? customData;

  CallLog({
    required this.id,
    required this.phoneNumber,
    required this.startAt,
    required this.method,
    required this.date,
    required this.callBy,
    this.endedAt,
    this.answeredAt,
    this.type,
    this.callDuration,
    this.endedBy,
    this.answeredDuration,
    this.timeRinging,
    this.syncAt,
    this.syncBy,
    this.callLogValid,
    this.hotlineNumber,
    this.customData,
  });

  CallLog.fromEntry(
      {required DeviceCallLog.CallLogEntry entry,
      bool isLocal = false,
      required String userName}) {
    id = "${entry.timestamp! ~/ 1000}&$userName";
    phoneNumber = entry.number!;
    timeRinging = 0;
    answeredDuration = entry.callType == DeviceCallLog.CallType.incoming ||
            entry.callType == DeviceCallLog.CallType.outgoing
        ? entry.duration
        : 0;
    method = CallMethod.sim;
    startAt = entry.timestamp ?? 0;
    type = entry.callType == DeviceCallLog.CallType.outgoing
        ? CallType.outgoing
        : CallType.incomming;
    date = ddMMYYYYSlashFormat
        .format(DateTime.fromMillisecondsSinceEpoch(entry.timestamp ?? 0));
    callLogValid = null;
  }

  CallLog.fromJson(JSON json) {
    id = json['id'].string!;
    phoneNumber = json['phoneNumber'].string ?? "";
    hotlineNumber = json['hotlineNumber'].string ?? "";
    startAt = json['startAt'].string != null
        ? DateFormat("MM/dd/yyyy HH:mm:ss")
            .parseUTC(json['startAt'].string!)
            .millisecondsSinceEpoch
        : 0;
    endedAt = json['endedAt'].string != null
        ? DateFormat("MM/dd/yyyy HH:mm:ss")
            .parseUTC(json['endedAt'].string!)
            .millisecondsSinceEpoch
        : 0;
    answeredAt = json['answeredAt'].string != null
        ? DateFormat("MM/dd/yyyy HH:mm:ss")
            .parseUTC(json['answeredAt'].string!)
            .millisecondsSinceEpoch
        : 0;
    type = json['type'].integer != null
        ? CallType.getByValue(json['type'].integer!)
        : null;
    callDuration = json['callDuration'].integer;

    endedBy = json['endedBy'].integer != null && json['endedBy'].integer! > 0
        ? EndBy.getByValue(json['endedBy'].integer!)
        : EndBy.getByValue(1);
    callLogValid = json['callLogValid'].integer != null &&
            json['callLogValid'].integer! > 0
        ? CallLogValid.getByValue(json['callLogValid'].integer!)
        : null;
    syncBy = json['syncBy'].integer != null && json['syncBy'].integer! > 0
        ? SyncBy.getByValue(json['syncBy'].integer!)
        : SyncBy.other;
    answeredDuration = json['answeredDuration'].integer;
    timeRinging = json['timeRinging'].integer;
    method = CallMethod.getByValue(json['method'].integer!);
    date = ddMMYYYYSlashFormat
        .format(DateFormat("MM/dd/yyyy HH:mm:ss").parse(json['date'].string!));
    syncAt = json['syncAt'].string != null
        ? DateFormat("MM/dd/yyyy HH:mm:ss")
            .parseUTC(json['syncAt'].string!)
            .millisecondsSinceEpoch
        : 0;
    customData = json["customData"].string;
    callBy = json['callBy'].integer != null && json['callBy'].integer! > 0
        ? CallBy.getByValue(json['callBy'].integer!)
        : CallBy.other;
  }

  CallLog.fromMap(Map<String, dynamic> json) {
    id = json['id'];
    phoneNumber = json['phoneNumber'];
    startAt = json['startAt'];
    endedAt = json['endedAt'];
    answeredAt = json['answeredAt'];
    type = json['type'] != null ? CallType.getByValue(json['type']) : null;
    callDuration = json['callDuration'];
    endedBy = json['endedBy'] != null
        ? EndBy.getByValue(json["endedBy"])
        : EndBy.getByValue(0);
    syncBy = json['syncBy'] != null
        ? SyncBy.getByValue(json['syncBy'])
        : SyncBy.other;
    answeredDuration = json['answeredDuration'];
    timeRinging = json['timeRinging'];
    method = json['method'] != null
        ? CallMethod.getByValue(json['method'])
        : CallMethod.sim;
    date = json['date'] ??
        ddMMYYYYSlashFormat
            .format(DateTime.fromMillisecondsSinceEpoch(json["startAt"]));
    hotlineNumber = json['hotlineNumber'];
    syncAt = json['syncAt'];
    callBy = json['callBy'] != null
        ? CallBy.getByValue(json['callBy'])
        : CallBy.other;
    customData = json['customData'];
    callLogValid = json['callLogValid'] != null
        ? CallLogValid.getByValue(json['callLogValid'])
        : null;
  }

  Map<String, dynamic> toJson() {
    final Map<String, dynamic> data = <String, dynamic>{};
    data['id'] = id;
    data['phoneNumber'] = phoneNumber;
    data['hotlineNumber'] = hotlineNumber;

    data['startAt'] = "${DateTime.fromMillisecondsSinceEpoch(startAt)}+0700";
    // data['endedAt'] = endedAt == null
    //     ? null
    //     : "${DateTime.fromMillisecondsSinceEpoch(endedAt!)}+0700";
    data['answeredAt'] = answeredAt == null
        ? null
        : "${DateTime.fromMillisecondsSinceEpoch(answeredAt!)}+0700";
    data['type'] = type == null ? null : type!.value;
    data['callDuration'] = callDuration;
    data['endedBy'] = endedBy == null ? EndBy.other : endedBy!.value;
    data['syncBy'] = syncBy == null ? SyncBy.other : syncBy!.value;
    data['callLogValid'] =
        callLogValid == null ? CallLogValid.valid : callLogValid!.value;
    data['answeredDuration'] = answeredDuration;
    data['timeRinging'] = timeRinging;
    data['method'] = method.value;
    data['date'] = date;
    // data['syncAt'] = syncAt == null
    //     ? null
    //     : "${DateTime.fromMillisecondsSinceEpoch(syncAt!)}+0700";
    data['customData'] = getCustomData();
    data['callBy'] = callBy.value;

    return data;
  }

  Map<String, dynamic>? getCustomData() {
    if (customData != null) {
      Map<String, dynamic> json = jsonDecode(customData!);
      return CustomData.fromMap(json).toJson();
    }
    return null;
  }

  @override
  String toString() {
    return 'CallLog{id: $id, phoneNumber: $phoneNumber, startAt: $startAt, '
        'endedAt: $endedAt, answeredAt: $answeredAt, type: $type, callDuration: $callDuration, '
        'endedBy: $endedBy, answeredDuration: $answeredDuration, timeRinging: $timeRinging, '
        'method: $method, syncAt: $syncAt, date: $date, syncBy: $syncBy, isLocal: $isLocal, '
        'callLogValid: $callLogValid, hotlineNumber: $hotlineNumber, customData: $customData, callBy: $callBy}';
  }
}
