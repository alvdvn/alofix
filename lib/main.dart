import 'package:base_project/my_app.dart';
import 'package:base_project/config/values.dart';
import 'package:base_project/services/remote/api_provider.dart';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:shared_preferences/shared_preferences.dart';

String callTypeGlobal = "3";

void main() async {
  await Future.wait([_initializeDependencies(), _appConfigurations()]);
  runApp(const MyApp());
}

Future<void> _initializeDependencies() async {
  WidgetsFlutterBinding.ensureInitialized();
}

Future<void> _appConfigurations() async {
  await SystemChrome.setPreferredOrientations(AppValues.deviceOrientations);
  final prefs = await SharedPreferences.getInstance();
  AuthenticationKey.shared.token = prefs.getString('access_token') ?? '';
  callTypeGlobal = prefs.getString('call_default') ?? '3';
}

Future<void> _getDateLocal() async {}
