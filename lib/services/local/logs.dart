// TODO change Sentry via Firebase
import 'package:firebase_crashlytics/firebase_crashlytics.dart';
import 'package:sentry_flutter/sentry_flutter.dart';
import 'app_share.dart';

class Logs {

  Future<void> sendError(String error) async {
    final userID = await AppShared().getUserName();
    final log = SentryLog(error, userID);
    await log.sendError();
  }

  Future<void> sendMessage(String error) async {
    final userID = await AppShared().getUserName();
    final log = SentryLog(error, userID);
    await log.sendMessage();
  }
}

class SentryLog {
  String message;
  String? userID;

  SentryLog(this.message, this.userID) {
    if (userID == "") {
      Sentry.configureScope((scope) {
        scope.setTag("login_tag", "LoginTag");
      });
      FirebaseCrashlytics.instance.setCustomKey("login_tag", "LoginTag");
    } else {
      Sentry.configureScope((scope) {
        scope.setTag("userID", userID!);
      });
      FirebaseCrashlytics.instance.setCustomKey("userID", userID!);
    }
  }

  Future<void> sendError() async {
    Sentry.configureScope((scope) => scope.level = SentryLevel.error);
    await Sentry.captureMessage(message);
    await FirebaseCrashlytics.instance.recordError(message, null); // Logging error to Firebase Crashlytics
  }

  Future<void> sendMessage() async {
    Sentry.configureScope((scope) => scope.level = SentryLevel.debug);
    await Sentry.captureMessage(message);
    await FirebaseCrashlytics.instance.log(message); // Logging message to Firebase Crashlytics
  }
}
