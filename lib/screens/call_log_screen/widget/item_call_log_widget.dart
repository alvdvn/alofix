import 'package:base_project/common/themes/colors.dart';
import 'package:base_project/config/fonts.dart';
import 'package:base_project/config/routes.dart';
import 'package:base_project/generated/assets.dart';
import 'package:base_project/models/history_call_log_model.dart';
import 'package:call_log/call_log.dart';
import 'package:flutter/material.dart';
import 'package:flutter_svg/flutter_svg.dart';
import 'package:get/get.dart';
import 'package:intl/intl.dart';

class ItemCallLogWidget extends StatelessWidget {
  final HistoryCallLogModel callLog;
  const ItemCallLogWidget({Key? key, required this.callLog}) : super(key: key);

  Widget _buildItemStatusCall(int callType) {
    switch (callType) {
      case 1:
        return Row(
          children: [
            SvgPicture.asset(Assets.iconsArrowUpRight),
            const SizedBox(width: 8),
            Text('Thành công',
                style: FontFamily.regular(size: 12, color: Colors.green))
          ],
        );
      case 2:
        return Row(
          children: [
            SvgPicture.asset(
              Assets.iconsArrowUpRight,
              color: AppColor.colorRedMain,
            ),
            const SizedBox(width: 8),
            Text(
              'Gọi nhỡ',
              style: FontFamily.regular(size: 12, color: AppColor.colorRedMain),
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
          style: FontFamily.regular(size: 12, color: Colors.green),
        )
      ],
    );
  }

  @override
  Widget build(BuildContext context) {
    final formatTime = DateFormat('hh:mm dd-MM-yyyy');
    return  InkWell(
      onTap: () async {
        Get.toNamed(Routes.detailCallLogScreen);
      },
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
                  Text(callLog.user?.fullName ?? '',
                      style: FontFamily.demiBold(
                          size: 14, color: AppColor.colorBlack)),
                  Text(callLog.phoneNumber ?? '',
                      style: FontFamily.demiBold(
                          size: 14, color: AppColor.colorBlack)),
                  Row(
                    children: [
                      _buildItemStatusCall(
                          callLog.type ?? 1),
                      const SizedBox(width: 8),
                      // Text(
                      //   "* ${DateFormat("yyyy-MM-dd'T'HH:mm:ss.SSS").format(DateTime.parse(callLog.startAt ?? ''))}",
                      //   style: FontFamily.regular(
                      //       size: 12, color: AppColor.colorBlack),
                      // ),
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
}
