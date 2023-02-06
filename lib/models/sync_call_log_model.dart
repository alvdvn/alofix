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
        this.answeredDuration,
        this.recordUrl});

}