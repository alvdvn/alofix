import 'package:g_json/g_json.dart';

class VersionInfoModel {
  int? minVersion;
  int? latest;
  String? driverReport;
  int? statusCode;

  VersionInfoModel({this.minVersion, this.latest, this.statusCode, this.driverReport});

  VersionInfoModel.fromJson(JSON json)
      : minVersion = json['min_version'].integer,
        latest = json['latest'].integer,
        driverReport = json['driver_reports'].string;

  @override
  String toString() {
    return '{minVersion: $minVersion latest $latest driverReport $driverReport';
  }
}
