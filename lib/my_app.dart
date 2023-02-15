import 'package:base_project/common/utils/global_app.dart';
import 'package:base_project/config/routes.dart';
import 'package:firebase_dynamic_links/firebase_dynamic_links.dart';
import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'screens/call/call_controller.dart';
import 'services/local/app_share.dart';

class MyApp extends StatefulWidget {
  const MyApp({super.key});

  @override
  State<MyApp> createState() => _MyHomePageState();
}

class _MyHomePageState extends State<MyApp> {
  FirebaseDynamicLinks dynamicLinks = FirebaseDynamicLinks.instance;
  CallController callController = Get.put(CallController());

  Future<void> initDynamicLinks() async {
    dynamicLinks.onLink.listen((dynamicLinkData) {
      final Uri uri = dynamicLinkData.link;
      final queryParams = uri.queryParameters;
      if (queryParams.isNotEmpty) {
        AppShared.jsonDeepLink = queryParams.toString();
        callController.setJsonDeepLink(queryParams.toString());
        callController.setPhone(queryParams["phoneNumber"].toString().split("?").first);
        callController.setIdTrack(queryParams["phoneNumber"].toString()
            .split("?")
            .last
            .split("=")
            .last);
      }
    }).onError((error) {
      debugPrint(error.message);
    });
  }

  @override
  Widget build(BuildContext context) {
    initDynamicLinks();
    return GetMaterialApp(
        navigatorKey: App.globalKey,
        debugShowCheckedModeBanner: false,
        getPages: Routes.getPages(),
        initialRoute: Routes.splashScreen);
  }
}
