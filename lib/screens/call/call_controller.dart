import 'package:base_project/services/local/app_share.dart';
import 'package:flutter_phone_direct_caller/flutter_phone_direct_caller.dart';
import 'package:get/get.dart';
import 'package:url_launcher/url_launcher.dart';

class CallController extends GetxController {
  RxString phoneNumber = "".obs;
  RxString typeObs = "".obs;

  void handCall(String phoneNumber) {
    switch (AppShared.callTypeGlobal) {
      case '1':
        FlutterPhoneDirectCaller.callNumber(phoneNumber);
        break;
      case '2':
        launchUrl(
            Uri(scheme: 'https://zalo.me/$phoneNumber', path: phoneNumber));
        break;
      case '3':
        FlutterPhoneDirectCaller.callNumber(phoneNumber);
        break;
      default:
        FlutterPhoneDirectCaller.callNumber(phoneNumber);
        break;
    }
  }

  void onPressPhone({required String buttonText}) {
    if(phoneNumber.value.length < 13) {
      phoneNumber.value += buttonText;
    }
  }

  void onPressBackSpace() {
    if (phoneNumber.isNotEmpty) {
      phoneNumber.value =
          phoneNumber.value.substring(0, phoneNumber.value.length - 1);
    }
  }

  void setPhone(String phone) async {
    await AppShared().savePhoneDeepLink(phone);
    phoneNumber.value = phone;
    handCall(phone.toString());
  }

  void setType(String type) async {
    await AppShared().saveType(type);
    typeObs.value = type;
  }
  void setIdDeepLink(String idDeeplink) async {
    await AppShared().saveIdDeeplink(idDeeplink);
  }
  void setRouter(String router) async {
    await AppShared().saveRouter(router);
  }

  String getTitleAppDefault() {
    switch (AppShared.callTypeGlobal) {
      case '1':
        return 'App AloNinja';
      case '2':
        return 'Zalo';
      case '3':
        return 'SIM';
      default:
        return 'SIM';
    }
  }
}
