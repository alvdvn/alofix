import 'package:g_json/g_json.dart';

class AccountModel {
  final int? id;
  final int? statusCode;
  final String? mess;
  final String? joinDate;
  final String? phone;
  final int? status;
  final String? fullName;
  final String? avatar;

  AccountModel(
      {this.id,
      this.joinDate,
      this.phone,
      this.status,
      this.fullName,
      this.avatar,
      this.statusCode,
      this.mess});

  AccountModel.fromJson(JSON json)
      : id = json['id'].integer ?? 0,
        joinDate = json[''].string,
        phone = json['phone'].string,
        status = json['status'].integer,
        fullName = json['fullName'].string,
        statusCode = json['statusCode'].integer,
        mess = json['mess'].string,
        avatar = json['avatar'].string;
  
}
