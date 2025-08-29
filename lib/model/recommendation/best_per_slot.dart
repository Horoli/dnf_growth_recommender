import 'package:dnf_growth_recommender/model/common/price.dart';

class MBestPerSlotEntry {
  final String slotId;
  final String slotName;
  final String itemId;
  final String itemName;
  final int upgrade;
  final MPrice price; // uses your existing Price model
  final Map<String, int>? status;
  final int deltaScore;
  final double efficiency;

  const MBestPerSlotEntry({
    required this.slotId,
    required this.slotName,
    required this.itemId,
    required this.itemName,
    required this.upgrade,
    required this.price,
    required this.deltaScore,
    required this.efficiency,
    required this.status,
  });

  factory MBestPerSlotEntry.fromJson(Map<String, dynamic> json) =>
      MBestPerSlotEntry(
        slotId: json['slotId'] as String,
        slotName: json['slotName'] as String,
        itemId: json['itemId'] as String,
        itemName: json['itemName'] as String,
        upgrade: (json['upgrade'] as num).toInt(),
        price: MPrice.fromJson(json['price'] as Map<String, dynamic>),
        deltaScore: (json['deltaScore'] as num).toInt(),
        efficiency: (json['efficiency'] as num).toDouble(),
        status: (json['status'] as Map<String, dynamic>?)?.map(
          (k, v) => MapEntry(k, (v as num).toInt()),
        ),
      );

  Map<String, dynamic> toJson() => {
        'slotId': slotId,
        'slotName': slotName,
        'itemId': itemId,
        'itemName': itemName,
        'upgrade': upgrade,
        'price': price.toJson(),
        'deltaScore': deltaScore,
        'efficiency': efficiency,
        'status': status,
      };
}
