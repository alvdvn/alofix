import 'package:base_project/common/themes/colors.dart';
import 'package:base_project/config/fonts.dart';
import 'package:base_project/database/models/call_log.dart';
import 'package:base_project/generated/assets.dart';
import 'package:flutter/material.dart';
import 'package:flutter_svg/flutter_svg.dart';

class ItemStatusCall extends StatelessWidget {
  final CallType callType;
  final int answeredDuration;
  final int ringingTime;
  const ItemStatusCall({Key? key, required this.callType, required this.answeredDuration, required this.ringingTime}) : super(key: key);
  Widget _buildItemStatusCall(CallType callType, int answeredDuration) {
    if (answeredDuration > 0 && ringingTime >= 0) {
      return Row(
        children: [
          if (callType == 2)
            SvgPicture.asset(Assets.iconsArrowDownLeft, color: Colors.green)
          else
            SvgPicture.asset(Assets.iconsArrowUpRight, color: Colors.green),
          const SizedBox(width: 8),
          Text('Thành công', style: FontFamily.regular(size: 12, color: Colors.green))
        ],
      );
    }
    return Row(
      children: [
        if (callType == 2)
          SvgPicture.asset(Assets.iconsArrowDownLeft, color: AppColor.colorRedMain)
        else
          SvgPicture.asset(Assets.iconsArrowUpRight, color: AppColor.colorRedMain),
        const SizedBox(width: 8),
        Text('Gọi nhỡ', style: FontFamily.regular(size: 12, color: AppColor.colorRedMain)),
      ],
    );
  }
  @override
  Widget build(BuildContext context) {
    return _buildItemStatusCall(callType,answeredDuration);
  }
}
