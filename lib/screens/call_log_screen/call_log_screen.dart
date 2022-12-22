import 'package:base_project/config/fonts.dart';
import 'package:base_project/generated/assets.dart';
import 'package:flutter/material.dart';
import 'package:flutter_svg/flutter_svg.dart';
import 'package:get/get.dart';

import 'call_log_controller.dart';

// ignore: must_be_immutable
class CallLogScreen extends StatelessWidget {
  CallLogScreen({super.key});

  CallLogController callLogController = Get.put(CallLogController());

  @override
  Widget build(BuildContext context) {
    return Scaffold(
        appBar: AppBar(
          backgroundColor: Colors.white,
          title: Text("Danh bạ", style: FontFamily.DemiBold(size: 20)),
          elevation: 0,
          actions: [
            SvgPicture.asset(Assets.iconsIconSearch, width: 24, height: 24),
            const SizedBox(width: 32),
            SvgPicture.asset(Assets.iconsIconPlus),
            const SizedBox(width: 16),
          ],
        ),
        body: SingleChildScrollView(
          padding: const EdgeInsets.all(16),
          child: GetBuilder<CallLogController>(
            builder: (context) => Column(
              children: [
                if (callLogController.callLogEntries.isEmpty)
                  const Text("Chưa có cuộc gọi gần nhất")
                else
                  ...callLogController.callLogEntries.map((e) => Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          if (e.name != null) Text(e.name ?? ''),
                          Text(e.number ?? ''),
                          Text(DateTime.fromMillisecondsSinceEpoch(
                                  e.timestamp ?? 0)
                              .toString()),
                          Text(e.callType.toString()),
                          const Divider(color: Colors.black),
                        ],
                      ))
              ],
            ),
          ),
        ));
  }
}
