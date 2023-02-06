import 'dart:io';
import 'package:base_project/common/themes/colors.dart';
import 'package:base_project/common/widget/text_input_search_widget.dart';
import 'package:base_project/config/fonts.dart';
import 'package:base_project/generated/assets.dart';
import 'package:flutter/material.dart';
import 'package:flutter_svg/flutter_svg.dart';
import 'package:get/get.dart';
import 'call_log_controller.dart';
import 'widget/item_call_log_widget.dart';

class CallLogScreen extends StatefulWidget {
  const CallLogScreen({super.key});

  @override
  State<StatefulWidget> createState() {
    return CallLogState();
  }
}

class CallLogState extends State<CallLogScreen> {
  CallLogController callLogController = Get.put(CallLogController());
  TextEditingController searchController = TextEditingController();

  @override
  void initState() {
    super.initState();
    callLogController.getCallLogFromServer();
  }


  @override
  Widget build(BuildContext context) {
    return Scaffold(
        appBar: AppBar(
          backgroundColor: Colors.white,
          title: Text("Lịch sử gọi", style: FontFamily.demiBold(size: 20)),
          elevation: 0,
          actions: [
            InkWell(
              onTap: () {
                callLogController.onClickSearch();
              },
              child: Obx(() => SvgPicture.asset(
                    Assets.iconsIconSearch,
                    width: 24,
                    height: 24,
                    color: callLogController.isShowSearch.value == true
                        ? AppColor.colorRedMain
                        : Colors.grey,
                  )),
            ),
            const SizedBox(width: 16),
            InkWell(
              onTap: () {
                callLogController.onClickCalender();
              },
              child: Obx(() => SvgPicture.asset(
                    Assets.iconsIconCalender,
                    width: 46,
                    height: 46,
                    color: callLogController.isShowCalender.value == true
                        ? AppColor.colorRedMain
                        : Colors.grey,
                  )),
            ),
            const SizedBox(width: 16)
          ],
        ),
        body: Column(
          children: [
            Obx(() {
              if (callLogController.isShowSearch.value == true ||
                  callLogController.isShowCalender.value == true) {
                searchController.text = callLogController.timePicker.value;
                return Container(
                    padding: const EdgeInsets.symmetric(horizontal: 16),
                    color: Colors.white,
                    child: TextInputSearchWidget(
                      isDisable: callLogController.isDisable.value,
                      controller: searchController,
                      labelHint: callLogController.isShowSearch.value == true
                          ? 'Tìm tên, số điện thoại, mã đơn hàng'
                          : '',
                    ));
              }
              return const SizedBox();
            }),
            Expanded(
                child: callLogController.callLogSv.isNotEmpty
                    ? ListView.builder(
                        itemBuilder: (context, index) => ItemCallLogWidget(
                            callLog: callLogController.callLogSv[index]),
                        itemCount: callLogController.callLogSv.length,
                      )
                    : Center(
                        child: Text('Chưa có lịch sử cuộc gọi gần nhất',
                            style: FontFamily.demiBold(size: 20))))
          ],
        ));
  }
}
