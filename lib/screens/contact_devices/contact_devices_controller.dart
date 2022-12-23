import 'package:fast_contacts/fast_contacts.dart';
import 'package:flutter/services.dart';
import 'package:get/get.dart';
import 'package:permission_handler/permission_handler.dart';

class ContactDevicesController extends GetxController {
  RxList<Contact> contact = <Contact>[].obs;

  @override
  void onInit() {
    super.onInit();
    initPlatformState();
  }


  Future<void> initPlatformState() async {
    try {
      await Permission.contacts.request();
      final contacts = await FastContacts.allContacts;
      contact = contacts.obs;
      update();
    } on PlatformException catch (_) {}
  }
}
