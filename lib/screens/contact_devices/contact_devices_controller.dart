import 'package:base_project/services/local/app_share.dart';
import 'package:fast_contacts/fast_contacts.dart';
import 'package:flutter/services.dart';
import 'package:flutter_phone_direct_caller/flutter_phone_direct_caller.dart';
import 'package:get/get.dart';
import 'package:permission_handler/permission_handler.dart';
import 'package:url_launcher/url_launcher.dart';

class ContactDevicesController extends GetxController {
  RxList<Contact> contact = <Contact>[].obs;


  Future<void> initPlatformState() async {
    try {
      await Permission.contacts.request();
      final contacts = await FastContacts.allContacts;
      contact.value = contacts;
      update();
    } on PlatformException catch (_) {}
  }

  void handCall(String phoneNumber) async {
    switch (AppShared.callTypeGlobal) {
      case '1':
        launchUrl(Uri(scheme: 'tel', path: phoneNumber));
        break;
      case '2':
        launchUrl(Uri(scheme: 'https://zalo.me/$phoneNumber',path: phoneNumber));
        break;
      case '3':
        FlutterPhoneDirectCaller.callNumber(phoneNumber);
        break;
      default:
        FlutterPhoneDirectCaller.callNumber(phoneNumber);
        break;
    }
  }
  void handSMS(String phoneNumber) {
    launchUrl(Uri(scheme: 'sms',path: phoneNumber));
  }
}
