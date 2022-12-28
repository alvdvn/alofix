import 'dart:io';

import 'package:base_project/common/themes/colors.dart';
import 'package:base_project/config/fonts.dart';
import 'package:base_project/generated/assets.dart';
import 'package:call_log/call_log.dart';
import 'package:flutter/material.dart';
import 'package:flutter_phone_direct_caller/flutter_phone_direct_caller.dart';
import 'package:flutter_svg/flutter_svg.dart';
import 'package:get/get.dart';
import 'package:intl/intl.dart';

import 'call_log_controller.dart';

// ignore: must_be_immutable
class CallLogScreen extends StatelessWidget {
  CallLogScreen({super.key});

  CallLogController callLogController = Get.put(CallLogController());
  final formatTime = DateFormat('hh:mm dd-MM-yyyy');

  Widget _buildItemStatusCall(CallType callType) {
    switch (callType) {
      case CallType.outgoing:
        return Row(
          children: [
            SvgPicture.asset(Assets.iconsArrowUpRight),
            const SizedBox(width: 8),
            Text('Thành công',
                style: FontFamily.Regular(size: 12, color: Colors.green))
          ],
        );
      case CallType.missed:
        return Row(
          children: [
            SvgPicture.asset(
              Assets.iconsArrowUpRight,
              color: AppColor.colorRedMain,
            ),
            const SizedBox(width: 8),
            Text(
              'Gọi nhỡ',
              style: FontFamily.Regular(size: 12, color: AppColor.colorRedMain),
            )
          ],
        );
    }
    return Row(
      children: [
        SvgPicture.asset(Assets.iconsArrowUpRight),
        const SizedBox(width: 8),
        Text(
          'Thành công',
          style: FontFamily.Regular(size: 12, color: Colors.green),
        )
      ],
    );
  }

  Widget _buildItemCallLog(CallLogEntry callLog) {
    return InkWell(
      onTap: () async =>
          await FlutterPhoneDirectCaller.callNumber(callLog.number ?? ''),
      child: Column(children: [
        ListTile(
          leading: CircleAvatar(
            radius: 20,
            backgroundColor: AppColor.colorGreyBackground,
            child: Image.asset(Assets.imagesImageNjv),
          ),
          title: Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(callLog.name ?? '',
                      style: FontFamily.DemiBold(
                          size: 14, color: AppColor.colorBlack)),
                  Text(callLog.number ?? '',
                      style: FontFamily.DemiBold(
                          size: 14, color: AppColor.colorBlack)),
                  Row(
                    children: [
                      _buildItemStatusCall(
                          callLog.callType ?? CallType.outgoing),
                      const SizedBox(width: 8),
                      Text(
                        "* ${formatTime.format(DateTime.fromMillisecondsSinceEpoch(callLog.timestamp ?? 0)).toString()}",
                        style: FontFamily.Regular(
                            size: 12, color: AppColor.colorBlack),
                      ),
                    ],
                  ),
                ],
              ),
              SvgPicture.asset(Assets.iconsIconCall, color: AppColor.colorBlack)
            ],
          ),
        ),
        const SizedBox(height: 16)
      ]),
    );
  }

  @override
  Widget build(BuildContext context) {
    if (Platform.isAndroid) {
      callLogController.getCallLog();
    }
    return Scaffold(
        appBar: AppBar(
          backgroundColor: Colors.white,
          title: Text("Lịch sử cuộc gọi", style: FontFamily.DemiBold(size: 20)),
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
                        return _buildItemCallLog(item);
                      }
                    }),
              ));
  }
}
