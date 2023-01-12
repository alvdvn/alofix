import 'package:base_project/common/themes/colors.dart';
import 'package:base_project/common/validator/auth_validator.dart';
import 'package:base_project/config/fonts.dart';
import 'package:flutter/material.dart';

class TextInputCustomWidget extends StatefulWidget {
  const TextInputCustomWidget(
      {super.key,
      required this.controllerText,
      required this.labelText,
      this.showEye,
      this.inputTypeNumber,
      this.showObscureText,
      this.validate, this.enableText});

  final TextEditingController controllerText;
  final String labelText;
  final bool? showEye;
  final bool? inputTypeNumber;
  final bool? showObscureText;
  final Function(String?)? validate;
  final bool? enableText;

  @override
  State<StatefulWidget> createState() {
    return _TextInputCustomWidget();
  }
}

class _TextInputCustomWidget extends State<TextInputCustomWidget> {
  bool showSecurity = true;

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 16),
      decoration: BoxDecoration(
          color: AppColor.colorGreyBackground,
          borderRadius: BorderRadius.circular(4),
          border: Border.all(width: 1, color: AppColor.colorGreyBorder)),
      child: TextFormField(
        style: FontFamily.demiBold(size: 16),
        controller: widget.controllerText,
        enabled: widget.enableText ?? true,
        validator: (value) {
          return widget.validate!(value);
        },
        obscureText: widget.showObscureText ?? showSecurity,
        keyboardType:
            widget.inputTypeNumber == true ? TextInputType.number : null,
        decoration: InputDecoration(
          labelText: widget.labelText,
          labelStyle: FontFamily.regular(color: AppColor.colorHintText),
          hintText: widget.labelText,
          border: InputBorder.none,
          suffixIcon: widget.showEye == true
              ? InkWell(
                  onTap: () => setState(() {
                    showSecurity = !showSecurity;
                  }),
                  child: showSecurity
                      ? const Icon(Icons.visibility_off_rounded,
                          color: AppColor.colorGreyBorder)
                      : const Icon(Icons.visibility_rounded,
                          color: AppColor.colorGreyBorder),
                )
              : null,
        ),
      ),
    );
  }
}
