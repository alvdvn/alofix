import 'package:g_json/g_json.dart';

class LoginResponse {
  final int? statusCode;
  final String? accessToken;
  final String? expiresIn;
  final String? message;
  final String? error;
  final bool? isFirstLogin;

  LoginResponse(
      {this.accessToken,
      this.expiresIn,
      this.message,
      this.error,
      this.statusCode,
      this.isFirstLogin});

  LoginResponse.fromJson(JSON json)
      : statusCode = json['statusCode'].integer,
        accessToken = json['access_token'].string ?? '',
        message = json['message'].string ?? '',
        error = json['error'].string ?? '',
        expiresIn = json['expires_in'].string ?? '',
        isFirstLogin = json['isFirstLogin'].boolean ?? false;


  Map<String, dynamic> toJson() {
    final map = <String, dynamic>{};
    map['accessToken'] = accessToken;
    return map;
  }
}
