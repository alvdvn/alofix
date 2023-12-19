import 'dart:async';
import 'dart:convert';
import 'package:base_project/common/utils/global_app.dart';
import 'package:base_project/config/routes.dart';
import 'package:base_project/database/DbContext.dart';
import 'package:base_project/database/models/deep_link.dart';
import 'package:base_project/screens/call_stringee/android_call_manager.dart';
import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:permission_handler/permission_handler.dart';
import 'screens/call/call_controller.dart';
import 'services/local/app_share.dart';
import 'package:uni_links/uni_links.dart';

class MyApp extends StatefulWidget {
  const MyApp({super.key});

  @override
  State<MyApp> createState() => _MyHomePageState();
}

class _MyHomePageState extends State<MyApp> {
  CallController callController = Get.put(CallController());
  final AndroidCallManager? _androidCallManager = AndroidCallManager.shared;

  Future<void> initUriLink() async {
    final db = await DatabaseContext.instance();
    final link = await getInitialUri();
    final phonePermission = await Permission.phone.status;
    if (link != null &&
        phonePermission == PermissionStatus.granted &&
        link.queryParameters.isNotEmpty) {
      final queryParams = link.queryParameters;
      var phone = queryParams["phoneNumber"].toString().removeAllWhitespace;
      if (phone.isEmpty) return;
      if (phone.startsWith("84")) {
        phone = phone.replaceRange(0, 2, "0");
      }
      if (phone.startsWith("+84")) {
        phone = phone.replaceRange(0, 3, "0");
      }

      db.deepLinks.insertDeepLink(DeepLink(
          phone: phone,
          data: jsonEncode(queryParams),
          saveAt: DateTime.now().millisecondsSinceEpoch ~/ 1000));

      callController.setPhone(phone);
    }
  }

  @override
  Widget build(BuildContext context) {
    return GetMaterialApp(
        navigatorKey: App.globalKey,
        debugShowCheckedModeBanner: false,
        getPages: Routes.getPages());
  }

  @override
  void initState() {
    // TODO: implement initState
    super.initState();
    initUriLink();
    _androidCallManager!.setContext(context);
  }
}
