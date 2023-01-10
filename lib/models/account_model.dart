import 'package:g_json/g_json.dart';

import 'string_value_model.dart';

class AccountModel {
  final int? id;
  final int? statusCode;
  final String? mess;
  final String? joinDate;
  final String? phone;
  final int? status;
  final String? fullName;
  final String? avatar;
  final List<StringValueModel>? roles;

  AccountModel(
      {this.id,
      this.joinDate,
      this.phone,
      this.status,
      this.fullName,
      this.avatar,
      this.statusCode,
      this.roles,
      this.mess});

  AccountModel.fromJson(JSON json)
      : id = json['id'].integer ?? 0,
        joinDate = json[''].string,
        phone = json['phone'].string,
        status = json['status'].integer,
        fullName = json['fullName'].string,
        statusCode = json['statusCode'].integer,
        mess = json['mess'].string,
        roles = [],
        avatar = json['avatar'].string;
}
