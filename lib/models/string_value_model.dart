import 'package:g_json/g_json.dart';

class StringValueModel {
  String? name;
  int? id;

  StringValueModel({this.name,  this.id});

  StringValueModel.fromJson(JSON json)
      : name = json['name'].string,
        id = json['id'].integer;
}
