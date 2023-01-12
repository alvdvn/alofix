import 'package:base_project/common/themes/colors.dart';
import 'package:base_project/config/fonts.dart';
import 'package:base_project/config/routes.dart';
import 'package:base_project/generated/assets.dart';
import 'package:call_log/call_log.dart';
import 'package:flutter/material.dart';
import 'package:flutter_svg/flutter_svg.dart';
import 'package:get/get.dart';
import 'package:intl/intl.dart';

class ItemCallLogWidget extends StatelessWidget {
  final CallLogEntry callLog;
  const ItemCallLogWidget({Key? key, required this.callLog}) : super(key: key);

  Widget _buildItemStatusCall(CallType callType) {
    switch (callType) {
      case CallType.outgoing:
        return Row(
          children: [
            SvgPicture.asset(Assets.iconsArrowUpRight),
            const SizedBox(width: 8),
            Text('Thành công',
                style: FontFamily.regular(size: 12, color: Colors.green))
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
                  Text(callLog.name ?? '',
                      style: FontFamily.demiBold(
                          size: 14, color: AppColor.colorBlack)),
                  Text(callLog.number ?? '',
                      style: FontFamily.demiBold(
                          size: 14, color: AppColor.colorBlack)),
                  Row(
                    children: [
                      _buildItemStatusCall(
                          callLog.callType ?? CallType.outgoing),
                      const SizedBox(width: 8),
                      Text(
                        "* ${formatTime.format(DateTime.fromMillisecondsSinceEpoch(callLog.timestamp ?? 0)).toString()}",
                        style: FontFamily.regular(
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
}
