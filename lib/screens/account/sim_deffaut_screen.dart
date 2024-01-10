import 'package:base_project/common/widget/app_bar_custom_widget.dart';
import 'package:base_project/generated/assets.dart';
import 'package:base_project/screens/account/account_controller.dart';
import 'package:base_project/screens/account/widget/item_call_default_widget.dart';
import 'package:base_project/services/local/app_share.dart';
import 'package:flutter/material.dart';
import 'package:get/get.dart';

import '../../extension.dart';

class SimDefaultScreen extends StatefulWidget {
  const SimDefaultScreen({Key? key}) : super(key: key);

  @override
  State<SimDefaultScreen> createState() => _SimDefaultScreenState();
}

class _SimDefaultScreenState extends State<SimDefaultScreen> {
  final AccountController _controller = Get.find();
  int? simSlotIndex;
@override
  void initState() {

    // TODO: implement initState
    super.initState();

  }


 void getSimSlotIndex() async{

  int index= await AppShared().getSimDefault() ;
    setState(() {
      simSlotIndex =index;
    });
    pprint("sim slot index $simSlotIndex" );

  }
  @override
  void didChangeDependencies() {
    // TODO: implement didChangeDependencies
    super.didChangeDependencies();
    getSimSlotIndex();
  }
  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.white,
      appBar: const CustomAppBar(title: 'Sim mặc định'),
      body: Obx(() => SingleChildScrollView(
            child: Column(
              children: [
                ..._controller.simCards.map((element) => InkWell(
                      child: ItemCallDefaultWidget(
                        assetsImage: Assets.imagesSim,
                        title: 'SIM ${element.simSlotIndex! + 1}',
                        value: element.phoneNumber.toString(),
                        viewIcon: true,
                        isChoose: simSlotIndex == element.simSlotIndex,
                      ),
                      onTap: () {
                        setState(() {
                          simSlotIndex = element.simSlotIndex!;
                        });
                        _controller.saveSimType(element.simSlotIndex!);
                      },
                    )),
                InkWell(
                  child: ItemCallDefaultWidget(
                    assetsImage: Assets.imagesSim,
                    title: 'Luôn hỏi',
                    value: '',
                    viewIcon: true,
                    isChoose: simSlotIndex == null,
                  ),
                  onTap: () {
                    setState(() {
                      simSlotIndex = null;
                    });
                    _controller.saveSimType(null);
                  },
                ),
                SizedBox(
                  height: 10,
                ),

              ],
            ),
          )),
    );
  }
}
