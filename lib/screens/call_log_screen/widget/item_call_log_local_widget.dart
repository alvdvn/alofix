import 'package:base_project/common/themes/colors.dart';
import 'package:base_project/config/fonts.dart';
import 'package:base_project/config/routes.dart';
import 'package:base_project/generated/assets.dart';
import 'package:base_project/screens/call_log_screen/call_log_controller.dart';
import 'package:call_log/call_log.dart';
import 'package:flutter/material.dart';
import 'package:flutter_svg/flutter_svg.dart';
import 'package:intl/intl.dart';

class ItemCallLogLocalWidget extends StatelessWidget {
  final CallLogEntry callLog;

  const ItemCallLogLocalWidget({Key? key, required this.callLog})
      : super(key: key);

  Widget _buildItemStatusCall({required CallLogEntry callLog}) {
    if (callLog.callType == CallType.outgoing) {
      return Row(
        children: [
          SvgPicture.asset(
            Assets.iconsArrowUpRight,
            color: callLog.duration == 0 ? AppColor.colorRedMain : Colors.green,
          ),
          const SizedBox(width: 8),
          callLog.duration == 0
              ? Text('Thất bại',
                  style: FontFamily.regular(
                      size: 12, color: AppColor.colorRedMain))
              : Text('Thành công',
                  style: FontFamily.regular(size: 12, color: Colors.green))
        ],
      );
    }
    if (callLog.callType == CallType.incoming) {
      return Row(
        children: [
          SvgPicture.asset(Assets.iconsArrowDownLeft,
              color:
                  callLog.duration == 0 ? AppColor.colorRedMain : Colors.green),
          const SizedBox(width: 8),
          callLog.duration == 0
              ? Text('Thất bại',
                  style: FontFamily.regular(
                      size: 12, color: AppColor.colorRedMain))
              : Text('Thành công',
                  style: FontFamily.regular(size: 12, color: Colors.green))
        ],
      );
    }
    return Row(
      children: [
        SvgPicture.asset(Assets.iconsArrowDownLeft),
        const SizedBox(width: 8),
        Text('Thất bại',
            style: FontFamily.regular(size: 12, color: AppColor.colorRedMain))
      ],
    );
  }

  @override
  Widget build(BuildContext context) {
    final callLogController = CallLogController();
    final formatTime = DateFormat('HH:mm dd/MM/yyyy');
    return InkWell(
      onTap: () async {
        // Get.toNamed(Routes.detailCallLogLocalScreen);
        callLogController.handCall(callLog.number ?? '');
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
                    Text(callLog.name ?? '',
                        style: FontFamily.demiBold(
                            size: 14, color: AppColor.colorBlack)),
                    Text(callLog.number ?? '',
                        style: FontFamily.demiBold(
                            size: 14, color: AppColor.colorBlack)),
                    Row(
                      children: [
                        _buildItemStatusCall(callLog: callLog),
                        const SizedBox(width: 8),
                        Text(
                          "* ${formatTime.format(DateTime.fromMillisecondsSinceEpoch(callLog.timestamp ?? 0).toLocal())}",
                          style: FontFamily.regular(
                              size: 12, color: AppColor.colorBlack),
                        ),
                      ],
                    ),
                  ],
                ),
                SvgPicture.asset(Assets.iconsIconCall,
                    color: AppColor.colorBlack)
              ],
            ),
          ),
          const SizedBox(height: 16)
        ]),
      ),
    );
  }
}
