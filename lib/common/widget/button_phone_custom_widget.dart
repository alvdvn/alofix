import 'package:base_project/common/themes/colors.dart';
import 'package:base_project/config/fonts.dart';
import 'package:flutter/material.dart';

class ButtonPhoneCustomWidget extends StatelessWidget {
  const ButtonPhoneCustomWidget({Key? key, required this.title})
      : super(key: key);
  final String title;

  @override
  Widget build(BuildContext context) {
    return Container(
      width: 80,
      height: 80,
      decoration: BoxDecoration(
        borderRadius: BorderRadius.circular(40),
        color: Colors.white,
      ),
      child: Center(
        child: Text(title,
            style: FontFamily.demiBold(size: 32, color: AppColor.colorBlack)),
      ),
    );
  }
}
