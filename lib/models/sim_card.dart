
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
