import 'package:base_project/common/constance/strings.dart';
import 'package:base_project/common/validator/auth_validator.dart';
import 'package:base_project/common/widget/button_custom_widget.dart';
import 'package:base_project/config/routes.dart';
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
  final _keyUsername = GlobalKey<FormState>();
  final _keyPassword = GlobalKey<FormState>();

  @override
  Widget build(BuildContext context) {
    final Size size = MediaQuery.of(context).size;
    return Scaffold(
      body: Container(
        height: size.height,
        margin: const EdgeInsets.all(16),
        child: Center(
          child: Column(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              const SizedBox(width: 1, height: 30),
              Form(
                  key: _keyUsername,
                  child: TextFormField(
                    controller: _usernameController,
                    onChanged: (value) {
                      _keyUsername.currentState?.validate();
                    },
                    validator: (value) => AuthValidator().userName(value ?? ''),
                    decoration: const InputDecoration(
                        labelText: AppStrings.usernamePlaceholder,
                        hintText: AppStrings.usernamePlaceholder,
                        border: OutlineInputBorder()),
                  )),
              const SizedBox(width: double.infinity, height: 24),
              Form(
                  key: _keyPassword,
                  child: TextFormField(
                    controller: _passwordController,
                    onChanged: (value) {
                      _keyPassword.currentState?.validate();
                    },
                    validator: (value) =>
                        AuthValidator().passwordEmpty(value ?? ''),
                    decoration: InputDecoration(
                        suffixIcon: IconButton(
                            icon: const Icon(Icons.remove_red_eye),
                            onPressed: () {}),
                        labelText: AppStrings.passwordPlaceholder,
                        hintText: AppStrings.passwordPlaceholder,
                        border: const OutlineInputBorder()),
                  )),
              const SizedBox(width: 1, height: 10),
              Container(
                width: double.maxFinite,
                padding: const EdgeInsets.only(top: 30),
                child: ButtonCustomWidget(
                    title: "Danh bạ",
                    action: () {
                      Get.toNamed(Routes.contactScreen);
                      // if (_keyUsername.currentState!.validate() &&
                      //     _keyPassword.currentState!.validate()) {
                      //   FocusScope.of(context).unfocus();
                      // }
                    }),
              ),
              Container(
                width: double.maxFinite,
                padding: const EdgeInsets.only(top: 30),
                child: ButtonCustomWidget(
                    title:"Lịch sử cuộc gọi",
                    action: () {
                      Get.toNamed(Routes.calLogScreen);
                      // if (_keyUsername.currentState!.validate() &&
                      //     _keyPassword.currentState!.validate()) {
                      //   FocusScope.of(context).unfocus();
                      // }
                    }),
              ),
              Container(
                width: double.maxFinite,
                padding: const EdgeInsets.only(top: 30),
                child: ButtonCustomWidget(
                    title: "Ghi âm",
                    action: () {
                      Get.toNamed(Routes.recordCall);
                    }),
              ),
              Container(
                width: double.maxFinite,
                padding: const EdgeInsets.only(top: 30),
                child: ButtonCustomWidget(
                    title: "Stringee",
                    action: () {
                      Get.toNamed(Routes.stringee_app);
                    }),
              ),
              const SizedBox(
                height: 20,
                width: double.infinity,
              ),
            ],
          ),
        ),
      ),
    );
  }
}
