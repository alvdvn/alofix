import 'package:base_project/services/local/app_share.dart';
import 'package:flutter_phone_direct_caller/flutter_phone_direct_caller.dart';
import 'package:get/get.dart';
import 'package:url_launcher/url_launcher.dart';

class CallController extends GetxController {
  RxString phoneNumber = "".obs;
  RxString idTrack = "".obs;
  String jsonDeepLink = "";

  void handCall() {
    switch (AppShared.callTypeGlobal) {
      case '1':
        launchUrl(Uri(scheme: 'tel', path: phoneNumber.value));
        break;
      case '2':
        launchUrl(Uri(
            scheme: 'https://zalo.me/$phoneNumber', path: phoneNumber.value));
        break;
      case '3':
        FlutterPhoneDirectCaller.callNumber(phoneNumber.value);
        break;
      default:
        FlutterPhoneDirectCaller.callNumber(phoneNumber.value);
        break;
    }
  }

  void onPressPhone({required String buttonText}) {
    phoneNumber.value += buttonText;
  }

  void onPressBackSpace() {
    if (phoneNumber.isNotEmpty) {
      phoneNumber.value =
          phoneNumber.value.substring(0, phoneNumber.value.length - 1);
    }
  }

  void setPhone(String phone) {
    phoneNumber.value = phone;
  }

  void setIdTrack(String id) {
    idTrack.value = id;
  }

  void setJsonDeepLink(String json) {
    jsonDeepLink = json;
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
