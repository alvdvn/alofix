class AuthValidator {
  String? userName(String value) {
    if (value.isEmpty) {
      return 'Vui lòng điền tên đăng nhập';
    } else {
      return null;
    }
  }
  String? passwordEmpty(String value) {
    if (value.isEmpty) {
      return 'Vui lòng điền mật khẩu';
    } else {
      return null;
    }
  }

  String? password(String value) {
    const pattern =
        r'^(?=.*?[A-Z])(?=.*?[a-z])(?=.*?[0-9])(?=.*?[!@#\$&*~]).{10,}$';
    final regExp = RegExp(pattern);
    if (value.isEmpty) {
      return 'Vui lòng điền mật khẩu';
    } else if (regExp.hasMatch(value) == false) {
      return 'Mật khẩu phải chứa ít nhất 10 kí tự. Trong đó ít nhất:\n- 1 ký tự viết hoa [A-Z].\n- 1 kí tự thường [a-z]\n- 1 số [0-9].\n- 1 ký tự đặc biệt.';
    }
    return null;
  }

  String? retypePassword(String value, String password) {
    if (value.isEmpty) {
      return 'Vui lòng điền mật khẩu';
    } else if (value != password) {
      return 'Nhập lại mật khẩu không đúng';
    } else {
      return null;
    }
  }
}
