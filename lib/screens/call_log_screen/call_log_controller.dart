import 'dart:io';

import 'package:base_project/common/utils/progress_h_u_d.dart';
import 'package:call_log/call_log.dart';
import 'package:get/get.dart';

class CallLogController extends GetxController {
  List<CallLogEntry> callLogEntries = <CallLogEntry>[].obs;

  @override
  void onInit() {
    super.onInit();
    if (Platform.isAndroid) {
      getCallLog();
    }
  }

  void getCallLog() async {
    Iterable<CallLogEntry> result = await CallLog.query();
    callLogEntries = result.toList();
    update();
  }
}
