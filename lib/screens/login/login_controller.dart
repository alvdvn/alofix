import 'package:base_project/common/utils/alert_dialog_utils.dart';
import 'package:base_project/config/routes.dart';
import 'package:base_project/services/local/app_share.dart';
import 'package:base_project/services/remote/api_provider.dart';
import 'package:base_project/services/responsitory/authen_repository.dart';
import 'package:get/get.dart';
import 'package:permission_handler/permission_handler.dart';

class LoginController extends GetxController {
  final service = AuthRepository();
  RxBool isChecker = false.obs;

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

  Future<void> login(
      {required String username, required String password}) async {
    final data = await service.login(username, password);
    await autoLogin(username, password);
    if (data.statusCode == 200) {
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
  }
}
