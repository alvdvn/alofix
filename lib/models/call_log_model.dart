import 'package:g_json/g_json.dart';

import 'history_call_log_app_model.dart';

class CallLogModel {
  String? key;
  List<HistoryCallLogAppModel>? calls;

  CallLogModel({this.key, this.calls});

  CallLogModel.fromJson(JSON json) {
    key = json['key'].string;
    calls = json['calls']
        .list
        ?.map((e) => HistoryCallLogAppModel.fromJson(JSON(e)))
        .toList();
  }
}
