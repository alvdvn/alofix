
import 'package:base_project/screens/account/account_controller.dart';
import 'package:base_project/screens/call/call_controller.dart';
import 'package:base_project/screens/call_log_screen/call_log_controller.dart';
import 'package:base_project/screens/contact_devices/contact_devices_controller.dart';
import 'package:base_project/screens/home/home_controller.dart';
import 'package:base_project/screens/login/login_controller.dart';
import 'package:get/get.dart';

Future<void> configureDependencies()async{
  Get.put(LoginController());
  Get.put(AccountController());
  Get.put(CallLogController());
  Get.put(CallController());
  Get.put(HomeController());
  Get.put(ContactDevicesController());


}