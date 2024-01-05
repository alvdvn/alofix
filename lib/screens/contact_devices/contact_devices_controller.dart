import 'package:base_project/services/local/app_share.dart';
import 'package:fast_contacts/fast_contacts.dart';
import 'package:flutter/cupertino.dart';
import 'package:flutter_phone_direct_caller/flutter_phone_direct_caller.dart';
import 'package:get/get.dart';
import 'package:permission_handler/permission_handler.dart';
import 'package:url_launcher/url_launcher.dart';

class ContactDevicesController extends GetxController {
  RxList<Contact> contactSearch = <Contact>[].obs;
  RxBool loading = false.obs;
  RxString searchContact = ''.obs;
  RxBool showSearch = false.obs;

  Future<void> initPlatformState() async {
    loading.value = true;

    final isHasPhonePermission =
        await Permission.contacts.status == PermissionStatus.granted;
    if (!isHasPhonePermission) {
      final askStatus = await Permission.contacts.request();
      if (askStatus == PermissionStatus.granted) {
        doGetContacts();
      }

      if (askStatus == PermissionStatus.denied) {
        final askStatus = await Permission.contacts.request();
        if (askStatus == PermissionStatus.granted) {
          doGetContacts();
        }

        if (askStatus == PermissionStatus.permanentlyDenied) {
          // TODO: show alert
          // alertPermission();
        }
      }
    } else {
      doGetContacts();
    }
  }

  Future<void> doGetContacts() async {
    final contacts = await FastContacts.getAllContacts();
    contactSearch.value = contacts;
    loading.value = false;

    debugPrint("FastContacts ${contacts.length}");
  }

  void searchContactLocal({required String search}) async {
    final contacts = await FastContacts.getAllContacts();
    if (search.isNotEmpty) {
      search = search.toLowerCase();
      contactSearch.value = contacts
          .where((e) =>
              e.phones.isNotEmpty &&
              (e.displayName.toLowerCase().contains(search) ||
                  e.phones.any((element) => element.number.contains(search))))
          .toList();
    } else {
      contactSearch.value =
          contacts.where((element) => element.phones.isNotEmpty).toList();
    }
  }

  void onClickSearch() {
    showSearch.value = !showSearch.value;
  }

  void handCall(String phoneNumber) async {
    switch (AppShared.callTypeGlobal) {
      case '1':
        directCall(phoneNumber);
        break;
      case '2':
        launchUrl(
            Uri(scheme: 'https://zalo.me/$phoneNumber', path: phoneNumber));
        break;
      case '3':
        directCall(phoneNumber);
        break;
      default:
        directCall(phoneNumber);
        break;
    }
  }

  void directCall(String phoneNumber) {
    FlutterPhoneDirectCaller.callNumber(phoneNumber);
  }

  void handSMS(String phoneNumber) {
    launchUrl(Uri(scheme: 'sms', path: phoneNumber));
  }
}
