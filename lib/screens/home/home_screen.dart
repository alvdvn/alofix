import 'package:base_project/screens/account/account_screen.dart';
import 'package:base_project/screens/call_log_screen/call_log_screen.dart';
import 'package:base_project/screens/contact_devices/contact_devices_screen.dart';
import 'package:base_project/services/SyncDb.dart';
import 'package:get/get.dart';
import 'package:flutter/material.dart';
import 'package:flutter_svg/flutter_svg.dart';
import 'package:base_project/screens/home/home_controller.dart';
import 'package:base_project/common/themes/colors.dart';
import 'package:base_project/generated/assets.dart';
import 'package:base_project/screens/call/call_screen.dart';
import '../call_log_screen/call_log_controller.dart';
import 'widget/home_bottom_bar.dart';

class HomeScreen extends StatefulWidget {
  const HomeScreen({Key? key}) : super(key: key);

  @override
  State<HomeScreen> createState() => HomeScreenState();
}

class HomeScreenState extends State<HomeScreen>
    with SingleTickerProviderStateMixin, WidgetsBindingObserver {
  int tabIndex = 0;
  late final TabController controller;

  final HomeController homeController = Get.put(HomeController());
  final CallLogController _callLogController = Get.put(CallLogController());

  static final List<Widget> widgetOptions = <Widget>[
    const CallScreen(),
    const CallLogScreen(),
    const ContactDeviceScreen(),
    const AccountScreen(),
  ];

  void onItemTapped(int index) {
    homeController.validatePermission(withRetry: false);
    if(index==1) _callLogController.onClickClose();
    setState(() {
      tabIndex = index;
    });
  }

  @override
  void initState() {
    super.initState();
    controller = TabController(length: widgetOptions.length, vsync: this);
    initData();
    homeController.initData();
    WidgetsBinding.instance.addObserver(this);
  }

  Future<void> initData() async {
    await homeController.initService();
    await homeController.dbService.syncFromServer();
    // _callLogController.initData();
  }

  @override
  void dispose() {
    WidgetsBinding.instance.removeObserver(this);

    // TODO: implement dispose
    super.dispose();
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
