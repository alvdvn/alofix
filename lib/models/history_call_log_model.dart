import 'package:base_project/models/call_log_user_model.dart';
import 'package:g_json/g_json.dart';


class HistoryCallLogModel {
  String? phoneNumber;
  int? timeRinging;
  int? answeredDuration;
  String? startAt;
  int? method;
  int? type;
  String? customData;
  String? hotlineNumber;
  String? recoredUrl;
  String? id;
  int? statusCode;
  HistoryCallLogModelUser? user;

  HistoryCallLogModel(
      {this.phoneNumber,
        this.statusCode,
      this.timeRinging,
      this.answeredDuration,
      this.startAt,
      this.method,
      this.type,
      this.customData,
      this.hotlineNumber,
      this.recoredUrl,
      this.id,
      this.user});

  HistoryCallLogModel.fromJson(JSON json) {
    id = json['id'].string ?? '';
    phoneNumber = json['phoneNumber'].string;
    startAt = json['phoneNumber'].string;
    recoredUrl = json['recoredUrl'].string;
    hotlineNumber = json['hotlineNumber'].string;
    answeredDuration = json['answeredDuration'].integer;
    method =  json['method'].integer;
    customData = json['customData'].string;
    timeRinging = json['timeRinging'].integer;
    type = json['type'].integer;
    user = HistoryCallLogModelUser.fromJson(json['user']);
  }
}
