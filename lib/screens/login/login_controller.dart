import 'package:base_project/common/utils/alert_dialog_utils.dart';
import 'package:base_project/config/routes.dart';
import 'package:base_project/database/db_context.dart';
import 'package:base_project/services/SyncDb.dart';
import 'package:base_project/services/local/app_share.dart';
import 'package:base_project/services/queue_process.dart';
import 'package:base_project/services/remote/api_provider.dart';
import 'package:base_project/services/responsitory/authen_repository.dart';
import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:flutter/services.dart';
import 'package:intl/intl.dart';

class LoginController extends GetxController with WidgetsBindingObserver {
  static const platform = MethodChannel(AppShared.FLUTTER_ANDROID_CHANNEL);
  final authRepository = AuthRepository();
  RxBool isChecker = false.obs;
  RxString tokenIsFirstLogin = ''.obs;
  RxBool isShowNotification = false.obs;
  RxBool isOnAsk = false.obs;
  @override
  void onInit() {
    super.onInit();
    getInitialCheck();
    WidgetsBinding.instance.addObserver(this);
  }

  @override
  void onReady() {
    debugPrint('Screen is ready!');
    super.onReady();
  }

  @override
  void didChangeAppLifecycleState(AppLifecycleState state) {
    if (state == AppLifecycleState.resumed) {
      // Xử lý khi ứng dụng quay lại foreground (chạy phía trước)
      debugPrint('AppLifecycleState.resumed!');
    }
  }

  @override
  void onClose() {
    WidgetsBinding.instance.removeObserver(this);
    super.onClose();
  }

  void onCheck() async {
    isChecker.value = !isChecker.value;
    AppShared.isRemember = isChecker.value.toString();
  }

  void getInitialCheck() {
    if (AppShared.isRemember == 'true') {
      isChecker.value = true;
    }
    if (AppShared.isRemember == 'false') {
      isChecker.value = false;
    }

    // TODO: replace this
    // AppShared.isRemember = isChecker.value.toString();
  }

  Future<bool> login(
      {required String username, required String password}) async {
    final data = await authRepository.login(username, password);
    await autoLogin(username, password);
    if (data.statusCode == 200 && data.isFirstLogin == false) {
      Get.offAllNamed(Routes.homeScreen);
      AppShared.shared.saveToken(data.accessToken ?? '');
      AuthenticationKey.shared.token = data.accessToken ?? '';
    }
    if (data.statusCode == 200) {
      try {
        await AppShared().saveLoginStatus(true);
        await AppShared().saveUserName(username);
        var now = DateTime.now().millisecondsSinceEpoch;
        final db = await DatabaseContext.instance();
        var syncService = SyncCallLogDb();
        var lastCallLog = await db.callLogs.getLastStartAt(now);
        late Duration syncFrom;

        await QueueProcess().addFromSP();
        if (lastCallLog == null) {
          syncFrom = const Duration(days: 3);
          await syncService.syncFromDevice(duration: syncFrom);
        } else {
          syncFrom = Duration(milliseconds: now - lastCallLog);
          await syncService.syncFromDevice(duration: syncFrom);
        }
        await syncService.syncToServer(loadDevice: false);
        var syncTime = await AppShared().getSyncTime();
        if( syncTime != 0){
          var startSyncTime  = DateTime.fromMillisecondsSinceEpoch(syncTime,isUtc: false);
          DateTimeRange syncRange = DateTimeRange(start: startSyncTime, end: DateTime.now());
          syncService.syncCallLogFromServer(filterRange: syncRange);
        }else{
          syncService.syncFromServer(page: 1);
        }
        AppShared().saveAutoLogin(true);
        invokeStartService(username);
      } catch (e) {
        rethrow;
      }
    }

    if (data.statusCode == 200 && data.isFirstLogin == true) {
      tokenIsFirstLogin.value = data.accessToken ?? '';
      AuthenticationKey.shared.token = data.accessToken ?? '';
      return true;
    }

    if (data.statusCode == 402) {
      showDialogNotification(
          title: "Vui lòng kiểm tra lại!",
          data.message.toString(),
          action: () => Get.back());
    }

    if (data.statusCode == 500) {
      showDialogNotification(
          title: "Lỗi", data.message.toString(), action: () => Get.back());
    }

    return false;
  }

  Future<void> firstChangePassword(
      {required String token,
      required String newPassword,
      required String confirmPassword}) async {
    final res = await authRepository.fristChangePassword(
        token: token,
        newPassword: newPassword,
        confirmPassword: confirmPassword);
    if (res.statusCode == 200) {
      await AppShared().saveLoginStatus(true);
      Get.offAllNamed(Routes.homeScreen);
      AppShared.shared.saveToken(res.accessToken ?? '');
      AuthenticationKey.shared.token = res.accessToken ?? '';
    }
    if (res.statusCode == 402) {
      showDialogNotification(
          title: "Đổi mật khẩu",
          'Đổi mật khẩu không thành công vui lòng xem lại!',
          action: () => Get.back());
    }
  }

  Future<void> autoLogin(String username, String password) async {
    await AppShared().saveIsCheck(isChecker.value);
    await AppShared().clearPassword();
    if (isChecker.value == true) {
      await AppShared().saveUserPassword(username, password);
    }
    if (isChecker.value == false) {
      AppShared().clearPassword();
    }
    AppShared().saveUserName(username);
  }

  Future<void> invokeStartService(String username) async {
    try {
      await platform.invokeMethod(AppShared.START_SERVICES_METHOD);
      print("invokeStartService");
    } on PlatformException catch (e) {
      final String errorString = "Error on invokeStartService ${e.details}";
      debugPrint(errorString);
      print('invokeStartService errorString $errorString');
    }
    await AppShared().saveUserName(username);
  }
}
