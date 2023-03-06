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
    final PendingDynamicLinkData? initialLink = await FirebaseDynamicLinks.instance.getInitialLink();
    if (initialLink != null) {
      final Uri deepLink = initialLink.link;
      final queryParams = deepLink.queryParameters;
      if (queryParams.isNotEmpty) {
        await AppShared().saveDateDeepLink();
        AppShared.jsonDeepLink = queryParams;
        callController.setPhone(queryParams["phoneNumber"].toString());
        callController.setIdDeepLink(queryParams["id"].toString());
        callController.setIdTrack(queryParams["idTrack"].toString());
        callController.setRouter(queryParams["routerId"].toString());
      }
    }
    dynamicLinks.onLink.listen((dynamicLinkData) async {
      final Uri uri = dynamicLinkData.link;
      final queryParams = uri.queryParameters;
      if (queryParams.isNotEmpty) {
        AppShared.jsonDeepLink = queryParams;
        await AppShared().saveDateDeepLink();
        callController.setPhone(queryParams["phoneNumber"].toString());
        callController.setIdDeepLink(queryParams["id"].toString());
        callController.setIdTrack(queryParams["idTrack"].toString());
        callController.setRouter(queryParams["routerId"].toString());
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
