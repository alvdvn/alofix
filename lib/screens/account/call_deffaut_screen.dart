import 'package:base_project/common/enum_call/enum_call.dart';
import 'package:base_project/common/widget/app_bar_custom_widget.dart';
import 'package:base_project/generated/assets.dart';
import 'package:base_project/main.dart';
import 'package:base_project/screens/account/account_controller.dart';
import 'package:base_project/screens/account/widget/item_call_default_widget.dart';
import 'package:flutter/material.dart';
import 'package:get/get.dart';

class CallDefaultScreen extends StatefulWidget {
  const CallDefaultScreen({Key? key}) : super(key: key);

  @override
  State<CallDefaultScreen> createState() => _CallDefaultScreenState();
}

class _CallDefaultScreenState extends State<CallDefaultScreen> {
  final AccountController _controller = Get.find();
  DefaultCall? defaultCall;


  @override
  Widget build(BuildContext context) {
    defaultCall = getCallTypeEnum(callTypeGlobal);
    return Scaffold(
      backgroundColor: Colors.white,
      appBar: const CustomAppBar(title: 'Cuộc gọi mặc định'),
      body: SingleChildScrollView(
        child: Column(
          children: [
            InkWell(
              child: ItemCallDefaultWidget(
                assetsImage: Assets.imagesImageApp,
                title: 'App AloNinja',
                value: 'Gọi qua AloNinja',
                isChoose: defaultCall == DefaultCall.aloNinja ? true : false,
              ),
              onTap: () {
                setState(() {
                  defaultCall = DefaultCall.aloNinja;
                });
                _controller.saveCallType(defaultCall!);
              },
            ),
            InkWell(
              child: ItemCallDefaultWidget(
                assetsImage: Assets.imagesZalo,
                title: 'Zalo',
                value: 'Gọi qua Zalo',
                isChoose: defaultCall == DefaultCall.zalo ? true : false,
              ),
              onTap: () {
                setState(() {
                  defaultCall = DefaultCall.zalo;
                });
                _controller.saveCallType(defaultCall!);

              },
            ),
            InkWell(
              child: ItemCallDefaultWidget(
                assetsImage: Assets.imagesSim,
                title: 'SIM',
                value: 'Gọi qua Sim',
                viewIcon: true,
                isChoose: defaultCall == DefaultCall.sim ? true : false,
              ),
              onTap: () {
                setState(() {
                  defaultCall = DefaultCall.sim;
                });
                _controller.saveCallType(defaultCall!);
              },
            ),
          ],
        ),
      ),
    );
  }
}
