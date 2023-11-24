import 'dart:async';

import 'package:base_project/screens/call_log_screen/call_log_controller.dart';
import 'package:base_project/services/local/app_share.dart';
import 'package:flutter/cupertino.dart';
import 'package:flutter_phone_direct_caller/flutter_phone_direct_caller.dart';
import 'package:get/get.dart';
import 'package:url_launcher/url_launcher.dart';

class CallController extends GetxController {
  RxString phoneNumber = "".obs;
  RxString typeObs = "".obs;
  CallLogController callLogController = Get.put(CallLogController());

  void handCall(String phoneNumber) {
    switch (AppShared.callTypeGlobal) {
      case '1':
        callPhoneViaPlugin(phoneNumber);
        break;
      case '2':
        launchUrl(Uri(scheme: 'https://zalo.me/$phoneNumber', path: phoneNumber));
        break;
      case '3':
        callPhoneViaPlugin(phoneNumber);
        break;
      default:
        callPhoneViaPlugin(phoneNumber);
        break;
    }
  }

  void onPressPhone({required String buttonText}) {
    if (phoneNumber.value.length < 13) {
      phoneNumber.value += buttonText;
      print('LOG: onPressPhone phoneNumber ${phoneNumber.value}');
      if (phoneNumber.value.length > 1) {
        final subStringPhone = phoneNumber.value.substring(0, 2);
        // print('LOG: onPressPhone subStringPhone $subStringPhone');
        if (subStringPhone == '84') {
          final newPhone = phoneNumber.value.replaceRange(0, 2, "0");
          phoneNumber.value = newPhone;
        }
      }
    }
  }

  void onPressBackSpace() {
    if (phoneNumber.isNotEmpty) {
      phoneNumber.value = phoneNumber.value.substring(0, phoneNumber.value.length - 1);
    }
  }

  void setPhone(String phone) async {
    final phoneRemoveSpace = phone.toString().removeAllWhitespace;
    var phoneConvert = phoneRemoveSpace;
    if (phoneConvert.isNotEmpty) {
      final subStringPhone = phoneConvert.substring(0, 2);
      if (subStringPhone == '84') {
        final newPhone = phoneRemoveSpace.replaceRange(0, 2, "0");
        phoneConvert = newPhone;
      }
    }
    await AppShared().savePhoneDeepLink(phoneConvert);
    phoneNumber.value = phoneConvert;
    callLogController.secondCall = 0;
    callLogController.handCall(phoneConvert);
  }

  void setType(String type) async {
    await AppShared().saveType(type);
    typeObs.value = type;
  }

  void setIdDeepLink(String idDeeplink) async {
    debugPrint("ID Deeplink Full $idDeeplink");
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

  void callPhoneViaPlugin(String phoneNumber) {
    FlutterPhoneDirectCaller.callNumber(phoneNumber);
  }
}