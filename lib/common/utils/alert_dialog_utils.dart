import 'package:base_project/common/themes/colors.dart';
import 'package:base_project/common/widget/button_custom_widget.dart';
import 'package:flutter/material.dart';
import 'package:get/get.dart';

Future<void> showDialogOneButton(String content, {String title = 'Thông báo'}) async {
  return Get.dialog(
    WillPopScope(
      onWillPop: () async {
        return false;
      },
      child: AlertDialog(
        title: Text(title),
        content: SingleChildScrollView(
          child: ListBody(
            children: [
              Text(content),
            ],
          ),
        ),
        actions: <Widget>[
          TextButton(
            onPressed: () {
              Get.back();
            },
            child: const Text('Xác nhận'),
          ),
        ],
      ),
    ),
  );
}

Future<void> showDialogError(String content, {Function? action}) async {
  return Get.dialog(
    WillPopScope(
      onWillPop: () async {
        return false;
      },
      child: Dialog(
        insetPadding: const EdgeInsets.only(left: 30, right: 30),
        shape: RoundedRectangleBorder(
            borderRadius:
            BorderRadius.circular(10)),
        child: ConstrainedBox(
          constraints: const BoxConstraints(
            minHeight: 150,
            // maxHeight: 250
          ),
          child: Container(
            padding: const EdgeInsets.symmetric(vertical: 16, horizontal: 16),
            // height: 300,
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              mainAxisSize: MainAxisSize.min,
              children: [
                const Padding(
                  padding: EdgeInsets.symmetric(vertical: 8),
                  child: Text('Thông báo', style: TextStyle(color: AppColor.highlightColor, fontSize: 16, fontWeight: FontWeight.bold),),
                ),
                Row(
                  mainAxisAlignment: MainAxisAlignment.end,
                  children: [
                    ButtonCustomWidget(title: 'Xác nhận', action: () {
                      Get.back();
                      if (action != null) { action(); }
                    })
                  ],
                )
              ],
            ),
          ),
        ),
      )
    ),
    barrierDismissible: true
  );
}



