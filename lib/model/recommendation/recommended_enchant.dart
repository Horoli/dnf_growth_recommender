import 'package:dnf_growth_recommender/model/common/diff.dart';
import 'package:dnf_growth_recommender/model/common/price.dart';

class MRecommendedEnchant {
  final String itemId;
  final String itemName;
  final String slotId;
  final String slotName;
  final int upgrade;
  final String rarity; // 예: 레전더리
  final int score;

  /// 추천 마부가 제공하는 스탯
  final Map<String, num> recStats;

  /// 현재 대비 변화량
  final MDiff diff;
  final MPrice? price;

  MRecommendedEnchant({
    required this.itemId,
    required this.itemName,
    required this.slotId,
    required this.slotName,
    required this.upgrade,
    required this.rarity,
    required this.score,
    required this.recStats,
    required this.diff,
    this.price,
  });

  factory MRecommendedEnchant.fromJson(Map<String, dynamic> json) =>
      MRecommendedEnchant(
        itemId: json['itemId'] as String,
        itemName: json['itemName'] as String,
        slotId: json['slotId'] as String,
        slotName: json['slotName'] as String,
        upgrade: (json['upgrade'] as num).toInt(),
        rarity: json['rarity'] as String,
        score: (json['score'] as num).toInt(),
        recStats: (json['recStats'] as Map<String, dynamic>? ?? {})
            .map((k, v) => MapEntry(k, v as num)),
        diff: MDiff.fromJson(json['diff'] as Map<String, dynamic>),
        price: json['price'] != null
            ? MPrice.fromJson(json['price'] as Map<String, dynamic>)
            : null,
      );

  Map<String, dynamic> toJson() => {
        'itemId': itemId,
        'itemName': itemName,
        'slotId': slotId,
        'slotName': slotName,
        'upgrade': upgrade,
        'rarity': rarity,
        'score': score,
        'recStats': recStats,
        'diff': diff.toJson(),
        if (price != null) 'price': price!.toJson(),
      };
}
