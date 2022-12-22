import 'package:base_project/common/themes/colors.dart';
import 'package:base_project/common/widget/item_account_widget.dart';
import 'package:base_project/config/fonts.dart';
import 'package:base_project/config/routes.dart';
import 'package:base_project/generated/assets.dart';
import 'package:flutter/material.dart';
import 'package:get/get.dart';

class AccountScreen extends StatefulWidget {
  const AccountScreen({Key? key}) : super(key: key);

  @override
  State<AccountScreen> createState() => _AccountScreenState();
}

class _AccountScreenState extends State<AccountScreen> {
  String linkAvatar =
      'https://scontent.fhan14-3.fna.fbcdn.net/v/t39.30808-6/295456524_1822983748047090_2898604788058561146_n.jpg?_nc_cat=102&ccb=1-7&_nc_sid=09cbfe&_nc_ohc=q5MUTMQVtusAX8E7jcJ&_nc_ht=scontent.fhan14-3.fna&oh=00_AfBW9datMPORfznusWG51NTNXzaK04txI5ZtsjU3g9215w&oe=63A7ED66';

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
                Text('Tài khoản', style: FontFamily.DemiBold(size: 20)),
                InkWell(
                    onTap: () => Get.offAllNamed(Routes.loginScreen),
                    child: Image.asset(Assets.iconsLogoutIcon,
                        width: 40, height: 40))
              ],
            ),
            const SizedBox(height: 16),
            Column(
              children: [
                Stack(
                  children: [
                    Image.asset(Assets.imagesBanner,
                        width: double.infinity, height: 63),
                    Align(
                      alignment: AlignmentDirectional.bottomCenter,
                      child: Container(
                        margin: const EdgeInsets.only(top: 40),
                        width: 80,
                        height: 80,
                        child: Stack(
                          children: [
                            CircleAvatar(
                              backgroundImage: NetworkImage(linkAvatar),
                              radius: 80.0,
                              backgroundColor: Colors.transparent,
                            ),
                            Align(
                              alignment: AlignmentDirectional.bottomEnd,
                              child: Image.asset(Assets.iconsCameraIcon,
                                  width: 24, height: 24),
                            )
                          ],
                        ),
                      ),
                    ),
                  ],
                ),
                const SizedBox(height: 16),
                Text('Nguyễn Hoàng Nam',
                    style: FontFamily.DemiBold(
                        color: AppColor.colorRedMain, size: 16)),
                const SizedBox(height: 8),
                Text('0965988698', style: FontFamily.Regular(size: 14)),
              ],
            ),
            const SizedBox(height: 16),
            ItemAccountWidget(
              assetsIcon: Assets.iconsPersonIcon,
              title: 'Thông tin tài khoản',
              action: () => Get.toNamed(Routes.accountInformationScreen),
            ),
            const SizedBox(height: 16),
            ItemAccountWidget(
              assetsIcon: Assets.iconsLockIcon,
              title: 'Đổi mật khẩu',
              action: () => Get.toNamed(Routes.changePasswordScreen),
            ),
            const SizedBox(height: 16),
            ItemAccountWidget(
              assetsIcon: Assets.iconsCallIcon,
              title: 'Cuộc gọi mặc định',
              action: () {},
            ),
            const SizedBox(height: 16),
            ItemAccountWidget(
              assetsIcon: Assets.iconsSettingIcon,
              title: 'Phiên bản',
              showVersion: true,
              action: () {},
            ),
          ],
        ),
      ),
    );
  }
}
