import 'dart:async';

import 'package:base_project/common/themes/colors.dart';
import 'package:base_project/common/widget/button_phone_custom_widget.dart';
import 'package:base_project/config/fonts.dart';
import 'package:base_project/generated/assets.dart';
import 'package:base_project/screens/call_log_screen/call_log_controller.dart';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:get/get.dart';

import '../../services/local/app_share.dart';
import '../home/home_controller.dart';
import 'call_controller.dart';
class CallScreen extends StatefulWidget {
  const CallScreen({Key? key}) : super(key: key);

  @override
  State<CallScreen> createState() => _CallScreenState();
}

class _CallScreenState extends State<CallScreen> with WidgetsBindingObserver {
  CallController callController = Get.put(CallController());
  CallLogController callLogController = Get.put(CallLogController());
  final TextEditingController _controller = TextEditingController();
  final ScrollController _scrollController = ScrollController();
  final HomeController homeController = Get.put(HomeController());

  // late TextEditingController _controller;
  // late TextSelection _selection;

  @override
  void initState() {
    WidgetsBinding.instance.addObserver(this);
    super.initState();
    // _controller = TextEditingController(text: callController.phoneNumber.value);
  }

  @override
  void dispose() {
    WidgetsBinding.instance.removeObserver(this);
    super.dispose();
  }
  @override
  void didChangeDependencies() {
    // callController.phoneNumber.value ="";
    // TODO: implement didChangeDependencies
    super.didChangeDependencies();
  }

  Widget _btnCall() {
    return GestureDetector(
        onTap: () async {
          if (_controller.text.isNotEmpty) {
            callLogController.secondCall = 0;
            callLogController.handCall(_controller.text.toString());
            Future.delayed(const Duration(seconds: 3)).then((val) {
              setState(() {
                callController.phoneNumber.value = '';
                _controller.text = '';
                _controller.selection = TextSelection.collapsed(offset: _controller.text.length);
              });
            });
          }
        },
        child: Stack(
          children: [
            Align(
                alignment: Alignment.center,
                child: Image.asset(Assets.imagesImgCallAccept,
                    width: 90, height: 90)),
            Container(
              margin: const EdgeInsets.fromLTRB(30, 0, 0, 0),
              child: const Align(
                alignment: Alignment.center,
                child: SizedBox(
                    height: 90,
                    child: Icon(Icons.call_sharp, color: Colors.white, size: 30)),
              ),
            ),
          ],
        ));
  }

  Widget _buildBtnClear({bool showIcon = true}) {
    return Container(
      width: 80,
      height: 80,
      decoration: BoxDecoration(
        borderRadius: BorderRadius.circular(40),
        color: AppColor.colorGreyBackground,
      ),
      child: showIcon
          ? const Center(
        child: Icon(Icons.backspace_sharp),
      )
          : Container(),
    );
  }

  Widget _buildKeyBoard() {
    return Column(
      children: [
        Row(
          mainAxisSize: MainAxisSize.max,
          mainAxisAlignment: MainAxisAlignment.spaceBetween,
          children: [
            const SizedBox(width: 30),
            AnimatedPhoneButton(
                text: '1',
                onPressed: () => _insertText("1")),
            AnimatedPhoneButton(
                text: '2',
                onPressed: () => _insertText("2")),
            AnimatedPhoneButton(
                text: '3',
                onPressed: () => _insertText("3")),
            const SizedBox(width: 30),
          ],
        ),
        const SizedBox(height: 12),
        Row(
          mainAxisSize: MainAxisSize.max,
          mainAxisAlignment: MainAxisAlignment.spaceBetween,
          children: [
            const SizedBox(width: 30),
            AnimatedPhoneButton(
                text: '4',
                onPressed: () => _insertText("4")),
            AnimatedPhoneButton(
                text: '5',
                onPressed: () => _insertText("5")),
            AnimatedPhoneButton(
                text: '6',
                onPressed: () => _insertText("6")),
            const SizedBox(width: 30),
          ],
        ),
        const SizedBox(height: 12),
        Row(
          mainAxisSize: MainAxisSize.max,
          mainAxisAlignment: MainAxisAlignment.spaceBetween,
          children: [
            const SizedBox(width: 30),
            AnimatedPhoneButton(
                text: '7',
                onPressed: () => _insertText("7")),
            AnimatedPhoneButton(
                text: '8',
                onPressed: () => _insertText("8")),
            AnimatedPhoneButton(
                text: '9',
                onPressed: () => _insertText("9")),
            const SizedBox(width: 30),
          ],
        ),
        const SizedBox(height: 12),
        Row(
          mainAxisSize: MainAxisSize.max,
          mainAxisAlignment: MainAxisAlignment.spaceBetween,
          children: [
            const SizedBox(width: 30),
            AnimatedPhoneButton(
                text: '*',
                onPressed: () => _insertText("*")),
            AnimatedPhoneButton(
                text: '0',
                onPressed: () => _insertText("0")),
            AnimatedPhoneButton(
                text: '#',
                onPressed: () => _insertText("#")),
            const SizedBox(width: 30),
          ],
        ),
        const SizedBox(height: 24),
        Row(
          mainAxisSize: MainAxisSize.max,
          mainAxisAlignment: MainAxisAlignment.spaceBetween,
          children: [
            const SizedBox(width: 30),
            _buildBtnClear(showIcon: false),
            _btnCall(),
            GestureDetector(
                onTap: _backspace,
                child: _buildBtnClear()),
            const SizedBox(width: 30),
          ],
        )

      ],
    );
  }

