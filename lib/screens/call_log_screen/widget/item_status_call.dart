import 'package:base_project/common/themes/colors.dart';
import 'package:base_project/config/fonts.dart';
import 'package:base_project/generated/assets.dart';
import 'package:flutter/material.dart';
import 'package:flutter_svg/flutter_svg.dart';

class ItemStatusCall extends StatelessWidget {
  final int callType;
  final int answeredDuration;
  const ItemStatusCall({Key? key, required this.callType, required this.answeredDuration}) : super(key: key);
  Widget _buildItemStatusCall(int callType, int answeredDuration) {
    if (answeredDuration > 0) {
      return Row(
        children: [
          if (callType == 2)
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
        if (callType == 2)
          SvgPicture.asset(Assets.iconsArrowDownLeft,
              color: AppColor.colorRedMain)
        else
          SvgPicture.asset(Assets.iconsArrowUpRight,
              color: AppColor.colorRedMain),
        const SizedBox(width: 8),
        Text('Gọi nhỡ',
            style: FontFamily.regular(size: 12, color: AppColor.colorRedMain)),
      ],
    );
  }
  @override
  Widget build(BuildContext context) {
    return _buildItemStatusCall(callType,answeredDuration);
  }
}
