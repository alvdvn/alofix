enum AppEnv {dev,prod}
class Environment{

  static const _devUrl = 'https://alo-staging.njv.vn/';
  static const _prdUrl = 'https://alo.njv.vn/';
  // https://alonjv-fix-invalid-calllog.njv.vn/ https://alo-beta.njv.vn/
  static const AppEnv evn =  AppEnv.prod;
  static var domain = "";

  static String getServerUrl() {
    switch (evn) {
      case AppEnv.dev:
        if (domain.isNotEmpty) {
          return 'https://$domain/';
        }
        return _devUrl;
      case AppEnv.prod:
        return _prdUrl;
      default:
        return '';
    }
  }
}