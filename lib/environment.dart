import 'package:flutter/foundation.dart';
import 'package:package_info_plus/package_info_plus.dart';

class Environment {
  static  PackageInfo? _packageInfo;
  static const _isReleaseMode = kReleaseMode || kProfileMode;
  static late String _apiDomain;

  static bool isProduction() {
    return _isReleaseMode;
  }

  static bool isDevelopment() {
    return !_isReleaseMode;
  }

  static Future<PackageInfo> get packageInfo async {
    _packageInfo ??= await PackageInfo.fromPlatform();
    return _packageInfo!;
  }

  static Future<String> get buildNumber async {
    return (await packageInfo).buildNumber;
  }

  static set apiDomain(String domain) {
    if (isDevelopment() && domain.contains("alo.njv.vn")) {
      throw "Môi trường dev/staging không được phép sử dụng domain Production";
    }
    if (domain.endsWith("/")) domain = domain.substring(0, domain.length - 1);

    _apiDomain = domain;
  }

  static String get apiDomain {
    if (_isReleaseMode) {
      return 'https://alo.njv.vn';
    }
    return _apiDomain;
  }

  static Uri getUrl(String? path) {
    path ??= "";
    return Uri.parse("$apiDomain/$path");
  }
}
