import 'package:base_project/models/call_log_model.dart';
import 'package:base_project/models/sync_call_log_model.dart';
import 'package:base_project/services/remote/api_provider.dart';
import 'package:flutter/material.dart';

class HistoryRepository {
  final _provider = ApiProvider();

  Future<List<CallLogModel>?> getInformation(
      {required int page,
      required int pageSize,
      String? searchItem,
      String? startTime,
      String? endTime}) async {
    String search = searchItem == null ? "" : "&Search=$searchItem";
    String start = startTime == null ? "" : "&Date=$startTime";
    String end = endTime == null ? "" : "&Date=$endTime";
    try {
      final data = await _provider.get(
          'api/calllogs/app?OnlyMe=true&Page=$page&Pagesize=$pageSize$search$start$end',
          params: {},
          isRequireAuth: true,
          backgroundMode: true);
      final res =
          data['data'].list?.map((e) => CallLogModel.fromJson(e)).toList();
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
        "customData": e.customData,
        "AnsweredDuration": e.answeredDuration,
        "RecordUrl": e.recordUrl,
        "Onlyme": true
      };
      listItem.add(params);
    }
    final params = listItem;
    try {
      await _provider.postListString('api/calllogs', params,
          isRequireAuth: true, backgroundMode: true);
    } catch (error, r) {
      debugPrint(error.toString());
      debugPrint(r.toString());
    }
  }
}
