import 'package:base_project/extension.dart';
import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:webview_flutter/webview_flutter.dart';

import '../../config/fonts.dart';
import '../../screens/account/account_controller.dart';
import '../themes/colors.dart';

class WebViewScreen extends StatelessWidget {
  static AccountController _controller = Get.put(AccountController());

  static Future<String> get _url async {
    var version = await _controller.getVersionMyApp();
    return version?.driverReport ?? '';
  }

  get controller => null;

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
        title: '',
        theme: ThemeData(
          primarySwatch: Colors.blue,
        ),
        home: Scaffold(
          appBar: AppBar(
            backgroundColor: Colors.white,
            title: Text("Báo cáo hiệu suất tài xế",
                style: FontFamily.demiBold(size: 20)),
            elevation: 0,
            actions: [
              InkWell(
                  onTap: () {
                    controller.onClickSearch();
                  },
                  child: Row(
                    children: [
                      InkWell(
                        child: const Icon(
                          Icons.close,
                          color: AppColor.colorGreyText,
                        ),
                        onTap: () => Get.back(),
                      ),
                      const SizedBox(width: 16)
                    ],
                  )),
            ],
          ),
          body: Center(
            child: FutureBuilder(
                future: _url,
                builder: (BuildContext context, AsyncSnapshot snapshot) =>
                    snapshot.hasData
                        ? DriveReportWidget(
                            url: snapshot.data,
                          )
                        : const CircularProgressIndicator()),
          ),
        ));
  }
}

class DriveReportWidget extends StatefulWidget {
  final String url;

  const DriveReportWidget({super.key, required this.url});

  @override
  _DriveReportWidget createState() => _DriveReportWidget();
}

class _DriveReportWidget extends State<DriveReportWidget> {
  late WebViewController controller;

  @override
  void initState() {
    super.initState();
    pprint(widget);
    controller = WebViewController()
      ..setJavaScriptMode(JavaScriptMode.unrestricted)
      ..setBackgroundColor(const Color(0x00000000))
      ..loadRequest(Uri.parse(widget.url));
  }

  @override
  void dispose() {
    super.dispose();
  }

  @override
  Widget build(BuildContext context) => WebViewWidget(controller: controller);
}
