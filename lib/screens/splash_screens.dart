import 'dart:async';
import 'package:base_project/config/routes.dart';
import 'package:base_project/generated/assets.dart';
import 'package:base_project/services/local/app_share.dart';
import 'package:device_apps/device_apps.dart';
import 'package:flutter/material.dart';
import 'package:get/get.dart';

class SplashScreen extends StatefulWidget {
  const SplashScreen({Key? key}) : super(key: key);

  @override
  State<SplashScreen> createState() => _SplashScreenState();
}

class _SplashScreenState extends State<SplashScreen> {
  final oldAppPackageName = 'vn.etelecom.njvcall';

  @override
  void initState() {
    super.initState();
    onInit();

    Future.delayed(
        const Duration(seconds: 2),
        () => Get.offAllNamed(AppShared.isAutoLogin == "false"
            ? Routes.loginScreen
            : Routes.homeScreen));
  }

  onInit() async {
    retryUnInstallOldApp(false);
  }

  retryUnInstallOldApp(bool isUnInstalled) async {
    if (isUnInstalled) {
      return;
    } else {
      await DeviceApps.uninstallApp(oldAppPackageName);

      var oldAppStillExisted =
          await DeviceApps.isAppInstalled(oldAppPackageName);
      if (oldAppStillExisted) {
        retryUnInstallOldApp(false);
      }
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: Center(
        child: Image.asset(Assets.imagesLogo, width: 253, height: 120),
      ),
    );
  }
}
