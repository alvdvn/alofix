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
      this.showObscureText});

  final TextEditingController controllerText;
  final String labelText;
  final bool? showEye;
  final bool? inputTypeNumber;
  final bool? showObscureText;

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
    return InkWell(
      onTap: () => setState(() {
        clickTextField = !clickTextField;
      }),
      child: Container(
        padding: const EdgeInsets.symmetric(horizontal: 16),
        decoration: BoxDecoration(
            borderRadius: BorderRadius.circular(4),
            border: Border.all(width: 1, color: AppColor.colorGreyBorder)),
        child: InkWell(
          onTap: () => setState(() {
            clickTextField = true;
          }),
          child: TextFormField(
            style: FontFamily.DemiBold(size: 16),
            controller: widget.controllerText,
            validator: (value) => AuthValidator().userName(value ?? ''),
            obscureText: widget.showObscureText ?? showSecurity,
            keyboardType:
                widget.inputTypeNumber == true ? TextInputType.number : null,
            decoration: InputDecoration(
              labelText: widget.labelText,
              labelStyle: FontFamily.Regular(color: AppColor.colorHintText),
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
        ),
      ),
    );
  }
}
