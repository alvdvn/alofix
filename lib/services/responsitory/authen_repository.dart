import 'package:base_project/services/remote/api_provider.dart';
import 'package:base_project/services/response_model/login_response.dart';
import 'package:flutter/material.dart';

class AuthRepository {
  final _provider = ApiProvider();

  Future<LoginResponse> login(String phoneNumber, String password) async {
    final params = {
      'UserName': phoneNumber,
      'Password': password,
    };
    try {
      final data = await _provider.post('token', params,backgroundMode: true);
      final response = LoginResponse.fromJson(data);
      return LoginResponse(
          statusCode: response.accessToken!.isEmpty ? 402 : 200,
          message: response.message ?? "Đăng nhập thanh công",
          accessToken: response.accessToken,
          expiresIn: response.expiresIn,
          isFirstLogin: response.isFirstLogin
      );
    } catch (error) {
      debugPrint(error.toString());
      return LoginResponse(statusCode: 500);
    }
  }

  Future<LoginResponse> fristChangePassword(
      {required String token,
        required String newPassword,
        required String confirmPassword}) async {
    final params = {
      'token': token,
      'newPassword': newPassword,
      'confirmPassword': confirmPassword,
    };
    print('reuqest fristchange' + params.toString());
    try {
      final data = await _provider.post('api/account/password-first', params, isRequireAuth: true, backgroundMode: true);
      final response = LoginResponse.fromJson(data);
      return LoginResponse(
          statusCode: response.accessToken!.isEmpty ? 402 : 200,
          message: response.message ?? "Đăng nhập thanh công",
          accessToken: response.accessToken,
          expiresIn: response.expiresIn
      );
    } catch (error) {
      debugPrint(error.toString());
      return LoginResponse(statusCode: 500);
    }
  }
}
