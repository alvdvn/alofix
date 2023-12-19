import 'package:base_project/database/models/call_log.dart';
import 'package:g_json/g_json.dart';

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
    id = json['id'] ;
    phoneNumber = json['phoneNumber'] ;
    type = json['type'] ;
    routeId = json['routerId'] ;
  }
}
