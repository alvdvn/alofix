import 'package:g_json/g_json.dart';

import 'history_call_log_model.dart';

class HistoryCallLogAppModel {
  String? phoneNumber;
  List<HistoryCallLogModel>? logs;

  HistoryCallLogAppModel({this.phoneNumber, this.logs});

  HistoryCallLogAppModel.fromJson(JSON json) {
    phoneNumber = json['phoneNumber'].string;
    logs = json['logs']
        .list
        ?.map((e) => HistoryCallLogModel.fromJson(JSON(e)))
        .toList();
  }

  @override
  String toString() {
    return '{logs: $logs, phoneNumber: $phoneNumber}';
  }
}
