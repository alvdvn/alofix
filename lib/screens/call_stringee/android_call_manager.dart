import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:get/get_core/src/get_main.dart';
import 'package:stringee_flutter_plugin/stringee_flutter_plugin.dart';
import 'package:audioplayers/audioplayers.dart';

import '../../../common/utils/global_app.dart';
import '../../../generated/assets.dart';
import '../call_log_screen/call_log_controller.dart';

class AndroidCallManager with WidgetsBindingObserver {
  static AndroidCallManager? _instance;
  late BuildContext _context;

  final navigatorKey = App.globalKey;

  String? _callId = "";

  StringeeMediaState? _mediaState;
  StringeeSignalingState? _signalingState;
  final player = AudioPlayer();
  final CallLogController callLogController = Get.put(CallLogController());

  static AndroidCallManager? get shared {
    if (_instance == null) {
      _instance = AndroidCallManager._internal();
    }
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

  @override
  void didChangeAppLifecycleState(AppLifecycleState state) {
    // TODO: implement didChangeAppLifecycleState
    super.didChangeAppLifecycleState(state);
    if (state == AppLifecycleState.resumed) {}
  }
}
