part of dnf_growth_recommender;

class RecommendedData {
  final Character character;
  final Summary summary;

  /// 슬롯 키(예: WEAPON, TITLE, PANTS …) → 슬롯별 추천 데이터
  final Map<String, SlotRecommendation> enchantRecommendations;

  RecommendedData({
    required this.character,
    required this.summary,
    required this.enchantRecommendations,
  });

  factory RecommendedData.fromJson(Map<String, dynamic> json) {
    final raw = json['enchantRecommendations'] as Map<String, dynamic>? ?? {};
    final mapped = raw.map((k, v) => MapEntry(
          k,
          SlotRecommendation.fromJson(v as Map<String, dynamic>),
        ));
    return RecommendedData(
      character: Character.fromJson(json['character'] as Map<String, dynamic>),
      summary: Summary.fromJson(json['summary'] as Map<String, dynamic>),
      enchantRecommendations: mapped,
    );
  }

  Map<String, dynamic> toJson() => {
        'character': character.toJson(),
        'summary': summary.toJson(),
        'enchantRecommendations':
            enchantRecommendations.map((k, v) => MapEntry(k, v.toJson())),
      };

  static RecommendedData fromJsonString(String s) =>
      RecommendedData.fromJson(jsonDecode(s) as Map<String, dynamic>);
}

// ---------------- core submodels ----------------

class Character {
  final String serverId;
  final String characterId;
  final String characterName;
  final String jobName;
  final String jobGrowName;
  final int fame;

  Character({
    required this.serverId,
    required this.characterId,
    required this.characterName,
    required this.jobName,
    required this.jobGrowName,
    required this.fame,
  });

  factory Character.fromJson(Map<String, dynamic> json) => Character(
        serverId: json['serverId'] as String,
        characterId: json['characterId'] as String,
        characterName: json['characterName'] as String,
        jobName: json['jobName'] as String,
        jobGrowName: json['jobGrowName'] as String,
        fame: (json['fame'] as num).toInt(),
      );

  Map<String, dynamic> toJson() => {
        'serverId': serverId,
        'characterId': characterId,
        'characterName': characterName,
        'jobName': jobName,
        'jobGrowName': jobGrowName,
        'fame': fame,
      };
}

class Summary {
  final int totalSlots;
  final int upgradeNeededSlots;
  final int recommendedPerSlot;

  Summary({
    required this.totalSlots,
    required this.upgradeNeededSlots,
    required this.recommendedPerSlot,
  });

  factory Summary.fromJson(Map<String, dynamic> json) => Summary(
        totalSlots: (json['totalSlots'] as num).toInt(),
        upgradeNeededSlots: (json['upgradeNeededSlots'] as num).toInt(),
        recommendedPerSlot: (json['recommendedPerSlot'] as num).toInt(),
      );

  Map<String, dynamic> toJson() => {
        'totalSlots': totalSlots,
        'upgradeNeededSlots': upgradeNeededSlots,
        'recommendedPerSlot': recommendedPerSlot,
      };
}

// ---------------- enchant recommendations ----------------

class SlotRecommendation {
  final String slotId;
  final String slotName;
  final String? equippedItemId;
  final String? equippedItemName;

  /// 현재 장착된 마부/옵션 수치 (키: 옵션명, 값: 수치)
  final Map<String, num> currentStats;

  /// 추천 카드/마부 목록
  final List<RecommendedEnchant> recommended;

  SlotRecommendation({
    required this.slotId,
    required this.slotName,
    this.equippedItemId,
    this.equippedItemName,
    required this.currentStats,
    required this.recommended,
  });

  factory SlotRecommendation.fromJson(Map<String, dynamic> json) =>
      SlotRecommendation(
        slotId: json['slotId'] as String,
        slotName: json['slotName'] as String,
        equippedItemId: json['equippedItemId'] as String?,
        equippedItemName: json['equippedItemName'] as String?,
        currentStats: (json['currentStats'] as Map<String, dynamic>? ?? {})
            .map((k, v) => MapEntry(k, v as num)),
        recommended: (json['recommended'] as List<dynamic>? ?? [])
            .map((e) => RecommendedEnchant.fromJson(e as Map<String, dynamic>))
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

class RecommendedEnchant {
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
  final Diff diff;
  final Price? price;

  RecommendedEnchant({
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

  factory RecommendedEnchant.fromJson(Map<String, dynamic> json) =>
      RecommendedEnchant(
        itemId: json['itemId'] as String,
        itemName: json['itemName'] as String,
        slotId: json['slotId'] as String,
        slotName: json['slotName'] as String,
        upgrade: (json['upgrade'] as num).toInt(),
        rarity: json['rarity'] as String,
        score: (json['score'] as num).toInt(),
        recStats: (json['recStats'] as Map<String, dynamic>? ?? {})
            .map((k, v) => MapEntry(k, v as num)),
        diff: Diff.fromJson(json['diff'] as Map<String, dynamic>),
        price: json['price'] != null
            ? Price.fromJson(json['price'] as Map<String, dynamic>)
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

class Diff {
  /// 스탯별 변화량 (키: 스탯명)
  final Map<String, StatDelta> byStat;
  final DiffMeta meta;

  Diff({required this.byStat, required this.meta});

  factory Diff.fromJson(Map<String, dynamic> json) {
    final raw = json['byStat'] as Map<String, dynamic>? ?? {};
    final mapped = raw.map((k, v) => MapEntry(
          k,
          StatDelta.fromJson(v as Map<String, dynamic>),
        ));
    return Diff(
      byStat: mapped,
      meta: DiffMeta.fromJson(json['meta'] as Map<String, dynamic>),
    );
  }

  Map<String, dynamic> toJson() => {
        'byStat': byStat.map((k, v) => MapEntry(k, v.toJson())),
        'meta': meta.toJson(),
      };
}

class StatDelta {
  final num current;
  final num recommended;
  final num delta;

  StatDelta({
    required this.current,
    required this.recommended,
    required this.delta,
  });

  factory StatDelta.fromJson(Map<String, dynamic> json) => StatDelta(
        current: json['current'] as num? ?? 0,
        recommended: json['recommended'] as num? ?? 0,
        delta: json['delta'] as num? ?? 0,
      );

  Map<String, dynamic> toJson() => {
        'current': current,
        'recommended': recommended,
        'delta': delta,
      };
}

class DiffMeta {
  final num elemDelta;
  final int deltaScore;

  DiffMeta({required this.elemDelta, required this.deltaScore});

  factory DiffMeta.fromJson(Map<String, dynamic> json) => DiffMeta(
        elemDelta: json['elemDelta'] as num? ?? 0,
        deltaScore: (json['deltaScore'] as num).toInt(),
      );

  Map<String, dynamic> toJson() => {
        'elemDelta': elemDelta,
        'deltaScore': deltaScore,
      };
}

class Price {
  final int lowestPrice;

  Price({required this.lowestPrice});

  factory Price.fromJson(Map<String, dynamic> json) => Price(
        lowestPrice: (json['lowestPrice'] as num).toInt(),
      );

  Map<String, dynamic> toJson() => {
        'lowestPrice': lowestPrice,
      };
}
