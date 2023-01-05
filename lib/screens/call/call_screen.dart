import 'package:base_project/common/themes/colors.dart';
import 'package:base_project/common/widget/button_phone_custom_widget.dart';
import 'package:base_project/config/fonts.dart';
import 'package:base_project/config/routes.dart';
import 'package:base_project/generated/assets.dart';
import 'package:flutter/material.dart';
import 'package:get/get.dart';

class CallScreen extends StatefulWidget {
  const CallScreen({Key? key}) : super(key: key);

  @override
  State<CallScreen> createState() => _CallScreenState();
}

class _CallScreenState extends State<CallScreen> {
  String phoneNumber = '';


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
                      if (phoneNumber.isNotEmpty) {
                        // await FlutterPhoneDirectCaller.callNumber(phoneNumber);
                        Get.toNamed(Routes.callProcess);
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

  void onPressPhone({required String buttonText}) {
    setState(() {});
    phoneNumber += buttonText;
  }

  void onPressBackSpace() {
    setState(() {});
    if (phoneNumber.isNotEmpty) {
      phoneNumber = phoneNumber.substring(0, phoneNumber.length - 1);
    }
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
                onTap: () => onPressPhone(buttonText: "1"),
                child: const ButtonPhoneCustomWidget(title: '1')),
            InkWell(
                onTap: () => onPressPhone(buttonText: "2"),
                child: const ButtonPhoneCustomWidget(title: '2')),
            InkWell(
                onTap: () => onPressPhone(buttonText: "3"),
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
                onTap: () => onPressPhone(buttonText: "4"),
                child: const ButtonPhoneCustomWidget(title: '4')),
            InkWell(
                onTap: () => onPressPhone(buttonText: "5"),
                child: const ButtonPhoneCustomWidget(title: '5')),
            InkWell(
                onTap: () => onPressPhone(buttonText: "6"),
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
                onTap: () => onPressPhone(buttonText: "7"),
                child: const ButtonPhoneCustomWidget(title: '7')),
            InkWell(
                onTap: () => onPressPhone(buttonText: "8"),
                child: const ButtonPhoneCustomWidget(title: '8')),
            InkWell(
                onTap: () => onPressPhone(buttonText: "9"),
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
                onTap: () => onPressPhone(buttonText: "0"),
                child: const ButtonPhoneCustomWidget(title: '0')),
            InkWell(onTap: onPressBackSpace, child: _buildBtnClear()),
            const SizedBox(width: 30),
          ],
        ),
        const SizedBox(height: 60),
        _btnCall()
      ],
    );
  }

  Widget _buildDisplay(Size size) {
    return Row(
      mainAxisAlignment: MainAxisAlignment.center,
      children: [
        const SizedBox(width: 16),
        SizedBox(
            width: size.width - 32,
            child: Text(phoneNumber,
                style:
                    FontFamily.DemiBold(size: 38, color: AppColor.colorBlack),
                overflow: TextOverflow.ellipsis,
                textAlign: TextAlign.center)),
        const SizedBox(width: 16),
      ],
    );
  }

  @override
  Widget build(BuildContext context) {
    final Size size = MediaQuery.of(context).size;
    return Scaffold(
      backgroundColor: AppColor.colorGreyBackground,
      body: Column(
        mainAxisAlignment: MainAxisAlignment.end,
        children: [
          _buildDisplay(size),
          const SizedBox(height: 80),
          _buildKeyBoard(),
          const SizedBox(height: 32),
        ],
      ),
    );
  }
}
