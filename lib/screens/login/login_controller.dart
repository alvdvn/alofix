import 'package:base_project/common/utils/alert_dialog_utils.dart';
import 'package:base_project/config/routes.dart';
import 'package:base_project/services/local/app_share.dart';
import 'package:base_project/services/remote/api_provider.dart';
import 'package:base_project/services/responsitory/authen_repository.dart';
import 'package:get/get.dart';

class LoginController extends GetxController {
  final service = AuthRepository();
  RxBool isChecker = true.obs;

  @override
  void onInit() {
    super.onInit();
    getInitialCheck();
  }

  void onCheck() {
    isChecker.value = !isChecker.value;
    AppShared().saveIsCheck(isChecker.value);
  }

  void getInitialCheck() {
    if (AppShared.isRemember == 'true') {
      isChecker.value = true;
    }
    isChecker.value = false;
  }

  Future<void> login(
      {required String username, required String password}) async {
    final data = await service.login(username, password);
    if (data.statusCode == 200) {
      Get.offAllNamed(Routes.homeScreen);
      AppShared.shared.saveToken(data.accessToken ?? '');
      if (isChecker.value == true) {
        AppShared().saveUserPassword(username, password);
      }
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
}
