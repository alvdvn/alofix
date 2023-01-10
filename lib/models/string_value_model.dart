import 'package:g_json/g_json.dart';

class StringValueModel {
  String? name;
  int? value;
  String? label;
  int? id;

  StringValueModel({this.name, this.value, this.label, this.id});

  StringValueModel.fromJson(JSON json)
      : name = json['name'].string,
        value = json['value'].integer,
        label = json['label'].string,
        id = json['id'].integer;
}
