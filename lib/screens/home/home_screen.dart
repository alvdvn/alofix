import 'dart:io';
import 'package:base_project/common/themes/colors.dart';
import 'package:base_project/generated/assets.dart';
import 'package:base_project/screens/account/account_controller.dart';
import 'package:base_project/screens/account/account_screen.dart';
import 'package:base_project/screens/call/call_screen.dart';
import 'package:base_project/screens/call_log_screen/call_log_controller.dart';
import 'package:base_project/screens/call_log_screen/call_log_screen.dart';
import 'package:base_project/screens/contact_devices/contact_devices_screen.dart';
import 'package:base_project/screens/home/home_controller.dart';
import 'package:flutter/material.dart';
import 'package:flutter_svg/flutter_svg.dart';
import 'package:get/get.dart';
import 'package:permission_handler/permission_handler.dart';

import 'widget/home_bottom_bar.dart';

class HomeScreen extends StatefulWidget {
  const HomeScreen({Key? key}) : super(key: key);

  @override
  State<HomeScreen> createState() => _HomeScreenState();
}

class _HomeScreenState extends State<HomeScreen>
    with SingleTickerProviderStateMixin {
  late final TabController controller;
  int _selectedIndex = 0;
  CallLogController callLogController = Get.put(CallLogController());
  HomeController homeController = Get.put(HomeController());
  final AccountController _controller = Get.put(AccountController());
  static final List<Widget> _widgetOptions = <Widget>[
    const CallScreen(),
    const CallLogScreen(),
    const ContactDeviceScreen(),
    const AccountScreen()
  ];

  void _onItemTapped(int index) {
    setState(() {
      _selectedIndex = index;
    });
  }

  @override
  void initState() {






    super.initState();
    controller = TabController(length: _widgetOptions.length, vsync: this);
    initData();
  }

  void initData() async {
    await _controller.getUserLogin();
    if (Platform.isAndroid) {
      callLogController.initData();
    }
    await homeController.initService();
  }



  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: Center(child: _widgetOptions.elementAt(_selectedIndex)),
      bottomNavigationBar: HomeBottomBar(
        selectedColor: AppColor.colorRedMain,
        unSelectedColor: AppColor.colorGreyText,
        backgroundColor: Colors.white,
        elevation: 24,
        currentIndex: _selectedIndex,
        onTap: _onItemTapped,
        enableLineIndicator: true,
        lineIndicatorWidth: 2,
        indicatorType: IndicatorType.top,
        unselectedFontSize: 13,
        selectedFontSize: 13,
        unselectedIconSize: 18,
        selectedIconSize: 18,
        customBottomBarItems: <HomeBottomBarItems>[
          HomeBottomBarItems(
              label: 'Gọi điện',
              unselectedIcon: SvgPicture.asset(Assets.iconsIconPhoneNumber),
              selectedIcon: SvgPicture.asset(Assets.iconsIconPhoneNumber,
                  color: AppColor.colorRedMain)),
          HomeBottomBarItems(
              label: 'Lịch sử',
              unselectedIcon: SvgPicture.asset(Assets.iconsIconHistory),
              selectedIcon: SvgPicture.asset(Assets.iconsIconHistory,
                  color: AppColor.colorRedMain)),
          HomeBottomBarItems(
              label: 'Danh bạ',
              unselectedIcon: SvgPicture.asset(Assets.iconsIconContact),
              selectedIcon: SvgPicture.asset(Assets.iconsIconContact,
                  color: AppColor.colorRedMain)),
          HomeBottomBarItems(
              label: 'Tài khoản',
              unselectedIcon: SvgPicture.asset(Assets.iconsIconAccount),
              selectedIcon: SvgPicture.asset(Assets.iconsIconAccount,
                  color: AppColor.colorRedMain)),
        ],
      ),
    );
  }
}
