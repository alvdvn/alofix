import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:audioplayers/audioplayers.dart';
import '../../../common/utils/global_app.dart';
import '../call_log_screen/call_log_controller.dart';

class AndroidCallManager with WidgetsBindingObserver {
  static AndroidCallManager? _instance;
  late BuildContext _context;

  final navigatorKey = App.globalKey;

  final player = AudioPlayer();
  final CallLogController callLogController = Get.put(CallLogController());

  static AndroidCallManager? get shared {
    _instance ??= AndroidCallManager._internal();
    return _instance;
  }

  void setContext(BuildContext context) {
    _context = context;
  }

  AndroidCallManager._internal() {
    WidgetsBinding.instance.addObserver(this);
  }

  void destroy() {
    WidgetsBinding.instance.removeObserver(this);
  }

}