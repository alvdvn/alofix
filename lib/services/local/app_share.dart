import 'package:base_project/common/enum_call/enum_call.dart';
import 'package:g_json/g_json.dart';
import 'package:shared_preferences/shared_preferences.dart';
import '../../models/call_log_model.dart';

class AppShared {
  static final shared = AppShared();

  static String callTypeGlobal = "3";
  static String dateInstallApp = "";
  static String? dateSyncApp;
  static String isRemember = "";
  static String username = "";
  static String password = "";
  static String isAutoLogin = "";

  static const FLUTTER_ANDROID_CHANNEL = "NJN_ANDROID_CHANNEL_MESSAGES";
  static const START_SERVICES_METHOD = "START_SERVICES_METHOD";
  static const STOP_SERVICES_METHOD = "STOP_SERVICES_METHOD";
  static const CALL_OUT_COMING_CHANNEL = "CALL_OUT_COMING_CHANNEL";
  static const CALL_IN_COMING_CHANNEL = "CALL_IN_COMING_CHANNEL";

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
    username = pref.get('user_name').toString() == "null" ? "" : pref.get('user_name').toString();
    password = pref.get('password').toString() == "null" ? "" : pref.get('password').toString();
  }

  Future saveUserName(String username) async {
    final pref = await SharedPreferences.getInstance();
    await pref.setString('user_name', username);
  }

  Future<String> getUserName() async {
    final pref = await SharedPreferences.getInstance();
    final userName = pref.get('user_name').toString() == "null" ? "" : pref.get('user_name').toString();
    return userName;
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
    final value = pref.get('auto_login') == null ? 'false' : pref.get('auto_login').toString();
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

  Future<String> getIsCheck() async {
    final pref = await SharedPreferences.getInstance();
    final value = pref.get('is_remember').toString() == 'null' ? 'false' : pref.get('is_remember').toString();
    return value;
  }

  Future<String> getLastDateCalLogSync() async {
    final pref = await SharedPreferences.getInstance();
    final value = pref.getString('last_date_call_log_sync').toString();
    return value;
  }

  Future saveDeeplinkPhone(String phone) async {
    final pref = await SharedPreferences.getInstance();
    await pref.setString('deep_link_phone', phone);
  }

  Future<List<TimeRingCallLog>> getTimeRingCallLog() async {
    final prefs = await SharedPreferences.getInstance();
    final data = JSON.parse(prefs.getString('call_log_time_ring').toString());
    final callLogs = data.list?.map((e) => TimeRingCallLog.fromJson(e)).toList() ?? [];
    return callLogs;
  }

  Future saveDomain(String domain) async {
    final pref = await SharedPreferences.getInstance();
    await pref.setString('api_domain', domain);
  }

  Future<String> getDomain() async {
    final pref = await SharedPreferences.getInstance();
    final value = pref.get('api_domain').toString();
    return value;
  }

  Future<void> saveEnv(String url, String version) async {
    final pref = await SharedPreferences.getInstance();
    await pref.setString('alo_url', url);
    await pref.setString('alo_version', version);
  }
}
