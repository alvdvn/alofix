import 'package:base_project/models/history_call_log_model.dart';
import 'package:base_project/services/remote/api_provider.dart';
import 'package:base_project/services/response_model/login_response.dart';
import 'package:flutter/material.dart';

class HistoryRepository {
  final _provider = ApiProvider();



  // Future<HistoryCallLogModel> getInformation() async {
  //   try {
  //     final data = await _provider.get('api/account',
  //         params: {}, isRequireAuth: true, backgroundMode: true);
  //     final response = AccountModel.fromJson(data);
  //     return AccountModel(
  //         avatar: response.avatar,
  //         fullName: response.fullName,
  //         joinDate: response.joinDate,
  //         phone: response.phone);
  //   } catch (error) {
  //     debugPrint(error.toString());
  //     return AccountModel(statusCode: 500);
  //   }
  // }
}
