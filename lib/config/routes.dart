import 'package:base_project/screens/call_log_screen/call_log_screen.dart';
import 'package:base_project/screens/call_stringee/tab_bar_stringee.dart';
import 'package:base_project/screens/contact_devices/contact_devices_screen.dart';
import 'package:base_project/screens/home/home_screen.dart';
import 'package:base_project/screens/login/login_screen.dart';
import 'package:base_project/screens/record_call/record_call_screen.dart';
import 'package:get/get_navigation/src/routes/get_route.dart';

class Routes {
  static const loginScreen = '/login';
  static const homeScreen = '/home';
  static const contactScreen = '/contactScreen';
  static const calLogScreen = '/callLogScreen';
  static const recordCall = '/recordCall';
  static const stringee_app = '/stringapp';

  static List<GetPage> getPages() {
    return [
      GetPage(name: Routes.loginScreen, page: () => const LoginScreen()),
      GetPage(name: Routes.homeScreen, page: () => const HomeScreen()),
      GetPage(name: Routes.calLogScreen, page: () => CallLogScreen()),
      GetPage(name: Routes.contactScreen, page: () => const ContactDeviceScreen()),
      GetPage(name: Routes.recordCall, page: () => const RecordCallScreen()),
      GetPage(name: Routes.stringee_app, page: () =>  StringeeApp()),

    ];
  }
}

