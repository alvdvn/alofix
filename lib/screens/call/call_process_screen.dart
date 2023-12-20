import 'package:base_project/common/themes/colors.dart';
import 'package:base_project/generated/assets.dart';
import 'package:flutter/material.dart';

class CallProcessScreen extends StatefulWidget {
  const CallProcessScreen({Key? key}) : super(key: key);

  @override
  State<CallProcessScreen> createState() => _CallProcessScreenState();
}

class _CallProcessScreenState extends State<CallProcessScreen> {
  final int _recordDuration = 0;
  @override
  void initState() {
    super.initState();
  }


  Widget _btnCallRefuse() {
    return Stack(
      children: [
        Align(
            alignment: Alignment.center,
            child: Image.asset(Assets.imagesImgRefuse, width: 80, height: 80)),
        Align(
          alignment: Alignment.center,
          child: SizedBox(
            height: 80,
            child: Column(
              mainAxisAlignment: MainAxisAlignment.center,
              mainAxisSize: MainAxisSize.max,
              children: [
                InkWell(
                    onTap: () async {
                    },
                    child: const Icon(Icons.call_end_sharp,
                        color: Colors.white, size: 25))
              ],
            ),
          ),
        )
      ],
    );
  }

  Widget _buildBody(Size size) {
    return Stack(
      alignment: Alignment.center,
      children: [
        Image.asset(Assets.imagesImgBackgroundCallCicrle),
        Container(
          width: 322,
          height: 322,
          decoration: BoxDecoration(
              borderRadius: BorderRadius.circular(161),
              color: AppColor.colorCircle),
        ),
        Column(
          children: [
            Container(
              width: 80,
              height: 80,
              decoration: BoxDecoration(
                borderRadius: BorderRadius.circular(161),
                color: Colors.white,
              ),
              child: SizedBox(
                width: 13,
                height: 13,
                child: Image.asset(
                  Assets.imagesImgNjv512h,
                  height: 10,
                  width: 10,
                ),
              ),
            ),
            const SizedBox(height: 64),
            _buildTimer(),
          ],
        ),
      ],
    );
  }

  String _formatNumber(int number) {
    String numberStr = number.toString();
    if (number < 10) {
      numberStr = '0$numberStr';
    }

    return numberStr;
  }

  Widget _buildTimer() {
    final String minutes = _formatNumber(_recordDuration ~/ 60);
    final String seconds = _formatNumber(_recordDuration % 60);

    return Text(
      'Đang xử lý cuộc gọi $minutes : $seconds',
      style: const TextStyle(color: Colors.red),
    );
  }

  @override
  Widget build(BuildContext context) {
    final Size size = MediaQuery.of(context).size.width < 0
        ? const Size(300, 500)
        : MediaQuery.of(context).size;
    return Scaffold(
      body: Column(
        mainAxisAlignment: MainAxisAlignment.end,
        children: [
          _buildBody(size),
          const SizedBox(height: 100),
          _btnCallRefuse(),
          const SizedBox(height: 32),
        ],
      ),
    );
  }
}
