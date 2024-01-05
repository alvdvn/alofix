// ignore_for_file: unrelated_type_equality_checks
import 'package:base_project/common/themes/colors.dart';
import 'package:base_project/config/fonts.dart';
import 'package:base_project/database/enum.dart';
import 'package:base_project/database/models/call_log.dart';
import 'package:base_project/generated/assets.dart';
import 'package:base_project/screens/call_log_screen/widget/item_status_call.dart';
import 'package:flutter/material.dart';
import 'package:flutter_svg/flutter_svg.dart';
import 'package:intl/intl.dart';

class ItemCallLogWidget extends StatelessWidget {
  final CallLog callLog;
  final Function(CallLog) onChange;

  const ItemCallLogWidget(
      {Key? key, required this.callLog, required this.onChange})
      : super(key: key);

  @override
  Widget build(BuildContext context) {
    final date = DateTime.fromMillisecondsSinceEpoch(callLog.startAt);
    final time = DateFormat("HH:mm dd/MM/yyyy").format(date);
    return InkWell(
      onTap: () {
        onChange(callLog);
      },
      child: Container(
        color: Colors.white,
        child: Column(children: [
          ListTile(
            leading: callLog.callLogValid == CallLogValid.invalid
                ? CircleAvatar(
                    radius: 16,
                    backgroundColor: AppColor.colorGreyBackground,
                    child: Image.asset(Assets.imagesCallLogInvalid))
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
                    Text(callLog.phoneNumber,
                        style: FontFamily.demiBold(
                            size: 14,
                            color: callLog.callLogValid == CallLogValid.invalid
                                ? AppColor.colorRedMain
                                : AppColor.colorBlack)),
                    Row(
                      children: [
                        ItemStatusCall(
                            callType: callLog.type ?? CallType.incomming,
                            answeredDuration: callLog.answeredDuration ?? 0,
                            ringingTime: callLog.timeRinging ?? 0),
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
                    Text(callLog.method == CallMethod.sim ? 'SIM' : "APP",
                        style: FontFamily.regular(
                            size: 12, color: AppColor.colorGreyText)),
                    const SizedBox(width: 4),
                    SvgPicture.asset(callLog.method == CallMethod.sim
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
