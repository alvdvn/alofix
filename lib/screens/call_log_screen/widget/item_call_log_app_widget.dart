// ignore_for_file: unrelated_type_equality_checks
import 'package:base_project/common/themes/colors.dart';
import 'package:base_project/config/fonts.dart';
import 'package:base_project/config/routes.dart';
import 'package:base_project/database/enum.dart';
import 'package:base_project/database/models/call_log.dart';
import 'package:base_project/extension.dart';
import 'package:base_project/generated/assets.dart';
import 'package:base_project/screens/call_log_screen/widget/item_status_call.dart';
import 'package:flutter/material.dart';
import 'package:flutter_svg/flutter_svg.dart';
import 'package:get/get.dart';
import 'package:intl/intl.dart';

class ItemListCallLogTime extends StatelessWidget {
  final List<List<CallLog>> logs;
  final String date;

  const ItemListCallLogTime({Key? key, required this.logs, required this.date})
      : super(key: key);

  String handlerDateTime(String element) {
    final String dateTimeNow = DateFormat("dd/MM/yyyy").format(DateTime.now());
    if (element == dateTimeNow) {
      return 'Hôm nay';
    }
    return element;
  }

  @override
  Widget build(BuildContext context) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Padding(
          padding: const EdgeInsets.symmetric(vertical: 12, horizontal: 16),
          child: Text(handlerDateTime(date),
              style:
                  FontFamily.demiBold(size: 14, color: AppColor.colorGreyText)),
        ),
        ItemCallLogAppWidget(logs: logs)
      ],
    );
  }
}

class ItemCallLogAppWidget extends StatelessWidget {
  final List<List<CallLog>> logs;

  const ItemCallLogAppWidget({Key? key, required this.logs}) : super(key: key);

  @override
  Widget build(BuildContext context) {

    return Column(
      children: [...logs.map((e) => CallGroupGroupByPhoneWidget(logs: e))],
    );
  }
}

class CallGroupGroupByPhoneWidget extends StatelessWidget {
  final List<CallLog> logs;

  const CallGroupGroupByPhoneWidget({Key? key, required this.logs})
      : super(key: key);

  @override
  Widget build(BuildContext context) {
    var first = logs.first;
    final date = DateTime.fromMillisecondsSinceEpoch(first.startAt).toLocal();
    final time = DateFormat("HH:mm").format(date);


    return InkWell(
      onTap: () async {
        Get.toNamed(Routes.detailCallLogScreen, arguments: logs);
      },
      child: Container(
        color: Colors.white,
        child: Column(children: [
          ListTile(
            leading: first.callLogValid == CallLogValid.invalid
                ? CircleAvatar(
                    radius: 16,
                    backgroundColor: AppColor.colorGreyBackground,
                    child: Image.asset(Assets.imagesCallLogInvalid,
                        width: 20, height: 20))
                : CircleAvatar(
                    radius: 16,
                    backgroundColor: AppColor.colorGreyBackground,
                    child: Image.asset(Assets.imagesImgNjv512h)),
            title: Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text('${first.phoneNumber} (${logs.length})',
                        style: FontFamily.demiBold(
                            size: 14,
                            color: first.callLogValid == CallLogValid.invalid
                                ? AppColor.colorRedMain
                                : AppColor.colorBlack)),
                    Row(
                      children: [
                        ItemStatusCall(
                            callType: first.type ?? CallType.incomming,
                            answeredDuration: first.answeredDuration ?? 0,
                            ringingTime: first.timeRinging ?? 0),
                        const SizedBox(width: 8),
                        SvgPicture.asset(Assets.iconsDot),
                        const SizedBox(width: 8),
                        Text(
                          time,
                          style: FontFamily.regular(
                              size: 12, color: AppColor.colorBlack),
                        ),
                      ],
                    ),
                  ],
                ),
                Row(
                  children: [
                    Text(first.method == CallMethod.sim ? 'SIM' : "APP",
                        style: FontFamily.regular(
                            size: 12, color: AppColor.colorGreyText)),
                    const SizedBox(width: 4),
                    SvgPicture.asset(first.method == CallMethod.sim
                        ? Assets.imagesSim
                        : Assets.imagesImgNjv512h)
                  ],
                )
              ],
            ),
          ),
          const SizedBox(height: 16)
        ]),
      ),
    );
  }
}
