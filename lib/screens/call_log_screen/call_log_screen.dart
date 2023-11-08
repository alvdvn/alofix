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
import 'widget/item_call_log_app_widget.dart';

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

  @override
  void initState() {
    WidgetsBinding.instance.addObserver(this);
    super.initState();
    callLogController.initData();
    controller.addListener(() {
      if (controller.position.pixels == controller.position.maxScrollExtent) {
        callLogController.loadMore(search: searchController.text, startTime: firstDayCurrentMonth, endTime: lastDayCurrentMonth);
      }
    });
  }

  @override
  void didChangeAppLifecycleState(AppLifecycleState state) {
    if (state == AppLifecycleState.resumed) {
      // TODO: cover this to made the scroll smoothly trans
      callLogController.initData();
    }
  }

  @override
  void dispose() {
    WidgetsBinding.instance.removeObserver(this);
    super.dispose();
  }

  String handlerDateTime(String element) {
    final String dateTimeNow = DateFormat("dd/MM/yyyy").format(DateTime.now());
    final date = DateTime.parse(element).toLocal();
    var time = ddMMYYYYSlashFormat.format(date);
    if (time == dateTimeNow) {
      return 'Hôm nay';
    }
    return time;
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
        appBar: AppBar(
          backgroundColor: Colors.white,
          title: Text("Lịch sử gọi", style: FontFamily.demiBold(size: 20)),
          elevation: 0,
          actions: [
            Obx(() => callLogController.loadDataLocal.value == true
                ? GestureDetector(
                    onTap: () => callLogController.onClickSearchLocal(),
                    child: Obx(() => SvgPicture.asset(
                          Assets.iconsIconSearch,
                          width: 30,
                          height: 30,
                          color: callLogController.isShowSearch.value == true ? AppColor.colorRedMain : Colors.grey,
                        )),
                  )
                : GestureDetector(
                    onTap: () => callLogController.onClickSearch(),
                    child: Obx(() => SvgPicture.asset(
                          Assets.iconsIconSearch,
                          width: 30,
                          height: 30,
                          color: callLogController.isShowSearch.value == true ? AppColor.colorRedMain : Colors.grey,
                        )),
                  )),
            const SizedBox(width: 8),
            Obx(() => callLogController.loadDataLocal.value
                ? GestureDetector(
                    onTap: () {
                      callLogController.onClickCalender();
                    },
                    child: Obx(() => SvgPicture.asset(
                          Assets.iconsIconCalender,
                          width: 50,
                          height: 50,
                          color: callLogController.isShowCalender.value == true ? AppColor.colorRedMain : Colors.grey,
                        )),
                  )
                : GestureDetector(
                    onTap: () {
                      callLogController.onClickCalender();
                    },
                    child: Obx(() => SvgPicture.asset(
                          Assets.iconsIconCalender,
                          width: 50,
                          height: 50,
                          color: callLogController.isShowCalender.value == true ? AppColor.colorRedMain : Colors.grey,
                        )),
                  )),
            const SizedBox(width: 8),
            // Obx(() => callLogController.loadDataLocal.value
            //     ? Container()
            //     : GestureDetector(
            //         onTap: () {
            //           callLogController.onClickFilter();
            //           showDialog(context: context, builder: (){
            //             return Column();
            //           });
            //         },
            //         child: Obx(() => Icon(
            //               Icons.candlestick_chart,
            //               size: 20,
            //               color: callLogController.isFilter.value == true
            //                   ? AppColor.colorRedMain
            //                   : Colors.grey,
            //             )),
            //       )),
            const SizedBox(width: 16)
          ],
        ),
        body: Column(
          children: [
            Obx(() {
              if (callLogController.isShowSearch.value == true && callLogController.loadDataLocal.value == false) {
                return Container(
                    padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
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
                      labelHint: callLogController.isShowSearch.value == true ? 'Số điện thoại, mã đơn hàng' : '',
                    ));
              }
              if (callLogController.isShowCalender.value == true) {
                return GestureDetector(
                  onTap: () async {
                    DateTimeRange? result = await showDateRangePickerDialog(context,
                        title: 'Chọn khoảng thời gian',
                        dateRange: DateTimeRange(
                            start: firstDayCurrentMonth ?? DateTime.now(), end: lastDayCurrentMonth ?? DateTime.now()));
                    firstDayCurrentMonth = result?.start;
                    lastDayCurrentMonth = result?.end;
                    callLogController.setTime(result);
                    if (callLogController.loadDataLocal.value == true) {
                      callLogController.onFilterCalenderLocal(
                          startTime: firstDayCurrentMonth, endTime: lastDayCurrentMonth, clearList: false);
                    } else {
                      callLogController.getCallLogFromServer(
                          page: callLogController.page.value,
                          search: searchController.text,
                          startTime: firstDayCurrentMonth,
                          endTime: lastDayCurrentMonth,
                          showLoading: true,
                          clearList: true);
                    }
                  },
                  child: Container(
                      padding: const EdgeInsets.only(left: 16, right: 16, bottom: 8),
                      width: double.infinity,
                      color: Colors.white,
                      child: Row(
                        mainAxisAlignment: MainAxisAlignment.end,
                        children: [
                          Expanded(
                            child: Container(
                              decoration: BoxDecoration(
                                  borderRadius: BorderRadius.circular(4),
                                  border: Border.all(width: 1, color: AppColor.colorGreyBorder)),
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
                              if (callLogController.loadDataLocal.value == true) {
                                callLogController.onClickCloseOffine();
                              } else {
                                callLogController.onClickClose();
                              }
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
              if (callLogController.isShowSearchLocal.value == true && callLogController.loadDataLocal.value == true) {
                return Container(
                    padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
                    color: Colors.white,
                    child: TextInputSearchWidget(
                      hideClose: true,
                      controller: searchController,
                      onChange: (value) => callLogController.searchCallLogLocal(search: searchController.text),
                      labelHint: 'Số điện thoại',
                    ));
              }
              return const SizedBox();
            }),
            Obx(() {
              if (callLogController.loading.isTrue) {
                return const Expanded(child: ShowLoading());
              }
              return Expanded(
                child: Scrollbar(
                  controller: controller,
                  thickness: 6,
                  radius: const Radius.circular(6),
                  thumbVisibility: true,
                  child: callLogController.loadDataLocal.value == false
                      ? RefreshIndicator(
                          onRefresh: () async {
                            callLogController.onRefresh(
                                search: searchController.text, startTime: firstDayCurrentMonth, endTime: lastDayCurrentMonth);
                          },
                          child: callLogController.callLogSv.isNotEmpty
                              ? ListView.builder(
                                  controller: controller,
                                  itemCount: callLogController.callLogSv.value.length,
                                  itemBuilder: (c, index) {
                                    if (index == 0 ||
                                        handlerDateTime(callLogController.callLogSv.value[index].key.toString()) !=
                                            handlerDateTime(callLogController.callLogSv.value[index - 1].key.toString())) {
                                      return ItemListCallLogTime(
                                        callLogModel: callLogController.callLogSv.value[index],
                                      );
                                    } else {
                                      return ItemCallLogAppWidget(callLog: callLogController.callLogSv.value[index].calls ?? []);
                                    }
                                  })
                              : Center(child: Text("Danh sách trống", style: FontFamily.demiBold(size: 20))),
                        )
                      : ListView.builder(
                          controller: controller,
                          itemCount: callLogController.callLogLocalSearch.value.length,
                          itemBuilder: (c, index) {
                            if (index == 0 ||
                                handlerDateTime(callLogController.callLogLocalSearch.value[index].key.toString()) !=
                                    handlerDateTime(callLogController.callLogLocalSearch.value[index - 1].key.toString())) {
                              return Column(
                                crossAxisAlignment: CrossAxisAlignment.start,
                                children: [
                                  Padding(
                                    padding: const EdgeInsets.symmetric(vertical: 12, horizontal: 16),
                                    child: Text(handlerDateTime(callLogController.callLogLocalSearch.value[index].key ?? ''),
                                        style: FontFamily.demiBold(size: 14, color: AppColor.colorGreyText)),
                                  ),
                                  ItemCallLogAppWidget(callLog: callLogController.callLogLocalSearch.value[index].calls ?? [])
                                ],
                              );
                            } else {
                              return ItemCallLogAppWidget(callLog: callLogController.callLogLocalSearch.value[index].calls ?? []);
                            }
                          }),
                ),
              );
            }),
          ],
        ));
  }
}
