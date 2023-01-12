import 'dart:io';

import 'package:base_project/common/themes/colors.dart';
import 'package:base_project/config/fonts.dart';
import 'package:base_project/config/routes.dart';
import 'package:base_project/generated/assets.dart';
import 'package:call_log/call_log.dart';
import 'package:flutter/material.dart';
import 'package:flutter_svg/flutter_svg.dart';
import 'package:get/get.dart';
import 'package:intl/intl.dart';

import 'call_log_controller.dart';
import 'widget/item_call_log_widget.dart';

// ignore: must_be_immutable
class CallLogScreen extends StatelessWidget {
  CallLogScreen({super.key});

  CallLogController callLogController = Get.put(CallLogController());

  @override
  Widget build(BuildContext context) {
    if (Platform.isAndroid) {
      callLogController.getCallLog();
    }
    return Scaffold(
        appBar: AppBar(
          backgroundColor: Colors.white,
          title: Text("Lịch sử cuộc gọi", style: FontFamily.demiBold(size: 20)),
          elevation: 0,
          actions: [
            SvgPicture.asset(Assets.iconsIconSearch, width: 24, height: 24),
            const SizedBox(width: 16),
            SvgPicture.asset(Assets.iconsIconCalender),
            const SizedBox(width: 16),
          ],
        ),
        body: callLogController.callLogEntries.isEmpty
            ? const Text('Chưa có cuộc gọi gần nhất')
            : GetBuilder<CallLogController>(
                builder: (context) => ListView.builder(
                    itemCount: callLogController.callLogEntries.length,
                    itemBuilder: (context, index) {
                      if (callLogController.callLogEntries.isEmpty) {
                        return const Text("Chưa có cuộc gọi gần nhất");
                      } else {
                        var item =
                            callLogController.callLogEntries.toList()[index];
                        return ItemCallLogWidget(callLog: item);
                      }
                    })));
  }
}
