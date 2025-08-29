import 'package:dnf_growth_recommender/model/recommendation/recommended_enchant.dart';

class MSlotRecommendation {
  final String slotId;
  final String slotName;
  final String? equippedItemId;
  final String? equippedItemName;

  /// 현재 장착된 마부/옵션 수치 (키: 옵션명, 값: 수치)
  final Map<String, double> currentStats;

  /// 추천 카드/마부 목록
  final List<MRecommendedEnchant> recommended;

  MSlotRecommendation({
    required this.slotId,
    required this.slotName,
    this.equippedItemId,
    this.equippedItemName,
    required this.currentStats,
    required this.recommended,
  });

  factory MSlotRecommendation.fromJson(Map<String, dynamic> json) =>
      MSlotRecommendation(
        slotId: json['slotId'] as String,
        slotName: json['slotName'] as String,
        equippedItemId: json['equippedItemId'] as String?,
        equippedItemName: json['equippedItemName'] as String?,
        currentStats: (json['currentStats'] as Map<String, dynamic>? ?? {})
            .map((k, v) => MapEntry(k, v as double)),
        recommended: (json['recommended'] as List<dynamic>? ?? [])
            .map((e) => MRecommendedEnchant.fromJson(e as Map<String, dynamic>))
            .toList(),
      );

  Map<String, dynamic> toJson() => {
        'slotId': slotId,
        'slotName': slotName,
        'equippedItemId': equippedItemId,
        'equippedItemName': equippedItemName,
        'currentStats': currentStats,
        'recommended': recommended.map((e) => e.toJson()).toList(),
      };
}
