import 'package:base_project/common/themes/colors.dart';
import 'package:base_project/config/fonts.dart';
import 'package:flutter/material.dart';

enum IndicatorType { top, bottom }

class HomeBottomBar extends StatelessWidget {
  final Color? backgroundColor;
  final double? elevation;
  final List<HomeBottomBarItems> customBottomBarItems;
  final Color? selectedColor;
  final Color? unSelectedColor;
  final double unselectedFontSize;
  final Color? splashColor;
  final int currentIndex;
  final bool enableLineIndicator;
  final double lineIndicatorWidth;
  final IndicatorType indicatorType;
  final Function(int) onTap;
  final double selectedFontSize;
  final double selectedIconSize;
  final double unselectedIconSize;
  final LinearGradient? gradient;

  const HomeBottomBar({
    super.key,
    this.backgroundColor,
    this.elevation,
    this.selectedColor,
    required this.customBottomBarItems,
    this.unSelectedColor,
    this.unselectedFontSize = 11,
    this.selectedFontSize = 12,
    this.selectedIconSize = 20,
    this.unselectedIconSize = 15,
    this.splashColor,
    this.currentIndex = 0,
    required this.onTap,
    this.enableLineIndicator = true,
    this.lineIndicatorWidth = 3,
    this.indicatorType = IndicatorType.top,
    this.gradient,
  });

  @override
  Widget build(BuildContext context) {
    final BottomNavigationBarThemeData bottomTheme =
        BottomNavigationBarTheme.of(context);
    return Card(
      elevation: elevation,
      margin: EdgeInsets.zero,
      child: Container(
        padding: const EdgeInsets.only(bottom: 8),
        width: double.infinity,
        decoration: BoxDecoration(
          color: backgroundColor ?? bottomTheme.backgroundColor,
          gradient: gradient,
        ),
        child: SingleChildScrollView(
          child: Row(
            mainAxisAlignment: MainAxisAlignment.spaceAround,
            children: [
              for (int i = 0; i < customBottomBarItems.length; i++) ...[
                Expanded(
                  child: _CustomLineIndicatorItems(
                    selectedColor: selectedColor,
                    unSelectedColor: unSelectedColor,
                    unSelectedIcon: customBottomBarItems[i].unselectedIcon,
                    selectedIcon: customBottomBarItems[i].selectedIcon,
                    label: customBottomBarItems[i].label,
                    unSelectedFontSize: unselectedFontSize,
                    selectedFontSize: selectedFontSize,
                    unselectedIconSize: unselectedIconSize,
                    selectedIconSize: selectedIconSize,
                    splashColor: splashColor,
                    currentIndex: currentIndex,
                    enableLineIndicator: enableLineIndicator,
                    lineIndicatorWidth: lineIndicatorWidth,
                    indicatorType: indicatorType,
                    index: i,
                    onTap: onTap,
                  ),
                ),
              ]
            ],
          ),
        ),
      ),
    );
  }
}

class HomeBottomBarItems {
  final Widget unselectedIcon;
  final Widget selectedIcon;
  final String label;

  const HomeBottomBarItems({
    required this.unselectedIcon,
    required this.selectedIcon,
    required this.label,
  });
}

class _CustomLineIndicatorItems extends StatelessWidget {
  final Widget? unSelectedIcon;
  final Widget? selectedIcon;
  final String? label;
  final Color? selectedColor;
  final Color? unSelectedColor;
  final double unSelectedFontSize;
  final double selectedIconSize;
  final double unselectedIconSize;

  final double selectedFontSize;
  final Color? splashColor;
  final int? currentIndex;
  final int index;
  final Function(int) onTap;
  final bool enableLineIndicator;
  final double lineIndicatorWidth;
  final IndicatorType indicatorType;

  const _CustomLineIndicatorItems({
    this.unSelectedIcon,
    this.selectedIcon,
    this.label,
    this.selectedColor,
    this.unSelectedColor,
    this.unSelectedFontSize = 11,
    this.selectedFontSize = 12,
    this.selectedIconSize = 20,
    this.unselectedIconSize = 15,
    this.splashColor,
    this.currentIndex,
    required this.onTap,
    required this.index,
    this.enableLineIndicator = true,
    this.lineIndicatorWidth = 3,
    this.indicatorType = IndicatorType.top,
  });

  @override
  Widget build(BuildContext context) {
    final BottomNavigationBarThemeData bottomTheme =
        BottomNavigationBarTheme.of(context);
    return Material(
      color: Colors.white,
      child: InkWell(
        splashColor: splashColor ?? Theme.of(context).splashColor,
        onTap: () => onTap(index),
        child: Container(
          alignment: Alignment.center,
          padding: const EdgeInsets.symmetric(vertical: 10),
          decoration: BoxDecoration(
            border: enableLineIndicator
                ? Border(
                    bottom: indicatorType == IndicatorType.bottom
                        ? BorderSide(
                            color: currentIndex == index
                                ? selectedColor ??
                                    bottomTheme.selectedItemColor!
                                : Colors.transparent,
                            width: lineIndicatorWidth,
                          )
                        : const BorderSide(color: Colors.transparent),
                    top: indicatorType == IndicatorType.top
                        ? BorderSide(
                            color: currentIndex == index
                                ? selectedColor ??
                                    bottomTheme.selectedItemColor!
                                : Colors.transparent,
                            width: lineIndicatorWidth,
                          )
                        : const BorderSide(color: Colors.transparent),
                  )
                : null,
          ),
          child: Column(
            children: [
              if (currentIndex == index)
                selectedIcon ?? Container()
              else
                unSelectedIcon ?? Container(),
              const SizedBox(
                height: 5.0,
              ),
              Text(
                '$label',
                textAlign: TextAlign.center,
                overflow: TextOverflow.ellipsis,
                style: currentIndex == index
                    ? FontFamily.regular(size: 14, color: AppColor.colorRedMain)
                    : FontFamily.regular(size: 14, color: AppColor.colorGreyText),
              ),
            ],
          ),
        ),
      ),
    );
  }
}
