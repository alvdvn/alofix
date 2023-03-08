import 'dart:async';

import 'package:base_project/common/utils/global_app.dart';
import 'package:base_project/config/routes.dart';
import 'package:firebase_dynamic_links/firebase_dynamic_links.dart';
import 'package:flutter/foundation.dart';
import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'screens/call/call_controller.dart';
import 'services/local/app_share.dart';

import 'package:uni_links/uni_links.dart';
import 'package:flutter/services.dart' show PlatformException;

class MyApp extends StatefulWidget {
  const MyApp({super.key});

  @override
  State<MyApp> createState() => _MyHomePageState();
}

enum UniLinksType { string, uri }

class _MyHomePageState extends State<MyApp> {
  FirebaseDynamicLinks dynamicLinks = FirebaseDynamicLinks.instance;
  CallController callController = Get.put(CallController());

  String? _initialLink;
  Uri? _initialUri;
  String? _latestLink = 'Unknown';
  Uri? _latestUri;
  UniLinksType _type = UniLinksType.string;

  StreamSubscription? _sub;

  @override
  void initState() {
    super.initState();
    initPlatformState();
  }

  @override
  void dispose() {
    _sub?.cancel();
    super.dispose();
  }

  Future<void> initPlatformState() async {
    if (_type == UniLinksType.string) {
      await initPlatformStateForStringUniLinks();
    } else {
      await initPlatformStateForUriUniLinks();
    }
  }

  /// An implementation using a [String] link
  Future<void> initPlatformStateForStringUniLinks() async {
    // Attach a listener to the links stream
    if (!kIsWeb) {
      _sub = linkStream.listen((String? link) {
        if (!mounted) return;
        setState(() {
          _latestLink = link ?? 'Unknown';
          _latestUri = null;
          try {
            if (link != null) _latestUri = Uri.parse(link);
          } on FormatException {}
        });
      }, onError: (Object err) {
        if (!mounted) return;
        setState(() {
          _latestLink = 'Failed to get latest link: $err.';
          _latestUri = null;
        });
      });
    }

    // Attach a second listener to the stream
    if (!kIsWeb) {
      linkStream.listen((String? link) {
        print('got link: $link');
      }, onError: (Object err) {
        print('got err: $err');
      });
    }

    // Get the latest link
    // Platform messages may fail, so we use a try/catch PlatformException.
    try {
      _initialLink = await getInitialLink();
      print('initial link: $_initialLink');
      if (_initialLink != null) _initialUri = Uri.parse(_initialLink!);
    } on PlatformException {
      _initialLink = 'Failed to get initial link.';
      _initialUri = null;
    } on FormatException {
      _initialLink = 'Failed to parse the initial link as Uri.';
      _initialUri = null;
    }

    // If the widget was removed from the tree while the asynchronous platform
    // message was in flight, we want to discard the reply rather than calling
    // setState to update our non-existent appearance.
    if (!mounted) return;

    setState(() {
      _latestLink = _initialLink;
      _latestUri = _initialUri;
    });
  }

  /// An implementation using the [Uri] convenience helpers
  Future<void> initPlatformStateForUriUniLinks() async {
    // Attach a listener to the Uri links stream
    if (!kIsWeb) {
      _sub = uriLinkStream.listen((Uri? uri) {
        if (!mounted) return;
        setState(() {
          _latestUri = uri;
          _latestLink = uri?.toString() ?? 'Unknown';
        });
      }, onError: (Object err) {
        if (!mounted) return;
        setState(() {
          _latestUri = null;
          _latestLink = 'Failed to get latest link: $err.';
        });
      });
    }

    // Attach a second listener to the stream
    if (!kIsWeb) {
      uriLinkStream.listen((Uri? uri) {
        print('got uri: ${uri?.path} ${uri?.queryParametersAll}');
      }, onError: (Object err) {
        print('got err: $err');
      });
    }

    // Get the latest Uri
    // Platform messages may fail, so we use a try/catch PlatformException.
    try {
      _initialUri = await getInitialUri();
      print('initial uri: ${_initialUri?.path}'
          ' ${_initialUri?.queryParametersAll}');
      _initialLink = _initialUri?.toString();
    } on PlatformException {
      _initialUri = null;
      _initialLink = 'Failed to get initial uri.';
    } on FormatException {
      _initialUri = null;
      _initialLink = 'Bad parse the initial link as Uri.';
    }

    // If the widget was removed from the tree while the asynchronous platform
    // message was in flight, we want to discard the reply rather than calling
    // setState to update our non-existent appearance.
    if (!mounted) return;

    setState(() {
      _latestUri = _initialUri;
      _latestLink = _initialLink;
    });
  }


  Future<void> initDynamicLinks() async {
    final PendingDynamicLinkData? initialLink = await FirebaseDynamicLinks.instance.getInitialLink();
    if (initialLink != null) {
      final Uri deepLink = initialLink.link;
      final queryParams = deepLink.queryParameters;
      if (queryParams.isNotEmpty) {
        await AppShared().saveDateDeepLink();
        AppShared.jsonDeepLink = queryParams;
        callController.setPhone(queryParams["phoneNumber"].toString());
        callController.setIdDeepLink(queryParams["id"].toString());
        callController.setIdTrack(queryParams["idTrack"].toString());
        callController.setRouter(queryParams["routerId"].toString());
      }
    }
    dynamicLinks.onLink.listen((dynamicLinkData) async {
      final Uri uri = dynamicLinkData.link;
      final queryParams = uri.queryParameters;
      if (queryParams.isNotEmpty) {
        AppShared.jsonDeepLink = queryParams;
        await AppShared().saveDateDeepLink();
        callController.setPhone(queryParams["phoneNumber"].toString());
        callController.setIdDeepLink(queryParams["id"].toString());
        callController.setIdTrack(queryParams["idTrack"].toString());
        callController.setRouter(queryParams["routerId"].toString());
      }
    }).onError((error) {
      debugPrint(error.message);
    });
  }

  @override
  Widget build(BuildContext context) {
    initDynamicLinks();
    return GetMaterialApp(
        navigatorKey: App.globalKey,
        debugShowCheckedModeBanner: false,
        getPages: Routes.getPages(),
        initialRoute: Routes.splashScreen);
  }
}
