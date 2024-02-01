import 'dart:async';

import 'package:base_project/common/enum_call/enum_call.dart';
import 'package:base_project/extension.dart';
import 'package:shared_preferences/shared_preferences.dart';

class AppShared {
  static final shared = AppShared();

  static String callTypeGlobal = "3";
  static int? simSlotIndex;
  static String dateInstallApp = "";
  static String? dateSyncApp;
  static String isRemember = "";
  static String username = "";
  static String password = "";
  static String isAutoLogin = "false";
  static bool isLogin = false;

  static const FLUTTER_ANDROID_CHANNEL = "NJN_ANDROID_CHANNEL_MESSAGES";
  static const START_SERVICES_METHOD = "START_SERVICES_METHOD";
  static const SET_DEFAULT_DIALER = "SET_DEFAULT_DIALER";
  static const STOP_SERVICES_METHOD = "STOP_SERVICES_METHOD";
  static const CALL_OUT_COMING_CHANNEL = "CALL_OUT_COMING_CHANNEL";
  static const GET_SIM_INFO = "GET_SIM_INFO";

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

  Future saveUserName(String username) async {
    final pref = await SharedPreferences.getInstance();
    await pref.setString('user_name', username);
  }

  Future<String> getUserName() async {
    final pref = await SharedPreferences.getInstance();
    final userName = pref.get('user_name').toString() == "null"
        ? ""
        : pref.get('user_name').toString();
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

  Future saveLoginStatus(bool isLogin) async {
    final pref = await SharedPreferences.getInstance();
    await pref.setBool('is_login', isLogin);
  }

  Future<bool> getLoginStatus() async {
    final pref = await SharedPreferences.getInstance();
    final value = pref.getBool("is_login") ?? false;
    return value;
  }
  Future saveFirst(bool isLogin) async {
    final pref = await SharedPreferences.getInstance();
    await pref.setBool('is_first', isLogin);
  }

  Future<bool> getFirst() async {
    final pref = await SharedPreferences.getInstance();
    final value = pref.getBool("is_first") ?? true;
    return value;
  }
  Future saveDateLocalSync() async {
    if (dateInstallApp == "null") {
      DateTime now = DateTime.now();
      final pref = await SharedPreferences.getInstance();
      await pref.setString('time_now_local', now.toString());
    }
  }

  Future saveDateSync() async {
    await getDateSync();
    final pref = await SharedPreferences.getInstance();
    if (dateSyncApp != "") {
      DateTime now = DateTime.now();
      await pref.setString('time_sync', now.toString());
      await getDateSync();
    } else {
      await pref.setString('time_sync', dateInstallApp);
      await getDateSync();
    }
  }

  Future getDateSync() async {
    final pref = await SharedPreferences.getInstance();
    dateSyncApp = pref.get('time_sync').toString();
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

  Future<String> getLastDateCalLogSync() async {
    final pref = await SharedPreferences.getInstance();
    final value = pref.getString('last_date_call_log_sync').toString();
    return value;
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

  Future saveSimDefault(int? index) async {
    final pref = await SharedPreferences.getInstance();
    if (index != null) {
      await pref.setInt('value_sim_choose', index);
    } else {
      await pref.remove('value_sim_choose');
    }
  }

  Future<int> getSimDefault() async {
    final pref = await SharedPreferences.getInstance();
    var slot = pref.getInt('value_sim_choose');
    if (slot == null) return -1;
    return slot;
  }
}
