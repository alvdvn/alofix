import 'package:g_json/g_json.dart';
import 'dart:core';

class CustomData {
  String? id;
  String? phoneNumber;
  String? type;
  String? routeId;

  CustomData({this.id, this.phoneNumber, this.type, this.routeId});

  CustomData.fromJson(JSON json) {
    id = json['id'].string;
    phoneNumber = json['phoneNumber'].string;
    type = json['type'].string;
    routeId = json['routeId'].string;
  }

  CustomData.fromMap(Map<String, dynamic> json) {
    id = json['id'];
    phoneNumber = json['phoneNumber'];
    type = json['type'];
    routeId = json['routedld'];
  }

  Map<String, dynamic> toJson() {
    return <String, dynamic>{
      "id": id,
      "phoneNumber": phoneNumber,
      "type": type,
      "routeId": routeId,
    };
  }
}
