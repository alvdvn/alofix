import 'package:base_project/common/themes/colors.dart';
import 'package:base_project/config/fonts.dart';
import 'package:base_project/generated/assets.dart';
import 'package:base_project/screens/account/account_controller.dart';
import 'package:base_project/screens/account/account_screen.dart';
import 'package:base_project/screens/call/call_screen.dart';
import 'package:base_project/screens/call_log_screen/call_log_screen.dart';
import 'package:base_project/screens/contact_devices/contact_devices_screen.dart';
import 'package:flutter/material.dart';
import 'package:flutter_svg/flutter_svg.dart';
import 'package:get/get.dart';

class HomeScreen extends StatefulWidget {
  const HomeScreen({Key? key}) : super(key: key);

  @override
  State<HomeScreen> createState() => _HomeScreenState();
}

class _HomeScreenState extends State<HomeScreen>  with SingleTickerProviderStateMixin {
  late final TabController controller;
  int _selectedIndex = 0;
  static const TextStyle optionStyle =
      TextStyle(fontSize: 30, fontWeight: FontWeight.bold);
  final AccountController _controller = Get.put(AccountController());
  static  final List<Widget> _widgetOptions = <Widget>[
    const CallScreen(),
    CallLogScreen(),
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
    _controller.getUserLogin();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: Center(
        child: _widgetOptions.elementAt(_selectedIndex),
      ),
      bottomNavigationBar: BottomNavigationBar(
        iconSize: 14,
        items: <BottomNavigationBarItem>[
          BottomNavigationBarItem(
              icon: SvgPicture.asset(Assets.iconsIconPhoneNumber),
              activeIcon: SvgPicture.asset(Assets.iconsIconPhoneNumber,color: AppColor.colorRedMain),
              label: 'Gọi điện'),
          BottomNavigationBarItem(
            icon: SvgPicture.asset(Assets.iconsIconHistory),
            activeIcon: SvgPicture.asset(Assets.iconsIconHistory,color: AppColor.colorRedMain),
            label: 'Lịch sử',
          ),
          BottomNavigationBarItem(
            activeIcon: SvgPicture.asset(Assets.iconsIconContact,
                color: AppColor.colorRedMain),
            icon: SvgPicture.asset(Assets.iconsIconContact),
            label: 'Danh bạ',
          ),
          BottomNavigationBarItem(
            activeIcon: SvgPicture.asset(Assets.iconsIconAccount,
                width: 18,height: 18,
                color: AppColor.colorRedMain),
            icon: SvgPicture.asset(Assets.iconsIconAccount),
            label: 'Tài khoản',
          ),
        ],
        selectedItemColor: AppColor.colorRedMain,
        currentIndex: _selectedIndex,
        showUnselectedLabels: true,
        showSelectedLabels: true,
        unselectedFontSize: 13,
        selectedFontSize: 13,
        selectedLabelStyle: FontFamily.Regular(size: 14, color: AppColor.colorRedMain),
        onTap: _onItemTapped,
        elevation: 7,
        type: BottomNavigationBarType.fixed,
      ),
    );
  }
}
