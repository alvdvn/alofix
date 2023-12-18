import 'dart:async';
import 'package:base_project/config/routes.dart';
import 'package:base_project/generated/assets.dart';
import 'package:base_project/services/local/app_share.dart';
import 'package:device_apps/device_apps.dart';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:g_json/g_json.dart';
import 'package:get/get.dart';
import 'package:package_info_plus/package_info_plus.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'package:url_launcher/url_launcher.dart';
import '../common/constance/strings.dart';
import '../config/fonts.dart';
import '../environment.dart';
import '../models/call_log_model.dart';
import '../models/sync_call_log_model.dart';
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
    onInit();
  }

  void checkForceUpdate() async {
    print('LOG: isAutoLogin ${AppShared.isAutoLogin}');
    if (AppShared.isAutoLogin == "true") {
      if (_controller.user?.phone.toString().removeAllWhitespace == "0900000003") {
        Get.offAllNamed(Routes.homeScreen);
        return;
      }
      await _controller.getVersionMyApp();
      final newVersion = _controller.versionInfoModel?.minVersion ?? 0;
      final latest = _controller.versionInfoModel?.latest ?? 0;
      final PackageInfo packageInfo = await PackageInfo.fromPlatform();
      final currentVersion = int.parse(packageInfo.buildNumber);
      print('LOG: versionInfoModel ${_controller.versionInfoModel.toString()}');
      print('LOG: buildNumber $currentVersion latest $latest');
      AppShared().saveDriverReport(_controller.versionInfoModel?.driverReport ?? '');
      if (newVersion > currentVersion || latest > currentVersion) {
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

  onCheckClearCache() async {
    final prefs = await SharedPreferences.getInstance();
    await prefs.reload();

    final callLogInBGService = await AppShared().getCallLogBGSync();
    final list = JSON.parse(callLogInBGService).list?.map((e) => SyncCallLogModel.fromJson(e)).toList() ?? [];
    print('LOG: callLogInBGService $callLogInBGService}');
    if (list.isNotEmpty) {
      final lastItemTimeRingCache = DateTime.parse(list.first.startAt ?? '');
      final today = DateTime.now();
      final compareDate = daysBetween(lastItemTimeRingCache, today);
      print('LOG: compareDate $compareDate, today $today, lastItemTimeRingCache $lastItemTimeRingCache');
      if (compareDate >= 1) {
        SharedPreferences preferences = await SharedPreferences.getInstance();
        await preferences.setString('call_logs_in_bg', "");
      }
    }

    // final callLogInBGService = await AppShared().getCallLogBGSync();
    // final list = JSON.parse(callLogInBGService).list?.map((e) => SyncCallLogModel.fromJson(e)).toList() ?? [];
    // if (list.isNotEmpty) {
    //   print('LOG: Splash callLogInBGService $list}');
    //   var index = list.indexWhere((element) => DateTime.parse(element.startAt ?? '').toLocal().hour < 6);
    //   list.removeAt(index);
    //   AppShared().savedCallLogBGSync(JSON(list));
    // }

    List<SyncCallLogModel> listBGNotSync = await AppShared().getCallLogsToSyncInBg();
    List<SyncCallLogModel> listBGError = await AppShared().getCallLogsToSyncError();
    print('LOG: onCheckClearCache ${listBGNotSync.toString()} listError ${listBGError.toString()}');
    if (listBGNotSync.isNotEmpty) {
      final first = listBGNotSync.first.id?.split('&');
      final item = first?[first.length - 2] ?? '';
      final intItem = int.parse(item);
      final dateItem = DateTime.fromMillisecondsSinceEpoch(intItem);
      print('LOG: item $item intItem $intItem first $first');
      final today = DateTime.now();
      final compareDate = daysBetween(dateItem, today);
      print('LOG: compareDate $compareDate, today $today, dateItem $dateItem');
      if (compareDate >= 1) {
        SharedPreferences preferences = await SharedPreferences.getInstance();
        await preferences.setString('call_logs_to_sync', '');
      }
    }

    if (listBGError.isNotEmpty) {
      final first = listBGError.first.id?.split('&');
      final item = first?[first.length - 2] ?? '';
      final intItem = int.parse(item);
      final dateItem = DateTime.fromMillisecondsSinceEpoch(intItem);
      print('LOG: item $item intItem $intItem first $first');
      final today = DateTime.now();
        final compareDate = daysBetween(dateItem, today);
        print('LOG: compareDate $compareDate, today $today, dateItem $dateItem');
        if (compareDate >= 1) {
          SharedPreferences preferences = await SharedPreferences.getInstance();
          await preferences.setString('call_err_logs_to_sync', '');
        }
    }
}

  int daysBetween(DateTime from, DateTime to) {
    from = DateTime(from.year, from.month, from.day);
    to = DateTime(to.year, to.month, to.day);
    return (to.difference(from).inHours / 24).round();
  }

  onInit() async {
    retryUnInstallOldApp(false);
    getDomainFromStorage();
    onCheckClearCache();
  }

  getDomainFromStorage() async {
    var domain = await AppShared().getDomain();
    print('domain in splash: $domain |||||||||||||||||||||||||');
    Environment.domain = domain;
  }

  retryUnInstallOldApp(bool isUnInstalled) async {
    if (isUnInstalled) {
      return;
    } else {
      // await DeviceApps.uninstallApp(oldAppPackageName);
      var oldAppStillExisted = await DeviceApps.isAppInstalled(oldAppPackageName);
      if (oldAppStillExisted) {
        // retryUnInstallOldApp(false);
        _showUninstallDialog(context);
      } else {
        Future.delayed(
            const Duration(seconds: 2),
                () => checkForceUpdate());
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

  _showUninstallDialog(context) async {
    await showDialog<String>(
      context: context,
      barrierDismissible: false,
      builder: (BuildContext context) {
        String title = "Alo Ninja VN";
        String message = "Vui lòng xóa Alo1 trước khi sử dụng Alo2";
        return AlertDialog(
          title: Text(title),
          content: Text(message),
          actions: <Widget>[
            TextButton(
              onPressed: () {
                SystemChannels.platform.invokeMethod('SystemNavigator.pop');
              },
              child: Text( 'OK', style: FontFamily.normal(size: 13)),
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
