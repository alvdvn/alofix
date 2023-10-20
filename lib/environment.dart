enum AppEnv {dev,prod}
class Environment {
  static const _devUrl = 'https://alo-test.njv.vn/'; //'https://alo-staging.njv.vn/';
  static const _prdUrl = 'https://alo.njv.vn/';

  static const AppEnv evn = AppEnv.dev;
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
