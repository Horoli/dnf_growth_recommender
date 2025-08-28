part of dnf_growth_recommender;

class RecommendedData {
  final Character character;
  final Summary summary;
  final int? budget;
  final Plan? plan;
  final Map<String, BestPerSlotEntry>? bestPerSlot;

  /// 슬롯 키(예: WEAPON, TITLE, PANTS …) → 슬롯별 추천 데이터
  final Map<String, SlotRecommendation> enchantRecommendations;

  RecommendedData({
    required this.character,
    required this.summary,
    required this.enchantRecommendations,
    this.budget,
    this.plan,
    this.bestPerSlot,
  });

  factory RecommendedData.fromJson(Map<String, dynamic> json) {
    try {
      // enchantRecommendations 파싱 with null safety
      Map<String, SlotRecommendation> enchantRecommendations = {};
      final rawRecommendations = json['enchantRecommendations'];
      if (rawRecommendations != null &&
          rawRecommendations is Map<String, dynamic>) {
        try {
          enchantRecommendations = rawRecommendations.map((k, v) {
            // if (v is Map<String, dynamic>) {
            return MapEntry(k, SlotRecommendation.fromJson(v));
            // }
            // 잘못된 데이터 타입인 경우 해당 항목 스킵
          });
        } catch (e) {
          print('Error parsing enchantRecommendations: $e');
          enchantRecommendations = {};
        }
      }

      // budget 파싱 with type safety
      int? budget;
      try {
        final budgetValue = json['budget'];
        if (budgetValue != null) {
          if (budgetValue is int) {
            budget = budgetValue;
          } else if (budgetValue is double) {
            budget = budgetValue.toInt();
          } else if (budgetValue is String) {
            budget = int.tryParse(budgetValue);
          }
        }
      } catch (e) {
        print('Error parsing budget: $e');
        budget = null;
      }

      // plan 파싱 with null safety
      Plan? plan;
      try {
        final planData = json['plan'];
        if (planData != null && planData is Map<String, dynamic>) {
          plan = Plan.fromJson(planData);
        }
      } catch (e) {
        print('Error parsing plan: $e');
        plan = null;
      }

      // bestPerSlot 파싱 with null safety
      Map<String, BestPerSlotEntry>? bestPerSlot;
      try {
        final bestPerSlotData = json['bestPerSlot'];
        if (bestPerSlotData != null &&
            bestPerSlotData is Map<String, dynamic>) {
          bestPerSlot = {};
          for (final entry in bestPerSlotData.entries) {
            try {
              if (entry.value is Map<String, dynamic>) {
                bestPerSlot[entry.key] = BestPerSlotEntry.fromJson(entry.value);
              } else {
                print(
                    'Warning: Invalid bestPerSlot data for key ${entry.key}: ${entry.value}');
              }
            } catch (e) {
              print('Error parsing bestPerSlot entry ${entry.key}: $e');
              // 해당 항목 스킵하고 계속 진행
            }
          }

          // 빈 맵인 경우 null로 설정
          if (bestPerSlot.isEmpty) {
            bestPerSlot = null;
          }
        }
      } catch (e) {
        print('Error parsing bestPerSlot: $e');
        bestPerSlot = null;
      }

      return RecommendedData(
        character:
            Character.fromJson(json['character'] as Map<String, dynamic>),
        summary: Summary.fromJson(json['summary'] as Map<String, dynamic>),
        enchantRecommendations: enchantRecommendations,
        budget: budget,
        plan: plan,
        bestPerSlot: bestPerSlot,
      );
    } on TypeError catch (e) {
      throw FormatException('Type error in RecommendedData.fromJson: $e');
    } on FormatException catch (e) {
      throw FormatException('Format error in RecommendedData.fromJson: $e');
    } catch (e) {
      throw FormatException('Unexpected error in RecommendedData.fromJson: $e');
    }
  }

  /// JSON 변환 시 디버깅을 위한 안전한 toJson 메서드
  Map<String, dynamic> toJson() {
    return {
      'character': character.toJson(),
      'summary': summary.toJson(),
      'enchantRecommendations':
          enchantRecommendations.map((k, v) => MapEntry(k, v.toJson())),
      if (budget != null) 'budget': budget,
      if (plan != null) 'plan': plan!.toJson(),
      if (bestPerSlot != null)
        'bestPerSlot': bestPerSlot!.map((k, v) => MapEntry(k, v.toJson())),
    };
  }

