enum AppEnv {dev,prod}
class Environment{

  static const _devUrl = 'https://alo.njv.vn/api/';
  static const _prdUrl = '';

  static const AppEnv evn =  AppEnv.dev;


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