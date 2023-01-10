import 'package:base_project/common/themes/colors.dart';
import 'package:base_project/common/validator/auth_validator.dart';
import 'package:base_project/common/widget/app_bar_custom_widget.dart';
import 'package:base_project/common/widget/button_custom_widget.dart';
import 'package:base_project/common/widget/text_input_custom_widget.dart';
import 'package:base_project/config/fonts.dart';
import 'package:base_project/screens/account/account_controller.dart';
import 'package:flutter/material.dart';
import 'package:get/get.dart';

class ChangePasswordScreen extends StatefulWidget {
  const ChangePasswordScreen({Key? key}) : super(key: key);

  @override
  State<ChangePasswordScreen> createState() => _ChangePasswordScreenState();
}

class _ChangePasswordScreenState extends State<ChangePasswordScreen> {
  TextEditingController oldPasswordController = TextEditingController();
  TextEditingController confirmPasswordController = TextEditingController();
  TextEditingController newPasswordController = TextEditingController();
  final AccountController _controller = Get.find();
  final _formKey = GlobalKey<FormState>();

  Widget _buildHeader() {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 16),
      width: double.infinity,
      color: AppColor.colorGreyBackground,
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          const SizedBox(height: 32),
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              Text(
                "Đổi mật khẩu",
                style: FontFamily.DemiBold(),
              ),
              Row(
                children: [
                  InkWell(
                    onTap: () => Get.back(),
                    child: const Icon(Icons.close),
                  ),
                  const SizedBox(width: 16)
                ],
              )
            ],
          ),
          const SizedBox(height: 22),
          Text("Bạn cần đổi mật khẩu lần đầu \nđể tiếp tục sử dụng",
              style: FontFamily.Regular(size: 16)),
        ],
      ),
    );
  }

  Widget _buildBody() {
    return Form(
      key: _formKey,
      child: Container(
        padding: const EdgeInsets.all(16),
        child: Column(
          children: [
            TextInputCustomWidget(
                controllerText: oldPasswordController,
                showEye: true,
                validate: (value) => AuthValidator().passwordEmpty(value ?? ''),
                labelText: 'Mật khẩu hiện tại'),
            const SizedBox(height: 16),
            TextInputCustomWidget(
                controllerText: newPasswordController,
                showEye: true,
                validate: (value) => AuthValidator().passwordEmpty(value ?? ''),
                labelText: 'Mật khẩu mới'),
            const SizedBox(height: 16),
            TextInputCustomWidget(
                controllerText: confirmPasswordController,
                showEye: true,
                validate: (value) => AuthValidator()
                    .retypePassword(newPasswordController.text, value ?? ''),
                labelText: 'Nhập lại mật khẩu mới')
          ],
        ),
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.white,
      appBar: const CustomAppBar(title: 'Đổi mật khẩu'),
      body: GestureDetector(
        onTap: () => FocusScope.of(context).requestFocus(FocusNode()),
        child: Column(
          children: [
            Expanded(
              child: SingleChildScrollView(
                child: Column(
                  mainAxisAlignment: MainAxisAlignment.spaceBetween,
                  children: [
                    Column(
                      children: [
                        _buildBody(),
                      ],
                    ),
                  ],
                ),
              ),
            ),
            Container(
              width: double.maxFinite,
              padding: const EdgeInsets.all(16),
              child: ButtonCustomWidget(
                  title: "Xác nhận",
                  action: () {
                    if (_formKey.currentState!.validate()) {
                      FocusScope.of(context).unfocus();
                      _controller.changePassword(
                          password: oldPasswordController.text,
                          confirmPassword: confirmPasswordController.text,
                          newPassword: newPasswordController.text);
                    }
                  }),
            ),
          ],
        ),
      ),
    );
  }
}
