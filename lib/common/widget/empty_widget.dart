import 'package:base_project/config/fonts.dart';
import 'package:flutter/material.dart';

class EmptyWidget extends StatelessWidget {
  const EmptyWidget({Key? key}) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return Center(
      child: Text(
        'Danh sách trống',
        style: FontFamily.normal(size: 18),
      ),
    );
  }
}
