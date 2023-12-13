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
        this.callBy});

  @override
  String toString() {
    return 'CallDetails{id: $id, phoneNumber: $phoneNumber, type: $type, userId: $userId, '
        'method: $method, ringAt: $ringAt, startAt: $startAt, endedAt: $endedAt, answeredAt: $answeredAt, '
        'hotlineNumber: $hotlineNumber, callDuration: $callDuration, endedBy: $endedBy, '
        'timeRinging: $timeRinging, answeredDuration: $answeredDuration, customData: $customData, '
        'recordUrl: $recordUrl, time1970: $time1970, syncBy: $syncBy, callBy: $callBy}';
  }
}