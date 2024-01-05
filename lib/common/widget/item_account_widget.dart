import 'package:base_project/common/themes/colors.dart';
import 'package:base_project/config/fonts.dart';
import 'package:flutter/material.dart';
import 'package:flutter_svg/flutter_svg.dart';

class ItemAccountWidget extends StatelessWidget {
  const ItemAccountWidget(
      {Key? key,
      required this.assetsIcon,
      required this.title,
      required this.action,
      this.showVersion,
      this.color,
      this.showCallDefault,
      this.titleCallDefault,
      this.versionAppString})
      : super(key: key);
  final String assetsIcon;
  final String title;
  final Function() action;
  final bool? showVersion;
  final Color? color;
  final bool? showCallDefault;
  final String? titleCallDefault;
  final String? versionAppString;

  @override
  Widget build(BuildContext context) {
    return InkWell(
      onTap: action,
      child: Container(
        padding: const EdgeInsets.all(16),
        decoration: BoxDecoration(
            borderRadius: BorderRadius.circular(8),
            border: Border.all(width: 1, color: AppColor.colorGreyBorder)),
        child: Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            crossAxisAlignment: CrossAxisAlignment.center,
            children: [
              Row(
                children: [
                  SvgPicture.asset(assetsIcon,
                      color: color ?? AppColor.colorRedMain),
                  const SizedBox(width: 20),
                  Text(title, style: FontFamily.normal()),
                  const SizedBox(width: 16),
                ],
              ),
              Row(
                children: [
                  if (showCallDefault == true)
                    Text(titleCallDefault ?? '',
                        style: FontFamily.normal(size: 14)),
                  const SizedBox(width: 16),
                  showVersion ?? false
                      ? Text(versionAppString ?? "12", style: FontFamily.normal(size: 14))
                      : const Icon(Icons.arrow_forward_ios, size: 12),
                ],
              )
            ]),
      ),
    );
  }
}
