import 'package:base_project/common/themes/colors.dart';
import 'package:flutter/material.dart';
import 'package:get/get.dart';

class ProgressHUD {
  static void show() {
    Get.dialog(
        const Center(
            child: SizedBox(
                width: 30,
                height: 30,
                child: CircularProgressIndicator(
                    valueColor: AlwaysStoppedAnimation<Color>(AppColor.colorRedMain)))),
        barrierDismissible: false);
  }

  static void dismiss() {
    Get.back();
  }
}
