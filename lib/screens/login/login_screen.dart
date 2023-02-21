import 'package:base_project/common/constance/strings.dart';
import 'package:base_project/common/themes/colors.dart';
import 'package:base_project/common/utils/alert_dialog_utils.dart';
import 'package:base_project/common/validator/auth_validator.dart';
import 'package:base_project/common/widget/button_custom_widget.dart';
import 'package:base_project/common/widget/text_input_custom_widget.dart';
import 'package:base_project/config/fonts.dart';
import 'package:base_project/generated/assets.dart';
import 'package:base_project/services/local/app_share.dart';
import 'package:flutter/material.dart';
import 'package:get/get.dart';

import 'login_controller.dart';

class LoginScreen extends StatefulWidget {
  const LoginScreen({Key? key}) : super(key: key);

  @override
  State<LoginScreen> createState() => _LoginScreenState();
}

class _LoginScreenState extends State<LoginScreen> {
  final _usernameController = TextEditingController();
  final _passwordController = TextEditingController();
  final _keyUsername = GlobalKey<FormState>();
  final _keyPassword = GlobalKey<FormState>();
  final LoginController _controller = Get.put(LoginController());

  @override
  void initState() {
    super.initState();
    initStateLocal();
  }
  void initStateLocal() async{
    AppShared().getUserPassword();
    _usernameController.text = AppShared.username;
    _passwordController.text = AppShared.password;
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: GestureDetector(
        onTap: () => FocusScope.of(context).requestFocus(FocusNode()),
        child: SafeArea(
          child: Column(
            children: [
              Expanded(
                child: SingleChildScrollView(
                  child: Container(
                    margin: const EdgeInsets.symmetric(horizontal: 16),
                    child: Column(
                      mainAxisAlignment: MainAxisAlignment.spaceBetween,
                      children: [
                        Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            Image.asset(Assets.imagesLogo,
                                width: 126, height: 60),
                            Stack(
                              children: [
                                Container(
                                  decoration: const BoxDecoration(
                                      border: Border(
                                    bottom: BorderSide(
                                        width: 1,
                                        color: AppColor.colorGreyBackground),
                                  )),
                                  child: Image.asset(Assets.imagesBanner,
                                      width: double.infinity, height: 63),
                                ),
                                Align(
                                  alignment: AlignmentDirectional.bottomCenter,
                                  child: Container(
                                    margin: const EdgeInsets.only(top: 30),
                                    width: 60,
                                    height: 60,
                                    child: Image.asset(Assets.imagesImageApp),
                                  ),
                                ),
                              ],
                            ),
                            const SizedBox(height: 30),
                            Row(
                              mainAxisAlignment: MainAxisAlignment.center,
                              children: [
                                Text("ALO NINJA",
                                    style: FontFamily.demiBold(
                                        color: AppColor.colorRedMain)),
                              ],
                            ),
                            const SizedBox(height: 12),
                            Row(
                              mainAxisAlignment: MainAxisAlignment.center,
                              children: [
                                Text("Vui lòng đăng nhập để truy cập ứng dụng",
                                    style: FontFamily.regular()),
                              ],
                            ),
                            const SizedBox(height: 30),
                            Form(
                              key: _keyUsername,
                              child: TextInputCustomWidget(
                                  controllerText: _usernameController,
                                  labelText: AppStrings.usernamePlaceholder,
                                  validate: (value) =>
                                      AuthValidator().userName(value ?? ''),
                                  showObscureText: false,
                                  inputTypeNumber: false),
                            ),
                            const SizedBox(width: double.infinity, height: 24),
                            Form(
                                key: _keyPassword,
                                child: TextInputCustomWidget(
                                    controllerText: _passwordController,
                                    validate: (value) => AuthValidator()
                                        .passwordEmpty(value ?? ''),
                                    labelText: AppStrings.passwordPlaceholder,
                                    showEye: true)),
                            const SizedBox(width: 1, height: 16),
                            Row(
                              children: [
                                Obx(
                                  () => Checkbox(
                                      checkColor:Colors.white,
                                     activeColor: AppColor.colorRedMain,
                                      value: _controller.isChecker.value,
                                      onChanged: (bool? value) {
                                        _controller.onCheck();
                                      }),
                                ),
                                const SizedBox(width: 8),
                                Text("Ghi nhớ mật khẩu",style: FontFamily.regular())
                              ],
                            ),
                            InkWell(
                              onTap: () {
                                showDialogNotification(
                                    title: 'Quên mật khẩu?',
                                    "Vui lòng liên hệ tới quản lý trực tiếp của\n bạn để được đổi mật khẩu",
                                    action: () => Get.back());
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
                            if (_keyUsername.currentState!.validate() &&
                                _keyPassword.currentState!.validate()) {
                              FocusScope.of(context).unfocus();
                              _controller.login(
                                  username: _usernameController.text,
                                  password: _passwordController.text);
                            }
                          }),
                    ),
                  ],
                ),
              )
            ],
          ),
        ),
      ),
    );
  }
}
