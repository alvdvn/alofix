import 'package:base_project/common/themes/colors.dart';
import 'package:base_project/config/fonts.dart';
import 'package:base_project/database/enum.dart';
import 'package:flutter/material.dart';
import 'package:flutter_svg/svg.dart';

import '../../generated/assets.dart';

class RowTitleValueWidget extends StatelessWidget {
  const RowTitleValueWidget(
      {Key? key,
      required this.title,
      required this.value,
      this.isShowInvalid})
      : super(key: key);
  final String title;
  final String value;
  final bool? isShowInvalid;

  @override
  Widget build(BuildContext context) {
    // print('isShowInvalid $isShowInvalid');
    return Row(
      mainAxisAlignment: MainAxisAlignment.spaceBetween,
      children: [
        Row(
          children: [
            const SizedBox(width: 16),
            Text(
              title,
              style: FontFamily.normal(size: 14, color: AppColor.colorGreyText),
            ),
          ],
        ),
        isShowInvalid == true
            ? Row(
                children: [
                  Text(value,
                      style: FontFamily.normal(
                          size: 14, color: AppColor.colorRedMain)),
                  const SizedBox(width: 4),
                  Image.asset(Assets.imagesCallLogInvalid,
                      width: 13, height: 13),
                  const SizedBox(width: 16)
                ],
              )
            : isShowInvalid == false
                ? Row(
                    children: [
                      Text(value,
                          style: FontFamily.normal(
                              size: 14, color: AppColor.colorBlack)),
                      const SizedBox(width: 4),
                      SvgPicture.asset(Assets.imagesCallLogValid,
                          width: 12, height: 12),
                      const SizedBox(width: 16)
                    ],
                  )
                : Row(
                    children: [
                      Text(value,
                          style: FontFamily.normal(
                              size: 14, color: AppColor.colorBlack)),
                      const SizedBox(width: 16)
                    ],
                  )
      ],
    );
  }
}
