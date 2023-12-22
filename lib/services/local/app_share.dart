import 'package:base_project/common/enum_call/enum_call.dart';
import 'package:g_json/g_json.dart';
import 'package:shared_preferences/shared_preferences.dart';
import '../../models/call_log_model.dart';
import '../../models/sync_call_log_model.dart';

class AppShared {
  static final shared = AppShared();

  static String callTypeGlobal = "3";
  static String simTypeGlobal = "Sim0";
  static String dateInstallApp = "";
  static String? dateSyncApp;
  static String isRemember = "";
  static String username = "";
  static String password = "";
  static String isAutoLogin = "";
  static int listSim = 0;
  static Map<String, String> jsonDeepLink = {};

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
    final value = pref.get('is_remember').toString() == 'null' ? 'false' : pref.get('is_remember').toString();
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

  Future saveType(String idTrack) async {
    final pref = await SharedPreferences.getInstance();
    await pref.setString('id_track', idTrack);
  }

  Future<String> getType() async {
    final pref = await SharedPreferences.getInstance();
    final value = pref.getString('id_track').toString();
    return value;
  }

  Future saveIdDeeplink(String id) async {
    final pref = await SharedPreferences.getInstance();
    await pref.setString('id_deeplink', id);
  }

  Future saveRouter(String router) async {
    final pref = await SharedPreferences.getInstance();
    await pref.setString('router_deeplink', router);
  }

  Future<String> getIdDeeplink() async {
    final pref = await SharedPreferences.getInstance();
    final value = pref.getString('id_deeplink').toString();
    return value;
  }

  Future<String> getRouterDeeplink() async {
    final pref = await SharedPreferences.getInstance();
    final value = pref.getString('router_deeplink').toString();
    return value;
  }

  Future saveLastDateManualSync(String date) async {
    final pref = await SharedPreferences.getInstance();
    await pref.setString('last_date_call_log_sync', date);
  }

  Future<String> getLastDateCalLogSync() async {
    final pref = await SharedPreferences.getInstance();
    final value = pref.getString('last_date_call_log_sync').toString();
    return value;
  }

  Future<void> saveLastRecoveredTimeStamp(String date) async {
    final pref = await SharedPreferences.getInstance();
    await pref.setString('last_recovered_time_stamp', date);
  }

  Future<String> getLastRecoveredTimeStamp() async {
    final pref = await SharedPreferences.getInstance();
    final value = pref.getString('last_recovered_time_stamp').toString();
    return value;
  }

  Future<void> saveLastDestroyTimeStamp(String date) async {
    final pref = await SharedPreferences.getInstance();
    await pref.setString('last_destroy_time_stamp', date);
  }

  Future<String> getLastShowNotify() async {
    final pref = await SharedPreferences.getInstance();
    final value = pref.getString('last_notify_time_stamp').toString();
    return value;
  }

  Future<void> saveLastShowNotify(String date) async {
    final pref = await SharedPreferences.getInstance();
    await pref.setString('last_notify_time_stamp', date);
  }

  Future<String> getLastDestroyTimeStamp() async {
    final pref = await SharedPreferences.getInstance();
    final value = pref.getString('last_destroy_time_stamp').toString();
    return value;
  }

  Future saveDeeplinkPhone(String phone) async {
    final pref = await SharedPreferences.getInstance();
    await pref.setString('deep_link_phone', phone);
  }

  Future setFirstTimeSyncCallLog(bool firstTime) async {
    final pref = await SharedPreferences.getInstance();
    await pref.setString('first_time_sync_home', firstTime.toString());
  }

  Future<String> getFirstTimeSyncCallLog() async {
    final pref = await SharedPreferences.getInstance();
    final value = pref.get('first_time_sync_home') == null ? 'false' : pref.get('first_time_sync_home').toString();
    return value;
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

  Future<String> getCallLogBGServiceToSync() async {
    final pref = await SharedPreferences.getInstance();
    final state = pref.get('call_logs_to_sync').toString();
    return state;
  }

  Future saveDriverReport(String value) async {
    final pref = await SharedPreferences.getInstance();
    await pref.setString('drive_report', value.toString());
  }

  Future<String> getDriverReport() async {
    final pref = await SharedPreferences.getInstance();
    final state = pref.get('drive_report').toString();
    return state;
  }

  Future<String> getCallLogBGSync() async {
    final pref = await SharedPreferences.getInstance();
    final state = pref.get('call_logs_in_bg').toString();
    return state;
  }

  Future savedCallLogBGSync(JSON json) async {
    final prefs = await SharedPreferences.getInstance();
    final value = json.rawString();
    // print('print saved JSON ${value.toString()}');
    await prefs.setString('call_logs_in_bg', value);
  }

  Future<List<SyncCallLogModel>> getCallLogsToSyncInBg() async {
    final pref = await SharedPreferences.getInstance();
    final data = JSON.parse(pref.getString('call_logs_to_sync').toString());
    final value = data.list?.map((e) => SyncCallLogModel.fromJson(e)).toList() ?? [];
    return value;
  }

  Future<List<SyncCallLogModel>> getCallLogsToSyncError() async {
    final pref = await SharedPreferences.getInstance();
    final data = JSON.parse(pref.getString('call_err_logs_to_sync').toString());
    final value = data.list?.map((e) => SyncCallLogModel.fromJson(e)).toList() ?? [];
    return value;
  }

  Future saveSimDefault(DefaultSim simType) async {
    final pref = await SharedPreferences.getInstance();
    await pref.setString('value_sim_choose', getTypeSim(simType));
  }

  Future<String>? getSimDefault() async {
    final pref = await SharedPreferences.getInstance();
    final value = pref.get('value_sim_choose').toString();
    return value;
  }

  Future<String>? listSimInDevice() async {
    final pref = await SharedPreferences.getInstance();
    final value = pref.get('list_sim_in_device').toString();
    return value;
  }
}
