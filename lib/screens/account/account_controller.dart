import 'dart:convert';

import 'package:base_project/common/enum_call/enum_call.dart';
import 'package:base_project/common/utils/alert_dialog_utils.dart';
import 'package:base_project/config/routes.dart';
import 'package:base_project/database/db_context.dart';
import 'package:base_project/models/account_model.dart';
import 'package:base_project/models/sim_card.dart';
import 'package:base_project/services/local/app_share.dart';
import 'package:base_project/services/responsitory/account_repository.dart';
import 'package:connectivity_plus/connectivity_plus.dart';
import 'package:flutter/services.dart';
import 'package:flutter_background_service/flutter_background_service.dart';
import 'package:get/get.dart';
import 'package:shared_preferences/shared_preferences.dart';
import '../../models/version_info_model.dart';

class AccountController extends GetxController {
  final service = AccountRepository();
  AccountModel? user;
  VersionInfoModel? versionInfoModel;
  RxString titleCall = AppShared.callTypeGlobal.obs;
  RxList<SimCard> simCards = <SimCard>[].obs;
  final backgroundService = FlutterBackgroundService();
  final platform = MethodChannel(AppShared.FLUTTER_ANDROID_CHANNEL);

  Future<void> getSims() async {
    String json = await platform.invokeMethod(AppShared.GET_SIM_INFO);
    List<dynamic> jsonList = jsonDecode(json);
    simCards.value = jsonList.map((e) => SimCard.fromJson(e)).toList();
  }

  Future<AccountModel?> getUserLogin() async {
    final connectivityResult = await Connectivity().checkConnectivity();
    if (ConnectivityResult.none != connectivityResult) {
      final res = await service.getInformation();
      user = res;
      return res;
    }
    return null;
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
        // final db = await DatabaseContext.instance();
        FlutterBackgroundService().invoke("stopService");
        await preferences.setString('access_token', "");
        await preferences.setString('stringee_token_connect', "");
        await preferences.setString('auto_login', "false");
        // db.callLogs.clean();
        if (AppShared.isRemember == 'false') {
          await AppShared().clearPassword();
          Get.offAllNamed(Routes.loginScreen);
        }
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

  Future<void> saveSimType(int? index) async {
    AppShared.shared.saveSimDefault(index);
    AppShared.simSlotIndex = index;
    update();
  }

  Future<VersionInfoModel?> getVersionMyApp() async {
    final connectivityResult = await Connectivity().checkConnectivity();
    if (ConnectivityResult.none != connectivityResult) {
      final res = await service.versionApp();
      versionInfoModel = res;
      return res;
    }
    return null;
  }
}
