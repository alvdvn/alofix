import 'package:base_project/common/themes/colors.dart';
import 'package:base_project/config/fonts.dart';
import 'package:flutter/material.dart';

class ButtonPhoneCustomWidget extends StatelessWidget {
  const ButtonPhoneCustomWidget({Key? key, required this.title})
      : super(key: key);
  final String title;

  @override
  Widget build(BuildContext context) {
    return Container(
      width: 80,
      height: 80,
      decoration: BoxDecoration(
        borderRadius: BorderRadius.circular(45),
        color: Colors.white,
      ),
      child: Center(
        child: Text(title,
            style: FontFamily.demiBold(size: 32, color: AppColor.colorBlack)),
      ),
    );
  }
}


class AnimatedPhoneButton extends StatefulWidget {
  final String text;
  final Function onPressed;

  const AnimatedPhoneButton({Key? key, required this.text, required this.onPressed})
      : super(key: key);

  @override
  State<StatefulWidget> createState() => _AnimatedButtonState();
}

class _AnimatedButtonState extends State<AnimatedPhoneButton> {
  bool _isPressed = false;

  @override
  Widget build(BuildContext context) {
    return GestureDetector(
      onTapDown: (_) {
        setState(() {
          _isPressed = true;
        });
      },
      onTapUp: (_) {
        setState(() {
          _isPressed = false;
        });
        widget.onPressed();
      },
      onTapCancel: () {
        setState(() {
          _isPressed = false;
        });
      },
      child: AnimatedContainer(
        width: 80,
        height: 80,
        duration: const Duration(milliseconds: 150),
        decoration: BoxDecoration(
          borderRadius: BorderRadius.circular(45),
          color: Colors.white,
          border: Border.all(
            color: _isPressed ? AppColor.colorRedMain : AppColor.colorGrey,
            width: 1,
          ),
        ),
        padding: widget.text == "*" ? const EdgeInsets.symmetric(horizontal: 20, vertical: 25) : const EdgeInsets.symmetric(horizontal: 20, vertical: 10),
        child: Center(
          child: Text(
            widget.text,
            style: FontFamily.demiBold(size: 32, color: AppColor.colorBlack)
            // const TextStyle(
            //   fontSize: 32,
            //   fontFamily: FontFamily.fontFamily,
            //   color: AppColor.colorBlack,
            // ),
          ),
        ),
      ),
    );
  }
}

