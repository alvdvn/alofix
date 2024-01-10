import 'dart:convert';

import 'package:floor/floor.dart';

@Entity(tableName: 'DeepLink', indices: [
  Index(value: ['saveAt', 'phone'])
])
class DeepLink {
  @PrimaryKey(autoGenerate: true)
  int? id;
  String phone = "";
  String? data = "";
  int? saveAt;

  DeepLink({this.id, required this.phone, this.data, required this.saveAt});

  @override
  String toString() {
    return "DeepLink{key:$id, value: $data, phone: $phone, saveAt: $saveAt)";
  }

  DeepLink.fromEntry({required String phone,
    required Map<String, String> json,
    required int time}) {
    phone = phone;
    data = jsonEncode(json);
    saveAt = time;
  }
}
