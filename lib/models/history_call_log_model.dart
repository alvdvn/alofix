import 'package:base_project/models/call_log_user_model.dart';
import 'package:base_project/models/custom_data_model.dart';
import 'package:g_json/g_json.dart';

class HistoryCallLogModel {
  String? phoneNumber;
  int? timeRinging;
  int? answeredDuration;
  String? startAt;
  int? method;
  int? type;
  CustomDataModel? customData;
  String? hotlineNumber;
  String? recoredUrl;
  String? id;
  int? statusCode;
  String? syncAt;
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
      this.syncAt,
      this.user});

  HistoryCallLogModel.fromJson(JSON json) {
    id = json['id'].string ?? '';
    phoneNumber = json['phoneNumber'].string;
    startAt = json['startAt'].string;
    recoredUrl = json['recoredUrl'].string;
    hotlineNumber = json['hotlineNumber'].string;
    answeredDuration = json['answeredDuration'].integer ?? 0;
    method = json['method'].integer;
    customData = CustomDataModel.fromJson(json['customData']);
    timeRinging = json['timeRinging'].integer;
    type = json['type'].integer;
    syncAt = json['syncAt'].string;
    user = HistoryCallLogModelUser.fromJson(json['user']);
  }
}
