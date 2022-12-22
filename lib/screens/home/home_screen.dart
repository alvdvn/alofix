import 'package:base_project/common/themes/colors.dart';
import 'package:base_project/config/fonts.dart';
import 'package:base_project/generated/assets.dart';
import 'package:base_project/screens/account/account_screen.dart';
import 'package:base_project/screens/call_log_screen/call_log_screen.dart';
import 'package:base_project/screens/contact_devices/contact_devices_screen.dart';
import 'package:flutter/material.dart';

class HomeScreen extends StatefulWidget {
  const HomeScreen({Key? key}) : super(key: key);

  @override
  State<HomeScreen> createState() => _HomeScreenState();
}

class _HomeScreenState extends State<HomeScreen>
    with SingleTickerProviderStateMixin {
  late final TabController controller;
  int _selectedIndex = 0;
  static const TextStyle optionStyle =
      TextStyle(fontSize: 30, fontWeight: FontWeight.bold);
  static final List<Widget> _widgetOptions = <Widget>[
    const Text('Comming soon', style: optionStyle),
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
              activeIcon: Image.asset(Assets.iconsPhoneNumberIcon,
                  color: AppColor.colorRedMain),
              icon: Image.asset(Assets.iconsPhoneNumberIcon,
                  color: AppColor.colorHintText),
              label: 'Gọi điện'),
          BottomNavigationBarItem(
            activeIcon: Image.asset(Assets.iconsHistoryIcon,
                color: AppColor.colorRedMain),
            icon: Image.asset(Assets.iconsHistoryIcon,
                color: AppColor.colorHintText),
            label: 'Lịch sử',
          ),
          BottomNavigationBarItem(
            activeIcon: Image.asset(Assets.iconsContactIcon,
                color: AppColor.colorRedMain),
            icon: Image.asset(Assets.iconsContactIcon,
                color: AppColor.colorHintText),
            label: 'Danh bạ',
          ),
          BottomNavigationBarItem(
            activeIcon: Image.asset(Assets.iconsAccountIcon,
                color: AppColor.colorRedMain),
            icon: Image.asset(Assets.iconsAccountIcon,
                color: AppColor.colorHintText),
            label: 'Tài khoản',
          ),
        ],
        selectedItemColor: AppColor.colorRedMain,
        currentIndex: _selectedIndex,
        showUnselectedLabels: true,
        showSelectedLabels: true,
        unselectedFontSize: 13,
        selectedFontSize: 13,
        selectedLabelStyle:
            FontFamily.Regular(size: 14, color: AppColor.colorRedMain),
        onTap: _onItemTapped,
        elevation: 7,
        type: BottomNavigationBarType.fixed,
      ),
    );
  }
}
