import 'dart:async';
import 'dart:io';
import 'package:base_project/dl/injection.dart';
import 'package:base_project/my_app.dart';
import 'package:base_project/config/values.dart';
import 'package:base_project/services/local/app_share.dart';
import 'package:base_project/services/remote/api_provider.dart';
import 'package:firebase_core/firebase_core.dart';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:firebase_crashlytics/firebase_crashlytics.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'firebase_options.dart';

void main() async {
  await Future.wait([_initializeDependencies(), _appConfigurations()]);
  // await configureDependencies();
  HttpOverrides.global = MyHttpOverrides();
  WidgetsFlutterBinding.ensureInitialized();
  MyApp app = const MyApp();
  runApp(app);
  final AppShared appShared = AppShared.shared;
  mockEvent(app, appShared);
  await setUp(appShared);
}

Future<void> mockEvent(MyApp app, AppShared shared) async {
  var username = await shared.getUserName();
  await Firebase.initializeApp(options: DefaultFirebaseOptions.currentPlatform);
  FirebaseCrashlytics.instance.setUserIdentifier(username);
  FirebaseCrashlytics.instance.setCrashlyticsCollectionEnabled(false);
  FlutterError.onError = FirebaseCrashlytics.instance.recordFlutterError;
}

Future<void> _initializeDependencies() async {
  WidgetsFlutterBinding.ensureInitialized();
}

Future<void> setUp(AppShared appShared) async {
  final prefs = await SharedPreferences.getInstance();

  await appShared.getTimeInstallLocal();
  await appShared.saveDateLocalSync();
  await appShared.getUserPassword();

  AuthenticationKey.shared.token = prefs.getString('access_token') ?? '';
  AppShared.callTypeGlobal = prefs.getString('call_default') ?? '3';
  AppShared.simSlotIndex = prefs.getInt('value_sim_choose') ?? 0;
  AppShared.isRemember = await AppShared().getIsCheck();
  AppShared.isAutoLogin = await AppShared().getAutoLogin();
}

Future<void> _appConfigurations() async {
  await SystemChrome.setPreferredOrientations(AppValues.deviceOrientations);
  await getFuncDataLocal();
}

Future<void> getFuncDataLocal() async {
  final prefs = await SharedPreferences.getInstance();
  bool isFirst = await AppShared().getFirst();
  if(isFirst){
     prefs.clear();
  }
  await AppShared().getTimeInstallLocal();
  await AppShared().saveDateLocalSync();
  await AppShared().getUserPassword();


  AuthenticationKey.shared.token = prefs.getString('access_token') ?? '';
  AppShared.callTypeGlobal = prefs.getString('call_default') ?? '3';
  AppShared.isRemember = await AppShared().getIsCheck();
  AppShared.isAutoLogin = await AppShared().getAutoLogin();
}

class MyHttpOverrides extends HttpOverrides {
  @override
  HttpClient createHttpClient(SecurityContext? context) {
    return super.createHttpClient(context)
      ..badCertificateCallback =
          (X509Certificate cert, String host, int port) => true;
  }
}
