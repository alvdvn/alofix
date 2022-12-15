import 'package:fast_contacts/fast_contacts.dart';
import 'package:get/get.dart';
import 'package:permission_handler/permission_handler.dart';

class ContactDevicesController extends GetxController {
  Future<List<Contact>> getContacts() async {
    bool isGranted = await Permission.contacts.status.isGranted;
    if (!isGranted) {
      isGranted = await Permission.contacts.request().isGranted;
    }
    if (isGranted) {
      return await FastContacts.allContacts;
    }
    return [];
  }
}
