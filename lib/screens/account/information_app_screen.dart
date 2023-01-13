import 'package:base_project/common/themes/colors.dart';
import 'package:base_project/common/widget/app_bar_custom_widget.dart';
import 'package:base_project/common/widget/text_input_custom_widget.dart';
import 'package:base_project/config/fonts.dart';
import 'package:base_project/generated/assets.dart';
import 'package:flutter/material.dart';

class InformationAppScreen extends StatefulWidget {
  const InformationAppScreen({Key? key}) : super(key: key);

  @override
  State<InformationAppScreen> createState() => _InformationAppScreenState();
}

class _InformationAppScreenState extends State<InformationAppScreen> {
  final versionController = TextEditingController(text: '1.0.0');
  final dayUpdateController = TextEditingController(text:'13/01/2023');
  final langController = TextEditingController(text:'Tiếng Việt');
  final unitController = TextEditingController(text:'Nin Sing Logistics Viet Nam');

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.white,
      appBar: const CustomAppBar(title: 'Thông tin ứng dụng'),
      body: SingleChildScrollView(
        padding: const EdgeInsets.all(16),
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          crossAxisAlignment: CrossAxisAlignment.center,
          children: [
            Image.asset(Assets.imagesImageApp, width: 60, height: 60),
            const SizedBox(height: 16),
            Text('ALO NINJA', style: FontFamily.demiBold(size: 18)),
            const SizedBox(height: 8),
            Text(
              'Phiên bản 1.0.0',
              style:
                  FontFamily.regular(size: 14, color: AppColor.colorGreyText),
            ),
            const SizedBox(height: 32),
            Text(
              'ALO NINJA là ứng dụng tương thích với điện thoại thông minh chạy hệ điều hành iOS và Android. Ứng dụng mang đến cho Rider trải nghiệm nghe gọi, quản lý cuộc gọi với khách hàng tiện lợi nhất.',
              textAlign: TextAlign.center,
              style: FontFamily.normal(size: 14,lineHeight: 1.5),
            ),
            const SizedBox(height: 16),
            TextInputCustomWidget(
                controllerText: versionController,
                labelText: 'Phiên bản',
                showObscureText: false,
                enableText: false,
                inputTypeNumber: true),
            const SizedBox(height: 16),
            TextInputCustomWidget(
                controllerText: dayUpdateController,
                labelText: 'Ngày cập nhật',
                showObscureText: false,
                enableText: false,
                inputTypeNumber: true),
            const SizedBox(height: 16),
            TextInputCustomWidget(
                controllerText: langController,
                labelText: 'Ngôn ngữ',
                enableText: false,
                showObscureText: false,
                inputTypeNumber: true),
            const SizedBox(height: 16),
            TextInputCustomWidget(
                controllerText: unitController,
                labelText: 'Đơn vị phát triển',
                showObscureText: false,
                enableText: false,
                inputTypeNumber: true),
          ],
        ),
      ),
    );
  }
}
