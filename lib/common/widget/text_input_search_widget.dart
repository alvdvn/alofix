import 'package:base_project/common/themes/colors.dart';
import 'package:base_project/config/fonts.dart';
import 'package:base_project/screens/call_log_screen/call_log_controller.dart';
import 'package:flutter/material.dart';
import 'package:get/get.dart';

class TextInputSearchWidget extends StatefulWidget {
  final TextEditingController controller;
  final String labelHint;
  final bool isDisable;
  final bool hideClose;
  final Function(String?)? onChange;
  final ValueChanged<String>? onSubmit;

  const TextInputSearchWidget(
      {Key? key,
      required this.controller,
      required this.labelHint,
      this.isDisable = false,
      this.onChange,
      this.onSubmit,  this.hideClose = false})
      : super(key: key);

  @override
  State<TextInputSearchWidget> createState() => _TextInputSearchWidgetState();
}

class _TextInputSearchWidgetState extends State<TextInputSearchWidget> {
  CallLogController callLogController = Get.put(CallLogController());

  @override
  Widget build(BuildContext context) {
    return Row(
      children: [
        Expanded(
          child: Container(
            padding: const EdgeInsets.symmetric(horizontal: 16),
            decoration: BoxDecoration(
                borderRadius: BorderRadius.circular(4),
                border: Border.all(width: 1, color: AppColor.colorGreyBorder)),
            child: TextField(
                controller: widget.controller,
                enabled: !widget.isDisable,
                textInputAction: TextInputAction.done,
                onSubmitted: widget.onSubmit,
                onChanged: widget.onChange,
                cursorColor: AppColor.colorRedMain,
                style: FontFamily.normal(),
                decoration: InputDecoration(
                    hintText: widget.labelHint,
                    border: InputBorder.none,
                    hintStyle: FontFamily.normal(color: AppColor.colorHintText),
                    enabledBorder: InputBorder.none)),
          ),
        ),
       widget.hideClose == true ? const SizedBox() : Row(
         children: [
           const SizedBox(width: 20),
           InkWell(
             onTap: () {
               setState((){});
               widget.controller.text = callLogController.searchCallLog.value;
               callLogController.onClickClose();
             },
             child: const Icon(Icons.close, size: 25, color: Colors.grey),
           )
         ],
       )
      ],
    );
  }
}
