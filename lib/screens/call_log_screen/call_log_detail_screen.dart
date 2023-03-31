import 'package:base_project/common/themes/colors.dart';
import 'package:base_project/common/utils/global_app.dart';
import 'package:base_project/common/widget/empty_widget.dart';
import 'package:base_project/common/widget/expansion_detail_block.dart';
import 'package:base_project/common/widget/hide_widget.dart';
import 'package:base_project/common/widget/row_value_widget.dart';
import 'package:base_project/common/widget/show_more_widget.dart';
import 'package:base_project/config/fonts.dart';
import 'package:base_project/generated/assets.dart';
import 'package:base_project/models/custom_data_model.dart';
import 'package:base_project/models/history_call_log_app_model.dart';
import 'package:base_project/models/history_call_log_model.dart';
import 'package:flutter/material.dart';
import 'package:flutter_svg/svg.dart';
import 'package:get/get.dart';
import 'package:intl/intl.dart';
import 'package:url_launcher/url_launcher.dart';
import 'call_log_controller.dart';
import 'widget/item_call_log_widget.dart';
import 'widget/item_status_call.dart';

class CallLogDetailScreen extends StatefulWidget {
  const CallLogDetailScreen({Key? key}) : super(key: key);

  @override
  State<CallLogDetailScreen> createState() => _CallLogDetailScreenState();
}

class _CallLogDetailScreenState extends State<CallLogDetailScreen> {
  final _controller = Get.put(CallLogController());
  List<HistoryCallLogModel> callLogShow3Item = [];
  List<CustomDataModel> lstCustomData = [];
  int lengthCount = 0;
  HistoryCallLogModel? callLogState;
  String deepLinkAlo1 = ' njvcall://vn.etelecom.njvcall/call/';

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

