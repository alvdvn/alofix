import 'dart:async';
import 'package:base_project/config/routes.dart';
import 'package:base_project/generated/assets.dart';
import 'package:base_project/services/local/app_share.dart';
import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:package_info_plus/package_info_plus.dart';
import 'package:url_launcher/url_launcher.dart';
import '../common/constance/strings.dart';
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
      if (_controller.user?.phone.toString().removeAllWhitespace == "0900000003") {
        Get.offAllNamed(Routes.homeScreen);
        return;
      }
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
                _launchURL();
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

  _launchURL() async {
    const url = AppConstant.linkProdDeploy;
    if (await canLaunchUrl(Uri.parse(url))) {
      await launchUrl(Uri.parse(url));
    } else {
      throw 'Could not launch $url';
    }
  }
}
