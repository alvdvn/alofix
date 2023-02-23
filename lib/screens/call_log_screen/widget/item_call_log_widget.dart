// ignore_for_file: unrelated_type_equality_checks
import 'package:base_project/common/themes/colors.dart';
import 'package:base_project/config/fonts.dart';
import 'package:base_project/config/routes.dart';
import 'package:base_project/generated/assets.dart';
import 'package:base_project/models/history_call_log_model.dart';
import 'package:base_project/screens/call_log_screen/widget/item_status_call.dart';
import 'package:flutter/material.dart';
import 'package:flutter_svg/flutter_svg.dart';
import 'package:get/get.dart';
import 'package:intl/intl.dart';

class ItemCallLogWidget extends StatelessWidget {
  final HistoryCallLogModel callLog;

  const ItemCallLogWidget({Key? key, required this.callLog}) : super(key: key);



  @override
  Widget build(BuildContext context) {
    final date = DateTime.parse('${callLog.startAt}').toLocal();
    final time = DateFormat("HH:mm dd/MM/yyyy").format(date);
    return InkWell(
      onTap: () async {
        Get.toNamed(Routes.detailCallLogScreen, arguments: callLog);
      },
      child: Container(
        color: Colors.white,
        child: Column(children: [
          ListTile(
            leading: CircleAvatar(
                radius: 16,
                backgroundColor: AppColor.colorGreyBackground,
                child: Image.asset(Assets.imagesImgNjv512h)),
            title: Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(callLog.phoneNumber ?? '',
                        style: FontFamily.demiBold(
                            size: 14, color: AppColor.colorBlack)),
                    if (callLog.user?.fullName == null)
                      Text(callLog.phoneNumber ?? '',
                          style: FontFamily.demiBold(
                              size: 14, color: AppColor.colorBlack)),
                    Row(
                      children: [
                        ItemStatusCall(
                            callType: callLog.type ?? 1,
                            answeredDuration: callLog.answeredDuration ?? 0),
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
                callLog.method == 2
                    ? Row(
                        children: [
                          Text('SIM',
                              style: FontFamily.regular(
                                  size: 12, color: AppColor.colorGreyText)),
                          const SizedBox(width: 4),
                          SvgPicture.asset(Assets.imagesSim)
                        ],
                      )
                    : Row(
                        children: [
                          Text('APP',
                              style: FontFamily.regular(
                                  size: 12, color: AppColor.colorGreyText)),
                          const SizedBox(width: 4),
                          Image.asset(Assets.imagesImgNjv512h,
                              width: 16, height: 16)
                        ],
                      ),
              ],
            ),
          ),
          const SizedBox(height: 16)
        ]),
      ),
    );
  }
}
