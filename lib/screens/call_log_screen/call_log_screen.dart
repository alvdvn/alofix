// ignore_for_file: invalid_use_of_protected_member
import 'package:base_project/common/themes/colors.dart';
import 'package:base_project/common/utils/alert_dialog_utils.dart';
import 'package:base_project/common/utils/global_app.dart';
import 'package:base_project/common/widget/loading_widget.dart';
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
import 'widget/item_call_log_local_widget.dart';

class CallLogScreen extends StatefulWidget {
  const CallLogScreen({super.key});

  @override
  State<StatefulWidget> createState() {
    return CallLogState();
  }
}

class CallLogState extends State<CallLogScreen> with WidgetsBindingObserver {
  CallLogController callLogController = Get.put(CallLogController());
  TextEditingController searchController = TextEditingController();
  final ScrollController controller = ScrollController();
  DateTime now = DateTime.now();
  DateTime? firstDayCurrentMonth;
  DateTime? lastDayCurrentMonth;
  final String _dateTimeNow = DateFormat("dd/MM/yyyy").format(DateTime.now());

  @override
  void initState() {
    WidgetsBinding.instance.addObserver(this);
    super.initState();
    callLogController.initData();
    controller.addListener(() {
      if (controller.position.pixels == controller.position.maxScrollExtent) {
        callLogController.loadMore(
            search: searchController.text,
            startTime: firstDayCurrentMonth,
            endTime: lastDayCurrentMonth);
      }
    });
  }

