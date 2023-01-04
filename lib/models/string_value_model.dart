import 'package:g_json/g_json.dart';

class StringValueModel {
  String? name;
  int? value;
  String? label;

  StringValueModel({this.name, this.value, this.label});

  StringValueModel.fromJson(JSON json)
      : name = json['name'].string,
        value = json['value'].integer,
        label = json['label'].string;
}
