import 'package:base_project/common/themes/colors.dart';
import 'package:base_project/config/fonts.dart';
import 'package:flutter/material.dart';

class ShowMoreWidget extends StatelessWidget {
  const ShowMoreWidget({Key? key}) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return Column(
      children: [
        Container(height: 1, color: AppColor.colorGreyBackground),
        const SizedBox(height: 8),
        Row(
          mainAxisAlignment: MainAxisAlignment.center,
          crossAxisAlignment: CrossAxisAlignment.center,
          children: [
            Text('Hiển thị thêm',
                style:
                    FontFamily.normal(color: AppColor.colorGreyText, size: 14)),
            const SizedBox(width: 8),
            const Icon(Icons.keyboard_arrow_down_outlined,
                size: 18, color: AppColor.colorGreyText)
          ],
        ),
        const SizedBox(height: 8),
        Container(height: 1, color: AppColor.colorGreyBackground),
      ],
    );
  }
}
