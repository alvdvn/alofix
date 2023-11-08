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
import 'package:package_info_plus/package_info_plus.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'environment.dart';
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
  MyApp app = const MyApp();
  runApp(app);

  // mockEvent(app);

  final AppShared appShared = AppShared.shared;

  // await setUp(appShared);

}


Future<void> mockEvent(MyApp app) async {
  await SentryFlutter.init(
        (options) {
      options.dsn = 'https://067853cff5c11498fbe407eaf55b30d2@o4506155150802944.ingest.sentry.io/4506155152375808';
      // Set tracesSampleRate to 1.0 to capture 100% of transactions for performance monitoring.
      // We recommend adjusting this value in production.
      options.tracesSampleRate = 1.0;
    },
    appRunner: () => runApp(app),
  );

  // await FirebaseAnalytics.instance.logEvent(
  //   name: "select_content",
  //   parameters: {
  //     "content_type": "image",
  //     "item_id": itemId,
  //   },
  // );
}

Future<void> _initializeDependencies() async {
  WidgetsFlutterBinding.ensureInitialized();
}

Future<void> setUp(AppShared appShared) async {
  final prefs = await SharedPreferences.getInstance();

  await appShared.getTimeInstallLocal();
  await appShared.saveDateLocalSync();
  await appShared.saveDateSync();
  await appShared.getUserPassword();

  AuthenticationKey.shared.token = prefs.getString('access_token') ?? '';
  AppShared.callTypeGlobal = prefs.getString('call_default') ?? '3';
  AppShared.isRemember = await AppShared().getIsCheck();
  AppShared.isAutoLogin = await AppShared().getAutoLogin();

  String url = Environment.getServerUrl();
  final PackageInfo packageInfo = await PackageInfo.fromPlatform();

  // TODO: re check app_share
  appShared.saveEnv(url, packageInfo.buildNumber);

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