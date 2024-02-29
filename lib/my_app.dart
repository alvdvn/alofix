import 'dart:async';
import 'dart:convert';
import 'package:base_project/common/utils/global_app.dart';
import 'package:base_project/config/routes.dart';
import 'package:base_project/database/db_context.dart';
import 'package:base_project/database/models/deep_link.dart';
import 'package:base_project/dl/injection.dart';
import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:permission_handler/permission_handler.dart';
import 'screens/call/call_controller.dart';
import 'package:uni_links/uni_links.dart';
import 'package:flutter/widgets.dart';

class MyApp extends StatefulWidget {
  const MyApp({super.key});

  @override
  State<MyApp> createState() => _MyHomePageState();
}

class _MyHomePageState extends State<MyApp> {
  late CallController callController;

  Future<void> initUriLink() async {
    final link = await getInitialUri();
    final phonePermission = await Permission.phone.status;
    if (link == null ||
        phonePermission != PermissionStatus.granted ||
        link.queryParameters.isEmpty ||
        !link.queryParameters.containsKey("phoneNumber")) {
      return;
    }

    final db = await DatabaseContext.instance();
    var phone = link.queryParameters["phoneNumber"]!.removeAllWhitespace;

    if (phone.startsWith("84")) {
      phone = phone.replaceRange(0, 2, "0");
    }
    if (phone.startsWith("+84")) {
      phone = phone.replaceRange(0, 3, "0");
    }

    db.deepLinks.insertDeepLink(DeepLink(
        phone: phone,
        data: jsonEncode(link.queryParameters),
        saveAt: DateTime.now().millisecondsSinceEpoch));



    callController.handCall(phone);



  }

  @override
  Widget build(BuildContext context) {
    return GetMaterialApp(
        navigatorKey: App.globalKey,
        debugShowCheckedModeBanner: false,
        getPages: Routes.getPages());
  }
  Future <void> initDependencies() async{
    await configureDependencies();
    callController = Get.find();

  }
  @override
  void initState() {
    // TODO: implement initState
    super.initState();
    initDependencies();
    initUriLink();
  }
}
