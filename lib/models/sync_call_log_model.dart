import 'package:g_json/g_json.dart';

class SyncCallLogModel {
  String? id;
  String? phoneNumber;
  int? type;
  int? userId;
  int? method;
  String? ringAt;
  String? startAt;
  String? endedAt;
  String? answeredAt;
  String? hotlineNumber;
  int? callDuration;
  int? endedBy;
  int? answeredDuration;
  String? recordUrl;
  int? timeRinging;
  Map<String,String>? customData;
  int? time1970;
  int? syncBy;
  int? callBy;
  int? callLogValid;

  SyncCallLogModel(
      {this.id,
        this.phoneNumber,
        this.type,
        this.userId,
        this.method,
        this.ringAt,
        this.startAt,
        this.endedAt,
        this.answeredAt,
        this.hotlineNumber,
        this.callDuration,
        this.endedBy,
        this.timeRinging,
        this.answeredDuration,
        this.customData,
        this.recordUrl,
        this.time1970,
        this.syncBy,
        this.callBy,
        this.callLogValid});

  SyncCallLogModel.fromJson(JSON json) {
    id = json['Id'].string;
    phoneNumber = json['PhoneNumber'].string;
    ringAt = json['RingAt'].string;
    startAt = json['StartAt'].string;
    endedAt = json['EndedAt'].string;
    answeredAt = json['AnsweredAt'].string;
    type = json['Type'].integer;
    callDuration = json['CallDuration'].integer;
    endedBy = json['EndedBy'].integer;
    answeredDuration = json['AnsweredDuration'].integer;
    timeRinging = json['TimeRinging'].integer;
    syncBy = json['SyncBy'].integer;
    method = json['Method'].integer;
    callBy = json['CallBy'].integer;
    callLogValid = json['CallLogValid'].integer;
  }

  Map<String, dynamic> toJson(){
    final map = <String, dynamic>{};
    map['Id'] = id;
    map['PhoneNumber'] = phoneNumber;
    map['RingAt'] = ringAt;
    map['EndedAt'] = endedAt;
    map['AnsweredAt'] = answeredAt;
    map['Type'] = type;
    map['CallDuration'] = callDuration;
    map['EndedBy'] = endedBy;
    map['AnsweredDuration'] = answeredDuration;
    map['TimeRinging'] = timeRinging;
    map['SyncBy'] = syncBy;
    map['Method'] = method;
    map['CallBy'] = callBy;
    map['CallLogValid'] = callLogValid;
    return map;
  }


  @override
  String toString() {
    return 'CallDetails{id: $id, phoneNumber: $phoneNumber, type: $type, userId: $userId, '
        'method: $method, ringAt: $ringAt, startAt: $startAt, endedAt: $endedAt, answeredAt: $answeredAt, '
        'hotlineNumber: $hotlineNumber, callDuration: $callDuration, endedBy: $endedBy, '
        'timeRinging: $timeRinging, answeredDuration: $answeredDuration, customData: $customData, '
        'recordUrl: $recordUrl, time1970: $time1970, syncBy: $syncBy, callBy: $callBy, callLogValid: $callLogValid}';
  }
}