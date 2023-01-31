import 'package:g_json/g_json.dart';

import 'string_value_model.dart';

class AccountModel {
  int? id;
  int? statusCode;
  String? mess;
  String? joinDate;
  String? phone;
  int? status;
  String? fullName;
  String? avatar;
  List<StringValueModel>? roles;
  List<StringValueModel>? hubs;
  List<StringValueModel>? departments;

  AccountModel(
      {this.id,
      this.joinDate,
      this.phone,
      this.status,
      this.fullName,
      this.avatar,
      this.statusCode,
      this.roles,
      this.departments,
      this.hubs,
      this.mess});

  AccountModel.fromJson(JSON json) {
    id = json['id'].integer ?? 0;
    joinDate = json[''].string;
    phone = json['phone'].string;
    status = json['status'].integer;
    fullName = json['fullName'].string;
    statusCode = json['statusCode'].integer;
    mess = json['mess'].string;
    avatar = json['avatar'].string;
    roles = json['roles']
        .list
        ?.map((e) => StringValueModel.fromJson(JSON(e)))
        .toList();
    hubs = json['hubs']
        .list
        ?.map((e) => StringValueModel.fromJson(JSON(e)))
        .toList();
    departments = json['departments']
        .list
        ?.map((e) => StringValueModel.fromJson(JSON(e)))
        .toList();
  }
}
