import 'package:g_json/g_json.dart';

class BaseResponse {
  final String? message;
  final bool? success;

  BaseResponse({this.message, this.success});

  BaseResponse.fromJson(JSON json)
      : message = json['message'].string.toString() ,
        success = json['success'].boolean ?? false;
}
