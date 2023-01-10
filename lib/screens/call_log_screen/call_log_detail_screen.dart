import 'package:base_project/common/themes/colors.dart';
import 'package:base_project/common/widget/expansion_detail_block.dart';
import 'package:base_project/common/widget/row_value_widget.dart';
import 'package:base_project/config/fonts.dart';
import 'package:base_project/generated/assets.dart';
import 'package:call_log/call_log.dart';
import 'package:flutter/material.dart';
import 'package:flutter_svg/svg.dart';
import 'package:get/get.dart';

class CallLogDetailScreen extends StatefulWidget {
  const CallLogDetailScreen({Key? key}) : super(key: key);

  @override
  State<CallLogDetailScreen> createState() => _CallLogDetailScreenState();
}

class _CallLogDetailScreenState extends State<CallLogDetailScreen> {


  Widget _buildItemStatusCall(CallType callType) {
    switch (callType) {
      case CallType.outgoing:
        return Row(
          children: [
            SvgPicture.asset(Assets.iconsArrowUpRight),
            const SizedBox(width: 8),
            Text('Thành công',
                style: FontFamily.Regular(size: 12, color: Colors.green))
          ],
        );
      case CallType.missed:
        return Row(
          children: [
            SvgPicture.asset(
              Assets.iconsArrowUpRight,
              color: AppColor.colorRedMain,
            ),
            const SizedBox(width: 8),
            Text(
              'Gọi nhỡ',
              style: FontFamily.Regular(size: 12, color: AppColor.colorRedMain),
            )
          ],
        );
    }
    return Row(
      children: [
        SvgPicture.asset(Assets.iconsArrowUpRight),
        const SizedBox(width: 8),
        Text(
          'Thành công',
          style: FontFamily.Regular(size: 12, color: Colors.green),
        )
      ],
    );
  }

  Widget _buildBtnColumnText({required String assetsImage, required String title}) {
    return Column(
      children: [
        SvgPicture.asset(assetsImage,
            width: 18, height: 18, color: AppColor.colorBlack),
        Text(
          title,
          style: FontFamily.normal(size: 10),
        )
      ],
    );
  }

  Widget _buildHeader() {
    return Column(
      children: [
        const SizedBox(height: 25),
        Row(
          mainAxisAlignment: MainAxisAlignment.spaceBetween,
          children: [
            Row(
              children: [
                const SizedBox(width: 16),
                Text('Chi tiết cuộc gọi', style: FontFamily.DemiBold(size: 20))
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
        const SizedBox(height: 30),
        CircleAvatar(
            radius: 40,
            backgroundColor: AppColor.colorGreyBackground,
            child: Image.asset(Assets.imagesImageNjv)),
        const SizedBox(height: 16),
        Row(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Text('0965988698', style: FontFamily.DemiBold(size: 14)),
            const SizedBox(width: 8),
            SvgPicture.asset(Assets.imagesSim, width: 12, height: 12)
          ],
        ),
        const SizedBox(height: 8),
        Row(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            _buildItemStatusCall(CallType.outgoing),
            const SizedBox(width: 8),
            Text('*',style: FontFamily.normal(size: 12, color: AppColor.colorGreyText)),
            const SizedBox(width: 8),
            Text(
              '15:30 24/11/22',
              style: FontFamily.normal(size: 12, color: AppColor.colorGreyText),
            )
          ],
        ),
        const SizedBox(height: 25),
        Row(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            _buildBtnColumnText(
                assetsImage: Assets.iconsPlayCircle, title: 'File ghi âm'),
            const SizedBox(width: 32),
            _buildBtnColumnText(
                assetsImage: Assets.iconsIconCall, title: 'Gọi điện'),
            const SizedBox(width: 32),
            _buildBtnColumnText(
                assetsImage: Assets.iconsMessger, title: 'Nhắn tin'),
          ],
        ),
        const SizedBox(height: 20),
        Container(
          color: AppColor.colorGreyBackground,
          height: 8,
        )
      ],
    );
  }

  Widget _buildInformation() {
    return Container(
      child: Column(
        children: [
          ExpansionBlock(
            title: 'Thông tin',
            items: [
              RowTitleValueWidget(title: 'Ngày gọi', value: '10:30 21/02/2022',)
            ],
          )
        ],
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.white,
      body: SingleChildScrollView(
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.center,
          children: [_buildHeader(), _buildInformation()],
        ),
      ),
    );
  }
}
