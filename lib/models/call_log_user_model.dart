import 'package:g_json/g_json.dart';

class HistoryCallLogModelUser {
  int? userId;
  String? fullName;
  String? phoneNumber;

  HistoryCallLogModelUser({this.userId, this.fullName, this.phoneNumber});

  HistoryCallLogModelUser.fromJson(JSON json) {
    userId = json['userId'].integer ?? 0;
    fullName = json['fullName'].string;
    phoneNumber = json['phoneNumber'].string;
  }
}
