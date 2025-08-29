import 'package:dnf_growth_recommender/model/plan/chosen.dart';

class MPlan {
  final int spent;
  final int remain;
  final Map<String, int> increaseStats;
  final List<MChosen> chosen;
  final int totalDelta;

  const MPlan({
    required this.spent,
    required this.remain,
    required this.increaseStats,
    required this.chosen,
    required this.totalDelta,
  });

  factory MPlan.fromJson(Map<String, dynamic> json) => MPlan(
        spent: (json['spent'] as num).toInt(),
        remain: (json['remain'] as num).toInt(),
        increaseStats: (json['increaseStats'] as Map<String, dynamic>)
            .map((k, v) => MapEntry(k, (v as num).toInt())),
        chosen: (json['chosen'] as List<dynamic>? ?? [])
            .map((e) => MChosen.fromJson(e as Map<String, dynamic>))
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
