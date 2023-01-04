import 'package:base_project/config/routes.dart';
import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'audio_player.dart';

class PlayRecordScreen extends StatefulWidget {
  const PlayRecordScreen({Key? key}) : super(key: key);

  @override
  State<PlayRecordScreen> createState() => _PlayRecordScreenState();
}

class _PlayRecordScreenState extends State<PlayRecordScreen> {
  @override
  Widget build(BuildContext context) {
    String path = ModalRoute.of(context)!.settings.arguments as String;
    return Scaffold(
      body: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          AudioPlayer(source: path),
          const SizedBox(height: 32),
          InkWell(
              onTap: () => Get.offAllNamed(Routes.homeScreen),
              child: const Text('Go to hhome'))
        ],
      ),
    );
  }
}