  /// 데이터 유효성 검사
  // bool isValid() {
  //   try {
  //     // 필수 필드들이 유효한지 확인
  //     if (!character.isValid() || !summary.isValid()) {
  //       return false;
  //     }

  //     // enchantRecommendations가 유효한지 확인
  //     for (final recommendation in enchantRecommendations.values) {
  //       if (!recommendation.isValid()) {
  //         return false;
  //       }
  //     }

  //     // nullable 필드들이 존재할 경우 유효성 확인
  //     if (plan != null && !plan!.isValid()) {
  //       return false;
  //     }

  //     if (bestPerSlot != null) {
  //       for (final entry in bestPerSlot!.values) {
  //         if (!entry.isValid()) {
  //           return false;
  //         }
  //       }
  //     }

  //     return true;
  //   } catch (e) {
  //     print('Error in RecommendedData.isValid(): $e');
  //     return false;
  //   }
  // }

  /// 안전한 복사 생성자
  RecommendedData copyWith({
    Character? character,
    Summary? summary,
    Map<String, SlotRecommendation>? enchantRecommendations,
    int? budget,
    Plan? plan,
    Map<String, BestPerSlotEntry>? bestPerSlot,
  }) {
    return RecommendedData(
      character: character ?? this.character,
      summary: summary ?? this.summary,
      enchantRecommendations:
          enchantRecommendations ?? this.enchantRecommendations,
      budget: budget ?? this.budget,
      plan: plan ?? this.plan,
      bestPerSlot: bestPerSlot ?? this.bestPerSlot,
    );
  }
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

class Plan {
  final int spent;
  final int remain;
  final Map<String, int> increaseStats;
  final List<PlannedChoice> chosen;
  final int totalDelta;

  const Plan({
    required this.spent,
    required this.remain,
    required this.increaseStats,
    required this.chosen,
    required this.totalDelta,
  });

  factory Plan.fromJson(Map<String, dynamic> json) => Plan(
        spent: (json['spent'] as num).toInt(),
        remain: (json['remain'] as num).toInt(),
        increaseStats: (json['increaseStats'] as Map<String, dynamic>)
            .map((k, v) => MapEntry(k, (v as num).toInt())),
        chosen: (json['chosen'] as List<dynamic>? ?? [])
            .map((e) => PlannedChoice.fromJson(e as Map<String, dynamic>))
            .toList(),
        totalDelta: (json['totalDelta'] as num).toInt(),
      );

  Map<String, dynamic> toJson() => {
        'spent': spent,
        'remain': remain,
        'chosen': chosen.map((e) => e.toJson()).toList(),
        'totalDelta': totalDelta,
      };
}

class PlannedChoice {
  final String slotId;
  final String slotName;
  final String equippedItemName;
  final String itemId;
  final String itemName;
  final Price price; // uses your existing Price model
  final int score;
  final int baseScore;
  final int deltaScore;
  final double efficiency;
  final Map<String, int>? status;
  final String rarity;

  const PlannedChoice({
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

  factory PlannedChoice.fromJson(Map<String, dynamic> json) => PlannedChoice(
        slotId: json['slotId'] as String,
        slotName: json['slotName'] as String,
        equippedItemName: json['equippedItemName'] as String,
        itemId: json['itemId'] as String,
        itemName: json['itemName'] as String,
        price: Price.fromJson(json['price'] as Map<String, dynamic>),
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

class BestPerSlotEntry {
  final String slotId;
  final String slotName;
  final String itemId;
  final String itemName;
  final int upgrade;
  final Price price; // uses your existing Price model
  final int deltaScore;
  final double efficiency;

  const BestPerSlotEntry({
    required this.slotId,
    required this.slotName,
    required this.itemId,
    required this.itemName,
    required this.upgrade,
    required this.price,
    required this.deltaScore,
    required this.efficiency,
  });

  factory BestPerSlotEntry.fromJson(Map<String, dynamic> json) =>
      BestPerSlotEntry(
        slotId: json['slotId'] as String,
        slotName: json['slotName'] as String,
        itemId: json['itemId'] as String,
        itemName: json['itemName'] as String,
        upgrade: (json['upgrade'] as num).toInt(),
        price: Price.fromJson(json['price'] as Map<String, dynamic>),
        deltaScore: (json['deltaScore'] as num).toInt(),
        efficiency: (json['efficiency'] as num).toDouble(),
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
      };
}
