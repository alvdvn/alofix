
import 'package:g_json/g_json.dart';

class ServerResponse<T> {
  String? message;
  int? statusCode;
  T? data;
  ServerResponse({this.message  = 'Có lỗi xảy ra vui lòng liên hệ admin.', this.statusCode = -1, this.data});


  ServerResponse.fromJson(JSON json) {
    statusCode = json['statusCode'].integer;
    message = json['message'].string;
  }

  Map<String, dynamic> toJson(){
    final map = <String, dynamic>{};
    map['message'] = message;
    map['data'] = data;
    map['statusCode'] = statusCode;
    return map;
  }



  bool get isLoadSuccess => statusCode == 200;

  void setData(T data){
    this.data = data;
  }

}
