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

import '../../environment.dart';
import 'login_controller.dart';

class LoginScreen extends StatefulWidget {
  const LoginScreen({Key? key}) : super(key: key);

  @override
  State<LoginScreen> createState() => _LoginScreenState();
}

class _LoginScreenState extends State<LoginScreen> {
  final _usernameController = TextEditingController();
  final _passwordController = TextEditingController();
  final _domainController = TextEditingController();
  final _keyUsername = GlobalKey<FormState>();
  final _keyPassword = GlobalKey<FormState>();
  final _keyDomain = GlobalKey<FormState>();
  final LoginController _controller = Get.put(LoginController());
  final _formKey = GlobalKey<FormState>();
  final _keyNewPassword = GlobalKey<FormState>();
  final _keyConfirmPassword = GlobalKey<FormState>();
  final _newPasswordController = TextEditingController();
  final _confirmPasswordController = TextEditingController();

  @override
  void initState() {
    super.initState();
    initStateLocal();
  }

  void initStateLocal() async {
    // _controller.onCheck();
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
                            Image.asset(Assets.imagesLogo, width: 126, height: 60),
                            Stack(
                              children: [
                                Container(
                                  decoration: const BoxDecoration(
                                      border: Border(
                                    bottom: BorderSide(width: 1, color: AppColor.colorGreyBackground),
                                  )),
                                  child: Image.asset(Assets.imagesBanner, width: double.infinity, height: 63),
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
                                Text("ALO NINJA", style: FontFamily.demiBold(color: AppColor.colorRedMain)),
                              ],
                            ),
                            const SizedBox(height: 12),
                            Row(
                              mainAxisAlignment: MainAxisAlignment.center,
                              children: [
                                Text("Vui lòng đăng nhập để truy cập ứng dụng", style: FontFamily.regular()),
                              ],
                            ),
                            const SizedBox(height: 30),
                            if (Environment.evn == AppEnv.dev)
                              Form(
                                key: _keyDomain,
                                child: TextInputCustomWidget(
                                    controllerText: _domainController,
                                    labelText: AppStrings.domainPlaceholder,
                                    showObscureText: false,
                                    inputTypeNumber: false),
                              ),
                            const SizedBox(width: double.infinity, height: 24),
                            Form(
                              key: _keyUsername,
                              child: TextInputCustomWidget(
                                  controllerText: _usernameController,
                                  labelText: AppStrings.usernamePlaceholder,
                                  validate: (value) => AuthValidator().userName(value ?? ''),
                                  showObscureText: false,
                                  inputTypeNumber: false),
                            ),
                            const SizedBox(width: double.infinity, height: 24),
                            Form(
                                key: _keyPassword,
                                child: TextInputCustomWidget(
                                    controllerText: _passwordController,
                                    validate: (value) => AuthValidator().passwordEmpty(value ?? ''),
                                    labelText: AppStrings.passwordPlaceholder,
                                    showEye: true)),
                            const SizedBox(width: 1, height: 16),
                            Row(
                              children: [
                                Obx(
                                  () => Checkbox(
                                      checkColor: Colors.white,
                                      activeColor: AppColor.colorRedMain,
                                      value: _controller.isChecker.value,
                                      onChanged: (bool? value) {
                                        _controller.onCheck();
                                      }),
                                ),
                                const SizedBox(width: 8),
                                Text("Ghi nhớ mật khẩu", style: FontFamily.regular())
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
                                children: [Text("Quên mật khẩu ?", style: FontFamily.normal(color: AppColor.colorRedMain))],
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
                            if (_keyUsername.currentState!.validate() && _keyPassword.currentState!.validate()) {
                              FocusScope.of(context).unfocus();
                              actionLogin();
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

  void actionLogin() async {
    final isFirstLogin = await _controller.login(
        username: _usernameController.text, password: _passwordController.text, domain: _domainController.text);
    if (isFirstLogin) {
      showDialogWithFields();
    }
  }

  void showDialogWithFields() {
    showDialog(
        context: context,
        builder: (BuildContext context) {
          return AlertDialog(
            contentPadding: EdgeInsets.zero,
            content: Stack(
              clipBehavior: Clip.none,
              children: <Widget>[
                Positioned(
                  right: -15.0,
                  top: -15.0,
                  child: InkResponse(
                    onTap: () {
                      Navigator.of(context).pop();
                    },
                    child: const CircleAvatar(
                      radius: 12,
                      child: Icon(
                        Icons.close,
                        size: 18,
                      ),
                      backgroundColor: Colors.red,
                    ),
                  ),
                ),
                Form(
                  key: _formKey,
                  child: Column(
                    mainAxisSize: MainAxisSize.min,
                    children: <Widget>[
                      Container(
                        height: 85,
                        width: MediaQuery.of(context).size.width,
                        decoration: BoxDecoration(
                            color: Colors.yellow.withOpacity(0.2),
                            border: Border(bottom: BorderSide(color: Colors.grey.withOpacity(0.3)))),
                        child: Column(
                          mainAxisAlignment: MainAxisAlignment.center,
                          children: [
                            Text("Đổi mật khẩu", style: FontFamily.demiBold(color: AppColor.colorRedMain)),
                            Text("Bạn cần đổi mật khẩu lần đầu để tiếp tục sử dụng",
                                style: FontFamily.regular(color: AppColor.colorRedMain, size: 13)),
                          ],
                        ),
                      ),
                      const SizedBox(height: 10),
                      Padding(
                        padding: const EdgeInsets.all(16.0),
                        child: Form(
                            key: _keyNewPassword,
                            child: TextInputCustomWidget(
                                controllerText: _newPasswordController,
                                validate: (value) => AuthValidator().password(value ?? ''),
                                labelText: 'Nhập tối thiểu 8 ký tự',
                                showEye: true)),
                      ),
                      Padding(
                        padding: const EdgeInsets.fromLTRB(16, 10, 16, 10),
                        child: Form(
                            key: _keyConfirmPassword,
                            child: TextInputCustomWidget(
                                controllerText: _confirmPasswordController,
                                validate: (value) => AuthValidator().retypePassword(_newPasswordController.text, value ?? ''),
                                labelText: 'Nhập lại mật khẩu mới',
                                showEye: true)),
                      ),
                      const SizedBox(width: 1, height: 16),
                      Container(
                        padding: const EdgeInsets.all(20.0),
                        child: ButtonCustomWidget(
                            title: "Cập nhật mật khẩu",
                            action: () {
                              if (_keyNewPassword.currentState!.validate() && _keyConfirmPassword.currentState!.validate()) {
                                FocusScope.of(context).unfocus();
                                _controller.firstChangePassword(
                                    token: _controller.tokenIsFirstLogin.string,
                                    newPassword: _newPasswordController.text,
                                    confirmPassword: _confirmPasswordController.text);
                              }
                            }),
                      ),
                    ],
                  ),
                ),
              ],
            ),
          );
        });
  }
}
