class MDiff {
  /// 스탯별 변화량 (키: 스탯명)
  final Map<String, MStatDelta> byStat;
  final DiffMeta meta;

  MDiff({required this.byStat, required this.meta});

  factory MDiff.fromJson(Map<String, dynamic> json) {
    final raw = json['byStat'] as Map<String, dynamic>? ?? {};
    final mapped = raw.map((k, v) => MapEntry(
          k,
          MStatDelta.fromJson(v as Map<String, dynamic>),
        ));
    return MDiff(
      byStat: mapped,
      meta: DiffMeta.fromJson(json['meta'] as Map<String, dynamic>),
    );
  }

  Map<String, dynamic> toJson() => {
        'byStat': byStat.map((k, v) => MapEntry(k, v.toJson())),
        'meta': meta.toJson(),
      };
}

class MStatDelta {
  final num current;
  final num recommended;
  final num delta;

  MStatDelta({
    required this.current,
    required this.recommended,
    required this.delta,
  });

  factory MStatDelta.fromJson(Map<String, dynamic> json) => MStatDelta(
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
