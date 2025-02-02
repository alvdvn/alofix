import 'package:base_project/screens/account/account_infomation_screen.dart';
import 'package:base_project/screens/account/account_screen.dart';
import 'package:base_project/screens/account/call_deffaut_screen.dart';
import 'package:base_project/screens/account/information_app_screen.dart';
import 'package:base_project/screens/call/call_process_screen.dart';
import 'package:base_project/screens/call/call_screen.dart';
import 'package:base_project/screens/call/play_recoder_screen.dart';
import 'package:base_project/screens/call_log_screen/call_log_detail_screen.dart';
import 'package:base_project/screens/call_log_screen/call_log_screen.dart';
import 'package:base_project/screens/call_stringee/tab_bar_stringee.dart';
import 'package:base_project/screens/account/change_password_screen.dart';
import 'package:base_project/screens/contact_devices/add_contact_screen.dart';
import 'package:base_project/screens/contact_devices/contact_binding.dart';
import 'package:base_project/screens/contact_devices/contact_devices_screen.dart';
import 'package:base_project/screens/home/home_screen.dart';
import 'package:base_project/screens/login/login_screen.dart';
import 'package:base_project/screens/splash_screens.dart';
import 'package:get/get_navigation/src/routes/get_route.dart';

class Routes {
  static const splashScreen = '/splashScreen';
  static const loginScreen = '/login';
  static const changePasswordScreen = '/change_password_screen';
  static const homeScreen = '/home';
  static const contactScreen = '/contactScreen';
  static const calLogScreen = '/callLogScreen';
  static const stringeeApp = '/stringapp';
  static const accountScreen = '/accountScreen';
  static const accountInformationScreen = '/accountInformationScreen';
  static const addContactScreen = '/addContactScreen';
  static const callScreen = '/callScreen';
  static const callProcess = '/callProcess';
  static const playRecord = '/playRecord';
  static const defaultCallScreen  = '/defaultCallScreen';
  static const detailCallLogScreen = '/detailCallLogScreen';
  static const informationAppScreen = '/informationAppScreen';

  static List<GetPage> getPages() {
    return [
      GetPage(name: Routes.splashScreen, page: () => const SplashScreen()),
      GetPage(name: Routes.loginScreen, page: () => const LoginScreen()),
      GetPage(name: Routes.changePasswordScreen,page: () => const ChangePasswordScreen()),
      GetPage(name: Routes.homeScreen, page: () => const HomeScreen()),
      GetPage(name: Routes.calLogScreen, page: () => CallLogScreen()),
      GetPage(name: Routes.contactScreen, page: () => const ContactDeviceScreen(),binding: ContactDevicesBinding()),
      GetPage(name: Routes.stringeeApp, page: () => StringeeApp()),
      GetPage(name: Routes.accountScreen, page: () => const AccountScreen()),
      GetPage(name: Routes.accountInformationScreen, page: () => const AccountInformationScreen()),
      GetPage(name: Routes.addContactScreen, page: () => const AddContactScreen()),
      GetPage(name: Routes.callScreen, page: () => const CallScreen()),
      GetPage(name: Routes.callProcess, page: () => const CallProcessScreen()),
      GetPage(name: Routes.playRecord, page: () => const PlayRecordScreen()),
      GetPage(name: Routes.defaultCallScreen, page: () => const CallDefaultScreen()),
      GetPage(name: Routes.detailCallLogScreen, page: () => const CallLogDetailScreen()),
      GetPage(name: Routes.informationAppScreen, page: () => const InformationAppScreen()),
    ];
  }
}
