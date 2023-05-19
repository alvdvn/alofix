enum AppEnv {dev,prod}
class Environment{

  static const _devUrl = 'https://alo-staging.njv.vn/';
  static const _prdUrl = 'https://alo.njv.vn/';

  static const AppEnv evn =  AppEnv.prod;


  static String getServerUrl(){
    switch(evn){
      case AppEnv.dev:
        return _devUrl;
      case AppEnv.prod:
        return _prdUrl;
      default: return '';
    }
  }
}