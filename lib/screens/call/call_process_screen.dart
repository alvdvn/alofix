import 'dart:async';

import 'package:base_project/common/themes/colors.dart';
import 'package:base_project/config/routes.dart';
import 'package:base_project/generated/assets.dart';
import 'package:flutter/foundation.dart';
import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:record/record.dart';

class CallProcessScreen extends StatefulWidget {
  const CallProcessScreen({Key? key}) : super(key: key);

  @override
  State<CallProcessScreen> createState() => _CallProcessScreenState();
}

class _CallProcessScreenState extends State<CallProcessScreen> {
  int _recordDuration = 0;
  Timer? _timer;
  final _audioRecorder = Record();
  StreamSubscription<RecordState>? _recordSub;
  RecordState _recordState = RecordState.stop;
  StreamSubscription<Amplitude>? _amplitudeSub;
  Amplitude? _amplitude;

  @override
  void initState() {
    _recordSub = _audioRecorder.onStateChanged().listen((recordState) {
      setState(() => _recordState = recordState);
    });

    _amplitudeSub = _audioRecorder
        .onAmplitudeChanged(const Duration(milliseconds: 300))
        .listen((amp) => setState(() => _amplitude = amp));
    super.initState();
    _start();
  }

  Future<void> _start() async {
    try {
      if (await _audioRecorder.hasPermission()) {
        final isSupported = await _audioRecorder.isEncoderSupported(
          AudioEncoder.aacLc,
        );
        if (kDebugMode) {
          print('${AudioEncoder.aacLc.name} supported: $isSupported');
        }
        await _audioRecorder.start();
        _recordDuration = 0;
        _startTimer();
      }
    } catch (e) {
      if (kDebugMode) {
        print(e);
      }
    }
  }

  Future<void> _stop() async {
    _timer?.cancel();
    _recordDuration = 0;

    final path = await _audioRecorder.stop();
    Get.toNamed(Routes.playRecord, arguments: path);
  }

  void _startTimer() {
    _timer?.cancel();
    _timer = Timer.periodic(const Duration(seconds: 1), (Timer t) {
      setState(() => _recordDuration++);
    });
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
                      _stop();
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
    final Size size = MediaQuery.of(context).size;
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
