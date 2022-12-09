import 'package:base_project/my_app.dart';
import 'package:base_project/config/values.dart';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';

void main() async {
  await Future.wait([_initializeDependencies(), _appConfigurations()]);
  runApp(const MyApp());
}

Future<void> _initializeDependencies() async {
  WidgetsFlutterBinding.ensureInitialized();
}

Future<void> _appConfigurations() async {
  await SystemChrome.setPreferredOrientations(AppValues.deviceOrientations);
}
