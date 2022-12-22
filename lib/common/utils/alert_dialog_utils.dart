import 'package:base_project/common/themes/colors.dart';
import 'package:base_project/common/widget/button_custom_widget.dart';
import 'package:base_project/config/fonts.dart';
import 'package:flutter/material.dart';
import 'package:get/get.dart';

Future<void> showDialogNotification(String content,
    {String title = 'Thông báo'}) async {
  return Get.dialog(
    WillPopScope(
      onWillPop: () async {
        return false;
      },
      child: AlertDialog(
        title: Row(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [Text(title, style: FontFamily.DemiBold(size: 16))],
        ),
        content: SingleChildScrollView(
          child: ListBody(
            children: [
              Text(content,
                  style: FontFamily.Regular(lineHeight: 1.5),
                  textAlign: TextAlign.center),
            ],
          ),
        ),
        actions: <Widget>[
          const Divider(
            thickness: 1,
            color: AppColor.colorGrey,
            height: 1,
          ),
          Row(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              Container(
                padding: const EdgeInsets.only(
                    top: 5, bottom: 5, right: 16, left: 16),
                child: TextButton(
                  onPressed: () {
                    Get.back();
                  },
                  child: Text(
                    'Đóng',
                    style: FontFamily.DemiBold(
                        color: AppColor.colorGreyBorder, size: 16),
                  ),
                ),
              ),
              const SizedBox(width: 55),
              Container(
                padding: const EdgeInsets.only(
                    top: 5, bottom: 5, right: 16, left: 16),
                child: TextButton(
                  onPressed: () {
                    Get.back();
                  },
                  child: Text('Đã hiểu',
                      style: FontFamily.DemiBold(
                          color: AppColor.colorRedMain, size: 16)),
                ),
              ),
            ],
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