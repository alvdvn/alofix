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
      this.validate});

  final TextEditingController controllerText;
  final String labelText;
  final bool? showEye;
  final bool? inputTypeNumber;
  final bool? showObscureText;
  final Function(String?)? validate;

  @override
  State<StatefulWidget> createState() {
    return _TextInputCustomWidget();
  }
}

class _TextInputCustomWidget extends State<TextInputCustomWidget> {
  bool showSecurity = true;
  bool clickTextField = false;

  @override
  Widget build(BuildContext context) {
    return TextFormField(
      style: FontFamily.DemiBold(size: 16),
      controller: widget.controllerText,
      validator: (value) {
        return widget.validate!(value);
      },
      obscureText: widget.showObscureText ?? showSecurity,
      keyboardType:
          widget.inputTypeNumber == true ? TextInputType.number : null,
      decoration: InputDecoration(
        labelText: widget.labelText,
        labelStyle: FontFamily.Regular(color: AppColor.colorHintText),
        hintText: widget.labelText,
        focusedBorder: const OutlineInputBorder(
            borderSide: BorderSide(color: AppColor.colorRedMain, width: 1.0)),
        border: const OutlineInputBorder(
            borderSide:
                BorderSide(color: AppColor.colorGreyBorder, width: 1.0)),
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
    );
  }
}
