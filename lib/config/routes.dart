import 'package:base_project/screens/account/account_infomation_screen.dart';
import 'package:base_project/screens/account/account_screen.dart';
import 'package:base_project/screens/account/call_deffaut_screen.dart';
import 'package:base_project/screens/account/information_app_screen.dart';
import 'package:base_project/screens/call/call_process_screen.dart';
import 'package:base_project/screens/call/call_screen.dart';
import 'package:base_project/screens/call_activity.dart';
import 'package:base_project/screens/call_log_screen/call_log_detail_screen.dart';
import 'package:base_project/screens/call_log_screen/call_log_screen.dart';
import 'package:base_project/screens/account/change_password_screen.dart';
import 'package:base_project/screens/contact_devices/contact_devices_screen.dart';
import 'package:base_project/screens/home/home_screen.dart';
import 'package:base_project/screens/login/login_screen.dart';
import 'package:base_project/screens/splash_screens.dart';
import 'package:get/get_navigation/src/routes/get_route.dart';

import '../screens/account/sim_deffaut_screen.dart';

class Routes {
  static const deffalut = '/';
  static const splashScreen = '/splashScreen';
  static const loginScreen = '/login';
  static const changePasswordScreen = '/change_password_screen';
  static const homeScreen = '/home';
  static const contactScreen = '/contactScreen';
  static const calLogScreen = '/callLogScreen';
  static const accountScreen = '/accountScreen';
  static const accountInformationScreen = '/accountInformationScreen';
  static const addContactScreen = '/addContactScreen';
  static const callScreen = '/callScreen';
  static const callProcess = '/callProcess';
  static const defaultCallScreen  = '/defaultCallScreen';
  static const defaultSimScreen  = '/defaultSimScreen';
  static const detailCallLogScreen = '/detailCallLogScreen';
  static const detailCallLogLocalScreen = '/detailCallLogLocalScreen';
  static const informationAppScreen = '/informationAppScreen';
  static const baseWebviewScreen = '/base_web_view_widget';
  static const callingScreen = '/calling';


  static List<GetPage> getPages() {
    return [
      GetPage(name: Routes.deffalut, page: () => const SplashScreen()),
      GetPage(name: Routes.splashScreen, page: () => const SplashScreen()),
      GetPage(name: Routes.loginScreen, page: () => const LoginScreen()),
      GetPage(name: Routes.changePasswordScreen,page: () => const ChangePasswordScreen()),
      GetPage(name: Routes.homeScreen, page: () => const HomeScreen()),
      GetPage(name: Routes.calLogScreen, page: () => const CallLogScreen()),
      GetPage(name: Routes.contactScreen, page: () => const ContactDeviceScreen()),
      GetPage(name: Routes.accountScreen, page: () => const AccountScreen()),
      GetPage(name: Routes.accountInformationScreen, page: () => const AccountInformationScreen()),
      GetPage(name: Routes.callScreen, page: () => const CallScreen()),
      GetPage(name: Routes.callProcess, page: () => const CallProcessScreen()),
      GetPage(name: Routes.defaultCallScreen, page: () => const CallDefaultScreen()),
      GetPage(name: Routes.defaultSimScreen, page: () => const SimDefaultScreen()),
      GetPage(name: Routes.detailCallLogScreen, page: () => const CallLogDetailScreen()),
      GetPage(name: Routes.informationAppScreen, page: () => const InformationAppScreen()),
      GetPage(name: Routes.callingScreen, page: () => CustomCallingScreen(contactName: "1231", contactNumber: "222")),

    ];
  }
}
