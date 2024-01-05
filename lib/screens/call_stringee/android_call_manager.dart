import 'package:flutter/material.dart';
import 'package:get/get.dart';
import '../../../common/utils/global_app.dart';
import '../call_log_screen/call_log_controller.dart';

class AndroidCallManager with WidgetsBindingObserver {
  static AndroidCallManager? _instance;

  final navigatorKey = App.globalKey;
  final CallLogController callLogController = Get.put(CallLogController());

  static AndroidCallManager? get shared {
    _instance ??= AndroidCallManager._internal();
    return _instance;
  }

  void setContext(BuildContext context) {
  }

  AndroidCallManager._internal() {
    WidgetsBinding.instance.addObserver(this);
  }

  void destroy() {
    WidgetsBinding.instance.removeObserver(this);
  }

  @override
  void didChangeAppLifecycleState(AppLifecycleState state) {
    print('LOG: AppLifecycleState android_call_manager state = $state');
    if (state == AppLifecycleState.resumed) {}
  }

}