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
  final ScrollController controller = ScrollController();

  @override
  void initState() {
    super.initState();
    // callLogController.getCallLog();
    callLogController.initData();
    controller.addListener(() {
      if (controller.position.pixels == controller.position.maxScrollExtent) {
        callLogController.loadMore();
      }
    });
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
              if (callLogController.isShowSearch.value == true) {
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
              if (callLogController.isShowCalender.value == true) {
                return InkWell(
                  onTap: () async {
                    // DateTime now = DateTime.now();
                    // DateTime firstDayCurrentMonth =
                    //     DateTime(now.year, now.month, 1);
                    // DateTime lastDayCurrentMonth =
                    //     DateTime(now.year, now.month + 1)
                    //         .subtract(const Duration(days: 1));
                    // DateTimeRange? result = await showDateRangePickerDialog(
                    //   context,
                    //   title: "Chọn khoảng thời gian",
                    //   dateRange: DateTimeRange(
                    //     start: firstDayCurrentMonth,
                    //     end: lastDayCurrentMonth,
                    //   ),
                    // );
                  },
                  child: Container(
                      padding:
                          const EdgeInsets.only(left: 16, right: 16, bottom: 8),
                      width: double.infinity,
                      color: Colors.white,
                      child: Row(
                        mainAxisAlignment: MainAxisAlignment.end,
                        children: [
                          Expanded(
                            child: Container(
                              decoration: BoxDecoration(
                                  borderRadius: BorderRadius.circular(4),
                                  border: Border.all(
                                      width: 1,
                                      color: AppColor.colorGreyBorder)),
                              padding: const EdgeInsets.all(16),
                              child: Text(callLogController.timePicker.value),
                            ),
                          ),
                          const SizedBox(width: 8),
                          InkWell(
                            onTap: () => callLogController.onClickClose(),
                            child: const Icon(
                              Icons.close,
                              size: 16,
                              color: Colors.grey,
                            ),
                          )
                        ],
                      )),
                );
              }
              return const SizedBox();
            }),
            Expanded(
                child: Obx(
              () => Scrollbar(
                controller: controller,
                thickness: 6,
                radius: const Radius.circular(6),
                thumbVisibility: true,
                child: RefreshIndicator(
                  onRefresh: () async {
                    callLogController.onRefresh();
                  },
                  child: ListView.builder(
                      controller: controller,
                      physics: const AlwaysScrollableScrollPhysics(),
                      itemBuilder: (context, index) {
                        if (callLogController.callLogSv.isNotEmpty) {
                          return ItemCallLogWidget(
                              callLog: callLogController.callLogSv[index]);
                        }
                        return Center(
                            child: Text('Chưa có lịch sử cuộc gọi gần nhất',
                                style: FontFamily.demiBold(size: 20)));
                      },
                      itemCount: callLogController.callLogSv.length),
                ),
              ),
            ))
          ],
        ));
  }
}
