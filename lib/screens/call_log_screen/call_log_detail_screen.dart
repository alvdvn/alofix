import 'dart:convert';

import 'package:base_project/database/enum.dart';
import 'package:base_project/database/models/call_log.dart';
import 'package:base_project/extension.dart';
import 'package:flutter/material.dart';
import 'package:flutter_svg/svg.dart';
import 'package:get/get.dart';
import 'package:intl/intl.dart';
import 'package:base_project/common/themes/colors.dart';
import 'package:base_project/common/utils/global_app.dart';
import 'package:base_project/common/widget/expansion_detail_block.dart';
import 'package:base_project/common/widget/row_value_widget.dart';
import 'package:base_project/config/fonts.dart';
import 'package:base_project/generated/assets.dart';
import 'package:base_project/models/custom_data_model.dart';
import 'package:base_project/screens/call_log_screen/widget/load_more_list_view_widget.dart';
import 'call_log_controller.dart';
import 'widget/item_status_call.dart';

class CallLogDetailScreen extends StatefulWidget {
  const CallLogDetailScreen({Key? key}) : super(key: key);

  @override
  State<CallLogDetailScreen> createState() => _CallLogDetailScreenState();
}

class _CallLogDetailScreenState extends State<CallLogDetailScreen>
    with WidgetsBindingObserver {
  final _controller = Get.put(CallLogController());
  List<CustomData> lstCustomData = [];
  int lengthCount = 0;
  String deepLinkAlo1 = 'njvcall://vn.etelecom.njvcall/call/';
  CallLog? callLog;

  Widget _buildText60(
      {required String title, required String value, required Size size}) {
    return Container(
      margin: const EdgeInsets.symmetric(horizontal: 16),
      child: Column(
        children: [
          Row(
            children: [
              SizedBox(
                  width: size.width * 0.6,
                  child: Text(
                    title,
                    style: FontFamily.regular(
                        size: 14, color: AppColor.colorBlack),
                  )),
              Text(value,
                  style:
                      FontFamily.regular(size: 14, color: AppColor.colorBlack))
            ],
          ),
          const SizedBox(
            height: 8,
          )
        ],
      ),
    );
  }

  Widget _buildSlider() {
    double currentSliderValue = 40;
    return SizedBox(
      width: double.maxFinite,
      child: Slider(
        value: currentSliderValue,
        max: 100,
        activeColor: AppColor.colorBlack,
        inactiveColor: AppColor.colorGreyBorder,
        label: currentSliderValue.round().toString(),
        onChanged: (double value) {
          setState(() {
            currentSliderValue = value;
          });
        },
      ),
    );
  }

  void showBottomSheetModel(CallLog callLog) {
    showModalBottomSheet<void>(
      context: context,
      builder: (BuildContext context) {
        return SizedBox(
          height: 350,
          child: Column(
            children: [
              const SizedBox(height: 16),
              Row(mainAxisAlignment: MainAxisAlignment.spaceBetween, children: [
                Row(
                  children: [
                    const SizedBox(width: 16),
                    SvgPicture.asset(Assets.iconsPlayCircle,
                        width: 18, height: 18),
                    const SizedBox(width: 8),
                    Text('File ghi âm',
                        style: FontFamily.normal(color: AppColor.colorBlack))
                  ],
                ),
                Row(
                  children: [
                    InkWell(
                      child: const Icon(
                        Icons.close,
                        color: AppColor.colorGreyText,
                      ),
                      onTap: () => Get.back(),
                    ),
                    const SizedBox(width: 16)
                  ],
                )
              ]),
              const SizedBox(height: 32),
              Text('Anh Thành Viettel', style: FontFamily.demiBold(size: 14)),
              const SizedBox(height: 8),
              Row(
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  ItemStatusCall(
                      callType: callLog.type ?? CallType.incomming,
                      answeredDuration: callLog.answeredDuration ?? 0,
                      ringingTime: callLog.timeRinging ?? 0),
                  const SizedBox(width: 8),
                  Text('*',
                      style: FontFamily.normal(
                          size: 14, color: AppColor.colorGreyText)),
                  const SizedBox(width: 8),
                  Text('15:30 24/11/22',
                      style: FontFamily.normal(
                          size: 14, color: AppColor.colorGreyText)),
                ],
              ),
              const SizedBox(height: 32),
              _buildSlider(),
              const SizedBox(height: 8),
              const Row(
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                children: [
                  Row(
                    children: [
                      SizedBox(width: 22),
                      Text('0:08:32'),
                    ],
                  ),
                  Row(
                    children: [
                      Text('0:08:32'),
                      SizedBox(width: 22),
                    ],
                  )
                ],
              ),
              const SizedBox(height: 16),
              Row(
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                children: [
                  const SizedBox(width: 16),
                  SvgPicture.asset(
                    Assets.iconsArrowDownload,
                  ),
                  SvgPicture.asset(Assets.iconsArrowRotaion),
                  Image.asset(Assets.imagesPlay, width: 80, height: 80),
                  SvgPicture.asset(Assets.iconsRotationRight),
                  SvgPicture.asset(Assets.icons1x),
                  const SizedBox(width: 16),
                ],
              )
            ],
          ),
        );
      },
    );
  }

  Widget _buildBtnColumnText(
      {required String assetsImage, required String title}) {
    return Container(
      width: 60,
      height: 60,
      decoration: BoxDecoration(
        borderRadius: BorderRadius.circular(35),
        color: Colors.white,
      ),
      child: Center(
          child: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        crossAxisAlignment: CrossAxisAlignment.center,
        children: [
          SvgPicture.asset(assetsImage,
              width: 18, height: 18, color: AppColor.colorBlack),
          const SizedBox(height: 8),
          Text(
            title,
            style: FontFamily.normal(size: 10),
            textAlign: TextAlign.center,
          )
        ],
      )),
    );
  }

  Widget _buildHeader(List<CallLog> callLogs) {
    callLog ??= callLogs.first;
    pprint("Đang xem ${callLog}");
    return Column(
      children: [
        const SizedBox(height: 30),
        callLog!.callLogValid == CallLogValid.invalid
            ? CircleAvatar(
                radius: 40,
                backgroundColor: AppColor.colorGreyBackground,
                child: Image.asset(Assets.imagesCallLogInvalid,
                    width: 40, height: 40))
            : CircleAvatar(
                radius: 40,
                backgroundColor: AppColor.colorGreyBackground,
                child: Image.asset(Assets.imagesImgNjv512h,
                    width: 40, height: 40)),
        const SizedBox(height: 16),
        SelectableText(callLog!.phoneNumber,
            style: FontFamily.demiBold(size: 18, color: callLog!.callLogValid == 2 ? AppColor.colorRedMain : AppColor.colorBlack)),
        Row(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            ItemStatusCall(
                callType: callLog!.type ?? CallType.incomming,
                answeredDuration: callLog!.answeredDuration ?? 0,
                ringingTime: callLog!.timeRinging ?? 0),
          ],
        ),
        const SizedBox(height: 10),
        Row(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            if (callLog!.method == CallMethod.stringee)
              InkWell(
                borderRadius: BorderRadius.circular(29.0),
                child: _buildBtnColumnText(
                    assetsImage: Assets.iconsPlayCircle, title: 'File ghi âm'),
                onTap: () {},
              ),
            InkWell(
              onTap: () {
                _controller.handCall(callLog!.phoneNumber);
              },
              borderRadius: BorderRadius.circular(29.0),
              child: _buildBtnColumnText(
                  assetsImage: Assets.iconsIconCall, title: 'Gọi điện'),
            ),
            const SizedBox(width: 5),
            InkWell(
              onTap: () {
                _controller.handSMS(callLog!.phoneNumber);
              },
              borderRadius: BorderRadius.circular(29.0),
              child: _buildBtnColumnText(
                  assetsImage: Assets.iconsMessger, title: 'Nhắn tin'),
            ),
            const SizedBox(width: 5),
          ],
        ),
        const SizedBox(height: 20),
        Container(color: AppColor.colorGreyBackground, height: 8)
      ],
    );
  }

  Widget _buildInformation(Size size, List<CallLog> callLogs) {
    callLog ??= callLogs.first;
    var ringing = callLog!.timeRinging ?? 0;
    print("syncAt ${callLog!}");
    final date =
        DateTime.fromMillisecondsSinceEpoch(callLog!.startAt).toLocal();
    var time = DateFormat("HH:mm dd-MM-yyyy").format(date);
    lstCustomData = callLogs
        .where((element) =>
            element.customData != null && element.customData!.isNotEmpty)
        .map((e) {
          Map<String, dynamic> json = jsonDecode(e.customData!);
          return CustomData.fromMap(json);
        })
        .toList()
        .distinctByProperty((e) => e.id);
    return Column(
      children: [
        ExpansionBlock(
          initiallyExpanded: true,
          title: 'Thông tin',
          assetsIcon: Assets.iconsInfo,
          items: [
            RowTitleValueWidget(title: 'Ngày gọi', value: time),
            const SizedBox(height: 16),
            RowTitleValueWidget(
              title: 'Gọi từ',
              value: callLog!.method == CallMethod.stringee ? 'APP' : 'SIM',
            ),
            const SizedBox(height: 16),
            RowTitleValueWidget(
              title: 'Thời lượng',
              value: (callLog!.timeRinging != null && callLog!.timeRinging! < 0)
                  ? '0 s'
                  : '${callLog!.answeredDuration ?? 0} s',
            ),
            const SizedBox(height: 16),
            RowTitleValueWidget(
              title: 'Thời điểm đồng bộ',
              value: callLog!.syncAt != null
                  ? ddMMYYYYTimeSlashFormat.format(
                      DateTime.fromMillisecondsSinceEpoch(callLog!.syncAt!)
                          .toLocal())
                  : "",
            ),
            const SizedBox(height: 16),
            callLog!.callLogValid == CallLogValid.invalid
                ? RowTitleValueWidget(
                    title:
                        'Đổ chuông', // Todo: return 1 - Out và 2 - In, WTF ngược
                    value: callLog!.getRingingText(),
                    isShowInvalid: true)
                : const RowTitleValueWidget(
                    title: 'Đổ chuông', value: '', isShowInvalid: false),
            const SizedBox(height: 16),
          ],
        ),
        Container(color: AppColor.colorGreyBackground, height: 8),
        ExpansionBlock(
            title: 'Các cuộc gọi khác',
            assetsIcon: Assets.iconsIconCall,
            items: [
              LoadMoreListView(
                  callLogs: _controller.callLogDetailSv.value,
                  callLog: callLog!,
                  size: size,
                  onChangeValue: (value) {
                    callLog = value;
                    setState(() {});
                  }),
            ]),
        Container(color: AppColor.colorGreyBackground, height: 8),
        ExpansionBlock(
          title: 'Đơn hàng',
          assetsIcon: Assets.iconsOrder,
          items: [
            Container(
              margin: const EdgeInsets.symmetric(horizontal: 16),
              child: Row(
                children: [
                  SizedBox(
                    width: size.width * 0.6,
                    child: Text('Mã đơn',
                        style: FontFamily.demiBold(
                            size: 12, color: AppColor.colorGreyText)),
                  ),
                  Text('Loại',
                      style: FontFamily.demiBold(
                          size: 12, color: AppColor.colorGreyText)),
                ],
              ),
            ),
            const SizedBox(height: 8),
            Container(height: 1, color: AppColor.colorGreyBackground),
            const SizedBox(height: 8),
            lstCustomData.isNotEmpty
                ? Column(
                    children: [
                      ...lstCustomData.map((e) => _buildText60(
                          title: e.id ?? "", value: e.type ?? "", size: size))
                    ],
                  )
                : Text('Không có thông tin đơn hàng',
                    style: FontFamily.normal(
                        size: 12, color: AppColor.colorGreyText)),
            const SizedBox(height: 8),
          ],
        ),
        Container(color: AppColor.colorGreyBackground, height: 8),
      ],
    );
  }

  @override
  void initState() {
    WidgetsBinding.instance.addObserver(this);
    super.initState();
    List<CallLog> callLogs = Get.arguments;
    callLog ??= callLogs.first;
    _controller.loadDetail(callLog!.phoneNumber);
  }

  @override
  void didChangeAppLifecycleState(AppLifecycleState state) {
    if (state == AppLifecycleState.resumed) {}
  }

  @override
  Widget build(BuildContext context) {
    final Size sizeWidth = MediaQuery.of(context).size;
    List<CallLog> callLogs = Get.arguments;
    return Scaffold(
      backgroundColor: Colors.white,
      body: SafeArea(
        child: Container(
          padding: const EdgeInsets.symmetric(vertical: 8),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.center,
            children: [
              Row(
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                children: [
                  Row(
                    children: [
                      const SizedBox(width: 16),
                      Text('Chi tiết cuộc gọi',
                          style: FontFamily.demiBold(size: 20))
                    ],
                  ),
                  Row(
                    children: [
                      InkWell(
                          onTap: () {
                            Get.back();
                          },
                          child: const Icon(Icons.close, size: 20)),
                      const SizedBox(width: 16),
                    ],
                  )
                ],
              ),
              const SizedBox(height: 8),
              Expanded(
                  child: SingleChildScrollView(
                      child: Column(children: [
                _buildHeader(callLogs),
                Obx(() {
                  return _buildInformation(sizeWidth, callLogs);
                })
              ])))
            ],
          ),
        ),
      ),
    );
  }
  // String getRingingText(CallLog callLog) {
  //   if (callLog.callLogValid == CallLogValid.valid ||
  //       callLog.type == CallType.incomming ||
  //       (callLog.answeredDuration != null && callLog.answeredDuration! > 0)) return "";
  //   var ringing = callLog.timeRinging != null ? (callLog.timeRinging! / 1000) : 0;
  //
  //   if (callLog.endedBy != EndBy.rider) {
  //     if (ringing <= 10) {
  //       return 'Tài xế ngắt sau ${ringing.round()}s';
  //     }
  //     if (ringing > 8.5 && ringing < 10) {
  //       return 'Tài xế ngắt sau 9s';
  //     }
  //   } else if (ringing < 3) {
  //     return 'Cuộc gọi tắt sau ${ringing.round()}s';
  //   }
  //
  //   return "";
  // }
}
