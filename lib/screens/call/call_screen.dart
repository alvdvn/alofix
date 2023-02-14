import 'package:base_project/common/themes/colors.dart';
import 'package:base_project/common/widget/button_phone_custom_widget.dart';
import 'package:base_project/config/fonts.dart';
import 'package:base_project/generated/assets.dart';
import 'package:base_project/services/local/app_share.dart';
import 'package:flutter/material.dart';
import 'package:get/get.dart';

import 'call_controller.dart';

class CallScreen extends StatefulWidget {
  const CallScreen({Key? key}) : super(key: key);

  @override
  State<CallScreen> createState() => _CallScreenState();
}

class _CallScreenState extends State<CallScreen> {
  CallController callController = Get.put(CallController());

  Widget _btnCall() {
    return Stack(
      children: [
        Align(
            alignment: Alignment.center,
            child:
                Image.asset(Assets.imagesImgCallAccept, width: 80, height: 80)),
        Align(
          alignment: Alignment.center,
          child: SizedBox(
            height: 80,
            child: Column(
              mainAxisAlignment: MainAxisAlignment.center,
              mainAxisSize: MainAxisSize.max,
              children: [
                InkWell(
                    onTap: () async {
                      if (callController.phoneNumber.isNotEmpty) {
                        callController.handCall();
                        // Get.toNamed(Routes.callProcess);
                      }
                    },
                    child: const Icon(Icons.call_sharp,
                        color: Colors.white, size: 25))
              ],
            ),
          ),
        )
      ],
    );
  }

  Widget _buildBtnClear({bool showIcon = true}) {
    return Container(
      width: 80,
      height: 80,
      decoration: BoxDecoration(
        borderRadius: BorderRadius.circular(40),
        color: AppColor.colorGreyBackground,
      ),
      child: showIcon
          ? const Center(
              child: Icon(Icons.backspace_sharp),
            )
          : Container(),
    );
  }

  Widget _buildKeyBoard() {
    return Column(
      children: [
        Row(
          mainAxisSize: MainAxisSize.max,
          mainAxisAlignment: MainAxisAlignment.spaceBetween,
          children: [
            const SizedBox(width: 30),
            InkWell(
                onTap: () => callController.onPressPhone(buttonText: "1"),
                child: const ButtonPhoneCustomWidget(title: '1')),
            InkWell(
                onTap: () => callController.onPressPhone(buttonText: "2"),
                child: const ButtonPhoneCustomWidget(title: '2')),
            InkWell(
                onTap: () => callController.onPressPhone(buttonText: "3"),
                child: const ButtonPhoneCustomWidget(title: '3')),
            const SizedBox(width: 30),
          ],
        ),
        const SizedBox(height: 12),
        Row(
          mainAxisSize: MainAxisSize.max,
          mainAxisAlignment: MainAxisAlignment.spaceBetween,
          children: [
            const SizedBox(width: 30),
            InkWell(
                onTap: () => callController.onPressPhone(buttonText: "4"),
                child: const ButtonPhoneCustomWidget(title: '4')),
            InkWell(
                onTap: () => callController.onPressPhone(buttonText: "5"),
                child: const ButtonPhoneCustomWidget(title: '5')),
            InkWell(
                onTap: () => callController.onPressPhone(buttonText: "6"),
                child: const ButtonPhoneCustomWidget(title: '6')),
            const SizedBox(width: 30),
          ],
        ),
        const SizedBox(height: 12),
        Row(
          mainAxisSize: MainAxisSize.max,
          mainAxisAlignment: MainAxisAlignment.spaceBetween,
          children: [
            const SizedBox(width: 30),
            InkWell(
                onTap: () => callController.onPressPhone(buttonText: "7"),
                child: const ButtonPhoneCustomWidget(title: '7')),
            InkWell(
                onTap: () => callController.onPressPhone(buttonText: "8"),
                child: const ButtonPhoneCustomWidget(title: '8')),
            InkWell(
                onTap: () => callController.onPressPhone(buttonText: "9"),
                child: const ButtonPhoneCustomWidget(title: '9')),
            const SizedBox(width: 30),
          ],
        ),
        const SizedBox(height: 12),
        Row(
          mainAxisSize: MainAxisSize.max,
          mainAxisAlignment: MainAxisAlignment.spaceBetween,
          children: [
            const SizedBox(width: 30),
            _buildBtnClear(showIcon: false),
            InkWell(
                onTap: () => callController.onPressPhone(buttonText: "0"),
                child: const ButtonPhoneCustomWidget(title: '0')),
            InkWell(
                onTap: callController.onPressBackSpace,
                child: _buildBtnClear()),
            const SizedBox(width: 30),
          ],
        ),
        const SizedBox(height: 24),
        _btnCall()
      ],
    );
  }

  Widget _buildDisplay(Size size) {
    return SizedBox(
      height: 80,
      child: Row(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          const SizedBox(width: 16),
          Obx(
            () => SizedBox(
                width: size.width - 32,
                child: Text(callController.phoneNumber.value,
                    style: FontFamily.demiBold(
                        size: 38, color: AppColor.colorBlack),
                    overflow: TextOverflow.ellipsis,
                    textAlign: TextAlign.center)),
          ),
          const SizedBox(width: 16),
        ],
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    final Size size = MediaQuery.of(context).size;
    return Scaffold(
      backgroundColor: AppColor.colorGreyBackground,
      body: SafeArea(
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            const SizedBox(height: 32),
            _buildDisplay(size),
            const SizedBox(height: 16),
            _buildKeyBoard(),
          ],
        ),
      ),
    );
  }
}
