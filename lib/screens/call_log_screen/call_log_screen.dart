import 'package:flutter/material.dart';
import 'package:get/get.dart';

import 'call_log_controller.dart';

// ignore: must_be_immutable
class CallLogScreen extends StatelessWidget {
  CallLogScreen({super.key});

  CallLogController callLogController = Get.put(CallLogController());

  @override
  Widget build(BuildContext context) {
    return Scaffold(
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
                      Text(DateTime.fromMillisecondsSinceEpoch(e.timestamp ?? 0)
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
