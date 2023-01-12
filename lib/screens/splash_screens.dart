import 'dart:async';

import 'package:base_project/config/routes.dart';
import 'package:base_project/generated/assets.dart';
import 'package:base_project/services/remote/api_provider.dart';
import 'package:flutter/material.dart';
import 'package:get/get.dart';

class SplashScreen extends StatefulWidget {
  const SplashScreen({Key? key}) : super(key: key);

  @override
  State<SplashScreen> createState() => _SplashScreenState();
}

class _SplashScreenState extends State<SplashScreen> {
  @override
  void initState() {
    super.initState();
    Future.delayed(
        const Duration(seconds: 2),
        () => Get.offAllNamed(AuthenticationKey.shared.token.isEmpty
            ? Routes.loginScreen
            : Routes.homeScreen));
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: Center(
        child: Image.asset(Assets.imagesLogo, width: 253, height: 120),
      ),
    );
  }
}
