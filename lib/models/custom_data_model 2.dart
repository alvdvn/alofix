import 'package:g_json/g_json.dart';

class CustomDataModel {
  String? id;
  String? phoneNumber;
  String? type;
  String? routeId;

  CustomDataModel({this.id, this.phoneNumber,this.type,this.routeId});


  CustomDataModel.fromJson(JSON json) {
    id = json['id'].string;
    phoneNumber = json['phoneNumber'].string;
    type = json['type'].string;
    routeId = json['routeId'].string;
  }
}