import 'package:g_json/g_json.dart';

class VersionInfoModel {
  int? minVersion;
  int? statusCode;

  VersionInfoModel({this.minVersion, this.statusCode});

  VersionInfoModel.fromJson(JSON json)
      : minVersion = json['min_version'].integer;

  @override
  String toString() {
    return '{minVersion: ${minVersion}';
  }
}
