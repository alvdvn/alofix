import 'dart:io';
import 'package:base_project/config/fonts.dart';
import 'package:base_project/generated/assets.dart';
import 'package:flutter/material.dart';
import 'package:flutter_svg/flutter_svg.dart';
import 'package:get/get.dart';

import 'call_log_controller.dart';
import 'widget/item_call_log_widget.dart';

// ignore: must_be_immutable
class CallLogScreen extends StatefulWidget {
  const CallLogScreen({super.key});

  @override
  State<StatefulWidget> createState() {
    return CallLogState();
  }
}

class CallLogState extends State<CallLogScreen> {
  CallLogController callLogController = Get.put(CallLogController());

  @override
  Widget build(BuildContext context) {
    callLogController.getCallLogFromServer();
    if (Platform.isAndroid) {
      callLogController.getCallLog();
    }
    print('lich su ${callLogController.callLogSv?.first.phoneNumber}');
    return Scaffold(
        appBar: AppBar(
          backgroundColor: Colors.white,
          title: Text("Lịch sử gọi", style: FontFamily.demiBold(size: 20)),
          elevation: 0,
          actions: [
            SvgPicture.asset(Assets.iconsIconSearch, width: 24, height: 24),
            const SizedBox(width: 16),
            SvgPicture.asset(Assets.iconsIconCalender),
            const SizedBox(width: 16),
          ],
        ),
        body: callLogController.callLogSv != null
            ? ListView.builder(
                itemBuilder: (context, index) {
                  // return ItemCallLogWidget(callLog: item);
                  return ItemCallLogWidget(
                    callLog: callLogController.callLogSv![index],
                  );
                },
                itemCount: callLogController.callLogSv?.length,
              )
            : Container());
  }
}
