import 'package:dnf_growth_recommender/model/common/price.dart';

class MChosen {
  final String slotId;
  final String slotName;
  final String equippedItemName;
  final String itemId;
  final String itemName;
  final MPrice price; // uses your existing Price model
  final int score;
  final int baseScore;
  final int deltaScore;
  final double efficiency;
  final Map<String, int>? status;
  final String rarity;

  const MChosen({
    required this.slotId,
    required this.slotName,
    required this.equippedItemName,
    required this.itemId,
    required this.itemName,
    required this.price,
    required this.score,
    required this.baseScore,
    required this.deltaScore,
    required this.efficiency,
    required this.rarity,
    this.status,
  });

  factory MChosen.fromJson(Map<String, dynamic> json) => MChosen(
        slotId: json['slotId'] as String,
        slotName: json['slotName'] as String,
        equippedItemName: json['equippedItemName'] as String,
        itemId: json['itemId'] as String,
        itemName: json['itemName'] as String,
        price: MPrice.fromJson(json['price'] as Map<String, dynamic>),
        score: (json['score'] as num).toInt(),
        baseScore: (json['baseScore'] as num).toInt(),
        deltaScore: (json['deltaScore'] as num).toInt(),
        efficiency: (json['efficiency'] as num).toDouble(),
        rarity: json['rarity'] as String,
        status: (json['status'] as Map<String, dynamic>?)?.map(
          (k, v) => MapEntry(k, (v as num).toInt()),
        ),
      );

  Map<String, dynamic> toJson() => {
        'slotId': slotId,
        'slotName': slotName,
        'equippedItemName': equippedItemName,
        'itemId': itemId,
        'itemName': itemName,
        'price': price.toJson(),
        'score': score,
        'baseScore': baseScore,
        'deltaScore': deltaScore,
        'efficiency': efficiency,
        'rarity': rarity,
        if (status != null) 'status': status,
      };
}
