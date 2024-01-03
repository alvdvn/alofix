import 'package:g_json/g_json.dart';

class SimCard {
  String? phoneNumber;
  int? simSlotIndex;

  SimCard({this.phoneNumber, this.simSlotIndex});

  factory SimCard.fromJson(Map<String, dynamic> json) {
    return SimCard(
      phoneNumber: json['phoneNumber'],
      simSlotIndex: json['simSlotIndex'],
    );
  }
}
