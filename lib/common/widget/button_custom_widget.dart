import 'package:base_project/common/themes/colors.dart';
import 'package:flutter/material.dart';

class ButtonCustomWidget extends StatelessWidget {
  const ButtonCustomWidget(
      {super.key,
      required this.title,
      required this.action,
      this.color,
      this.maxSize,
      this.enable,
      this.titleColor,
      this.borderColor,
      this.borderRadius});

  final String? title;
  final Function() action;
  final Color? color;
  final Color? titleColor;
  final Color? borderColor;
  final bool? maxSize;
  final bool? enable;
  final double? borderRadius;

  @override
  Widget build(BuildContext context) {
    return Container(
      width: maxSize ?? false ? double.maxFinite : null,
      decoration: BoxDecoration(
          borderRadius: BorderRadius.all(Radius.circular(borderRadius ?? 6)),
          border: Border.all(
              color: borderColor ?? Colors.white.withOpacity(0), width: 1),
          color: AppColor.colorRedMain),
      child: TextButton(
          onPressed: action,
          child: Padding(
              padding: const EdgeInsets.symmetric(horizontal: 16),
              child: Text(title ?? '',
                  style: TextStyle(
                      color: titleColor ?? Colors.white,
                      fontWeight: FontWeight.w500,
                      fontSize: 15)))),
    );
  }
}
