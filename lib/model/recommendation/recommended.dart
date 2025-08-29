import 'package:dnf_growth_recommender/model/character/character.dart';
import 'package:dnf_growth_recommender/model/plan/plan.dart';
import 'package:dnf_growth_recommender/model/recommendation/best_per_slot.dart';
import 'package:dnf_growth_recommender/model/recommendation/slot_recommendation.dart';
import 'package:dnf_growth_recommender/model/recommendation/summary.dart';
import 'package:flutter/foundation.dart'; //debugPrint

class MRecommended {
  final MCharacter character;
  final MSummary summary;
  final int? budget;
  final MPlan? plan;
  final Map<String, MBestPerSlotEntry>? bestPerSlot;

  /// 슬롯 키(예: WEAPON, TITLE, PANTS …) → 슬롯별 추천 데이터
  final Map<String, MSlotRecommendation> enchantRecommendations;

  MRecommended({
    required this.character,
    required this.summary,
    required this.enchantRecommendations,
    this.budget,
    this.plan,
    this.bestPerSlot,
  });

  factory MRecommended.fromJson(final Map<String, dynamic> json) {
    try {
      // --- enchantRecommendations ---
      Map<String, MSlotRecommendation> parsedEnchantRecommendations =
          <String, MSlotRecommendation>{};

      final Object? rawRecommendations = json['enchantRecommendations'];
      if (rawRecommendations is Map<String, dynamic>) {
        try {
          parsedEnchantRecommendations =
              rawRecommendations.map<String, MSlotRecommendation>(
            (final String key, final dynamic value) {
              final Map<String, dynamic> valueMap =
                  value as Map<String, dynamic>;
              return MapEntry<String, MSlotRecommendation>(
                key,
                MSlotRecommendation.fromJson(valueMap),
              );
            },
          );
        } catch (error) {
          debugPrint('Error parsing enchantRecommendations: $error');
          parsedEnchantRecommendations = <String, MSlotRecommendation>{};
        }
      }

      // --- budget ---
      int? parsedBudget;
      try {
        final Object? budgetValue = json['budget'];
        if (budgetValue is int) {
          parsedBudget = budgetValue;
        } else if (budgetValue is num) {
          parsedBudget = budgetValue.toInt();
        } else if (budgetValue is String) {
          parsedBudget = int.tryParse(budgetValue);
        }
      } catch (error) {
        debugPrint('Error parsing budget: $error');
        parsedBudget = null;
      }

      // --- plan ---
      MPlan? parsedPlan;
      try {
        final Object? planData = json['plan'];
        if (planData is Map<String, dynamic>) {
          parsedPlan = MPlan.fromJson(planData);
        }
      } catch (error) {
        debugPrint('Error parsing plan: $error');
        parsedPlan = null;
      }

      // --- bestPerSlot ---
      Map<String, MBestPerSlotEntry>? parsedBestPerSlot;
      try {
        final Object? bestPerSlotData = json['bestPerSlot'];
        if (bestPerSlotData is Map<String, dynamic>) {
          final Map<String, MBestPerSlotEntry> temp =
              <String, MBestPerSlotEntry>{};

          for (final MapEntry<String, dynamic> entry
              in bestPerSlotData.entries) {
            try {
              final dynamic raw = entry.value;
              if (raw is Map<String, dynamic>) {
                temp[entry.key] = MBestPerSlotEntry.fromJson(raw);
              } else {
                debugPrint(
                  'Warning: Invalid bestPerSlot data for key ${entry.key}: ${entry.value}',
                );
              }
            } catch (error) {
              debugPrint(
                  'Error parsing bestPerSlot entry ${entry.key}: $error');
            }
          }

          parsedBestPerSlot = temp.isEmpty ? null : temp;
        }
      } catch (error) {
        debugPrint('Error parsing bestPerSlot: $error');
        parsedBestPerSlot = null;
      }

      return MRecommended(
        character:
            MCharacter.fromJson(json['character'] as Map<String, dynamic>),
        summary: MSummary.fromJson(json['summary'] as Map<String, dynamic>),
        enchantRecommendations: parsedEnchantRecommendations,
        budget: parsedBudget,
        plan: parsedPlan,
        bestPerSlot: parsedBestPerSlot,
      );
    } on TypeError catch (error) {
      throw FormatException('Type error in Recommended.fromJson: $error');
    } on FormatException catch (error) {
      throw FormatException('Format error in Recommended.fromJson: $error');
    } catch (error) {
      throw FormatException('Unexpected error in Recommended.fromJson: $error');
    }
  }

  Map<String, dynamic> toJson() {
    final Map<String, dynamic> map = <String, dynamic>{
      'character': character.toJson(),
      'summary': summary.toJson(),
      'enchantRecommendations': enchantRecommendations.map<String, dynamic>(
        (final String key, final MSlotRecommendation value) =>
            MapEntry<String, dynamic>(key, value.toJson()),
      ),
    };
    if (budget != null) map['budget'] = budget;
    if (plan != null) map['plan'] = plan!.toJson();
    if (bestPerSlot != null) {
      map['bestPerSlot'] = bestPerSlot!.map<String, dynamic>(
        (final String key, final MBestPerSlotEntry value) =>
            MapEntry<String, dynamic>(key, value.toJson()),
      );
    }
    return map;
  }

  MRecommended copyWith({
    MCharacter? character,
    MSummary? summary,
    Map<String, MSlotRecommendation>? enchantRecommendations,
    int? budget,
    MPlan? plan,
    Map<String, MBestPerSlotEntry>? bestPerSlot,
  }) {
    return MRecommended(
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