  Widget _buildDisplay(Size size) {
    return SizedBox(
      height: 80,
      child: Row(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          const SizedBox(width: 16),
          SizedBox(
              width: size.width - 32,
              height: 100,
              child: TextFormField(
                  style: FontFamily.demiBold(size: 30, lineHeight: 1.5),
                  controller: _controller,
                  keyboardType: TextInputType.none,
                  cursorColor: AppColor.colorRedMain,
                  cursorWidth: 1,
                  textAlign: TextAlign.center,
                  maxLines: 1,
                  scrollController: _scrollController,
                  inputFormatters: [
                    FilteringTextInputFormatter.allow(
                      RegExp("[0-9*#]"),
                    ),
                  ],
                  // onTap: _controller.selectAll,
                  // onChanged: (String value) {
                  //   print("onChanged $value");
                  //   // _insertText(value);
                  //   // _controller.text = value;
                  //   // _controller.selection = TextSelection.collapsed(offset: _controller.text.length);
                  //   // _scrollController.jumpTo(_scrollController.position.maxScrollExtent);
                  // },
                  decoration: InputDecoration(
                      labelText: '',
                      labelStyle:
                      FontFamily.regular(color: AppColor.colorHintText),
                      border: InputBorder.none))),
          const SizedBox(width: 16),
        ],
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    final Size size = MediaQuery.of(context).size;
    return Scaffold(
      backgroundColor: AppColor.colorGreyBackground,
      body: SafeArea(
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            const SizedBox(height: 32),
            _buildDisplay(size),
            const SizedBox(height: 16),
            _buildKeyBoard(),
          ],
        ),
      ),
    );
  }
  void _insertText(String text) {
    int position = _controller.selection.base.offset; // gets position of cursor
    var value = _controller.text; // text in our textfield

    if (value.length > 19) {
      return;
    }

    int start = _controller.selection.baseOffset <
        _controller.selection.extentOffset
        ? _controller.selection.baseOffset
        : _controller.selection.extentOffset;
    int end = _controller.selection.baseOffset >
        _controller.selection.extentOffset
        ? _controller.selection.baseOffset
        : _controller.selection.extentOffset;

    print('LOG: start $start end $end');
    if (value.isNotEmpty) {
      final subStringPhone = (_controller.text + text).substring(0, 2);
      // print('LOG: onPressPhone subStringPhone $subStringPhone');
      if (subStringPhone == '84') {
        final newPhone = (text + _controller.text).replaceRange(0, 2, "0");
        value = newPhone;

        var suffix = value.substring(position, value.length); // 1) suffix: the string
        // from the position of the cursor to the end of the text in the controller
        value = value.substring(0, position) + suffix; // 2) value.substring gets
        // a new string from start of the string in our textfield, appends the new input to our
        // new string and appends the suffix to it.
        _controller.text = value; // 3) set our controller text to the gotten value
        _controller.selection = TextSelection.fromPosition(TextPosition(offset: position)); // 4) update selection
      } else {
        String selectedText = _controller.text.substring(start, end);
        if (selectedText.isNotEmpty) {
          final newPhone = _controller.text.replaceRange(start, end, text);
          value = newPhone;
        } else {
          var suffix = value.substring(position, value.length); // 1) suffix: the string
          // from the position of the cursor to the end of the text in the controller
          value = value.substring(0, position) + text + suffix; // 2) value.substring gets
          // a new string from start of the string in our textfield, appends the new input to our
          // new string and appends the suffix to it.
        }
        _controller.text = value; // 3) set our controller text to the gotten value
        _controller.selection = TextSelection.fromPosition(TextPosition(offset: position + 1)); // 4) update selection
        _scrollController.jumpTo(_scrollController.position.maxScrollExtent);
      }
      // to update our position.
    } else {
      value = _controller.text + text; // 5) appends controller text and new input
      // and assigns to value

      _controller.text = value; // 6) set our controller text to the gotten value
      _controller.selection = TextSelection.fromPosition(const TextPosition(offset: 1)); // 7) since this is the first input
      // set position of cursor to 1, so the cursor is placed at the end
    }
  }
  void _backspace() {
    final text = _controller.text;
    final textSelection = _controller.selection;
    final selectionLength = textSelection.end - textSelection.start;

    // There is a selection.
    if (selectionLength > 0) {
      final newText = text.replaceRange(
        textSelection.start,
        textSelection.end,
        '',
      );
      _controller.text = newText;
      _controller.selection = textSelection.copyWith(
        baseOffset: textSelection.start,
        extentOffset: textSelection.start,
      );
      return;
    }

    // The cursor is at the beginning.
    if (textSelection.start == 0) {
      return;
    }

    // Delete the previous character
    final newStart = textSelection.start - 1;
    final newEnd = textSelection.start;
    final newText = text.replaceRange(
      newStart,
      newEnd,
      '',
    );
    _controller.text = newText;
    _controller.selection = textSelection.copyWith(
      baseOffset: newStart,
      extentOffset: newStart,
    );
  }


}
extension TextEditingControllerExt on TextEditingController {
  void selectAll() {
    if (text.isEmpty) return;
    selection = TextSelection(baseOffset: 0, extentOffset: text.length);
  }
}
