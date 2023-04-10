import 'dart:async';

import 'package:base_project/common/themes/colors.dart';
import 'package:base_project/common/widget/button_phone_custom_widget.dart';
import 'package:base_project/config/fonts.dart';
import 'package:base_project/generated/assets.dart';
import 'package:base_project/screens/call_log_screen/call_log_controller.dart';
import 'package:flutter/material.dart';
import 'package:get/get.dart';

import 'call_controller.dart';

class CallScreen extends StatefulWidget {
  const CallScreen({Key? key}) : super(key: key);

  @override
  State<CallScreen> createState() => _CallScreenState();
}

class _CallScreenState extends State<CallScreen> with WidgetsBindingObserver {
  CallController callController = Get.put(CallController());
  CallLogController callLogController = Get.put(CallLogController());
  int secondCall = 0;
  Timer? timer;

  Widget _btnCall() {
    return GestureDetector(
        onTap: () async {
          if (callController.phoneNumber.isNotEmpty) {
            callController.handCall(callController.phoneNumber.toString());
          }
          timer = Timer.periodic(const Duration(seconds: 1), (timer) {
            secondCall ++;
          });
        },
        child: Stack(
          children: [
            Align(
                alignment: Alignment.center,
                child: Image.asset(Assets.imagesImgCallAccept,
                    width: 90, height: 90)),
            const Align(
              alignment: Alignment.center,
              child: SizedBox(
                  height: 90,
                  child: Icon(Icons.call_sharp, color: Colors.white, size: 30)),
            )
          ],
        ));
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
            AnimatedPhoneButton(
                text: '1',
                onPressed: () => callController.onPressPhone(buttonText: "1")),
            AnimatedPhoneButton(
                text: '2',
                onPressed: () => callController.onPressPhone(buttonText: "2")),
            AnimatedPhoneButton(
                text: '3',
                onPressed: () => callController.onPressPhone(buttonText: "3")),
            const SizedBox(width: 30),
          ],
        ),
        const SizedBox(height: 12),
        Row(
          mainAxisSize: MainAxisSize.max,
          mainAxisAlignment: MainAxisAlignment.spaceBetween,
          children: [
            const SizedBox(width: 30),
            AnimatedPhoneButton(
                text: '4',
                onPressed: () => callController.onPressPhone(buttonText: "4")),
            AnimatedPhoneButton(
                text: '5',
                onPressed: () => callController.onPressPhone(buttonText: "5")),
            AnimatedPhoneButton(
                text: '6',
                onPressed: () => callController.onPressPhone(buttonText: "6")),
            const SizedBox(width: 30),
          ],
        ),
        const SizedBox(height: 12),
        Row(
          mainAxisSize: MainAxisSize.max,
          mainAxisAlignment: MainAxisAlignment.spaceBetween,
          children: [
            const SizedBox(width: 30),
            AnimatedPhoneButton(
                text: '7',
                onPressed: () => callController.onPressPhone(buttonText: "7")),
            AnimatedPhoneButton(
                text: '8',
                onPressed: () => callController.onPressPhone(buttonText: "8")),
            AnimatedPhoneButton(
                text: '9',
                onPressed: () => callController.onPressPhone(buttonText: "9")),
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
            AnimatedPhoneButton(
                text: '0',
                onPressed: () => callController.onPressPhone(buttonText: "0")),
            GestureDetector(
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
          SizedBox(
              width: size.width - 32,
              height: 50,
              child: Obx(() => TextFormField(
                  style: FontFamily.demiBold(size: 32, lineHeight: 1.5),
                  controller: TextEditingController(
                      text: callController.phoneNumber.value),
                  keyboardType: TextInputType.none,
                  cursorColor: AppColor.colorRedMain,
                  textAlign: TextAlign.center,
                  decoration: InputDecoration(
                      labelText: '',
                      labelStyle:
                          FontFamily.regular(color: AppColor.colorHintText),
                      border: InputBorder.none)))),
          const SizedBox(width: 16),
        ],
      ),
    );
  }

  @override
  void initState() {
    WidgetsBinding.instance.addObserver(this);
    super.initState();
  }

  @override
  void didChangeAppLifecycleState(AppLifecycleState state) {
    if (state == AppLifecycleState.resumed) {
      print('time $secondCall');
      callLogController.initData(timeRing: secondCall);
      // timer?.cancel();
      // secondCall = 0;
    }
  }

  @override
  void dispose() {
    WidgetsBinding.instance.removeObserver(this);
    super.dispose();
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
