import 'package:base_project/common/constance/strings.dart';
import 'package:base_project/common/themes/colors.dart';
import 'package:base_project/common/utils/alert_dialog_utils.dart';
import 'package:base_project/common/validator/auth_validator.dart';
import 'package:base_project/common/widget/button_custom_widget.dart';
import 'package:base_project/common/widget/text_input_custom_widget.dart';
import 'package:base_project/config/fonts.dart';
import 'package:base_project/config/routes.dart';
import 'package:base_project/generated/assets.dart';
import 'package:flutter/material.dart';
import 'package:get/route_manager.dart';

class LoginScreen extends StatefulWidget {
  const LoginScreen({Key? key}) : super(key: key);

  @override
  State<LoginScreen> createState() => _LoginScreenState();
}

class _LoginScreenState extends State<LoginScreen> {
  final _usernameController = TextEditingController();
  final _passwordController = TextEditingController();

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: GestureDetector(
        onTap: () => FocusScope.of(context).requestFocus(FocusNode()),
        child: Column(
          children: [
            Expanded(
              child: SingleChildScrollView(
                child: Container(
                  margin: const EdgeInsets.all(16),
                  child: Column(
                    mainAxisAlignment: MainAxisAlignment.spaceBetween,
                    children: [
                      Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          const SizedBox(height: 16),
                          Image.asset(Assets.imagesLogo,
                              width: 126, height: 60),
                          Stack(
                            children: [
                              Image.asset(Assets.imagesBanner,
                                  width: double.infinity, height: 63),
                              Align(
                                alignment: AlignmentDirectional.bottomCenter,
                                child: Container(
                                  margin: const EdgeInsets.only(top: 30),
                                  width: 60,
                                  height: 60,
                                  child: Image.asset(Assets.iconsAppIcon),
                                ),
                              ),
                            ],
                          ),
                          const SizedBox(height: 30),
                          Row(
                            mainAxisAlignment: MainAxisAlignment.center,
                            children: [
                              Text("ALO NINJA",
                                  style: FontFamily.DemiBold(
                                      color: AppColor.colorRedMain)),
                            ],
                          ),
                          const SizedBox(height: 12),
                          Row(
                            mainAxisAlignment: MainAxisAlignment.center,
                            children: [
                              Text("Vui lòng đăng nhập để truy cập ứng dụng",
                                  style: FontFamily.Regular()),
                            ],
                          ),
                          const SizedBox(height: 30),
                          TextInputCustomWidget(
                              controllerText: _usernameController,
                              labelText: AppStrings.usernamePlaceholder,
                              showObscureText: false,
                              inputTypeNumber: true),
                          const SizedBox(width: double.infinity, height: 24),
                          TextInputCustomWidget(
                              controllerText: _passwordController,
                              labelText: AppStrings.passwordPlaceholder,
                              showEye: true),
                          const SizedBox(width: 1, height: 16),
                          InkWell(
                            onTap: () {
                              // Get.toNamed(Routes.changePasswordScreen);
                              showDialogNotification(
                                  title: 'Quên mật khẩu',
                                  "Vui lòng liên hệ tới quản lý khu vực của bạn để được đổi mật khẩu");
                            },
                            child: Row(
                              mainAxisAlignment: MainAxisAlignment.center,
                              children: [
                                Text("Quên mật khẩu ?",
                                    style: FontFamily.normal(
                                        color: AppColor.colorRedMain))
                              ],
                            ),
                          )
                        ],
                      ),
                    ],
                  ),
                ),
              ),
            ),
            Container(
              padding: const EdgeInsets.all(16),
              child: Column(
                children: [
                  const Divider(
                    thickness: 1,
                    color: AppColor.colorGrey,
                    height: 1,
                  ),
                  Container(
                    width: double.maxFinite,
                    padding: const EdgeInsets.only(top: 16, bottom: 16),
                    child: ButtonCustomWidget(
                        title: "Đăng nhập",
                        action: () {
                          Get.offAllNamed(Routes.homeScreen);
                        }),
                  ),
                ],
              ),
            )
          ],
        ),
      ),
    );
  }
}
