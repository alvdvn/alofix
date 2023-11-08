import 'dart:io';
import 'package:get/get.dart';
import 'package:flutter/material.dart';
import 'package:flutter_svg/flutter_svg.dart';
import 'package:base_project/screens/home/home_controller.dart';
import 'package:base_project/common/themes/colors.dart';
import 'package:base_project/generated/assets.dart';
import 'package:base_project/screens/account/account_screen.dart';
import 'package:base_project/screens/call/call_screen.dart';
import 'package:base_project/screens/call_log_screen/call_log_screen.dart';
import 'package:base_project/screens/contact_devices/contact_devices_screen.dart';
import '../../services/local/logs.dart';
import 'widget/home_bottom_bar.dart';

class HomeScreen extends StatefulWidget {
  const HomeScreen({Key? key}) : super(key: key);

  @override
  State<HomeScreen> createState() => HomeScreenState();
}

class AccountScreenClone extends StatelessWidget {
  const AccountScreenClone({super.key});

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      home: Scaffold(
        appBar: AppBar(
          title: const Text('Simplest Flutter Screen'),
        ),
        body: const Center(
          child: Text(
            'Hello, Flutter!',
            style: TextStyle(fontSize: 24),
          ),
        ),
      ),
    );
  }
}

class HomeScreenState extends State<HomeScreen> with SingleTickerProviderStateMixin, Logs {
  int tabIndex = 0;
  late final TabController controller;

  final HomeController homeController = Get.put(HomeController());

  static final List<Widget> widgetOptions = <Widget>[
    const CallScreen(),
    const CallLogScreen(),
    const ContactDeviceScreen(),
    const AccountScreen(),
  ];

  void onItemTapped(int index) {
    setState(() {
      tabIndex = index;
    });
  }

  @override
  void initState() {
    super.initState();
    controller = TabController(length: widgetOptions.length, vsync: this);
    homeController.initData();
    // sendMessage("Home initState");
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: Center(child: widgetOptions.elementAt(tabIndex)),
      bottomNavigationBar: HomeBottomBar(
        selectedColor: AppColor.colorRedMain,
        unSelectedColor: AppColor.colorGreyText,
        backgroundColor: Colors.white,
        elevation: 24,
        currentIndex: tabIndex,
        onTap: onItemTapped,
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
              selectedIcon: SvgPicture.asset(Assets.iconsIconPhoneNumber, color: AppColor.colorRedMain)),
          HomeBottomBarItems(
              label: 'Lịch sử',
              unselectedIcon: SvgPicture.asset(Assets.iconsIconHistory),
              selectedIcon: SvgPicture.asset(Assets.iconsIconHistory, color: AppColor.colorRedMain)),
          HomeBottomBarItems(
              label: 'Danh bạ',
              unselectedIcon: SvgPicture.asset(Assets.iconsIconContact),
              selectedIcon: SvgPicture.asset(Assets.iconsIconContact, color: AppColor.colorRedMain)),
          HomeBottomBarItems(
              label: 'Tài khoản',
              unselectedIcon: SvgPicture.asset(Assets.iconsIconAccount),
              selectedIcon: SvgPicture.asset(Assets.iconsIconAccount, color: AppColor.colorRedMain)),
        ],
      ),
    );
  }
}
