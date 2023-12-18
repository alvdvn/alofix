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
  String? syncAt;
  HistoryCallLogModelUser? user;
  int? callLogValid;
  int? endedBy;

  HistoryCallLogModel(
      {this.phoneNumber,
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
      this.user,
      this.callLogValid,
      this.endedBy});

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
    type = json['type'].integer;
    callLogValid = json['callLogValid'].integer;
    endedBy = json['endedBy'].integer;
  }

  @override
  String toString() {
    return '{HistoryCallLogModel: id: $id, phoneNumber: $phoneNumber, type: $type, startAt: $startAt, timeRinging: $timeRinging, answeredDuration: $answeredDuration, callLogValid: $callLogValid, endedBy: $endedBy}';
  }
}
