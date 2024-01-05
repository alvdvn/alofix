import 'package:base_project/extension.dart';
import 'package:base_project/models/account_model.dart';
import 'package:base_project/services/remote/api_provider.dart';
import 'package:base_project/services/response_model/base_response.dart';
import 'package:flutter/material.dart';

import '../../models/version_info_model.dart';

class AccountRepository {
  final _provider = ApiProvider();

  Future<AccountModel> getInformation() async {
    try {
      final data = await _provider.get('api/account',
          params: {}, isRequireAuth: true, backgroundMode: true);
      final response = AccountModel.fromJson(data);
      return AccountModel(
          avatar: response.avatar,
          fullName: response.fullName,
          departments: response.departments,
          hubs: response.hubs,
          roles: response.roles,
          joinDate: response.joinDate,
          phone: response.phone);
    } catch (error) {
      debugPrint(error.toString());
      return AccountModel(statusCode: 500);
    }
  }

  Future<BaseResponse> changePassword(
      {required String password,
      required String newPassword,
      required String confirmPassword}) async {
    final params = {
      'password': password,
      'newPassword': newPassword,
      'confirmPassword': confirmPassword,
    };
    try {
      final data = await _provider.post('api/account/password', params,
          isRequireAuth: true, backgroundMode: true);
      final response = BaseResponse.fromJson(data);
      return response;
    } catch (error) {
      debugPrint(error.toString());
      return BaseResponse(success: false, message: 'Vui lòng xem lại');
    }
  }

  Future<VersionInfoModel> versionApp() async {
    try {
      final data = await _provider.get('api/options',
          params: {}, isRequireAuth: true, backgroundMode: true);
      return VersionInfoModel.fromJson(data);
    } catch (error) {
      debugPrint(error.toString());
      return VersionInfoModel(statusCode: 500);
    }
  }
}
