import 'dart:convert';
import 'dart:core';

import 'package:base_project/common/utils/global_app.dart';
import 'package:base_project/models/custom_data_model.dart';
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
  int? ringAt;
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
  CallLogValid? callLogValid = CallLogValid.valid;
  String? customData;

  CallLog(
      {required this.id,
      required this.phoneNumber,
      this.ringAt,
      required this.startAt,
      this.endedAt,
      this.answeredAt,
      this.type,
      this.callDuration,
      this.endedBy,
      this.answeredDuration,
      this.timeRinging,
      required this.method,
      this.syncAt,
      required this.date,
      this.syncBy,
      this.isLocal,
      this.callLogValid,
      this.hotlineNumber,
      this.customData,
      required this.callBy});

  CallLog.fromEntry(
      {required DeviceCallLog.CallLogEntry entry, bool isLocal = false}) {
    id = (entry.timestamp! ~/ 1000).toString();
    phoneNumber = entry.number!;
    hotlineNumber = entry.number!;
    timeRinging = 0;
    answeredDuration = entry.callType == DeviceCallLog.CallType.incoming ||
            entry.callType == DeviceCallLog.CallType.outgoing
        ? entry.duration
        : 0;
    method = CallMethod.sim;
    isLocal = isLocal;
    startAt = entry.timestamp ?? 0;
    callLogValid = null;
    type = entry.callType == DeviceCallLog.CallType.outgoing
        ? CallType.outgoing
        : CallType.incomming;
    date = ddMMYYYYSlashFormat
        .format(DateTime.fromMillisecondsSinceEpoch(entry.timestamp ?? 0));
  }

  CallLog.fromJson(JSON json) {
    id = json['id'].string!;
    phoneNumber = json['phoneNumber'].string ?? "";
    hotlineNumber = json['hotlineNumber'].string ?? "";
    ringAt = json['ringAt'].string != null
        ? DateFormat("MM/dd/yyyy HH:mm:ss")
            .parseUTC(json['ringAt'].string!)
            .millisecondsSinceEpoch
        : 0;
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
        : null;
    callLogValid = json['callLogValid'].integer != null &&
            json['callLogValid'].integer! > 0
        ? CallLogValid.getByValue(json['callLogValid'].integer!)
        : null;
    syncBy = json['syncBy'].integer != null && json['syncBy'].integer! > 0
        ? SyncBy.getByValue(json['syncBy'].integer!)
        : null;
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
    ringAt = json['ringAt'];
    startAt = json['startAt'];
    endedAt = json['endedAt'];
    answeredAt = json['answeredAt'];
    type = json['type'] != null ? CallType.getByValue(json['type']) : null;
    callDuration = json['callDuration'];
    endedBy =
        json['endedBy'] != null ? EndBy.getByValue(json["endedBy"]) : null;
    syncBy = json['syncBy'] != null ? SyncBy.getByValue(json['syncBy']) : null;
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
  }

  Map<String, dynamic> toJson() {
    final Map<String, dynamic> data = <String, dynamic>{};
    data['id'] = id;
    data['phoneNumber'] = phoneNumber;
    data['hotlineNumber'] = hotlineNumber;
    data['ringAt'] = ringAt == null
        ? null
        : "${DateTime.fromMillisecondsSinceEpoch(ringAt!)}+0700";
    data['startAt'] = "${DateTime.fromMillisecondsSinceEpoch(startAt)}+0700";
    // data['endedAt'] = endedAt == null
    //     ? null
    //     : "${DateTime.fromMillisecondsSinceEpoch(endedAt!)}+0700";
    data['answeredAt'] = answeredAt == null
        ? null
        : "${DateTime.fromMillisecondsSinceEpoch(answeredAt!)}+0700";
    data['type'] = type == null ? null : type!.value;
    data['callDuration'] = callDuration;
    data['endedBy'] = endedBy == null ? null : endedBy!.value;
    data['syncBy'] = syncBy == null ? null : syncBy!.value;
    data['callLogValid'] = callLogValid == null ? null : callLogValid!.value;
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
    return 'CallLog{id: $id, phoneNumber: $phoneNumber, ringAt: $ringAt, startAt: $startAt, '
        'endedAt: $endedAt, answeredAt: $answeredAt, type: $type, callDuration: $callDuration, '
        'endedBy: $endedBy, answeredDuration: $answeredDuration, timeRinging: $timeRinging, '
        'method: $method, syncAt: $syncAt, date: $date, syncBy: $syncBy, isLocal: $isLocal, '
        'callLogValid: $callLogValid, hotlineNumber: $hotlineNumber, customData: $customData, callBy: $callBy}';
  }
}

enum EndBy {
  rider(1),
  other(2);

  const EndBy(this.value);

  final int value;

  static EndBy getByValue(int i) {
    return EndBy.values.firstWhere((x) => x.value == i);
  }
}

enum SyncBy {
  background(1),
  other(2);

  const SyncBy(this.value);

  final int value;

  static SyncBy getByValue(int i) {
    if (i == 0) return SyncBy.other;
    return SyncBy.values.firstWhere((x) => x.value == i);
  }
}

enum CallType {
  incomming(2),
  outgoing(1);

  const CallType(this.value);

  final int value;

  static CallType getByValue(int i) {
    if (i == 0) return CallType.outgoing;
    return CallType.values.firstWhere((x) => x.value == i);
  }
}

enum CallMethod {
  sim(2),
  stringee(1);

  const CallMethod(this.value);

  final int value;

  static CallMethod getByValue(int i) {
    if (i == 0) return CallMethod.sim;
    return CallMethod.values.firstWhere((x) => x.value == i);
  }
}

enum CallLogValid {
  valid(1),
  invalid(2);

  const CallLogValid(this.value);

  final int value;

  static CallLogValid getByValue(int i) {
    return CallLogValid.values.firstWhere((x) => x.value == i);
  }
}

enum CallBy {
  alo(1),
  other(2);

  const CallBy(this.value);

  final int value;

  static CallBy getByValue(int i) {
    if (i == 0) return CallBy.other;
    return CallBy.values.firstWhere((x) => x.value == i);
  }
}
