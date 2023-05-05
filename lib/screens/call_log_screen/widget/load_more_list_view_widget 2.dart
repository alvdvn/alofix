import 'package:base_project/common/themes/colors.dart';
import 'package:base_project/config/fonts.dart';
import 'package:base_project/screens/call_log_screen/widget/item_call_log_widget.dart';
import 'package:flutter/material.dart';

import '../../../models/history_call_log_model.dart';

class LoadMoreListView extends StatefulWidget {

  const LoadMoreListView(
      {super.key,
        required this.callLog,
        required this.callLogState,
        required this.size,
        required this.onChangeValue
        });
  final List<HistoryCallLogModel> callLog;
  final HistoryCallLogModel? callLogState;
  final Size size;
  final Function(HistoryCallLogModel?) onChangeValue;

  @override
  State<StatefulWidget> createState() {
    return _LoadMoreListViewState();
  }
}

class _LoadMoreListViewState extends State<LoadMoreListView> {
  int itemCount = 4;
  @override
  Widget build(BuildContext context) {
    int maxLength = widget.callLog.length;
    if (widget.callLog.length == 1) {
      return Text('Danh sách trống',
          style: FontFamily.normal(size: 12, color: AppColor.colorGreyText));
    }
    return Column(children: [
      ListView.builder(
        shrinkWrap: true,
        itemCount: maxLength < 4 ? maxLength : itemCount,
        physics: const NeverScrollableScrollPhysics(),
        itemBuilder: (BuildContext context, int index) {
          var item = widget.callLog[index];
          return item.id == widget.callLogState?.id
              ? const SizedBox()
              : ItemCallLogWidget(
                  callLog: item,
                  onChange: (value) {
                    widget.onChangeValue(value);
                    setState(() {});
                  },
                );
        },
      ),
      GestureDetector(
          onTap: () {
            setState(() {
              if (maxLength == itemCount) {
                itemCount = 4;
              } else {
                itemCount = itemCount <= maxLength - 3 ? itemCount + 3 : maxLength;
              }
            });
          },
          child: maxLength > itemCount
              ? SizedBox(
                  width: widget.size.width,
                  child: Container(
                    alignment: Alignment.center,
                    child: Column(
                      children: [
                        Container(
                            height: 1, color: AppColor.colorGreyBackground),
                        Container(
                          margin: const EdgeInsets.symmetric(vertical: 8),
                          child: Row(
                            mainAxisAlignment: MainAxisAlignment.center,
                            children: [
                              Text('Hiển thị thêm',
                                  style: FontFamily.demiBold(
                                      size: 14, color: AppColor.colorGreyText)),
                              const Icon(Icons.keyboard_arrow_down,
                                  color: AppColor.colorGreyText)
                            ],
                          ),
                        ),
                      ],
                    ),
                  ))
              : maxLength == itemCount && maxLength > 4 ?
          SizedBox(
              width: widget.size.width,
              child: Container(
                alignment: Alignment.center,
                child: Column(
                  children: [
                    Container(
                        height: 1, color: AppColor.colorGreyBackground),
                    Container(
                      margin: const EdgeInsets.symmetric(vertical: 8),
                      child: Row(
                        mainAxisAlignment: MainAxisAlignment.center,
                        children: [
                          Text('Ẩn bớt',
                              style: FontFamily.demiBold(
                                  size: 14, color: AppColor.colorGreyText)),
                          const Icon(Icons.keyboard_arrow_up,
                              color: AppColor.colorGreyText)
                        ],
                      ),
                    ),
                  ],
                ),
              ))
          :const SizedBox()),
    ]);
  }
}
