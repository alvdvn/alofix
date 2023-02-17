import 'dart:convert';

import 'package:base_project/models/history_call_log_model.dart';
import 'package:base_project/models/sync_call_log_model.dart';
import 'package:base_project/services/remote/api_provider.dart';
import 'package:flutter/material.dart';

class HistoryRepository {
  final _provider = ApiProvider();

  Future<List<HistoryCallLogModel>?> getInformation({required int page,required int pageSize}) async {
    try {
      final data = await _provider.get('api/calllogs?Page=$page&Pagesize=$pageSize',
          params: {}, isRequireAuth: true, backgroundMode: true);
      final res = data['data']
          .list
          ?.map((e) => HistoryCallLogModel.fromJson(e))
          .toList();
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
        "EndedBy": e.endedBy,
        "customData":e.customData ?? jsonEncode(e.customData),
        "AnsweredDuration": e.answeredDuration,
        "RecordUrl": e.recordUrl
      };
      listItem.add(params);
    }
    final params = listItem;
    try {
      await _provider.postListString('api/calllogs', params,
          isRequireAuth: true, backgroundMode: true);
    } catch (error,r) {
      debugPrint(error.toString());
      debugPrint(r.toString());
    }
  }
}
