import 'package:base_project/services/responsitory/account_repository.dart';
import 'package:get/get.dart';

class AccountController extends GetxController {

  final service = AccountRepository();


  @override
  void onInit() {
    super.onInit();
    getUserLogin();
  }

  Future<void> getUserLogin() async {
    final res = await service.getInformation();
  }
}
