import 'package:g_json/g_json.dart';

class VersionInfoModel {
  int? minVersion;
  int? latest;
  int? statusCode;

  VersionInfoModel({this.minVersion, this.latest, this.statusCode});

  VersionInfoModel.fromJson(JSON json)
      : minVersion = json['min_version'].integer,
        latest = json['latest'].integer;

  @override
  String toString() {
    return '{minVersion: ${minVersion} latest ${latest}';
  }
}
