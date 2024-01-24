import 'package:package_info_plus/package_info_plus.dart';

class Environment {
  static  PackageInfo? _packageInfo;
  static const _isReleaseMode = false;
  // static const _isReleaseMode = bool.fromEnvironment('dart.vm.product');
  static late String _apiDomain;

  static bool isProduction() {
    return _isReleaseMode;
  }

  static bool isDevelopment() {
    return !_isReleaseMode;
  }

  // static set apiDomain(String domain) {
  //   _apiDomain = domain;
  // }

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
//https://alonjv-fix-invalid-calllog.njv.vn/
  static Uri getUrl(String? path) {
    path ??= "";
    return Uri.parse("$apiDomain/$path");
  }
}
