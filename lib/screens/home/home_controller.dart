import 'package:get/get.dart';
import 'package:stringee_flutter_plugin/stringee_flutter_plugin.dart';

class HomeController extends GetxController {
  StringeeClient clientStringTree = StringeeClient();


  void getChat(){
    clientStringTree.eventStreamController.stream.listen((event) {
      Map<dynamic, dynamic> map = event;
      switch (map['eventType']) {
        case StringeeClientEvents.didConnect:
          handleDidConnectEvent();
          break;
        case StringeeClientEvents.didDisconnect:
          handleDiddisconnectEvent();
          break;
        case StringeeClientEvents.didFailWithError:
          int code = map['body']['code'];
          String msg = map['body']['message'];
          handleDidFailWithErrorEvent(code, msg);
          break;
        case StringeeClientEvents.requestAccessToken:
          handleRequestAccessTokenEvent();
          break;
        case StringeeClientEvents.didReceiveCustomMessage:
          handleDidReceiveCustomMessageEvent(map['body']);
          break;
        case StringeeClientEvents.userBeginTyping:
          handleUserBeginTypingEvent(map['body']);
          break;
        case StringeeClientEvents.userEndTyping:
          handleUserEndTypingEvent(map['body']);
          break;
        default:
          break;
      }
    });
  }
  /// Invoked when the StringeeClient is connected
  void handleDidConnectEvent() {}

  /// Invoked when the StringeeClient is disconnected
  void handleDiddisconnectEvent() {}

  /// Invoked when StringeeClient connect false
  void handleDidFailWithErrorEvent(int code, String message) {}

  /// Invoked when your token is expired
  void handleRequestAccessTokenEvent() {}

  /// Invoked when get Custom message
  void handleDidReceiveCustomMessageEvent(Map<dynamic, dynamic> map) {}

  /// Invoked when user send begin typing event
  void handleUserBeginTypingEvent(Map<dynamic, dynamic> map) {}

  /// Invoked when user send end typing event
  void handleUserEndTypingEvent(Map<dynamic, dynamic> map) {}

  /// Invoked when receive an chat change event
  void handleDidReceiveObjectChangeEvent(
      StringeeObjectChange stringeeObjectChange) {}
}
