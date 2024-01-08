import 'dart:convert';

import 'package:base_project/database/models/call_log.dart';
import 'package:base_project/services/remote/api_provider.dart';
import 'package:flutter/material.dart';

class HistoryRepository {
  final _provider = ApiProvider();

  Future<List<CallLog>> getInformation({int page = 1}) async {
    try {
      final data = await _provider.get('api/calllogs/flatten?page=$page',
          params: {}, isRequireAuth: true);
      final res =
          data['items'].list?.map((e) => CallLog.fromJson(e)).toList() ?? [];
      return res;
    } catch (error, r) {
      debugPrint(error.toString());
      debugPrint(r.toString());
      return [];
    }
  }

  Future<bool> syncCallLog({required List<CallLog> listSync}) async {
    if (listSync.isEmpty) {
      return true;
    }

    try {
      var lstData = listSync.map((e) => e.toJson()).toList();
          final data = await _provider.postListString(
          'api/calllogs', lstData,
          isRequireAuth: true);
      Map<String, dynamic> response = jsonDecode(data.toString());
      print("sync CALL LOG============================== ${data}");
      return response['success'] != null && response['success'] as bool;

    } catch (error, r) {
      debugPrint(error.toString());
      debugPrint(r.toString());
      return false;
    }
  }

  Future<List<CallLog>> getDetailInformation({required String phone}) async {
    try {
      final data = await _provider.get(
          'api/calllogs/detail/flatten?phone=$phone',
          params: {},
          isRequireAuth: true);
      final res =
          data['items'].list?.map((e) => CallLog.fromJson(e)).toList() ?? [];
      print("res=========================================$res");
      return res;
    } catch (error, r) {
      debugPrint(error.toString());
      debugPrint(r.toString());
      return [];
    }
  }
}
