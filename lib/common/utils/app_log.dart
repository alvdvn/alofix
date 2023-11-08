
import 'package:firebase_crashlytics/firebase_crashlytics.dart';
import '../../services/local/app_share.dart';
import 'package:sentry/sentry.dart';

class Logs {
  late String userID;

  sendError(String error) async {
    userID = await AppShared().getUserName();
    final log = SentryLog(error, userID);
    log.sendError();
  }

  sendMessage(String error) async {
    userID = await AppShared().getUserName();
    final log = SentryLog(error, userID);
    log.sendMessage();
  }
}

// TODO change Sentry via Firebase
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

  void sendError() {
    Sentry.configureScope((scope) => scope.level = SentryLevel.error);
    Sentry.captureMessage(message);
    FirebaseCrashlytics.instance.recordError(message, null); // Logging error to Firebase Crashlytics
  }

  void sendMessage() {
    Sentry.configureScope((scope) => scope.level = SentryLevel.debug);
    Sentry.captureMessage(message);
    FirebaseCrashlytics.instance.log(message); // Logging message to Firebase Crashlytics
  }
}