  void showBottomSheetModel(HistoryCallLogModel callLog) {
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
                      callType: callLog.type ?? 1,
                      answeredDuration: callLog.answeredDuration ?? 0),
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
              Row(
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                children: [
                  Row(
                    children: const [
                      SizedBox(width: 22),
                      Text('0:08:32'),
                    ],
                  ),
                  Row(
                    children: const [
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

  Widget _buildHeader(HistoryCallLogAppModel callLogApp) {
    callLogState ??= callLogApp.logs!.first;
    return Column(
      children: [
        const SizedBox(height: 30),
        CircleAvatar(
            radius: 40,
            backgroundColor: AppColor.colorGreyBackground,
            child: Image.asset(Assets.imagesImgNjv512h, width: 40, height: 40)),
        const SizedBox(height: 16),
        Text('${callLogState?.phoneNumber}',
            style: FontFamily.demiBold(size: 18)),
        Row(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            ItemStatusCall(
                callType: callLogState?.type ?? 1,
                answeredDuration: callLogState?.answeredDuration ?? 0),
          ],
        ),
        const SizedBox(height: 10),
        Row(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            if (callLogState?.method == 1)
              InkWell(
                borderRadius: BorderRadius.circular(29.0),
                child: _buildBtnColumnText(
                    assetsImage: Assets.iconsPlayCircle, title: 'File ghi âm'),
                onTap: () {
                  // showBottomSheetModel(callLogState?.);
                },
              ),
            InkWell(
              onTap: () {
                _controller.handCall(callLogState?.phoneNumber ?? "");
              },
              borderRadius: BorderRadius.circular(29.0),
              child: _buildBtnColumnText(
                  assetsImage: Assets.iconsIconCall, title: 'Gọi điện'),
            ),
            const SizedBox(width: 5),
            InkWell(
              onTap: () {
                _controller.handSMS(callLogState?.phoneNumber ?? "");
              },
              borderRadius: BorderRadius.circular(29.0),
              child: _buildBtnColumnText(
                  assetsImage: Assets.iconsMessger, title: 'Nhắn tin'),
            ),
            const SizedBox(width: 5),
            InkWell(
              onTap: () {
                if (lstCustomData.isNotEmpty) {
                  deepLinkAlo1 =
                      '$deepLinkAlo1${callLogState?.phoneNumber}?ID=${lstCustomData.first.id}&routeID=${lstCustomData.first.routeId}&type=${lstCustomData.first.type}';
                }
                deepLinkAlo1 = '$deepLinkAlo1${callLogState?.phoneNumber}';
                launchUrl(Uri.parse(deepLinkAlo1),
                    mode: LaunchMode.externalApplication);
              },
              borderRadius: BorderRadius.circular(29.0),
              child: _buildBtnColumnText(
                  assetsImage: Assets.iconsDot, title: 'Gọi alo 1'),
            ),
          ],
        ),
        const SizedBox(height: 20),
        Container(color: AppColor.colorGreyBackground, height: 8)
      ],
    );
  }

  Widget _buildListCallLog({required List<HistoryCallLogModel> callLog}) {
    if (callLog.length == 1) {
      return Text('Danh sách trống',
          style: FontFamily.normal(size: 12, color: AppColor.colorGreyText));
    }
    return Column(
      children: [
        ...callLog.map((e) => e.id == callLogState?.id
            ? const SizedBox()
            : ItemCallLogWidget(
                callLog: e,
                onChange: (value) {
                  callLogState = value;
                  setState(() {});
                },
              )),
      ],
    );
  }

  Widget _buildInformation(Size size, HistoryCallLogAppModel callLogApp) {
    callLogState ??= callLogApp.logs!.first;
    final date = DateTime.parse(callLogState?.startAt ?? '').toLocal();
    var time = DateFormat("HH:mm dd-MM-yyyy").format(date);
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
              value: callLogState?.method == 1 ? 'APP' : 'SIM',
            ),
            const SizedBox(height: 16),
            RowTitleValueWidget(
              title: 'Thời lượng',
              value: '${callLogState?.answeredDuration} s',
            ),
            const SizedBox(height: 16),
            RowTitleValueWidget(
              title: 'Đổ chuông',
              value: '${callLogState?.timeRinging ?? 0}s',
            ),
            const SizedBox(height: 16),
            RowTitleValueWidget(
              title: 'Thời điểm đồng bộ',
              value: ddMMYYYYTimeSlashFormat
                  .format(DateTime.parse(callLogState?.syncAt ?? '').toLocal()),
            ),
            // const RowTitleValueWidget(
            //   title: 'Cước phí',
            //   value: '2.000đ',
            // ),
            // const SizedBox(height: 16),
            // const RowTitleValueWidget(
            //   title: 'Bên tắt máy',
            //   value: 'Người nhận',
            // ),
            // const SizedBox(height: 16),
            // const RowTitleValueWidget(
            //   title: 'Lý do ngắt máy',
            //   value: 'Hoàn thành',
            // ),
            const SizedBox(height: 16),
          ],
        ),
        Container(color: AppColor.colorGreyBackground, height: 8),
        ExpansionBlock(
          title: 'Các cuộc gọi khác',
          assetsIcon: Assets.iconsIconCall,
          items: [_buildListCallLog(callLog: callLogApp.logs ?? [])],
        ),
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
                          title: e.id ?? '', value: e.type ?? '', size: size))
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

  _handlerCustom({required HistoryCallLogAppModel callLogApp}) {
    lstCustomData = [];
    List<CustomDataModel> lstCustomDataTemp = [];
    for (var e in callLogApp.logs ?? []) {
      if (e.customData?.id != null) {
        lstCustomDataTemp.add(CustomDataModel(
            id: e.customData?.id,
            routeId: e.customData?.routeId,
            phoneNumber: e.customData?.phoneNumber,
            type: e.customData?.type));
      }
    }
    var lst = <String>{};
    lstCustomData =
        lstCustomDataTemp.where((item) => lst.add(item.id ?? '')).toList();
    setState(() {});
  }

  @override
  Widget build(BuildContext context) {
    final Size sizeWidth = MediaQuery.of(context).size;
    HistoryCallLogAppModel args = Get.arguments;
    _handlerCustom(callLogApp: args);
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
                            _controller.initData();
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
                _buildHeader(args),
                _buildInformation(sizeWidth, args)
              ])))
            ],
          ),
        ),
      ),
    );
  }
}
