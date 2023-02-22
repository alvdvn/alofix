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
        r'^(?=.*?[A-Z])(?=.*?[a-z])(?=.*?[0-9])(?=.*?[!@#\$&*~]).{8,}$';
    final regExp = RegExp(pattern);
    if (value.isEmpty) {
      return 'Vui lòng điền mật khẩu';
    } else if (value.length < 8) {
      return 'Tối thiếu 8 ký tự';
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
