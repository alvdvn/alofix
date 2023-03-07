// ignore_for_file: unrelated_type_equality_checks
import 'package:base_project/common/themes/colors.dart';
import 'package:base_project/config/fonts.dart';
import 'package:base_project/config/routes.dart';
import 'package:base_project/generated/assets.dart';
import 'package:base_project/models/history_call_log_app_model.dart';
import 'package:base_project/screens/call_log_screen/widget/item_status_call.dart';
import 'package:flutter/material.dart';
import 'package:flutter_svg/flutter_svg.dart';
import 'package:get/get.dart';
import 'package:intl/intl.dart';

class ItemCallLogAppWidget extends StatelessWidget {
  final List<HistoryCallLogAppModel> callLog;

  const ItemCallLogAppWidget({Key? key, required this.callLog})
      : super(key: key);

  @override
  Widget build(BuildContext context) {
    return Column(
      children: [...callLog.map((e) => ItemCallLogWidget(log: e))],
    );
  }
}

class ItemCallLogWidget extends StatelessWidget {
  final HistoryCallLogAppModel log;

  const ItemCallLogWidget({super.key, required this.log});

  @override
  Widget build(BuildContext context) {
    final date = DateTime.parse('${log.logs?.first.startAt}').toLocal();
    final time = DateFormat("HH:mm").format(date);
    return InkWell(
      onTap: () async {
        Get.toNamed(Routes.detailCallLogScreen, arguments: log);
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
                    Text('${log.phoneNumber} (${log.logs?.length})' ?? '',
                        style: FontFamily.demiBold(
                            size: 14, color: AppColor.colorBlack)),
                    // if (log.logs?.first.user?.fullName == null)
                    //   Text(log.phoneNumber ?? '',
                    //       style: FontFamily.demiBold(
                    //           size: 14, color: AppColor.colorBlack)),
                    Row(
                      children: [
                        ItemStatusCall(
                            callType: log.logs?.first.type ?? 1,
                            answeredDuration:
                                log.logs?.first.answeredDuration ?? 0),
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
                log.logs?.first.method == 2
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
