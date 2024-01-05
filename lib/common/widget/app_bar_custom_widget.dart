import 'package:base_project/common/themes/colors.dart';
import 'package:base_project/config/fonts.dart';
import 'package:flutter/material.dart';
import 'package:get/get.dart';

class CustomAppBar extends StatelessWidget implements PreferredSizeWidget {
  const CustomAppBar({
    super.key,
    required this.title,
    this.background,
    this.leading,
    this.action,
    this.bottom,
    this.titleSpacing,
  }) ;
  final String title;
  final Color? background;
  final Widget? leading;
  final List<Widget>? action;
  final PreferredSizeWidget? bottom;
  final double? titleSpacing;

  @override
  Widget build(BuildContext context) {
    List<Widget>? latestAction;
    if (action != null) {
      latestAction = List.from(action!);
      latestAction.add(const SizedBox(width: 8));
    }
    return AppBar(
      leading: IconButton(
        onPressed: () => Get.back(),
        icon: const Icon(Icons.arrow_back_ios_new,
            color: AppColor.colorRedMain, size: 14),
      ),
      centerTitle: true,
      backgroundColor: Colors.white,
      title: Text(title, style: FontFamily.demiBold(size: 20)),
      elevation: 0,
      actions: action,
    );
  }

  @override
  Size get preferredSize => Size(
      double.maxFinite,
      bottom == null
          ? kToolbarHeight
          : kToolbarHeight + bottom!.preferredSize.height);
}
