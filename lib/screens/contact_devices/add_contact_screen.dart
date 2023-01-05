import 'package:base_project/common/themes/colors.dart';
import 'package:base_project/common/widget/button_custom_widget.dart';
import 'package:base_project/common/widget/text_input_custom_widget.dart';
import 'package:base_project/config/fonts.dart';
import 'package:base_project/generated/assets.dart';
import 'package:flutter/material.dart';
import 'package:flutter_svg/flutter_svg.dart';
import 'package:get/get.dart';

class AddContactScreen extends StatefulWidget {
  const AddContactScreen({Key? key}) : super(key: key);

  @override
  State<AddContactScreen> createState() => _AddContactScreenState();
}

class _AddContactScreenState extends State<AddContactScreen> {
  final fullNameController = TextEditingController();
  final phoneNumberController = TextEditingController();

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
                CircleAvatar(
                  radius: 80.0,
                  backgroundColor: AppColor.colorGreyBackground,
                  child: Image.asset(Assets.imagesImageNjv),
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

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.white,
      appBar: AppBar(
          automaticallyImplyLeading: false,
          centerTitle: false,
          backgroundColor: Colors.white,
          elevation: 0,
          actions: [
            IconButton(
                onPressed: () => Get.back(),
                icon: const Icon(Icons.close, color: AppColor.colorBlack)),
            const SizedBox(width: 16)
          ],
          title: Text("Thêm danh bạ", style: FontFamily.DemiBold(size: 20))),
      body: Column(
        mainAxisAlignment: MainAxisAlignment.spaceBetween,
        children: [
          Expanded(
            child: SingleChildScrollView(
              padding: const EdgeInsets.all(16),
              child: Column(
                children: [
                  _buildAvatar(),
                  const SizedBox(height: 32),
                  TextInputCustomWidget(
                    showObscureText: false,
                    controllerText: fullNameController,
                    labelText: 'Nhập họ và tên',
                  ),
                  const SizedBox(height: 16),
                  TextInputCustomWidget(
                    showObscureText: false,
                    controllerText: phoneNumberController,
                    labelText: 'Số điện thoai',
                  ),
                ],
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
                      title: "Thêm vào danh bạ", action: () {}),
                ),
              ],
            ),
          )
        ],
      ),
    );
  }
}
