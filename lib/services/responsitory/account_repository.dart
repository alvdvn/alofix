import 'package:base_project/models/account_model.dart';
import 'package:base_project/services/remote/api_provider.dart';
import 'package:flutter/material.dart';

class AccountRepository {
  final _provider = ApiProvider();

  Future<AccountModel> getInformation() async {
    try {
      final data = await _provider.get('account',
          params: {}, isRequireAuth: true, backgroundMode: true);
      final response = AccountModel.fromJson(data);
      return AccountModel(
          avatar: response.avatar,
          fullName: response.fullName,
          joinDate: response.joinDate,
          phone: response.phone);
    } catch (error) {
      debugPrint(error.toString());
      return AccountModel(statusCode: 500);
    }
  }
}
