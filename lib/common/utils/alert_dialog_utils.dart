import 'package:base_project/common/themes/colors.dart';
import 'package:base_project/common/widget/button_custom_widget.dart';
import 'package:base_project/common/widget/date_range_selection.dart';
import 'package:base_project/config/fonts.dart';
import 'package:base_project/generated/assets.dart';
import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:flutter_svg/flutter_svg.dart';
import 'package:get/get.dart';

Future<void> showDialogNotification(String content, {String title = 'Thông báo', GestureTapCallback? action, String? titleBtn, bool? showBack = false}) async {
  return Get.dialog(
    AlertDialog(
      contentPadding: EdgeInsets.only(top: 16, bottom:  showBack!?8:16),
      content: Column(
        mainAxisSize: MainAxisSize.min,
        crossAxisAlignment: CrossAxisAlignment.stretch,
        children: [
          Text(title, style: FontFamily.demiBold(size: 16), textAlign: TextAlign.center),
          const SizedBox(height: 16),
          Container(
            padding: EdgeInsets.symmetric(horizontal: 16),
              child: Text(content, style: FontFamily.regular(lineHeight: 1.9, color: AppColor.colorGreyText, size: 13), textAlign: TextAlign.center)),
          SizedBox(height: 16,),
          const Divider(

            thickness: 1,
            color: AppColor.colorGreyLine,
            height: 1,
          ),
          showBack!?SizedBox(height: 0,):SizedBox(height: 16,),
          Row(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              if (showBack == true)
                Expanded(
                  child: Center(
                    child: TextButton(
                      onPressed: () {
                        Get.back();
                      },
                      child: Text(
                        'Đóng',
                        style: FontFamily.normal(color: AppColor.colorBlack, size: 16),
                      ),
                    ),
                  ),
                ),
              Expanded(
                child: Center(
                  child: InkWell(
                    onTap: action,
                    child: Text(titleBtn ?? 'Đã hiểu', style: FontFamily.demiBold(color: AppColor.colorRedMain, size: 16)),
                  ),
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
            shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(20)),
            child: ConstrainedBox(
              constraints: const BoxConstraints(
                minHeight: 150,
                // maxHeight: 250
              ),
              child: Container(
                padding: const EdgeInsets.symmetric( vertical: 16),
                // height: 300,
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.center,
                  mainAxisSize: MainAxisSize.min,
                  children: [
                    const Padding(
                      padding: EdgeInsets.only(top: 8),
                      child: Text(
                        'Thông báo',
                        style: TextStyle(color: AppColor.colorBlack, fontSize: 18, fontWeight: FontWeight.bold),
                      ),
                    ),
                    Padding(
                      padding: const EdgeInsets.symmetric(vertical: 8, horizontal: 0),
                      child: Text(content,
                          style: FontFamily.regular(lineHeight: 1.6, color: AppColor.colorHintText, size: 14),
                          textAlign: TextAlign.center),
                    ),
                    SizedBox(height: 16,),
                    const Divider(
                      thickness: 1,
                      color: AppColor.colorGreyLine,
                      height: 1,
                    ),
                    SizedBox(height: 16,),
                    Row(
                      mainAxisAlignment: MainAxisAlignment.center,
                      children: [
                        InkWell(
                          onTap: (){
                            Get.back();
                            if (action != null) {
                              action();
                            }
                          },
                          child: const Text("Xác nhận",style: TextStyle(
                            fontSize: 17, fontWeight: FontWeight.w600,color: AppColor.colorRedMain,fontFamily: "AvenirNext"
                          ),),
                        )
                      ],
                    )
                  ],
                ),
              ),
            ),
          )),
      barrierDismissible: true);
}

Future<void> showDialogCallLog(String content, {String title = 'Thông báo', GestureTapCallback? action, String? titleBtn}) async {
  return Get.dialog(
    WillPopScope(
      onWillPop: () async {
        return false;
      },
      child: AlertDialog(
        content: SingleChildScrollView(
          child: ListBody(
            children: [
              Row(mainAxisAlignment: MainAxisAlignment.center, children: [Text(title, style: FontFamily.demiBold(size: 16))]),
              const SizedBox(height: 32),
              Row(
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                children: [
                  const SizedBox(width: 16),
                  Text(content, style: FontFamily.demiBold(lineHeight: 1.9, size: 18), textAlign: TextAlign.center),
                  const SizedBox(width: 32),
                  SvgPicture.asset(Assets.iconsIconCall),
                  const SizedBox(width: 16),
                ],
              )
            ],
          ),
        ),
        actions: const <Widget>[SizedBox(height: 32)],
      ),
    ),
  );
}

Future<DateTimeRange?> showDateRangePickerDialog(
    BuildContext context, {
      String? title,
      DateTimeRange? dateRange,
    }) async {
  return await showDialog<DateTimeRange>(
    context: context,
    barrierDismissible: false,
    builder: (BuildContext context) {
      return Dialog(
        insetPadding: const EdgeInsets.symmetric(horizontal: 16),
        shape: RoundedRectangleBorder(
          borderRadius: BorderRadius.circular(10),
        ),
        child: DateRangeSelection(
          title: title,
          dateRange: dateRange,
        ),
      );
    },
  );
}
