import 'dart:async';
import 'package:base_project/my_app.dart';
import 'package:base_project/config/values.dart';
import 'package:base_project/services/local/app_share.dart';
import 'package:base_project/services/remote/api_provider.dart';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';

import 'package:shared_preferences/shared_preferences.dart';

void main() async {
  await Future.wait([_initializeDependencies(), _appConfigurations()]);
  runApp(const MyApp());
}

Future<void> _initializeDependencies() async {
  WidgetsFlutterBinding.ensureInitialized();
}

Future<void> _appConfigurations() async {
  await SystemChrome.setPreferredOrientations(AppValues.deviceOrientations);
  await getFuncDataLocal();
}

Future<void> getFuncDataLocal() async {
  await AppShared().getTimeInstallLocal();
  await AppShared().saveDateLocalSync();
  await AppShared().saveDateSync();
  await AppShared().getUserPassword();
  final prefs = await SharedPreferences.getInstance();
  AuthenticationKey.shared.token = prefs.getString('access_token') ?? '';
  AppShared.callTypeGlobal = prefs.getString('call_default') ?? '3';
  AppShared.isRemember = await AppShared().getIsCheck();
  AppShared.isAutoLogin = await AppShared().getAutoLogin();
}


