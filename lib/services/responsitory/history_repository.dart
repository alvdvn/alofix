import 'package:base_project/models/history_call_log_model.dart';
import 'package:base_project/services/remote/api_provider.dart';
import 'package:flutter/material.dart';

class HistoryRepository {
  final _provider = ApiProvider();

  Future<List<HistoryCallLogModel>?> getInformation() async {
    try {
      final data = await _provider.get('api/calllogs',
          params: {}, isRequireAuth: true, backgroundMode: true);
      final res = data['data']
          .list
          ?.map((e) => HistoryCallLogModel.fromJson(e))
          .toList();
      return res;
    } catch (error,r) {
      debugPrint(error.toString());
      print(r);
      return [];
    }
  }
}
