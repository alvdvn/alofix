import 'dart:async';
import 'dart:io';
import 'package:base_project/my_app.dart';
import 'package:base_project/config/values.dart';
import 'package:base_project/services/local/app_share.dart';
import 'package:base_project/services/remote/api_provider.dart';
import 'package:firebase_core/firebase_core.dart';
import 'package:firebase_messaging/firebase_messaging.dart';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:firebase_crashlytics/firebase_crashlytics.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'firebase_options.dart';

void main() async {
  await Future.wait([_initializeDependencies(), _appConfigurations()]);
  HttpOverrides.global = MyHttpOverrides();
  WidgetsFlutterBinding.ensureInitialized();
  await Firebase.initializeApp(options: DefaultFirebaseOptions.currentPlatform);

  FirebaseCrashlytics.instance.setCrashlyticsCollectionEnabled(true);
  FlutterError.onError = FirebaseCrashlytics.instance.recordFlutterError;

  Firebase.initializeApp().whenComplete(() {
    print("completed initializeApp");
    FirebaseMessaging.onMessage.listen((event) {
      print("Handling a background message initializeApp: ${event.data}");
    });
  });

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

class MyHttpOverrides extends HttpOverrides {
  @override
  HttpClient createHttpClient(SecurityContext? context) {
    return super.createHttpClient(context)
      ..badCertificateCallback =
          (X509Certificate cert, String host, int port) => true;
  }
}