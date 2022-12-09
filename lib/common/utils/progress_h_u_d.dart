import 'package:flutter/material.dart';
import 'package:get/get.dart';

class ProgressHUD {
  static void show() {
    Get.dialog(
        const Center(
            child: SizedBox(
                width: 70,
                height: 70,
                child: CircularProgressIndicator(
                    valueColor: AlwaysStoppedAnimation<Color>(Colors.white)))),
        barrierDismissible: false);
  }

  static void dismiss() {
    Get.back();
  }
}
