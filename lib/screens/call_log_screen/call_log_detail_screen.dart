import 'package:base_project/common/themes/colors.dart';
import 'package:base_project/common/utils/global_app.dart';
import 'package:base_project/common/widget/empty_widget.dart';
import 'package:base_project/common/widget/expansion_detail_block.dart';
import 'package:base_project/common/widget/hide_widget.dart';
import 'package:base_project/common/widget/row_value_widget.dart';
import 'package:base_project/common/widget/show_more_widget.dart';
import 'package:base_project/config/fonts.dart';
import 'package:base_project/generated/assets.dart';
import 'package:base_project/models/history_call_log_app_model.dart';
import 'package:base_project/models/history_call_log_model.dart';
import 'package:flutter/material.dart';
import 'package:flutter_svg/svg.dart';
import 'package:get/get.dart';
import 'package:intl/intl.dart';

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
                    const SizedBox(
                      width: 16,
                    ),
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
    return Column(
      children: [
        SvgPicture.asset(assetsImage,
            width: 25, height: 25, color: AppColor.colorBlack),
        const SizedBox(height: 8),
        Text(
          title,
          style: FontFamily.normal(size: 10),
        )
      ],
    );
  }

  Widget _buildHeader(HistoryCallLogModel callLog) {
    return Column(
      children: [
        const SizedBox(height: 30),
        CircleAvatar(
            radius: 40,
            backgroundColor: AppColor.colorGreyBackground,
            child: Image.asset(Assets.imagesImgNjv512h, width: 40, height: 40)),
        const SizedBox(height: 16),
        Text('${callLog.phoneNumber}', style: FontFamily.demiBold(size: 18)),
        // Row(
        //   mainAxisAlignment: MainAxisAlignment.center,
        //   children: [
        //     Text('${callLog.user?.phoneNumber}',
        //         style: FontFamily.regular(size: 14)),
        //     const SizedBox(width: 8),
        //     callLog.method == 2
        //         ? SvgPicture.asset(Assets.imagesSim, width: 12, height: 12)
        //         : Image.asset(Assets.imagesImageNjv, width: 16, height: 16)
        //   ],
        // ),
        // const SizedBox(height: 8),
        Row(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            ItemStatusCall(
                callType: callLog.type ?? 1,
                answeredDuration: callLog.answeredDuration ?? 0),
          ],
        ),
        const SizedBox(height: 25),
        Row(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            if (callLog.method == 1)
              Row(
                children: [
                  InkWell(
                    child: _buildBtnColumnText(
                        assetsImage: Assets.iconsPlayCircle,
                        title: 'File ghi âm'),
                    onTap: () {
                      showBottomSheetModel(callLog);
                    },
                  ),
                  const SizedBox(width: 32),
                ],
              ),
            InkWell(
              onTap: () {
                _controller.handCall(callLog.phoneNumber ?? "");
              },
              child: _buildBtnColumnText(
                  assetsImage: Assets.iconsIconCall, title: 'Gọi điện'),
            ),
            const SizedBox(width: 32),
            InkWell(
              onTap: () {
                _controller.handSMS(callLog.phoneNumber ?? "");
              },
              child: _buildBtnColumnText(
                  assetsImage: Assets.iconsMessger, title: 'Nhắn tin'),
            ),
          ],
        ),
        const SizedBox(height: 20),
        Container(color: AppColor.colorGreyBackground, height: 8)
      ],
    );
  }

  handShowItemCallLog3({required List<HistoryCallLogModel> callLog}) {
    if (callLog.length > 3) {
      for (var i = 0; i < 3; i++) {
        callLogShow3Item.add(callLog[i]);
      }
    }
  }

  handleShowMore({required List<HistoryCallLogModel> callLog}) {
    if(callLog.length >= callLogShow3Item.length) {
      for (var i = callLogShow3Item.length; i < 3; i++) {
        callLogShow3Item.add(callLog[i]);
      }
    }
  }

  handleHideCallLog({required List<HistoryCallLogModel> callLog}) {
    callLogShow3Item = [];
    if (callLog.length > 3) {
      for (var i = 0; i < 3; i++) {
        callLogShow3Item.add(callLog[i]);
      }
    }
    setState(() {});
  }

  Widget _buildListCallLog({required List<HistoryCallLogModel> callLog}) {
    handShowItemCallLog3(callLog: callLog);
    if (callLog.isEmpty) {
      return const EmptyWidget();
    }
    return Column(
      children: [
        ...callLogShow3Item.map((e) => ItemCallLogWidget(callLog: e)),
        if (callLog.length > 3)
          if (callLogShow3Item.length == 3)
            GestureDetector(
                child: const ShowMoreWidget(),
                onTap: () {
                  callLogShow3Item = callLog;
                  setState(() {});
                })
          else
            GestureDetector(
                child: const HideWidget(),
                onTap: () {
                  handleHideCallLog(callLog: callLog);
                  setState(() {});
                })
      ],
    );
  }

  Widget _buildInformation(Size size, HistoryCallLogAppModel callLogApp) {
    final callLog = callLogApp.logs!.first;
    final date = DateTime.parse(callLog.startAt ?? '').toLocal();
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
              value: callLog.method == 1 ? 'APP' : 'SIM',
            ),
            const SizedBox(height: 16),
            RowTitleValueWidget(
              title: 'Thời lượng',
              value: '${callLog.answeredDuration} s',
            ),
            const SizedBox(height: 16),
            RowTitleValueWidget(
              title: 'Đổ chuông',
              value: '${callLog.timeRinging ?? 0}s',
            ),
            const SizedBox(height: 16),
            RowTitleValueWidget(
              title: 'Thời điểm đồng bộ',
              value: ddMMYYYYTimeSlashFormat
                  .format(DateTime.parse(callLog.syncAt ?? '')),
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
            if (callLogApp.logs?.first.customData == null)
              Column(
                children: [
                  _buildText60(
                      title: callLogApp.logs?.first.customData?.idTrack ?? '',
                      value: 'Tracking',
                      size: size),
                  const SizedBox(height: 8),
                  const ShowMoreWidget(),
                ],
              )
            else
              const Text('Không có thông tin đơn hàng'),
            const SizedBox(height: 8),
          ],
        ),
        Container(color: AppColor.colorGreyBackground, height: 8),
      ],
    );
  }

  @override
  Widget build(BuildContext context) {
    final Size sizeWidth = MediaQuery.of(context).size;
    HistoryCallLogAppModel args = Get.arguments;
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
                  _buildHeader(args.logs!.first),
                  _buildInformation(sizeWidth, args)
                ]),
              ))
            ],
          ),
        ),
      ),
    );
  }
}
