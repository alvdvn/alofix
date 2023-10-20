import 'package:base_project/common/utils/alert_dialog_utils.dart';
import 'package:base_project/config/routes.dart';
import 'package:base_project/services/local/app_share.dart';
import 'package:base_project/services/remote/api_provider.dart';
import 'package:base_project/services/responsitory/authen_repository.dart';
import 'package:get/get.dart';
import 'package:permission_handler/permission_handler.dart';
import 'package:flutter/services.dart';

import '../../environment.dart';

class LoginController extends GetxController {

  static const platform = MethodChannel(AppShared.FLUTTER_ANDROID_CHANNEL);

  final service = AuthRepository();
  RxBool isChecker = false.obs;
  RxString tokenIsFirstLogin = ''.obs;

  @override
  void onInit() {
    super.onInit();
    requestPermissions();
    getInitialCheck();
  }

  requestPermissions() async {
    var statuses = await [
      Permission.phone,
    ].request();
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
  }

  Future<bool> login(
      {required String username,
        required String password,
        String domain = ""}) async {
    if (Environment.evn == AppEnv.dev) {
      Environment.domain = domain;
    }

    final data = await service.login(username, password);

    await autoLogin(username, password);

    if (data.statusCode == 200 && Environment.evn == AppEnv.dev) {
      AppShared().saveDomain(domain);
    }
    if (data.statusCode == 200 && data.isFirstLogin == true) {
      tokenIsFirstLogin.value = data.accessToken ?? '';
      AuthenticationKey.shared.token = data.accessToken ?? '';
      AppShared().saveAutoLogin(true);
      return true;
    }

    if (data.statusCode == 200 && data.isFirstLogin == false) {
      Get.offAllNamed(Routes.homeScreen);
      AppShared.shared.saveToken(data.accessToken ?? '');
      AuthenticationKey.shared.token = data.accessToken ?? '';
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

    if (data.statusCode == 200) {
      runStartService();
    }

    return false;
  }

  Future<void> firstChangePassword(
      {required String token,
        required String newPassword,
        required String confirmPassword}) async {
    final res = await service.fristChangePassword(
        token: token,
        newPassword: newPassword,
        confirmPassword: confirmPassword);
    if (res.statusCode == 200) {
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
    if (isChecker.value == true) {
      AppShared().saveUserPassword(username, password);
      AppShared().saveAutoLogin(true);
    }
    if (isChecker.value == false) {
      AppShared().clearPassword();
      AppShared().saveAutoLogin(false);
    }
    AppShared().saveUserName(username);
  }

  Future<void> runStartService() async {
      try {
        final int result = await platform.invokeMethod(AppShared.START_SERVICES_METHOD);
      } on PlatformException catch (e) {
        print("Error on runPhoneService");
      }
  }

}