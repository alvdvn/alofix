import 'package:stringee_flutter_plugin/stringee_flutter_plugin.dart';

class ClientString {

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
