import 'package:base_project/database/models/call_log.dart';
import 'package:g_json/g_json.dart';

class CallLogModel {
  String? key;
  List<CallLog>? calls;

  CallLogModel({this.key, this.calls});

  CallLogModel.fromJson(JSON json) {
    key = json['key'].string;
    calls = json['calls']
        .list
        ?.map((e) => CallLog.fromJson(JSON(e)))
        .toList();
  }

  @override
  String toString() {
    return '{calls: $calls key: $key';
  }
}


class TimeRingCallLog {
  String? callId;
  String? startAt;
  int? timeRing;
  String? phone;
  int? endAt;
  int? startAtEndBy;

  TimeRingCallLog({
    this.callId, this.startAt, this.timeRing, this.phone, this.endAt, this.startAtEndBy });

  Map<String, dynamic> toJson(){
    final map = <String, dynamic>{};
    map['callId'] = callId;
    map['startAt'] = startAt;
    map['timeRing'] = timeRing;
    map['phone'] = phone;
    map['endAt'] = endAt;
    map['startAtEndBy'] = startAtEndBy;
    return map;
  }

  TimeRingCallLog.fromJson(JSON json) {
    callId = json['callId'].string;
    startAt = json['startAt'].string;
    timeRing = json['timeRing'].integer;
    phone = json['phone'].string;
    endAt = json['endAt'].integer;
  }

  TimeRingCallLog.fromJsonBG(JSON json) {
    callId = json['Id'].string;
    startAt = json['StartAt'].string;
    timeRing = json['TimeRinging'].integer;
    phone = json['PhoneNumber'].string;
    endAt = json['EndAt'].integer;
    startAtEndBy = json['StartAt'].integer;
  }

  @override
  String toString() {
    return 'callId: $callId startAt: $startAt endAt: $endAt startAtEndBy: $startAtEndBy timeRing: $timeRing phone $phone';
  }
}