import 'package:base_project/common/enum_call/enum_call.dart';
import 'package:shared_preferences/shared_preferences.dart';

class AppShared {
  static final shared = AppShared();

  Future saveToken(String token) async {
    final pref = await SharedPreferences.getInstance();
    await pref.setString('access_token', token);
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
}
