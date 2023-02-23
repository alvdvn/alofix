// ignore_for_file: invalid_use_of_protected_member
import 'package:date_range_picker/date_range_picker.dart' as DateRangePicker;
import 'package:base_project/common/themes/colors.dart';
import 'package:base_project/common/widget/text_input_search_widget.dart';
import 'package:base_project/config/fonts.dart';
import 'package:base_project/generated/assets.dart';
import 'package:flutter/material.dart';
import 'package:flutter_svg/flutter_svg.dart';
import 'package:get/get.dart';
import 'package:intl/intl.dart';
import 'call_log_controller.dart';
import 'package:grouped_list/grouped_list.dart';
import 'widget/item_call_log_app_widget.dart';

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
  final String _dateTimeNow = DateFormat("dd/MM/yyyy").format(DateTime.now());

  @override
  void initState() {
    super.initState();
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
                      onSubmit: (value) {},
                      onChange: (value) async {
                        await callLogController.getCallLogFromServer(
                            page: callLogController.page.value, search: value);
                      },
                      labelHint: callLogController.isShowSearch.value == true
                          ? 'Số điện thoại, mã đơn hàng'
                          : '',
                    ));
              }
              if (callLogController.isShowCalender.value == true) {
                return InkWell(
                  onTap: () async {
                    final List<DateTime> picked =
                        await DateRangePicker.showDatePicker(
                            context: context,
                            initialFirstDate: DateTime.now(),
                            initialLastDate:
                                (DateTime.now()).add(const Duration(days: 7)),
                            firstDate: DateTime(2015),
                            lastDate: DateTime(DateTime.now().year + 2));
                    if (picked != null && picked.length == 2) {
                      print(picked);
                    }
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
              child: Obx(() => Scrollbar(
                    controller: controller,
                    thickness: 6,
                    radius: const Radius.circular(6),
                    thumbVisibility: true,
                    child: RefreshIndicator(
                      onRefresh: () async {
                        callLogController.onRefresh();
                      },
                      child: GroupedListView(
                        controller: controller,
                        elements: callLogController.callLogSv.value,
                        groupComparator: (value1, value2) =>
                            value2.compareTo(value1),
                        itemComparator: (item1, item2) {
                          final time1 =
                              DateTime.parse(item1.logs?.last.startAt ?? '')
                                  .millisecondsSinceEpoch;
                          final time2 =
                              DateTime.parse(item2.logs?.last.startAt ?? '')
                                  .millisecondsSinceEpoch;
                          return time1.compareTo(time2);
                        },
                        order: GroupedListOrder.ASC,
                        groupSeparatorBuilder: (String value) => Padding(
                          padding: const EdgeInsets.symmetric(
                              vertical: 12, horizontal: 16),
                          child: Text(
                            value,
                            style: FontFamily.demiBold(
                                size: 14, color: AppColor.colorGreyText),
                          ),
                        ),
                        groupBy: (element) {
                          final date =
                              DateTime.parse(element.logs?.last.startAt ?? '')
                                  .toLocal();
                          var time = DateFormat("dd/MM/yyyy").format(date);
                          if (time == _dateTimeNow) {
                            return 'Hôm nay';
                          }
                          return time;
                        },
                        itemBuilder: (c, e) => ItemCallLogAppWidget(callLog: e),
                      ),
                    ),
                  )),
            )
          ],
        ));
  }
}
