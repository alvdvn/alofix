import 'package:base_project/common/utils/alert_dialog_utils.dart';
import 'package:base_project/config/routes.dart';
import 'package:base_project/services/local/app_share.dart';
import 'package:base_project/services/remote/api_provider.dart';
import 'package:base_project/services/responsitory/authen_repository.dart';
import 'package:flutter/cupertino.dart';
import 'package:get/get.dart';
import 'package:permission_handler/permission_handler.dart';
import 'package:flutter/services.dart';
import '../../common/constance/strings.dart';
import '../../environment.dart';
import '../home/home_controller.dart';

class LoginController extends GetxController with WidgetsBindingObserver {
  static const platform = MethodChannel(AppShared.FLUTTER_ANDROID_CHANNEL);
  final HomeController homeController = Get.put(HomeController());

  final authRepository = AuthRepository();

  RxBool isChecker = false.obs;
  RxString tokenIsFirstLogin = ''.obs;

  final RxBool isPermissionGranted = true.obs;
  RxBool isShowNotification = false.obs;
  RxBool isOnAsk = false.obs;

  @override
  void onInit() {

    super.onInit();
    getInitialCheck();
    WidgetsBinding.instance.addObserver(this);
    // TODO: this will use for listener permission state change
    // ever(isPermissionGranted, (isGranted) {
    //   if (!isGranted) {
    //     debugPrint('Permissions Denied!');
    //     warningPermission();
    //   }
    // });
  }

  @override
  void onReady() {
    debugPrint('Screen is ready!');
    super.onReady();
    checkPermission();
  }

  @override
  void didChangeAppLifecycleState(AppLifecycleState state) {
    if (state == AppLifecycleState.resumed) {
      // Xử lý khi ứng dụng quay lại foreground (chạy phía trước)
      debugPrint('AppLifecycleState.resumed!');
      // checkPermission();
    }
  }

  Future<void> checkPermission() async {
    // Assume false
    debugPrint("Permissions Check");
    isPermissionGranted.value = await getContactStatus();
  }

  @override
  void onClose() {
    WidgetsBinding.instance.removeObserver(this);
    super.onClose();
  }

  Future<void> warningPermission() async {
    debugPrint("LoginController handlerPermissions");
    showDialogNotification(title: AppStrings.alertTitle, AppStrings.missingPermission, titleBtn: AppStrings.understandButtonTitle,
        action: () async {
          // AppSettings.openAppSettings();
          Get.back();
          await askPermissions();
          checkPermission();
        });
  }

  Future<bool> getContactStatus() async {
    var contactStatus = await Permission.contacts.status;
    debugPrint("getContactStatus $contactStatus");
    if (contactStatus.isGranted) {
      return true;
    }

    await askPermissions();

    return false;
  }

  Future<void> askPermissions() async {
    var contactStatus = await Permission.contacts.request();
    var phoneStatus = await Permission.phone.request();
    debugPrint("contact permission Status $contactStatus");

  }

  Future<void> requestContactPermission() async {
    var contactStatus = await Permission.contacts.request();
    debugPrint("requestContactPermission request $contactStatus");
  }

  Future<bool> isPermanentlyDenied() async {
    var contactStatus = await Permission.contacts.status;
    var phoneStatus = await Permission.phone.status;
    debugPrint("isPermanentlyDenied getGrandStatus $contactStatus $phoneStatus");
    if (phoneStatus.isPermanentlyDenied || contactStatus.isPermanentlyDenied) {
      return true;
    }
    return false;
  }

  Future<void> requestPhonePermission() async {
    var phoneStatus = await Permission.phone.request();
    if (phoneStatus.isDenied) {
      // while (phoneStatus.isDenied) {
      //   phoneStatus = await Permission.phone.request();
      // }
    }
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
      {required String username,
        required String password,
        String domain = ""}) async {
    if (Environment.evn == AppEnv.dev) {
      Environment.domain = domain;
    }

    final data = await authRepository.login(username, password);

    await autoLogin(username, password);

    if (data.statusCode == 200 && Environment.evn == AppEnv.dev) {
      AppShared().saveDomain(domain);
    }
    if (data.statusCode == 200 && data.isFirstLogin == true) {
      tokenIsFirstLogin.value = data.accessToken ?? '';
      AuthenticationKey.shared.token = data.accessToken ?? '';
      return true;
    }

    if (data.statusCode == 200 && data.isFirstLogin == false) {
      Get.offAllNamed(Routes.homeScreen);
      AppShared.shared.saveToken(data.accessToken ?? '');
      AuthenticationKey.shared.token = data.accessToken ?? '';
    }

    if (data.statusCode == 402) {
      showDialogNotification(title: "Vui lòng kiểm tra lại!", data.message.toString(), action: () => Get.back());
    }

    if (data.statusCode == 500) {
      showDialogNotification(title: "Lỗi", data.message.toString(), action: () => Get.back());
    }

    if (data.statusCode == 200) {
      AppShared().saveAutoLogin(true);
      invokeStartService(username);
    }

    return false;
  }

  Future<void> firstChangePassword({required String token, required String newPassword, required String confirmPassword}) async {
    final res = await authRepository.fristChangePassword(token: token, newPassword: newPassword, confirmPassword: confirmPassword);
    if (res.statusCode == 200) {
      Get.offAllNamed(Routes.homeScreen);
      AppShared.shared.saveToken(res.accessToken ?? '');
      AuthenticationKey.shared.token = res.accessToken ?? '';
    }
    if (res.statusCode == 402) {
      showDialogNotification(title: "Đổi mật khẩu", 'Đổi mật khẩu không thành công vui lòng xem lại!', action: () => Get.back());
    }
  }

  Future<void> autoLogin(String username, String password) async {
    await AppShared().saveIsCheck(isChecker.value);
    if (isChecker.value == true) {
      AppShared().saveUserPassword(username, password);
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
    AppShared().saveUserName(username);
  }
}