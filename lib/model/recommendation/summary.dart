class MSummary {
  final int totalSlots;
  final int upgradeNeededSlots;
  final int recommendedPerSlot;

  MSummary({
    required this.totalSlots,
    required this.upgradeNeededSlots,
    required this.recommendedPerSlot,
  });

  factory MSummary.fromJson(Map<String, dynamic> json) => MSummary(
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
