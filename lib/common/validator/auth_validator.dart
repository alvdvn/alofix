class AuthValidator {
  String? userName(String value) {
    RegExp regExp = RegExp(
        r"((?:\+|00)[17](?: |\-)?|(?:\+|00)[1-9]\d{0,2}(?: |\-)?|(?:\+|00)1\-\d{3}(?: |\-)?)?(0\d|\([0-9]{3}\)|[1-9]{0,3})(?:((?: |\-)[0-9]{2}){4}|((?:[0-9]{2}){4})|((?: |\-)[0-9]{3}(?: |\-)[0-9]{4})|([0-9]{7}))");

    if (value.isEmpty) {
      return 'Vui lòng điền tên đăng nhập';
    } else if (regExp.hasMatch(value) == false) {
      return 'Số điên thoại không hợp lê';
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
    const pattern =
        r'^(?=.*?[A-Z])(?=.*?[a-z])(?=.*?[0-9])(?=.*?[!@#\$&*~]).{10,}$';
    final regExp = RegExp(pattern);
    if (value.isEmpty) {
      return 'Vui lòng điền mật khẩu';
    } else if (regExp.hasMatch(value) == false) {
      return 'Mật khẩu phải chứa ít nhất 10 kí tự. Trong đó ít nhất:\n- 1 ký tự viết hoa [A-Z].\n- 1 kí tự thường [a-z]\n- 1 số [0-9].\n- 1 ký tự đặc biệt.';
    } else if (value != password) {
      return 'Nhập lại mật khẩu không đúng';
    } else {
      return null;
    }
  }
}
