import 'dart:convert';
import 'dart:ffi';

import 'package:base_project/models/call_log_model.dart';
import 'package:base_project/models/sync_call_log_model.dart';
import 'package:base_project/services/remote/api_provider.dart';
import 'package:flutter/material.dart';
import 'package:get/get.dart';
import '../local/app_share.dart';

class HistoryRepository {
  final _provider = ApiProvider();

  Future<List<CallLogModel>?> getInformation(
      {required int page,
      required int pageSize,
      String? searchItem,
      DateTime? startTime,
      DateTime? endTime}) async {
    String search = searchItem == null || searchItem == "" ? "" : "&Search=$searchItem";
    String start = startTime == null
        ? ""
        : "&dates=${startTime.month}%2F${startTime.day}%2F${startTime.year}";
    String end = endTime == null
        ? ""
        : "&dates=${endTime.month}%2F${endTime.day}%2F${endTime.year}";
    try {
      final data = await _provider.get(
          'api/calllogs/app?OnlyMe=true&Page=$page&Pagesize=$pageSize$search$start$end',
          params: {},
          isRequireAuth: true);
      final res = data['data'].list?.map((e) => CallLogModel.fromJson(e)).toList() ?? [];
      return res;
    } catch (error, r) {
      debugPrint(error.toString());
      debugPrint(r.toString());
      return [];
    }
  }

  Future syncCallLog({required List<SyncCallLogModel> listSync}) async {
    List<Map<String, dynamic>> listItem = <Map<String, dynamic>>[];
    for (var e in listSync) {
      Map<String, dynamic> params = {
        "Id": e.id.toString(),
        "PhoneNumber": e.phoneNumber.toString(),
        "Type": e.type,
        "UserId": e.userId,
        "Method": e.method,
        "RingAt": e.ringAt,
        "StartAt": e.startAt,
        "EndedAt": e.endedAt,
        "AnsweredAt": e.endedAt,
        "HotlineNumber": e.hotlineNumber.toString(),
        "CallDuration": e.callDuration,
        "timeRinging": e.timeRinging,
        "EndedBy": e.endedBy,
        "customData": e.customData,
        "AnsweredDuration": e.answeredDuration,
        "RecordUrl": e.recordUrl,
        "Onlyme": true
      };
      listItem.add(params);
    }
    final params = listItem;
    print('params sync callLog ${params.toList()}');
    try {
      final data = await _provider.postListString('api/calllogs', params, isRequireAuth: true);
      Map<String,dynamic> resposne = jsonDecode(data.toString());
      final isSuccess = resposne['success'] as bool;
      print('data success ${isSuccess.toString()}');
      if (isSuccess) {
        final firstItemCall = listSync.first.time1970;
        String convertFirstItemCall = firstItemCall.toString();
        AppShared.shared.saveLastDateCalLogSync(convertFirstItemCall);
      }
    } catch (error, r) {
      debugPrint(error.toString());
      debugPrint(r.toString());
    }
  }

  Future<List<CallLogModel>?> getDetailInformation(
      {String? searchItem,
        DateTime? startTime,
        DateTime? endTime}) async {
    String search = searchItem == null || searchItem == "" ? "" : "&Search=$searchItem";
    String start = startTime == null
        ? ""
        : "&dates=${startTime.month}%2F${startTime.day}%2F${startTime.year}";
    String end = endTime == null
        ? ""
        : "&dates=${endTime.month}%2F${endTime.day}%2F${endTime.year}";
    try {
      final data = await _provider.get(
          'api/calllogs/app?OnlyMe=true&Page=1&Pagesize=1000$search$start$end',
          params: {},
          isRequireAuth: true);
      final res = data['data'].list?.map((e) => CallLogModel.fromJson(e)).toList() ?? [];
      return res;
    } catch (error, r) {
      debugPrint(error.toString());
      debugPrint(r.toString());
      return [];
    }
  }
}
