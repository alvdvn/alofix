import 'package:call_log/call_log.dart';
import 'package:get/get.dart';

class CallLogController extends GetxController {
  Iterable<CallLogEntry> callLogEntries = <CallLogEntry>[].obs;

  @override
  void onInit() {
    super.onInit();
    getCallLog();
  }

  void getCallLog() async {
    Iterable<CallLogEntry> result = await CallLog.query();
    callLogEntries = result;
    update();
  }

}
