import 'package:base_project/common/enum_call/enum_call.dart';
import 'package:shared_preferences/shared_preferences.dart';

class AppShared {
  static final shared = AppShared();
  static String callTypeGlobal = "3";
  static String dateInstallApp = "";
  static String isRemember = "";
  static String username = "";
  static String password = "";
  static Map<String, String> jsonDeepLink = {};

  Future saveToken(String token) async {
    final pref = await SharedPreferences.getInstance();
    await pref.setString('access_token', token);
    await pref.setString('user_name', username);
    await pref.setString('password', password);
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
    if (dateInstallApp == "null") {
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

  Future<String>? getIsCheck() async {
    final pref = await SharedPreferences.getInstance();
    final value = pref.get('is_remember').toString();
    return value;
  }
}
