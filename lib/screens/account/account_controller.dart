import 'package:base_project/common/enum_call/enum_call.dart';
import 'package:base_project/common/utils/alert_dialog_utils.dart';
import 'package:base_project/config/routes.dart';
import 'package:base_project/models/account_model.dart';
import 'package:base_project/services/local/app_share.dart';
import 'package:base_project/services/responsitory/account_repository.dart';
import 'package:get/get.dart';
import 'package:shared_preferences/shared_preferences.dart';

class AccountController extends GetxController {
  final service = AccountRepository();
  AccountModel? user;
  RxString titleCall = AppShared.callTypeGlobal.obs;


  Future<void> getUserLogin() async {
    final res = await service.getInformation();
    user = res;
  }

  Future<void> changePassword(
      {required String password,
      required String confirmPassword,
      required String newPassword}) async {
    SharedPreferences preferences = await SharedPreferences.getInstance();
    final res = await service.changePassword(
        password: password,
        newPassword: newPassword,
        confirmPassword: confirmPassword);
    if (res.success == true) {
      showDialogNotification(
        title: "Đổi mật khẩu",
        'Đổi mật khẩu thành công',
        titleBtn: "Đăng xuất",
        action: () async {
          await preferences.clear();
          Get.offAllNamed(Routes.loginScreen);
        },
      );
    }
    if (res.success == false) {
      showDialogNotification(
          title: "Đổi mật khẩu",
          'Đổi mật khẩu không thành công vui lòng xem lại!',
          action: () => Get.back());
    }
  }

  Future<void> logOut() async {
    SharedPreferences preferences = await SharedPreferences.getInstance();
    showDialogNotification(
      title: "Đăng xuất",
      'Bạn có muốn kết thúc phiên đăng nhập \n này không ?',
      titleBtn: "Đăng xuất",
      showBack: true,
      action: () async {
        await preferences.setString('access_token', "");
        Get.offAllNamed(Routes.loginScreen);
      },
    );
  }

  Future<void> saveCallType(DefaultCall defaultCall) async {
    AppShared.shared.saveCallDefault(defaultCall);
    AppShared.callTypeGlobal = getTypeCall(defaultCall);
    titleCall.value = getTypeCall(defaultCall);
    update();
  }

}
