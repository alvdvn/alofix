import 'package:base_project/common/themes/colors.dart';
import 'package:base_project/common/widget/item_account_widget.dart';
import 'package:base_project/config/fonts.dart';
import 'package:base_project/config/routes.dart';
import 'package:base_project/generated/assets.dart';
import 'package:base_project/screens/account/account_controller.dart';
import 'package:flutter/material.dart';
import 'package:flutter_svg/flutter_svg.dart';
import 'package:get/get.dart';

class AccountScreen extends StatefulWidget {
  const AccountScreen({Key? key}) : super(key: key);

  @override
  State<AccountScreen> createState() => _AccountScreenState();
}

class _AccountScreenState extends State<AccountScreen> {
  final AccountController _controller = Get.put(AccountController());

  Widget _buildAvatar() {
    return Stack(
      children: [
        Image.asset(Assets.imagesBanner, width: double.infinity, height: 63),
        Align(
          alignment: AlignmentDirectional.bottomCenter,
          child: Container(
            margin: const EdgeInsets.only(top: 40),
            width: 80,
            height: 80,
            child: Stack(
              children: [
                if (_controller.user?.avatar != null)
                  CircleAvatar(
                      backgroundImage:
                          NetworkImage('https://alo.njv.vn/${_controller.user?.avatar }'),
                      radius: 80.0,
                      backgroundColor: Colors.transparent)
                else
                  CircleAvatar(
                    radius: 80.0,
                    backgroundColor: AppColor.colorGreyBackground,
                    child: Image.asset(Assets.imagesImageNjv,
                        width: 80, height: 80),
                  ),
                Align(
                  alignment: AlignmentDirectional.bottomEnd,
                  child: SvgPicture.asset(Assets.iconsIconCamera,
                      width: 24, height: 24),
                )
              ],
            ),
          ),
        ),
      ],
    );
  }

  Widget _buildListButton() {
    return Column(
      children: [
        const SizedBox(height: 16),
        ItemAccountWidget(
          assetsIcon: Assets.iconsIconPerson,
          title: 'Thông tin tài khoản',
          action: () => Get.toNamed(Routes.accountInformationScreen),
        ),
        const SizedBox(height: 16),
        ItemAccountWidget(
          assetsIcon: Assets.iconsIconLock,
          title: 'Đổi mật khẩu',
          action: () => Get.toNamed(Routes.changePasswordScreen),
        ),
        const SizedBox(height: 16),
        Obx(
          () => ItemAccountWidget(
            assetsIcon: Assets.iconsIconCall,
            title: 'Cuộc gọi mặc định',
            showCallDefault: true,
            titleCallDefault: getTitleAppDefault(),
            action: () {
              Get.toNamed(Routes.defaultCallScreen);
            },
          ),
        ),
        const SizedBox(height: 16),
        ItemAccountWidget(
          assetsIcon: Assets.iconsIconSetting,
          color: AppColor.colorBlack,
          title: 'Phiên bản',
          showVersion: true,
          action: () => Get.toNamed(Routes.informationAppScreen),
        ),
      ],
    );
  }

  String getTitleAppDefault() {
    switch (_controller.titleCall.value) {
      case '1':
        return 'App AloNinja';
      case '2':
        return 'Zalo';
      case '3':
        return 'SIM';
      default:
        return '';
    }
  }

  @override
  void initState() {
    super.initState();
    _controller.getUserLogin();
    getTitleAppDefault();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: SingleChildScrollView(
        padding: const EdgeInsets.all(16),
        child: Column(
          children: [
            const SizedBox(height: 25),
            Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                Text('Tài khoản', style: FontFamily.demiBold(size: 20)),
                InkWell(
                    onTap: () {
                      _controller.logOut();
                    },
                    child: SvgPicture.asset(Assets.iconsIconLogout,
                        width: 40, height: 40))
              ],
            ),
            const SizedBox(height: 16),
            GetBuilder<AccountController>(builder: (context) {
              return Column(
                children: [
                  _buildAvatar(),
                  const SizedBox(height: 16),
                  Text(_controller.user?.fullName ?? '',
                      style: FontFamily.demiBold(
                          color: AppColor.colorRedMain, size: 16)),
                  const SizedBox(height: 8),
                  Text(_controller.user?.phone ?? '',
                      style: FontFamily.regular(size: 14)),
                ],
              );
            }),
            _buildListButton()
          ],
        ),
      ),
    );
  }
}
