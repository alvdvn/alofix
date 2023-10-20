import 'dart:async';
import 'dart:io';
import 'package:base_project/my_app.dart';
import 'package:base_project/config/values.dart';
import 'package:base_project/services/local/app_share.dart';
import 'package:base_project/services/remote/api_provider.dart';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:package_info_plus/package_info_plus.dart';
import 'package:shared_preferences/shared_preferences.dart';

import 'environment.dart';

final AppShared appShared = AppShared.shared;

void main() async {
  await Future.wait([_initializeDependencies(), _appConfigurations()]);
  HttpOverrides.global = MyHttpOverrides();
  runApp(const MyApp());
}

Future<void> _initializeDependencies() async {
  WidgetsFlutterBinding.ensureInitialized();
}

Future<void> _appConfigurations() async {
  await SystemChrome.setPreferredOrientations(AppValues.deviceOrientations);
  await getFuncDataLocal();

  String url = Environment.getServerUrl();
  final PackageInfo packageInfo = await PackageInfo.fromPlatform();
  appShared.saveEnv(url, packageInfo.buildNumber);
}

Future<void> getFuncDataLocal() async {
  await appShared.getTimeInstallLocal();
  await appShared.saveDateLocalSync();
  await appShared.saveDateSync();
  await appShared.getUserPassword();
  final prefs = await SharedPreferences.getInstance();
  AuthenticationKey.shared.token = prefs.getString('access_token') ?? '';
  AppShared.callTypeGlobal = prefs.getString('call_default') ?? '3';
  AppShared.isRemember = await AppShared().getIsCheck();
  // AppShared.isAutoLogin = await AppShared().getAutoLogin();
  AppShared.isAutoLogin = "true";
}

class MyHttpOverrides extends HttpOverrides {
  @override
  HttpClient createHttpClient(SecurityContext? context) {
    return super.createHttpClient(context)
      ..badCertificateCallback =
          (X509Certificate cert, String host, int port) => true;
  }
}