import 'package:flutter/material.dart';

class RowTitleValueWidget extends StatelessWidget {
  const RowTitleValueWidget({Key? key,required this.title,required this.value}) : super(key: key);
  final String title;
  final String value;

  @override
  Widget build(BuildContext context) {
    return Row(
      mainAxisAlignment: MainAxisAlignment.spaceBetween,
      children: [
        Text(title),
        Text(value)
      ],
    );
  }
}
