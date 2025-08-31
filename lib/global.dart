part of 'dnf_growth_recommender.dart';

late ServiceDnf GServiceDnf;

extension EquippedItemIds on Map<String, MSlotRecommendation> {
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

Widget buildCommonCard({Widget? child}) => Card(
      margin: const EdgeInsets.all(16),
      shape: const RoundedRectangleBorder(
        side: BorderSide(
          color: Color.fromARGB(255, 19, 57, 88),
        ),
      ),
      child: Padding(
        padding: const EdgeInsets.all(16.0),
        child: child,
      ),
    );

String statsTooltip(Map<String, double>? currentStats) {
  if (currentStats == null || currentStats.isEmpty) return '정보 없음';

  const List<String> statOrder = [
    '모든속성강화',
    '화속성강화',
    '수속성강화',
    '최종데미지',
    '물리공격력',
    '마법공격력',
    '독립공격력',
    '힘',
    '지능',
    '체력',
    '정신력',
    '물리크리티컬히트',
    '마법크리티컬히트',
    '공격력증폭',
  ];

  final sortedEntries = currentStats.entries.toList()
    ..sort((a, b) {
      final int aIndex = statOrder.indexOf(a.key);
      final int bIndex = statOrder.indexOf(b.key);
      final int aValue = aIndex == -1 ? 1 << 30 : aIndex;
      final int bValue = bIndex == -1 ? 1 << 30 : bIndex;
      if (aValue != bValue) return aValue.compareTo(bValue);
      return a.key.compareTo(b.key);
    });

  return sortedEntries
      .map((entry) => '• ${entry.key}: ${formatNumber(entry.value)}')
      .join('\n');
}

/// 소수점 .0 이면 정수로, 아니면 그대로
String formatNumber(num statValue) {
  final intValue = statValue.toInt();
  return (statValue == intValue) ? intValue.toString() : statValue.toString();
}

void showSnackbar(BuildContext context, String message, {Color? color}) {
  ScaffoldMessenger.of(context).showSnackBar(
    SnackBar(
      duration: const Duration(seconds: 2),
      content: Text(message),
      backgroundColor: color,
    ),
  );
}

class HResponse<T> {
  final bool isSuccess;
  final T? data;
  final String? errorMessage;
  final int? statusCode;

  HResponse._({
    required this.isSuccess,
    this.data,
    this.errorMessage,
    this.statusCode,
  });

  // 성공 응답
  factory HResponse.success(T data) {
    return HResponse._(
      isSuccess: true,
      data: data,
    );
  }

  // 에러 응답
  factory HResponse.error({
    required String message,
    int? statusCode,
  }) {
    return HResponse._(
      isSuccess: false,
      errorMessage: message,
      statusCode: statusCode,
    );
  }

  // 네트워크 에러
  factory HResponse.networkError(String message) {
    return HResponse._(
      isSuccess: false,
      errorMessage: message,
      statusCode: null,
    );
  }

  // 파싱 에러
  factory HResponse.parseError(String message) {
    return HResponse._(
      isSuccess: false,
      errorMessage: message,
    );
  }
}
