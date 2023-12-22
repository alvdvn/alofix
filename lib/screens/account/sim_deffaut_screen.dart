import 'package:base_project/common/enum_call/enum_call.dart';
import 'package:base_project/common/widget/app_bar_custom_widget.dart';
import 'package:base_project/generated/assets.dart';
import 'package:base_project/screens/account/account_controller.dart';
import 'package:base_project/screens/account/widget/item_call_default_widget.dart';
import 'package:base_project/services/local/app_share.dart';
import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:shared_preferences/shared_preferences.dart';

class SimDefaultScreen extends StatefulWidget {
  const SimDefaultScreen({Key? key}) : super(key: key);

  @override
  State<SimDefaultScreen> createState() => _SimDefaultScreenState();
}

class _SimDefaultScreenState extends State<SimDefaultScreen> {
  final AccountController _controller = Get.find();
  DefaultSim? defaultSim;

  @override
  void initState() {
    // TODO: implement initState
    super.initState();
    getSimInCache();
  }

  getSimInCache() async {
    final prefs = await SharedPreferences.getInstance();
    await prefs.reload();
    String? simDefault = await AppShared().getSimDefault();
    if (simDefault?.isNotEmpty ?? false) {
      setState(() {
        AppShared.simTypeGlobal = simDefault!;
        defaultSim = getSimTypeEnum(simDefault!);
      });
    }
  }

  @override
  Widget build(BuildContext context) {
    defaultSim = getSimTypeEnum(AppShared.simTypeGlobal);
    print('LOG: defaultSim $defaultSim');
    return Scaffold(
      backgroundColor: Colors.white,
      appBar: const CustomAppBar(title: 'Sim mặc định'),
      body: SingleChildScrollView(
        child: Column(
          children: [
            InkWell(
              child: ItemCallDefaultWidget(
                assetsImage: Assets.imagesSim,
                title: 'SIM 1',
                value: '',
                viewIcon: true,
                isChoose: defaultSim == DefaultSim.sim1 ? true : false,
              ),
              onTap: () {
                setState(() {
                  defaultSim = DefaultSim.sim1;
                });
                _controller.saveSimType(defaultSim!);
              },
            ),
            InkWell(
              child: ItemCallDefaultWidget(
                assetsImage: Assets.imagesSim,
                title: 'SIM 2',
                value: '',
                viewIcon: true,
                isChoose: defaultSim == DefaultSim.sim2 ? true : false,
              ),
              onTap: () {
                setState(() {
                  defaultSim =  DefaultSim.sim2;
                });
                _controller.saveSimType(defaultSim!);
              },
            ),
            InkWell(
              child: ItemCallDefaultWidget(
                assetsImage: Assets.imagesSim,
                title: 'Luôn hỏi',
                value: '',
                viewIcon: true,
                isChoose: defaultSim == DefaultSim.sim0 ? true : false,
              ),
              onTap: () {
                setState(() {
                  defaultSim =  DefaultSim.sim0;
                });
                _controller.saveSimType(defaultSim!);
              },
            )
          ],
        ),
      ),
    );
  }
}
