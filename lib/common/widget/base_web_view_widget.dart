import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:get/get_core/src/get_main.dart';
import 'package:webview_flutter/webview_flutter.dart';

import '../../config/fonts.dart';
import '../../screens/account/account_controller.dart';
import '../themes/colors.dart';

class WebViewScreen extends StatelessWidget {

  static AccountController _controller = Get.put(AccountController());

  static Future<String> get _url async {
    await _controller.getVersionMyApp();
    final url = _controller.versionInfoModel?.driverReport ?? '';
    await Future.delayed(const Duration(seconds: 1));
    return url;
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
            title: Text("Báo cáo hiệu suất tài xế", style: FontFamily.demiBold(size: 20)),
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
                builder: (BuildContext context, AsyncSnapshot snapshot) => snapshot.hasData
                    ? WebViewWidget(url: snapshot.data,)
                    : const CircularProgressIndicator()),
          ),));
  }
}

class WebViewWidget extends StatefulWidget {
  final String url;
  const WebViewWidget({super.key, required this.url});

  @override
  _WebViewWidget createState() => _WebViewWidget();
}

class _WebViewWidget extends State<WebViewWidget> {

  late WebView _webView;

  @override
  void initState() {
    super.initState();
    _webView = WebView(
      initialUrl: widget.url,
      javascriptMode: JavascriptMode.unrestricted,
    );
  }

  @override
  void dispose() {
    super.dispose();
  }

  @override
  Widget build(BuildContext context) => _webView;
}