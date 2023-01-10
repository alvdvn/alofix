import 'package:base_project/common/themes/colors.dart';
import 'package:base_project/config/fonts.dart';
import 'package:flutter/material.dart';
import 'package:flutter_svg/flutter_svg.dart';

class ItemCallDefaultWidget extends StatelessWidget {
  final String assetsImage;
  final String title;
  final String value;
  final bool? isChoose;
  final bool? viewIcon;

  const ItemCallDefaultWidget(
      {Key? key,
      required this.assetsImage,
      required this.title,
      required this.value,
      this.viewIcon = false,
      this.isChoose = false})
      : super(key: key);

  @override
  Widget build(BuildContext context) {
    return Container(
      margin: const EdgeInsets.all(16),
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
          border: Border.all(
              color: isChoose == false
                  ? AppColor.colorGrey
                  : AppColor.colorRedMain,
              width: 1),
          borderRadius: BorderRadius.circular(10),
          color: Colors.white),
      child: Row(
        mainAxisAlignment: MainAxisAlignment.spaceBetween,
        children: [
          Row(
            children: [
              viewIcon == true
                  ? SvgPicture.asset(assetsImage, width: 60, height: 60)
                  : Image.asset(assetsImage, width: 60, height: 60),
              const SizedBox(width: 24),
              Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(title,
                      style: FontFamily.normal(size: 18, color: Colors.black)),
                  const SizedBox(height: 8),
                  Text(isChoose == true ? 'Đang chọn' : value,
                      style: FontFamily.regular(
                          size: 12, color: AppColor.colorGreyText))
                ],
              ),
            ],
          ),
          isChoose == true
              ? const Icon(Icons.radio_button_checked_outlined,
                  color: AppColor.colorRedMain)
              : const Icon(Icons.radio_button_off_outlined,
                  color: AppColor.colorGrey)
        ],
      ),
    );
  }
}
