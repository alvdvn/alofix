import 'package:base_project/common/enum_call/enum_call.dart';
import 'package:shared_preferences/shared_preferences.dart';

class AppShared {
  static final shared = AppShared();
  static String callTypeGlobal = "3";
  static String dateInstallApp = "";
  static String isRemember = "";
  static String username = "";
  static String password = "";
  static String isAutoLogin = "";
  static Map<String, String> jsonDeepLink = {};

  Future saveToken(String token) async {
    final pref = await SharedPreferences.getInstance();
    await pref.setString('access_token', token);
  }

  Future saveUserPassword(String username, String password) async {
    final pref = await SharedPreferences.getInstance();
    await pref.setString('user_name', username);
    await pref.setString('password', password);
  }

  Future getUserPassword() async {
    final pref = await SharedPreferences.getInstance();
    username = pref.get('user_name').toString() == "null"
        ? ""
        : pref.get('user_name').toString();
    password = pref.get('password').toString() == "null"
        ? ""
        : pref.get('password').toString();
  }

  Future clearPassword() async {
    final pref = await SharedPreferences.getInstance();
    await pref.setString('user_name', "");
    await pref.setString('password', "");
  }

  Future saveAutoLogin(bool autoLogin) async {
    final pref = await SharedPreferences.getInstance();
    await pref.setString('auto_login', autoLogin.toString());
  }

  Future<String> getAutoLogin() async {
    final pref = await SharedPreferences.getInstance();
    final value = pref.get('auto_login') == null
        ? 'false'
        : pref.get('auto_login').toString();
    return value;
  }

  Future saveCallDefault(DefaultCall callType) async {
    final pref = await SharedPreferences.getInstance();
    await pref.setString('call_default', getTypeCall(callType));
  }

  Future<String>? getCallDefault() async {
    final pref = await SharedPreferences.getInstance();
    final value = pref.get('call_default').toString();
    return value;
  }

  Future saveDateLocalSync() async {
    if (dateInstallApp == "") {
      DateTime now = DateTime.now();
      final pref = await SharedPreferences.getInstance();
      await pref.setString('time_now_local', now.toString());
    }
  }

  Future getTimeInstallLocal() async {
    final pref = await SharedPreferences.getInstance();
    final value = pref.get('time_now_local').toString();
    dateInstallApp = value;
  }

  Future saveIsCheck(bool isRemember) async {
    final pref = await SharedPreferences.getInstance();
    await pref.setString('is_remember', isRemember.toString());
  }

  Future<String> getIsCheck() async {
    final pref = await SharedPreferences.getInstance();
    final value = pref.get('is_remember').toString() == 'null'
        ? 'false'
        : pref.get('is_remember').toString();
    return value;
  }

  Future saveDateDeepLink() async {
    DateTime now = DateTime.now();
    final pref = await SharedPreferences.getInstance();
    await pref.setString('time_now_deep_link', now.toString());
  }

  Future<String> getDateDeepLink() async {
    final pref = await SharedPreferences.getInstance();
    final value = pref.getString('time_now_deep_link').toString();
    return value;
  }

  Future savePhoneDeepLink(String phoneNumber) async {
    final pref = await SharedPreferences.getInstance();
    await pref.setString('phone_deep_link', phoneNumber);
  }

  Future<String> getPhoneDeepLink() async {
    final pref = await SharedPreferences.getInstance();
    final value = pref.getString('phone_deep_link').toString();
    return value;
  }
  Future saveIdTrack(String idTrack) async {
    final pref = await SharedPreferences.getInstance();
    await pref.setString('id_track', idTrack);
  }
  Future<String> getIdTrack() async {
    final pref = await SharedPreferences.getInstance();
    final value = pref.getString('id_track').toString();
    return value;
  }
}
