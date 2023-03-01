import 'package:base_project/common/themes/colors.dart';
import 'package:flutter/material.dart';

class ShowLoading extends StatelessWidget {
  const ShowLoading({Key? key}) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return const Center(
        child: SizedBox(
            width: 30,
            height: 30,
            child: CircularProgressIndicator(
                valueColor: AlwaysStoppedAnimation<Color>(AppColor.colorRedMain))));
  }
}
