import 'package:base_project/screens/login/login_screen.dart';
import 'package:get/get_navigation/src/routes/get_route.dart';

class Routes {
  static const loginScreen = '/login';

  static List<GetPage> getPages() {
    return [
      GetPage(name: Routes.loginScreen, page: () => const LoginScreen()),

    ];
  }
}

