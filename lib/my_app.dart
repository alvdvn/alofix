import 'dart:async';
import 'package:base_project/common/utils/global_app.dart';
import 'package:base_project/config/routes.dart';
import 'package:base_project/screens/call_stringee/android_call_manager.dart';
import 'package:flutter/material.dart';
import 'package:get/get.dart';
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
  AndroidCallManager? _androidCallManager = AndroidCallManager.shared;

  Future<void> initUriLink() async {
    final link = await getInitialUri();
    // print("deeplink full string" + link.toString());
    if (link != null) {
      if (link.queryParameters.isNotEmpty) {
        final queryParams = link.queryParameters;
        await AppShared().saveDateDeepLink();
        AppShared.jsonDeepLink = queryParams;
        final phone = queryParams["phoneNumber"].toString().removeAllWhitespace;
        // print("deeplink of phone" + phone);
        if (phone.length > 0) {
          final subStringPhone = phone.substring(0, 2);
          if (subStringPhone == '84') {
            final newPhone = phone.replaceRange(0, 2, "0");
            callController.setPhone(newPhone);
          } else {
            callController.setPhone(phone);
          }
        } else {
          callController.setPhone(phone);
        }

        callController.setIdDeepLink(queryParams["id"].toString());
        callController.setType(queryParams["type"].toString());
        callController.setRouter(queryParams["routedId"].toString());
      }
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
