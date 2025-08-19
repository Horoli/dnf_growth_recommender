part of 'dnf_growth_recommender.dart';

late ServiceDnf GServiceDnf;

extension EquippedItemIds on Map<String, SlotRecommendation> {
  String? get weaponId => this['WEAPON']?.equippedItemId;
  String? get titleId => this['TITLE']?.equippedItemId;
  String? get jacketId => this['JACKET']?.equippedItemId;
  String? get shoulderId => this['SHOULDER']?.equippedItemId;
  String? get pantsId => this['PANTS']?.equippedItemId;
  String? get shoesId => this['SHOES']?.equippedItemId;
  String? get waistId => this['WAIST']?.equippedItemId;
  String? get amuletId => this['AMULET']?.equippedItemId;
  String? get wristId => this['WRIST']?.equippedItemId;
  String? get ringId => this['RING']?.equippedItemId;
  String? get supportId => this['SUPPORT']?.equippedItemId;
  // 주의: API 키가 MAGIC_STONE이 아니라 "MAGIC_STON"
  String? get magicStoneId => this['MAGIC_STON']?.equippedItemId;
  String? get earringId => this['EARRING']?.equippedItemId;
}

// UI에서 보여줄 순서
const List<String> leftSlots = [
  'SHOULDER',
  'JACKET',
  'PANTS',
  'WAIST',
  'SHOES',
];

const List<String> rightSlots = [
  'WEAPON',
  'TITLE',
  'WRIST',
  'AMULET',
  'SUPPORT',
  'RING',
  'EARRING',
  'MAGIC_STON',
];

// 편의 URL 빌더
String itemImgUrl(String base, String path, String id, {String? zoom}) {
  final z = (zoom == null || zoom.isEmpty) ? '' : '&zoom=$zoom';
  return "$base/$path?type=item&id=$id$z";
}
