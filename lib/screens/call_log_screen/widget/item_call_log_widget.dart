// ignore_for_file: unrelated_type_equality_checks
import 'package:base_project/common/themes/colors.dart';
import 'package:base_project/config/fonts.dart';
import 'package:base_project/config/routes.dart';
import 'package:base_project/generated/assets.dart';
import 'package:base_project/models/history_call_log_model.dart';
import 'package:flutter/material.dart';
import 'package:flutter_svg/flutter_svg.dart';
import 'package:get/get.dart';

class ItemCallLogWidget extends StatelessWidget {
  final HistoryCallLogModel callLog;

  const ItemCallLogWidget({Key? key, required this.callLog}) : super(key: key);

  Widget _buildItemStatusCall(int callType, int answeredDuration) {
    if (answeredDuration > 0) {
      return Row(
        children: [
          if (callLog == 1)
            SvgPicture.asset(Assets.iconsArrowDownLeft, color: Colors.green)
          else
            SvgPicture.asset(Assets.iconsArrowUpRight, color: Colors.green),
          const SizedBox(width: 8),
          Text('Thành công',
              style: FontFamily.regular(size: 12, color: Colors.green))
        ],
      );
    }
    return Row(
      children: [
        if (callLog == 1)
          SvgPicture.asset(Assets.iconsArrowDownLeft,
              color: AppColor.colorRedMain)
        else
          SvgPicture.asset(Assets.iconsArrowUpRight,
              color: AppColor.colorRedMain),
        const SizedBox(width: 8),
        Text('Thất bại',
            style: FontFamily.regular(size: 12, color: AppColor.colorRedMain)),
      ],
    );
  }

  @override
  Widget build(BuildContext context) {
    final time = DateTime.parse('${callLog.startAt}');
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
                        _buildItemStatusCall(
                            callLog.type ?? 2, callLog.answeredDuration ?? 0),
                        const SizedBox(width: 8),
                        Text(
                          "*${time.hour}:${time.minute}",
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
