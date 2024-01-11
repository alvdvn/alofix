import 'package:flutter/material.dart';
import 'package:flutter_svg/flutter_svg.dart';
import 'package:get/get.dart';
import 'package:intl/intl.dart';
import '../../common/constance/strings.dart';
import 'call_log_controller.dart';
import 'widget/item_call_log_app_widget.dart';
import 'package:base_project/common/themes/colors.dart';
import 'package:base_project/common/utils/alert_dialog_utils.dart';
import 'package:base_project/common/utils/global_app.dart';
import 'package:base_project/common/widget/loading_widget.dart';
import 'package:base_project/common/widget/text_input_search_widget.dart';
import 'package:base_project/config/fonts.dart';
import 'package:base_project/generated/assets.dart';

class CallLogScreen extends StatefulWidget {
  const CallLogScreen({super.key});

  @override
  State<StatefulWidget> createState() {
    return CallLogState();
  }
}

class CallLogState extends State<CallLogScreen> with WidgetsBindingObserver {
  final CallLogController callLogController = Get.put(CallLogController());
  final TextEditingController searchController = TextEditingController();
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
      print(
          "${controller.position.pixels} ${controller.position.maxScrollExtent}");
      if (controller.position.pixels == controller.position.maxScrollExtent) {
        print("Load more");
        callLogController.loadMore();
      }
    });
  }

  @override
  void dispose() {
    WidgetsBinding.instance.removeObserver(this);
    super.dispose();
  }
@override
  void didChangeDependencies() {
    // TODO: implement didChangeDependencies
    super.didChangeDependencies();
    callLogController.isShowSearch.value == false;
    callLogController.isShowCalender.value == false;
  }
  String handlerDateTime(String element) {
    final String dateTimeNow = DateFormat("dd/MM/yyyy").format(DateTime.now());
    final date = DateTime.parse(element).toLocal();
    var time = ddMMYYYYSlashFormat.format(date);
    if (time == dateTimeNow) {
      return AppStrings.today;
    }
    return time;
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
        appBar: AppBar(
          backgroundColor: Colors.white,
          title: Text(AppStrings.historiesCall,
              style: FontFamily.demiBold(size: 20)),
          elevation: 0,
          actions: [
            GestureDetector(
              onTap: () => callLogController.onClickSearch(),
              child: Obx(() => SvgPicture.asset(
                    Assets.iconsIconSearch,
                    width: 30,
                    height: 30,
                    color: callLogController.isShowSearch.value == true
                        ? AppColor.colorRedMain
                        : Colors.grey,
                  )),
            ),
            const SizedBox(width: 8),
            GestureDetector(
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
            ),
            const SizedBox(width: 8),
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
                        callLogController.searchCallLog.value = value;
                        await callLogController.loadData();
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
                        title: AppStrings.choiceTimeRange,
                        dateRange: DateTimeRange(
                            start: firstDayCurrentMonth ?? DateTime.now(),
                            end: lastDayCurrentMonth ?? DateTime.now()));
                    firstDayCurrentMonth = result?.start;
                    lastDayCurrentMonth = result?.end;
                    await callLogController.setTime(result);
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
                  child: RefreshIndicator(
                    onRefresh: () async {
                      await callLogController.loadData();
                    },
                    child: callLogController.callLogSv.isNotEmpty
                        ? ListView.builder(
                            controller: controller,
                            itemCount: callLogController.callLogSv.length,
                            itemBuilder: (c, index) {
                              String key = callLogController.callLogSv.keys
                                  .elementAt(index);

                              var group = callLogController.callLogSv[key];
                              return ItemListCallLogTime(
                                logs: group!,
                                date: key,
                              );
                            })
                        : Center(
                            child: Text(AppStrings.emptyCallLogs,
                                style: FontFamily.demiBold(size: 20))),
                  ),
                ),
              );
            }),
          ],
        ));
  }


}
