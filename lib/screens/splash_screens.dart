import 'package:base_project/config/routes.dart';
import 'package:base_project/generated/assets.dart';
import 'package:base_project/screens/home/home_controller.dart';
import 'package:base_project/services/local/app_share.dart';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:get/get.dart';
import 'package:package_info_plus/package_info_plus.dart';
import '../config/fonts.dart';
import '../environment.dart';
import 'account/account_controller.dart';

class SplashScreen extends StatefulWidget {
  const SplashScreen({Key? key}) : super(key: key);

  @override
  State<SplashScreen> createState() => _SplashScreenState();
}

class _SplashScreenState extends State<SplashScreen> {
  final AccountController _controller = Get.put(AccountController());
  final HomeController _homeController = Get.put(HomeController());
  final oldAppPackageName = 'vn.etelecom.njvcall';

  @override
  void initState() {
    super.initState();
    onInit();
    Future.delayed(const Duration(milliseconds: 500), () => checkForceUpdate());
  }

  void checkForceUpdate() async {
    print('LOG: isAutoLogin ${AppShared.isAutoLogin}');
    if (AppShared.isAutoLogin == "true") {
      await _controller.getVersionMyApp();
      final newVersion = _controller.versionInfoModel?.minVersion ?? 0;
      final latest = _controller.versionInfoModel?.latest ?? 0;
      final PackageInfo packageInfo = await PackageInfo.fromPlatform();
      final currentVersion = int.parse(packageInfo.buildNumber);
      if (newVersion > currentVersion || latest > currentVersion) {
        await _showVersionDialog(context);
      } else {
        Get.offAllNamed(Routes.homeScreen);
      }
    } else {
      Get.offAllNamed(Routes.loginScreen);
    }
  }

  onInit() async {
    getDomainFromStorage();
    // _homeController.startBg();
  }

  getDomainFromStorage() async {
    var domain = await AppShared().getDomain();
    Environment.domain = domain;
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
            "Phiên bản không hợp lệ. Vui lòng cập nhập lên phiên bản mới nhất tại ứng dụng Deploy Gate";
        return AlertDialog(
          title: Text(title),
          content: Text(message),
          actions: <Widget>[
            TextButton(
              onPressed: () {
                SystemChannels.platform.invokeMethod('SystemNavigator.pop');
              },
              child: Text('Cập nhật ngay', style: FontFamily.normal(size: 13)),
            ),
          ],
        );
      },
    );
  }
}
