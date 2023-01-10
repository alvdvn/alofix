import 'package:base_project/common/themes/colors.dart';
import 'package:base_project/config/fonts.dart';
import 'package:flutter/material.dart';
import 'package:flutter_svg/flutter_svg.dart';

class ExpansionBlock extends StatelessWidget {
  const ExpansionBlock({
    Key? key,
    required this.title,
    required this.items,
    this.initiallyExpanded,
    this.onExpansionChanged,
    this.maintainState = true, required this.assetsIcon,
  }) : super(key: key);
  final String title;
  final List<Widget> items;
  final bool? initiallyExpanded;
  final ValueChanged<bool>? onExpansionChanged;
  final bool maintainState;
  final String assetsIcon;

  @override
  Widget build(BuildContext context) {
    return Container(
      decoration: const BoxDecoration(
        color: Colors.white,
      ),
      child: Theme(
        data: Theme.of(context).copyWith(
          dividerColor: Colors.transparent,
          listTileTheme: const ListTileThemeData(
            dense: true,
          ),
        ),
        child: ExpansionTile(
          maintainState: maintainState,
          onExpansionChanged: onExpansionChanged,
          initiallyExpanded: initiallyExpanded ?? false,
          title: Row(
            children: [
              SvgPicture.asset(assetsIcon,color: AppColor.colorGreyText,),
              const SizedBox(width: 8),
              Text(title,
                  style:
                      FontFamily.normal(size: 16, color: AppColor.colorRedMain))
            ],
          ),
          children: items,
        ),
      ),
    );
  }
}
