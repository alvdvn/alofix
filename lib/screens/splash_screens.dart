import 'dart:async';
import 'package:base_project/config/routes.dart';
import 'package:base_project/generated/assets.dart';
import 'package:base_project/services/local/app_share.dart';
import 'package:device_apps/device_apps.dart';
import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:package_info_plus/package_info_plus.dart';
import 'package:url_launcher/url_launcher.dart';

import '../config/fonts.dart';
import 'account/account_controller.dart';

class SplashScreen extends StatefulWidget {
  const SplashScreen({Key? key}) : super(key: key);

  @override
  State<SplashScreen> createState() => _SplashScreenState();
}

class _SplashScreenState extends State<SplashScreen> {

  final AccountController _controller = Get.put(AccountController());
  final oldAppPackageName = 'vn.etelecom.njvcall';

  @override
  void initState() {
    super.initState();
    // initData();

    Future.delayed(
        const Duration(seconds: 2),
        () => checkForceUpdate());
  }

  void checkForceUpdate() async {
    if (AppShared.isAutoLogin == "true") {
      await _controller.getVersionMyApp();
      final newVersion = _controller.versionInfoModel?.minVersion ?? 0;
      final PackageInfo packageInfo = await PackageInfo.fromPlatform();
      final currentVersion = int.parse(packageInfo.buildNumber);
      // print('buildNumber ${buildNumber}');
      if (newVersion > currentVersion) {
        _showVersionDialog(context);
      } else {
        Get.offAllNamed(Routes.homeScreen);
      }
    } else {
      Get.offAllNamed(Routes.loginScreen);
      // Get.offAllNamed(AppShared.isAutoLogin == "false"
      //     ? Routes.loginScreen
      //     : Routes.homeScreen);
    }
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

  _showVersionDialog(context) async {
    final urlDeyloygate = 'https://deploygate.com/distributions/70e96c12c780bda9145f696f6be4200d26e1c065';
    await showDialog<String>(
      context: context,
      barrierDismissible: false,
      builder: (BuildContext context) {
        String title = "Bản cập nhật mới có sẵn";
        String message =
            "Đã có phiên bản mới hơn ứng dụng hiện tại, vui lòng cập nhật ngay bây giờ.";
        return AlertDialog(
          title: Text(title),
          content: Text(message),
          actions: <Widget>[
            TextButton(
              onPressed: () {
                launchUrl(Uri.parse(urlDeyloygate));
              },
              child: Text( 'Cập nhật ngay', style: FontFamily.normal(size: 13)),
            ),
            // TextButton(
            //   onPressed: () { },
            //   child: Text( 'Để sau', style: FontFamily.normal(size: 13)),
            // )
          ],
        );
      },
    );
  }
}
