import 'package:base_project/common/themes/colors.dart';
import 'package:base_project/common/widget/text_input_custom_widget.dart';
import 'package:base_project/config/fonts.dart';
import 'package:flutter/material.dart';
import 'package:get/get.dart';

class AccountInformationScreen extends StatefulWidget {
  const AccountInformationScreen({Key? key}) : super(key: key);

  @override
  State<AccountInformationScreen> createState() =>
      _AccountInformationScreenState();
}

class _AccountInformationScreenState extends State<AccountInformationScreen> {
  final userController = TextEditingController();
  final phoneNumberController = TextEditingController();

  @override
  void initState() {
    super.initState();
    userController.text = "Phạm Thái Công";
    phoneNumberController.text = "0332902919";
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.white,
      appBar: AppBar(
          leading:IconButton(
            onPressed: ()=> Get.back(),
            icon: const Icon(Icons.arrow_back_ios_new,color: AppColor.colorRedMain,size: 18,),
          ),
          title:
              Text('Thông tin tài khoản', style: FontFamily.DemiBold(size: 14)),
          elevation: 0,
          centerTitle: true,
          backgroundColor: Colors.white),
      body: SingleChildScrollView(
        padding: const EdgeInsets.all(16),
        child: Column(
          children: [
            TextInputCustomWidget(
              controllerText: userController,
              labelText: 'Họ Tên',
              showObscureText: false,
            ),
            const SizedBox(height: 16),
            TextInputCustomWidget(
              controllerText: phoneNumberController,
              labelText: 'Số điện thoại',
              showObscureText: false,
            )
          ],
        ),
      ),
    );
  }
}
