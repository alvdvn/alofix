import 'package:base_project/models/history_call_log_model.dart';
import 'package:base_project/models/sync_call_log_model.dart';
import 'package:base_project/services/remote/api_provider.dart';
import 'package:flutter/material.dart';

class HistoryRepository {
  final _provider = ApiProvider();

  Future<List<HistoryCallLogModel>?> getInformation() async {
    try {
      final data = await _provider.get('api/calllogs?Page=1&Pagesize=50',
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
      Map<String, dynamic> val = {
        "Id": e.id.toString(),
        "PhoneNumber": e.phoneNumber.toString(),
        "Type": e.type,
        "UserId": e.userId,
        "Method": e.method,
        "RingAt": "2023-02-06 05:59 +0700",
        "StartAt": "2023-02-06 05:59 +0700",
        "EndedAt": "2023-02-06 05:59 +0700",
        "AnsweredAt": "2023-02-06 05:59 +0700",
        "HotlineNumber": e.hotlineNumber.toString(),
        "CallDuration": e.callDuration,
        "EndedBy": e.endedBy,
        "AnsweredDuration": e.answeredDuration,
        "RecordUrl": e.recordUrl
      };
      listItem.add(val);
    }
    final params = listItem;
    try {
      final data = await _provider.postListString('api/calllogs', params,
          isRequireAuth: true, backgroundMode: true);
    } catch (error) {
      debugPrint(error.toString());
    }
  }
}
