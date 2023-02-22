import 'package:g_json/g_json.dart';

class CustomDataModel {
  String? idTrack;
  String? phoneNumber;

  CustomDataModel({this.idTrack, this.phoneNumber});


  CustomDataModel.fromJson(JSON json) {
    idTrack = json['idTrack'].string;
    phoneNumber = json['phoneNumber'].string;
  }
}