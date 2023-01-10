import 'package:base_project/common/themes/colors.dart';
import 'package:base_project/config/fonts.dart';
import 'package:flutter/material.dart';

class RowTitleValueWidget extends StatelessWidget {
  const RowTitleValueWidget(
      {Key? key, required this.title, required this.value})
      : super(key: key);
  final String title;
  final String value;

  @override
  Widget build(BuildContext context) {
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
        Row(
          children: [
            Text(value,
                style: FontFamily.normal(size: 14, color: AppColor.colorBlack)),
            const SizedBox(width: 16),
          ],
        )
      ],
    );
  }
}
