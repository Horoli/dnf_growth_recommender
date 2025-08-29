class MPrice {
  final int lowestPrice;

  MPrice({required this.lowestPrice});

  factory MPrice.fromJson(Map<String, dynamic> json) => MPrice(
        lowestPrice: (json['lowestPrice'] as num).toInt(),
      );

  Map<String, dynamic> toJson() => {
        'lowestPrice': lowestPrice,
      };
}
