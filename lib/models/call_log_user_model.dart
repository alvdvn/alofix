import 'package:g_json/g_json.dart';

class HistoryCallLogModel {
  int? userId;
  String? fullName;
  String? phoneNumber;

  HistoryCallLogModel({this.userId, this.fullName, this.phoneNumber});

  HistoryCallLogModel.fromJson(JSON json) {
    userId = json['userId'].integer ?? 0;
    fullName = json['fullName'].string;
    phoneNumber = json['phoneNumber'].string;
  }
}
