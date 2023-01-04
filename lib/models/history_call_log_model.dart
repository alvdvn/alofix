import 'package:g_json/g_json.dart';

import 'string_value_model.dart';

class HistoryCallLogModel {
  int? id;
  String? userName;
  String? joinDate;
  String? phone;
  int? status;
  String? fullName;
  String? avatar;
  String? lockAt;
  String? email;
  int? roles;
  int? hubs;
  List<StringValueModel>? departments;

  HistoryCallLogModel(
      {this.id,
      this.userName,
      this.joinDate,
      this.phone,
      this.status,
      this.fullName,
      this.avatar,
      this.lockAt,
      this.email,
      this.roles,
      this.hubs,
      this.departments});

  HistoryCallLogModel.formJson(JSON json)
      : id = json['id'].integer,
        userName = json['userName'].string,
        avatar = json['avatar'].string,
        status = json['status'].integer,
        fullName = json['fullName'].string,
        lockAt = json['lockAt'].string,
        phone = json['phone'].string;
}
