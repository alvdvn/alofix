import 'package:get/get.dart';

import 'contact_devices_controller.dart';


class ContactDevicesBinding extends Bindings {

  @override
  void dependencies() {
    Get.lazyPut(() => ContactDevicesController());
  }
}