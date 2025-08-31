part of dnf_growth_recommender;

abstract class AbstractViewSearch extends StatefulWidget {
  const AbstractViewSearch({super.key});

  @override
  State<StatefulWidget> createState() => throw UnimplementedError();
}

abstract class AbstractViewSearchState<T extends AbstractViewSearch>
    extends State<T> {
  final TextEditingController ctlServer =
      TextEditingController(text: "casillas");
  final TextEditingController ctlId = TextEditingController(text: 'horoli');
  final TextEditingController ctlGold = TextEditingController(text: '50000000');

  String selectedSlotType = '';

  String serverId = SERVER.LIST.first['serverId']!;
  @override
  Widget build(BuildContext context) {
    return const Placeholder();
  }

  Widget buildSearchFields() {
    // 🔎 검색 영역 (buildCommonCard가 margin/padding 포함)
    return buildCommonCard(
        child: Row(
      spacing: SIZE.SPACING,
      children: [
        DropdownButtonFormField<String>(
          initialValue: serverId,
          decoration: const InputDecoration(labelText: '서버'),
          items: SERVER.LIST
              .map(
                (m) => DropdownMenuItem(
                  value: m['serverId']!,
                  child: Text(m['serverName']!),
                ),
              )
              .toList(),
          onChanged: (value) {
            if (value == null) return;
            setState(() {
              serverId = value;
              ctlServer.text = value;
            });
          },
        ).expand(),
        TextField(
          controller: ctlId,
          decoration: const InputDecoration(labelText: 'ID'),
        ).expand(),
        TextField(
          controller: ctlGold,
          decoration: const InputDecoration(labelText: '보유 골드'),
        ).expand(),
        IconButton(
          icon: const Icon(Icons.search),
          onPressed: () async {
            await GServiceDnf.getRecommendation(
              server: ctlServer.text,
              id: ctlId.text,
              gold: ctlGold.text.isEmpty ? null : ctlGold.text,
            );
          },
        ),
      ],
    ));
  }

  // height 고정
  Widget buildCharacterDetails(
    String charUrl,
    Map<String, MSlotRecommendation> slots,
  ) {
    final List<MapEntry<String, MSlotRecommendation>> getLeftSlots = leftSlots
        .where((k) => slots.containsKey(k))
        .map((k) => MapEntry(k, slots[k]!))
        .toList();

    final List<MapEntry<String, MSlotRecommendation>> getRightSlots = rightSlots
        .where((k) => slots.containsKey(k))
        .map((k) => MapEntry(k, slots[k]!))
        .toList();

    return buildCommonCard(
      child: Row(
        children: [
          _buildSlotGrid(getLeftSlots).expand(),
          Image.network(
            charUrl,
            errorBuilder: (_, __, ___) => const Icon(Icons.error),
          ).center,
          _buildSlotGrid(getRightSlots).expand(),
        ],
      ),
    );
  }

  // 💰 예산 정보 카드
  Widget buildBudgetCard(MRecommended data) {
    final int budget = data.budget ?? 0;
    final MPlan plan = data.plan!;
    final int spent = plan.spent;
    final int remain = plan.remain;
    final int totalDelta = plan.totalDelta;
    // final Map<String, int> increaseStats = plan.increaseStats;
    // final List<MChosen> chosen = plan.chosen;

    return buildCommonCard(
      child: Column(
        spacing: SIZE.SPACING,
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(
            '예산 계획',
            style: Theme.of(context)
                .textTheme
                .headlineSmall
                ?.copyWith(fontWeight: FontWeight.bold),
          ),
          Column(
            spacing: SIZE.SPACING,
            children: [
              Row(
                spacing: SIZE.SPACING,
                children: [
                  buildBudgetItem('총 예산', budget, Colors.blue).expand(),
                  buildBudgetItem('사용 예정', spent, Colors.orange).expand(),
                ],
              ).expand(),
              Row(
                spacing: SIZE.SPACING,
                children: [
                  buildBudgetItem('남은 예산', remain, Colors.green).expand(),
                  buildBudgetItem('총 점수', totalDelta, Colors.purple).expand(),
                ],
              ).expand(),
            ],
          ).expand(),
        ],
      ),
    );
  }

  Widget buildSelectedEnchants(MRecommended data) {
    final MPlan plan = data.plan!;
    final Map<String, int> increaseStats = plan.increaseStats;
    final List<MChosen> chosen = plan.chosen;
    return buildCommonCard(
      child: Column(
        spacing: SIZE.SPACING,
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          buildBudgetItem('총 스탯 증가', increaseStats, Colors.pink)
              .sizedBox(width: double.infinity),
          Text(
            '선택된 아이템 (${chosen.length}개)',
            style: Theme.of(context)
                .textTheme
                .titleMedium
                ?.copyWith(fontWeight: FontWeight.bold),
          ),
          ListView.builder(
            itemCount: chosen.length,
            itemBuilder: (context, index) {
              return buildChosenItemTile(chosen[index]);
            },
          ).expand(flex: 3),
        ],
      ),
    );
  }

  // 🔢 예산/통계 카드 내부 아이템
  Widget buildBudgetItem(String label, dynamic value, Color color) {
    return Container(
      width: double.infinity,
      decoration: BoxDecoration(
        color: color.withAlpha(30),
        borderRadius: BorderRadius.circular(10),
        border: Border.all(color: color.withAlpha(25)),
      ),
      child: Center(
        child: ListTile(
          title: Text(
            label,
            style: TextStyle(
              color: color,
              fontSize: SIZE.FONT_SIZE_SUBTITLE,
              fontWeight: FontWeight.w600,
            ),
          ),
          subtitle: Text(
            _formatNumber(value),
            style: TextStyle(
              color: color,
              fontSize: SIZE.FONT_SIZE_TITLE,
              fontWeight: FontWeight.bold,
            ),
          ),
        ),
      ),
    );
  }

  // 🛒 선택된 아이템 타일
  Widget buildChosenItemTile(MChosen item) {
    final String itemUrl =
        "${PATH.URL_BASE}/${PATH.URL_IMAGE}?type=item&id=${item.itemId}";
    final int price = item.price.lowestPrice;
    final int deltaScore = item.deltaScore;
    final double efficiency = item.efficiency;
    final Map<String, int>? stats = item.status;

    return Container(
      margin: const EdgeInsets.only(bottom: 8),
      padding: const EdgeInsets.all(12),
      decoration: BoxDecoration(
        border: Border.all(color: Colors.grey.withAlpha(30)),
        borderRadius: BorderRadius.circular(8),
      ),
      child: Row(
        spacing: SIZE.SPACING,
        children: [
          Image.network(
            itemUrl,
            fit: BoxFit.contain,
            errorBuilder: (_, __, ___) => const Icon(Icons.image),
          ).sizedBox(width: 40, height: 40),

          // 아이템 정보
          Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            spacing: 2,
            children: [
              Text(
                '${item.slotName} - ${item.itemName}',
                style: const TextStyle(fontWeight: FontWeight.bold),
                maxLines: 1,
                overflow: TextOverflow.ellipsis,
              ),
              Text(
                '세부 옵션: $stats',
                style: TextStyle(fontSize: 12, color: Colors.grey[600]),
                maxLines: 1,
                overflow: TextOverflow.ellipsis,
              ),
            ],
          ).expand(),

          // 가격/점수/효율
          Column(
            crossAxisAlignment: CrossAxisAlignment.end,
            spacing: 2,
            children: [
              Text(
                _formatNumber(price),
                style: const TextStyle(
                  fontWeight: FontWeight.bold,
                  color: Colors.green,
                ),
              ),
              Text('점수: $deltaScore',
                  style: TextStyle(fontSize: 12, color: Colors.grey[600])),
              Text('효율: ${efficiency.toStringAsFixed(8)}',
                  style: TextStyle(fontSize: 10, color: Colors.grey[500])),
            ],
          ),
        ],
      ),
    );
  }

  Widget buildEnchantRecommendationsList(MRecommended data) {
    final Map<String, MSlotRecommendation> slotRecommendation =
        data.enchantRecommendations;

    final List<MapEntry<String, MSlotRecommendation>> entries =
        slotRecommendation.entries
            .where((e) => e.value.recommended.isNotEmpty) // 빈 항목 필터링
            .toList();

    return buildCommonCard(
      child: Column(
        spacing: SIZE.SPACING,
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(
            '부위별 추천 마법부여',
            style: Theme.of(context)
                .textTheme
                .headlineSmall
                ?.copyWith(fontWeight: FontWeight.bold),
          ),
          SingleChildScrollView(
            child: ExpansionPanelList.radio(
              children: entries.map((e) {
                final String slotId = e.key; // 예: "weapon", "ring" ...
                final MSlotRecommendation slot = e.value;
                int recommendedLength = slot.recommended.length;

                return ExpansionPanelRadio(
                  value: slotId,
                  headerBuilder: (context, isExpanded) {
                    return Text('${slot.slotName} ${slot.recommended.length}개');
                  },
                  body: Column(
                    children:
                        slot.recommended.map((MRecommendedEnchant enchant) {
                      return buildEnchantRecommendationItem(enchant);
                    }).toList(),
                  ).sizedBox(height: (150 * recommendedLength).toDouble()),
                );
              }).toList(),
            ),
          ).expand(),
        ],
      ),
    );
  }

  Widget buildEnchantRecommendationItem(MRecommendedEnchant enchant) {
    final String itemUrl =
        "${PATH.URL_BASE}/${PATH.URL_IMAGE}?type=item&id=${enchant.itemId}";
    final int price = enchant.price!.lowestPrice;

    return Container(
      margin: const EdgeInsets.only(bottom: 8),
      padding: const EdgeInsets.all(12),
      decoration: BoxDecoration(
        border: Border.all(color: Colors.grey.withAlpha(30)),
        borderRadius: BorderRadius.circular(8),
      ),
      child: Row(
        spacing: SIZE.SPACING,
        children: [
          Image.network(
            itemUrl,
            fit: BoxFit.contain,
            errorBuilder: (_, __, ___) => const Icon(Icons.image),
          ).sizedBox(width: 50, height: 50),

          // 슬롯/아이템 정보
          Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            spacing: 6,
            children: [
              Row(
                spacing: 8,
                children: [
                  Container(
                    padding:
                        const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
                    decoration: BoxDecoration(
                      color: Colors.blue,
                      borderRadius: BorderRadius.circular(12),
                    ),
                    child: Text(
                      enchant.slotName,
                      style: const TextStyle(
                        color: Colors.white,
                        fontSize: 12,
                        fontWeight: FontWeight.bold,
                      ),
                    ),
                  ),
                  if (enchant.upgrade > 0)
                    Container(
                      padding: const EdgeInsets.symmetric(
                          horizontal: 6, vertical: 2),
                      decoration: BoxDecoration(
                        color: Colors.orange,
                        borderRadius: BorderRadius.circular(8),
                      ),
                      child: Text(
                        '+${enchant.upgrade}',
                        style: const TextStyle(
                          color: Colors.white,
                          fontSize: 10,
                          fontWeight: FontWeight.bold,
                        ),
                      ),
                    ),
                ],
              ),
              Text(
                enchant.itemName,
                style: const TextStyle(
                  fontWeight: FontWeight.bold,
                  fontSize: 16,
                ),
                maxLines: 1,
                overflow: TextOverflow.ellipsis,
              ),
              Text(
                '${enchant.recStats}',
                style: const TextStyle(
                  fontSize: 12,
                ),
                maxLines: 2,
                overflow: TextOverflow.ellipsis,
              ),
            ],
          ).expand(),

          // 가격/점수/효율
          Column(
            crossAxisAlignment: CrossAxisAlignment.end,
            spacing: 2,
            children: [
              Text(
                _formatNumber(price),
                style: const TextStyle(
                  fontWeight: FontWeight.bold,
                  fontSize: 16,
                  color: Colors.green,
                ),
              ),
            ],
          ),
        ],
      ),
    );
  }

  // 🧩 슬롯별 최적 아이템 목록
  Widget buildBestPerSlotList(MRecommended data) {
    final Map<String, MBestPerSlotEntry> bestPerSlot = data.bestPerSlot ?? {};

    if (bestPerSlot.isEmpty) return const SizedBox.shrink();
    final List<MapEntry<String, MBestPerSlotEntry>> entries =
        bestPerSlot.entries.toList();

    return buildCommonCard(
      child: Column(
        spacing: SIZE.SPACING,
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(
            '부위별 가성비 마법부여',
            style: Theme.of(context)
                .textTheme
                .headlineSmall
                ?.copyWith(fontWeight: FontWeight.bold),
          ),
          SingleChildScrollView(
            child: ExpansionPanelList.radio(
              children: entries.map((e) {
                final String slotId = e.key; // 예: "weapon", "ring" ...
                final MBestPerSlotEntry slot = e.value;
                return ExpansionPanelRadio(
                  value: slotId,
                  headerBuilder: (context, isExpanded) {
                    return buildBestSlotItem(slot);
                  },
                  body: Text('${slot.status}'),
                );
              }).toList(),
            ),
          ).expand(),
        ],
      ),
    );
  }

  // 🏷️ 단일 슬롯 추천 아이템 카드
  Widget buildBestSlotItem(MBestPerSlotEntry best) {
    final String itemUrl =
        "${PATH.URL_BASE}/${PATH.URL_IMAGE}?type=item&id=${best.itemId}";
    final int price = best.price.lowestPrice;

    return Container(
      margin: const EdgeInsets.only(bottom: 12),
      padding: const EdgeInsets.all(16),
      // decoration: BoxDecoration(
      //   border: Border.all(color: Colors.blue.withAlpha(30)),
      //   borderRadius: BorderRadius.circular(8),
      //   color: Colors.blue.withAlpha(5),
      // ),
      child: Row(
        spacing: SIZE.SPACING,
        children: [
          Image.network(
            itemUrl,
            fit: BoxFit.contain,
            errorBuilder: (_, __, ___) => const Icon(Icons.image),
          ).sizedBox(width: 50, height: 50),

          // 슬롯/아이템 정보
          Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            spacing: 6,
            children: [
              Row(
                spacing: 8,
                children: [
                  Container(
                    padding:
                        const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
                    decoration: BoxDecoration(
                      color: Colors.blue,
                      borderRadius: BorderRadius.circular(12),
                    ),
                    child: Text(
                      best.slotName,
                      style: const TextStyle(
                        color: Colors.white,
                        fontSize: 12,
                        fontWeight: FontWeight.bold,
                      ),
                    ),
                  ),
                  if (best.upgrade > 0)
                    Container(
                      padding: const EdgeInsets.symmetric(
                          horizontal: 6, vertical: 2),
                      decoration: BoxDecoration(
                        color: Colors.orange,
                        borderRadius: BorderRadius.circular(8),
                      ),
                      child: Text(
                        '+${best.upgrade}',
                        style: const TextStyle(
                          color: Colors.white,
                          fontSize: 10,
                          fontWeight: FontWeight.bold,
                        ),
                      ),
                    ),
                ],
              ),
              Text(
                best.itemName,
                style: const TextStyle(
                  fontWeight: FontWeight.bold,
                  fontSize: 16,
                ),
                maxLines: 1,
                overflow: TextOverflow.ellipsis,
              ),
            ],
          ).expand(),

          // 가격/점수/효율
          Column(
            crossAxisAlignment: CrossAxisAlignment.end,
            spacing: 2,
            children: [
              Text(
                _formatNumber(price),
                style: const TextStyle(
                  fontWeight: FontWeight.bold,
                  fontSize: 16,
                  color: Colors.green,
                ),
              ),
              Row(
                mainAxisSize: MainAxisSize.min,
                spacing: 4,
                children: [
                  Icon(Icons.trending_up, size: 16, color: Colors.orange[600]),
                  Text(
                    '${best.deltaScore}',
                    style: TextStyle(
                      fontWeight: FontWeight.bold,
                      color: Colors.orange[600],
                    ),
                  ),
                ],
              ),
              Text(
                '효율: ${best.efficiency.toStringAsFixed(8)}',
                style: TextStyle(fontSize: 11, color: Colors.grey[600]),
              ),
            ],
          ),
        ],
      ),
    );
  }

  // 🎛️ 슬롯 그리드 (카드 통일)
  Widget _buildSlotGrid(List<MapEntry<String, MSlotRecommendation>> entries) {
    return GridView.builder(
      shrinkWrap: true,
      physics: const NeverScrollableScrollPhysics(),
      itemCount: entries.length,
      // padding: const EdgeInsets.all(8),
      gridDelegate: const SliverGridDelegateWithFixedCrossAxisCount(
        crossAxisCount: 2,
        // childAspectRatio: 0.85,
        // crossAxisSpacing: 8,
        // mainAxisSpacing: 8,
      ),
      itemBuilder: (context, index) {
        final MSlotRecommendation slot = entries[index].value;
        final String? itemId = slot.equippedItemId;
        final String? itemUrl = (itemId == null)
            ? null
            : "${PATH.URL_BASE}/${PATH.URL_IMAGE}?type=item&id=$itemId";

        return Card(
          child: (itemUrl != null
              ? ClipRRect(
                  borderRadius: BorderRadius.circular(8),
                  child: Tooltip(
                    message: statsTooltip(slot.currentStats),
                    decoration: BoxDecoration(
                      color: Colors.black.withAlpha(92),
                      borderRadius: BorderRadius.circular(10),
                      boxShadow: [
                        BoxShadow(
                          blurRadius: 10,
                          spreadRadius: 1,
                          offset: const Offset(0, 6),
                          color: Colors.black.withAlpha(25),
                        ),
                      ],
                      border: Border.all(color: Colors.white.withAlpha(8)),
                    ),
                    textStyle: const TextStyle(
                      color: Colors.white,
                      fontSize: 12,
                      height: 1.35,
                      fontFeatures: [FontFeature.tabularFigures()],
                    ),
                    padding: const EdgeInsets.symmetric(
                        horizontal: 12, vertical: 10),
                    margin: const EdgeInsets.symmetric(horizontal: 8),
                    preferBelow: false,
                    verticalOffset: 14,
                    waitDuration: const Duration(milliseconds: 250),
                    showDuration: const Duration(seconds: 6),
                    triggerMode:
                        TooltipTriggerMode.longPress, // 모바일 배려, 웹에선 hover도 동작
                    child: Image.network(
                      itemUrl,
                      fit: BoxFit.fill,
                      errorBuilder: (_, __, ___) => Icon(
                        Icons.hide_image,
                        color: Colors.grey.shade400,
                        size: 40,
                      ),
                    ),
                  ),
                )
              : Icon(
                  Icons.hide_image,
                  color: Colors.grey.shade400,
                  size: 40,
                )),
        );
      },
    );
  }

  // 숫자 포맷팅
  String _formatNumber(dynamic value) {
    if (value == null) return '0';
    if (value is int) {
      return value.toString().replaceAllMapped(
            RegExp(r'(\d{1,3})(?=(\d{3})+(?!\d))'),
            (m) => '${m[1]},',
          );
    }
    if (value is double) {
      return value.toStringAsFixed(0).replaceAllMapped(
            RegExp(r'(\d{1,3})(?=(\d{3})+(?!\d))'),
            (m) => '${m[1]},',
          );
    }
    return value.toString();
  }
}