  @override
  void didChangeAppLifecycleState(AppLifecycleState state) {
    if (state == AppLifecycleState.resumed) {
      callLogController.initData();
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
        appBar: AppBar(
          backgroundColor: Colors.white,
          title: Text("Lịch sử gọi", style: FontFamily.demiBold(size: 20)),
          elevation: 0,
          actions: [
            Obx(() => callLogController.loadDataLocal.value == true
                ? Container()
                : GestureDetector(
                    onTap: () {
                      callLogController.onClickSearch();
                    },
                    child: Obx(() => SvgPicture.asset(
                          Assets.iconsIconSearch,
                          width: 30,
                          height: 30,
                          color: callLogController.isShowSearch.value == true
                              ? AppColor.colorRedMain
                              : Colors.grey,
                        )),
                  )),
            const SizedBox(width: 16),
            Obx(() => callLogController.loadDataLocal.value
                ? Container()
                : GestureDetector(
                    onTap: () {
                      callLogController.onClickCalender();
                    },
                    child: Obx(() => SvgPicture.asset(
                          Assets.iconsIconCalender,
                          width: 50,
                          height: 50,
                          color: callLogController.isShowCalender.value == true
                              ? AppColor.colorRedMain
                              : Colors.grey,
                        )),
                  )),
            const SizedBox(width: 16)
          ],
        ),
        body: Column(
          children: [
            Obx(() {
              if (callLogController.isShowSearch.value == true) {
                return Container(
                    padding:
                        const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
                    color: Colors.white,
                    child: TextInputSearchWidget(
                      isDisable: callLogController.isDisable.value,
                      controller: searchController,
                      onSubmit: (value) async {
                        callLogController.getCallLogFromServer(
                            page: callLogController.page.value,
                            search: searchController.text,
                            clearList: true,
                            showLoading: true);
                      },
                      labelHint: callLogController.isShowSearch.value == true
                          ? 'Số điện thoại, mã đơn hàng'
                          : '',
                    ));
              }
              if (callLogController.isShowCalender.value == true) {
                return GestureDetector(
                  onTap: () async {
                    DateTimeRange? result = await showDateRangePickerDialog(
                        context,
                        title: 'Chọn khoảng thời gian',
                        dateRange: DateTimeRange(
                            start: firstDayCurrentMonth ?? DateTime.now(),
                            end: lastDayCurrentMonth ?? DateTime.now()));
                    firstDayCurrentMonth = result?.start;
                    lastDayCurrentMonth = result?.end;
                    callLogController.setTime(result);
                    callLogController.getCallLogFromServer(
                        page: callLogController.page.value,
                        search: searchController.text,
                        startTime: firstDayCurrentMonth,
                        endTime: lastDayCurrentMonth,
                        showLoading: true,
                        clearList: true);
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
                          const SizedBox(width: 20),
                          GestureDetector(
                            onTap: () {
                              firstDayCurrentMonth = null;
                              lastDayCurrentMonth = null;
                              searchController.text = '';
                              callLogController.onClickClose();
                            },
                            child: const Icon(
                              Icons.close,
                              size: 25,
                              color: Colors.grey,
                            ),
                          )
                        ],
                      )),
                );
              }
              return const SizedBox();
            }),
            Expanded(child: Obx(() {
              if (callLogController.loading.isTrue) {
                return const ShowLoading();
              }
              return Scrollbar(
                controller: controller,
                thickness: 6,
                radius: const Radius.circular(6),
                thumbVisibility: true,
                child: callLogController.loadDataLocal.value == false
                    ? RefreshIndicator(
                        onRefresh: () async {
                          callLogController.onRefresh(
                              search: searchController.text,
                              startTime: firstDayCurrentMonth,
                              endTime: lastDayCurrentMonth);
                        },
                        child: callLogController.callLogSv.isNotEmpty
                            ? callLogController.callLogSv.length < 3
                                ? SingleChildScrollView(
                                    controller: controller,
                                    physics:
                                        const AlwaysScrollableScrollPhysics(),
                                    child: SizedBox(
                                      width: double.infinity,
                                      height: size.height * 0.8,
                                      child: GroupedListView(
                                          elements:
                                              callLogController.callLogSv.value,
                                          groupComparator: (value1, value2) =>
                                              value2.compareTo(value1),
                                          itemComparator: (item1, item2) {
                                            final time1 =
                                                DateTime.parse(item1.key ?? '')
                                                    .millisecondsSinceEpoch;
                                            final time2 =
                                                DateTime.parse(item2.key ?? '')
                                                    .millisecondsSinceEpoch;
                                            return time1.compareTo(time2);
                                          },
                                          groupSeparatorBuilder: (String
                                                  value) =>
                                              Padding(
                                                padding:
                                                    const EdgeInsets.symmetric(
                                                        vertical: 12,
                                                        horizontal: 16),
                                                child: Text(value,
                                                    style: FontFamily.demiBold(
                                                        size: 14,
                                                        color: AppColor
                                                            .colorGreyText)),
                                              ),
                                          groupBy: (element) {
                                            final date = DateTime.parse(
                                                    element.key ?? '')
                                                .toLocal();
                                            var time = ddMMYYYYSlashFormat
                                                .format(date);
                                            if (time == _dateTimeNow) {
                                              return 'Hôm nay';
                                            }
                                            return time;
                                          },
                                          itemBuilder: (c, e) {
                                            return ItemCallLogAppWidget(
                                                callLog: e.calls ?? []);
                                          }),
                                    ),
                                  )
                                : GroupedListView(
                                    controller: controller,
                                    elements: callLogController.callLogSv.value,
                                    groupComparator: (value1, value2) =>
                                        value2.compareTo(value1),
                                    itemComparator: (item1, item2) {
                                      final time1 =
                                          DateTime.parse(item1.key ?? '')
                                              .millisecondsSinceEpoch;
                                      final time2 =
                                          DateTime.parse(item2.key ?? '')
                                              .millisecondsSinceEpoch;
                                      return time1.compareTo(time2);
                                    },
                                    order: GroupedListOrder.ASC,
                                    groupSeparatorBuilder: (String value) =>
                                        Padding(
                                          padding: const EdgeInsets.symmetric(
                                              vertical: 12, horizontal: 16),
                                          child: Text(value,
                                              style: FontFamily.demiBold(
                                                  size: 14,
                                                  color:
                                                      AppColor.colorGreyText)),
                                        ),
                                    groupBy: (element) {
                                      final date =
                                          DateTime.parse(element.key ?? '')
                                              .toLocal();
                                      var time =
                                          ddMMYYYYSlashFormat.format(date);
                                      if (time == _dateTimeNow) {
                                        return 'Hôm nay';
                                      }
                                      return time;
                                    },
                                    itemBuilder: (c, e) {
                                      return ItemCallLogAppWidget(
                                          callLog: e.calls ?? []);
                                    })
                            : SingleChildScrollView(
                                controller: controller,
                                physics: const AlwaysScrollableScrollPhysics(),
                                child: SizedBox(
                                  width: double.infinity,
                                  height: size.height * 0.7,
                                  child: Center(
                                    child: Text("Danh sách trống",
                                        style: FontFamily.demiBold(size: 20)),
                                  ),
                                )),
                      )
                    : ListView.builder(
                        controller: controller,
                        itemCount:
                            callLogController.callLogEntries.value.length,
                        itemBuilder: (BuildContext context, int index) {
                          return ItemCallLogLocalWidget(
                              callLog: callLogController
                                  .callLogEntries.value[index]);
                        },
                      ),
              );
            })),
          ],
        ));
  }
}
