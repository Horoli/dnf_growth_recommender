part of dnf_growth_recommender;

class ViewSearch extends StatefulWidget {
  const ViewSearch({super.key});

  @override
  State<ViewSearch> createState() => ViewSearchState();
}

class ViewSearchState extends State<ViewSearch> {
  TextEditingController ctlServer = TextEditingController();
  TextEditingController ctlId = TextEditingController();
  TextEditingController ctlGold = TextEditingController();

  String serverId = SERVER.LIST.first['serverId']!;

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: Column(
        children: [
          Card(
            margin: const EdgeInsets.all(16),
            child: Padding(
              padding: const EdgeInsets.all(16.0),
              child: Row(
                spacing: 16,
                children: [
                  DropdownButtonFormField<String>(
                    initialValue: serverId,
                    decoration: const InputDecoration(labelText: '서버'),
                    items: SERVER.LIST
                        .map<DropdownMenuItem<String>>(
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
                        gold: ctlGold.text == '' ? null : ctlGold.text,
                      );
                    },
                  ),
                ],
              ).sizedBox(height: 100),
            ),
          ),
          StreamBuilder(
            stream: GServiceDnf.subject.browse,
            builder: (context, AsyncSnapshot<RecommendedData> snapshot) {
              if (snapshot.connectionState == ConnectionState.waiting) {
                return const Center(
                  child: Row(
                    mainAxisAlignment: MainAxisAlignment.center,
                    children: [
                      Text('캐릭터를 검색하세요'),
                      Icon(Icons.search),
                    ],
                  ),
                );
              }

              final RecommendedData data = snapshot.data!;
              final Map<String, SlotRecommendation> slots =
                  data.enchantRecommendations;

              // 캐릭터 전신 이미지
              final String charUrl = "${PATH.URL_BASE}/${PATH.URL_IMAGE}"
                  "?type=char&server=${data.character.serverId}"
                  "&id=${data.character.characterId}&zoom=1";

              // 슬롯 순서대로 정렬된 엔트리
              final List<MapEntry<String, SlotRecommendation>> getLeftSlots =
                  leftSlots
                      .where((k) => slots.containsKey(k))
                      .map((k) => MapEntry(k, slots[k]!))
                      .toList();

              final List<MapEntry<String, SlotRecommendation>> getRightSlots =
                  rightSlots
                      .where((k) => slots.containsKey(k))
                      .map((k) => MapEntry(k, slots[k]!))
                      .toList();

              return SingleChildScrollView(
                child: Column(
                  children: [
                    // 예산 정보 카드
                    if (data.plan != null) _buildBudgetCard(data),
                    const SizedBox(height: 20),

                    // 기존 캐릭터 및 슬롯 표시
                    SizedBox(
                      height: 600,
                      width: 1000,
                      child: Row(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          buildSlotGrid(getLeftSlots).expand(),
                          Image.network(
                            charUrl,
                            height: 200,
                            errorBuilder: (_, __, ___) => const Icon(
                              Icons.error,
                            ),
                          ).expand(),
                          buildSlotGrid(getRightSlots).expand(),
                        ],
                      ),
                    ),
                    const SizedBox(height: 20),

                    // 슬롯별 최적 아이템 목록
                    _buildBestPerSlotList(data),
                  ],
                ),
              );
            },
          ).expand(),
        ],
      ),
    );
  }

  // 예산 정보 카드
  Widget _buildBudgetCard(RecommendedData data) {
    final int budget = data.budget ?? 0;
    final Plan plan = data.plan!;
    final int spent = plan.spent;
    final int remain = plan.remain;
    final int totalDelta = plan.totalDelta;
    final Map<String, int> increaseStats = plan.increaseStats;
    final List<PlannedChoice> chosen = plan.chosen;

    return buildCommonCard(
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(
            '예산 계획',
            style: Theme.of(context).textTheme.headlineSmall?.copyWith(
                  fontWeight: FontWeight.bold,
                ),
          ),
          const SizedBox(height: 12),
          Row(
            children: [
              _buildBudgetItem('총 예산', budget, Colors.blue).expand(),
              _buildBudgetItem('사용 예정', spent, Colors.orange).expand(),
              _buildBudgetItem('남은 예산', remain, Colors.green).expand(),
              _buildBudgetItem('총 점수', totalDelta, Colors.purple).expand(),
            ],
          ),
          const SizedBox(height: 16),
          _buildBudgetItem('총 스탯 증가', increaseStats, Colors.pink).sizedBox(
            width: double.infinity,
          ),
          const SizedBox(height: 16),
          Text(
            '선택된 아이템 (${chosen.length}개)',
            style: Theme.of(context).textTheme.titleMedium?.copyWith(
                  fontWeight: FontWeight.bold,
                ),
          ),
          const SizedBox(height: 8),
          ...chosen.map((item) => _buildChosenItemTile(item)),
        ],
      ),
    );
  }

  Widget _buildBudgetItem(String label, dynamic value, Color color) {
    return Container(
      padding: const EdgeInsets.all(12),
      margin: const EdgeInsets.only(right: 8),
      decoration: BoxDecoration(
        color: color.withOpacity(0.1),
        borderRadius: BorderRadius.circular(8),
        border: Border.all(color: color.withOpacity(0.3)),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(
            label,
            style: TextStyle(
              color: color,
              fontSize: 12,
              fontWeight: FontWeight.w500,
            ),
          ),
          const SizedBox(height: 4),
          Text(
            _formatNumber(value),
            style: TextStyle(
              color: color,
              fontSize: 16,
              fontWeight: FontWeight.bold,
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildChosenItemTile(PlannedChoice item) {
    final String itemUrl =
        "${PATH.URL_BASE}/${PATH.URL_IMAGE}?type=item&id=${item.itemId}";
    final int price = item.price.lowestPrice;
    final int deltaScore = item.deltaScore;
    final double efficiency = item.efficiency;

    return Container(
      margin: const EdgeInsets.only(bottom: 8),
      padding: const EdgeInsets.all(12),
      decoration: BoxDecoration(
        border: Border.all(color: Colors.grey.withAlpha(30)),
        borderRadius: BorderRadius.circular(8),
      ),
      child: Row(
        children: [
          // 아이템 이미지
          SizedBox(
            width: 40,
            height: 40,
            child: Image.network(
              itemUrl,
              fit: BoxFit.contain,
              errorBuilder: (_, __, ___) => const Icon(Icons.image),
            ),
          ),
          const SizedBox(width: 12),

          // 아이템 정보
          Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text(
                '${item.slotName} - ${item.itemName}',
                style: const TextStyle(fontWeight: FontWeight.bold),
                maxLines: 1,
                overflow: TextOverflow.ellipsis,
              ),
              Text(
                '현재 장착: ${item.equippedItemName}',
                style: TextStyle(
                  fontSize: 12,
                  color: Colors.grey[600],
                ),
                maxLines: 1,
                overflow: TextOverflow.ellipsis,
              ),
            ],
          ).expand(),

          // 가격 및 성능 정보
          Column(
            crossAxisAlignment: CrossAxisAlignment.end,
            children: [
              Text(
                _formatNumber(price),
                style: const TextStyle(
                  fontWeight: FontWeight.bold,
                  color: Colors.green,
                ),
              ),
              Text(
                '점수: $deltaScore',
                style: TextStyle(
                  fontSize: 12,
                  color: Colors.grey[600],
                ),
              ),
              Text(
                '효율: ${efficiency.toStringAsFixed(8)}',
                style: TextStyle(
                  fontSize: 10,
                  color: Colors.grey[500],
                ),
              ),
            ],
          ),
        ],
      ),
    );
  }

  // 슬롯별 최적 아이템 목록
  Widget _buildBestPerSlotList(RecommendedData data) {
    final Map<String, BestPerSlotEntry> bestPerSlot = data.bestPerSlot ?? {};

    if (bestPerSlot.isEmpty) {
      return const SizedBox.shrink();
    }

    return buildCommonCard(
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(
            '슬롯별 최적 아이템',
            style: Theme.of(context).textTheme.headlineSmall?.copyWith(
                  fontWeight: FontWeight.bold,
                ),
          ),
          const SizedBox(height: 16),
          ...bestPerSlot.entries
              .map((entry) => _buildBestSlotItem(entry.value)),
        ],
      ),
    );
  }

  Widget _buildBestSlotItem(BestPerSlotEntry bestSlotEntry) {
    final String itemUrl =
        "${PATH.URL_BASE}/${PATH.URL_IMAGE}?type=item&id=${bestSlotEntry.itemId}";
    final int price = bestSlotEntry.price.lowestPrice;
    final int deltaScore = bestSlotEntry.deltaScore;
    final double efficiency = bestSlotEntry.efficiency;
    final int upgrade = bestSlotEntry.upgrade;

    return Container(
      margin: const EdgeInsets.only(bottom: 12),
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        border: Border.all(color: Colors.blue.withAlpha(30)),
        borderRadius: BorderRadius.circular(8),
        color: Colors.blue.withAlpha(5),
      ),
      child: Row(
        children: [
          // 아이템 이미지
          SizedBox(
            width: 50,
            height: 50,
            child: Image.network(
              itemUrl,
              fit: BoxFit.contain,
              errorBuilder: (_, __, ___) => const Icon(Icons.image),
            ),
          ),
          const SizedBox(width: 16),

          // 슬롯 및 아이템 정보
          Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Row(
                children: [
                  Container(
                    padding:
                        const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
                    decoration: BoxDecoration(
                      color: Colors.blue,
                      borderRadius: BorderRadius.circular(12),
                    ),
                    child: Text(
                      bestSlotEntry.slotName,
                      style: const TextStyle(
                        color: Colors.white,
                        fontSize: 12,
                        fontWeight: FontWeight.bold,
                      ),
                    ),
                  ),
                  if (upgrade > 0) ...[
                    const SizedBox(width: 8),
                    Container(
                      padding: const EdgeInsets.symmetric(
                          horizontal: 6, vertical: 2),
                      decoration: BoxDecoration(
                        color: Colors.orange,
                        borderRadius: BorderRadius.circular(8),
                      ),
                      child: Text(
                        '+$upgrade',
                        style: const TextStyle(
                          color: Colors.white,
                          fontSize: 10,
                          fontWeight: FontWeight.bold,
                        ),
                      ),
                    ),
                  ],
                ],
              ),
              const SizedBox(height: 6),
              Text(
                bestSlotEntry.itemName,
                style: const TextStyle(
                  fontWeight: FontWeight.bold,
                  fontSize: 16,
                ),
                maxLines: 2,
                overflow: TextOverflow.ellipsis,
              ),
            ],
          ).expand(),

          // 성능 및 가격 정보
          Column(
            crossAxisAlignment: CrossAxisAlignment.end,
            children: [
              Text(
                _formatNumber(price),
                style: const TextStyle(
                  fontWeight: FontWeight.bold,
                  fontSize: 16,
                  color: Colors.green,
                ),
              ),
              const SizedBox(height: 4),
              Row(
                mainAxisSize: MainAxisSize.min,
                children: [
                  Icon(Icons.trending_up, size: 16, color: Colors.orange[600]),
                  const SizedBox(width: 4),
                  Text(
                    '$deltaScore',
                    style: TextStyle(
                      fontWeight: FontWeight.bold,
                      color: Colors.orange[600],
                    ),
                  ),
                ],
              ),
              const SizedBox(height: 2),
              Text(
                '효율: ${efficiency.toStringAsFixed(8)}',
                style: TextStyle(
                  fontSize: 11,
                  color: Colors.grey[600],
                ),
              ),
            ],
          ),
        ],
      ),
    );
  }

  // 슬롯들을 2열 그리드로 렌더링 - 카드 형태 UI
  Widget buildSlotGrid(
    List<MapEntry<String, SlotRecommendation>> entries,
  ) {
    return GridView.builder(
      shrinkWrap: true,
      physics: const NeverScrollableScrollPhysics(),
      itemCount: entries.length,
      padding: const EdgeInsets.all(8),
      gridDelegate: const SliverGridDelegateWithFixedCrossAxisCount(
        crossAxisCount: 2,
        childAspectRatio: 0.85, // 카드 비율 조정
        crossAxisSpacing: 8,
        mainAxisSpacing: 8,
      ),
      itemBuilder: (context, index) {
        final SlotRecommendation slot = entries[index].value;
        final String? itemId = slot.equippedItemId;
        final String? itemUrl = (itemId == null)
            ? null
            : "${PATH.URL_BASE}/${PATH.URL_IMAGE}?type=item&id=$itemId";

        return Card(
          elevation: 2,
          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(12),
          ),
          child: Container(
            padding: const EdgeInsets.all(12),
            decoration: BoxDecoration(
              borderRadius: BorderRadius.circular(12),
              gradient: LinearGradient(
                begin: Alignment.topCenter,
                end: Alignment.bottomCenter,
                colors: [
                  Colors.grey.shade50,
                  Colors.grey.shade100,
                ],
              ),
            ),
            child: Column(
              spacing: 8,
              crossAxisAlignment: CrossAxisAlignment.center,
              children: [
                // 슬롯명 배지
                Container(
                  padding:
                      const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
                  decoration: BoxDecoration(
                    color: Colors.indigo,
                    borderRadius: BorderRadius.circular(8),
                  ),
                  child: Text(
                    slot.slotName,
                    style: const TextStyle(
                      color: Colors.white,
                      fontSize: 11,
                      fontWeight: FontWeight.bold,
                    ),
                    maxLines: 1,
                    overflow: TextOverflow.ellipsis,
                  ),
                ),
                // 아이템 이미지
                itemUrl != null
                    ? ClipRRect(
                        borderRadius: BorderRadius.circular(6),
                        child: Image.network(
                          itemUrl,
                          fit: BoxFit.contain,
                          errorBuilder: (_, __, ___) => Icon(
                            Icons.hide_image,
                            color: Colors.grey.shade400,
                            size: 40,
                          ),
                        ),
                      )
                    : Icon(
                        Icons.hide_image,
                        color: Colors.grey.shade400,
                        size: 40,
                      ).expand(flex: 3),

                // 현재 스탯 정보
                Container(
                  width: double.infinity,
                  padding: const EdgeInsets.all(6),
                  decoration: BoxDecoration(
                    color: Colors.blue.shade50,
                    borderRadius: BorderRadius.circular(6),
                    border: Border.all(
                      color: Colors.blue.shade200,
                      width: 1,
                    ),
                  ),
                  child: Tooltip(
                    // message: slot.currentStats ?? '정보 없음',
                    message: '',
                    child: Text(
                      '${slot.currentStats.entries}' ?? '정보 없음',
                      style: TextStyle(
                        fontSize: 10,
                        color: Colors.blue.shade700,
                        fontWeight: FontWeight.w500,
                      ),
                      textAlign: TextAlign.center,
                      maxLines: 2,
                      overflow: TextOverflow.ellipsis,
                    ),
                  ),
                ).expand(),
              ],
            ),
          ),
        );
      },
    );
  }

  // 숫자 포맷팅 헬퍼 함수
  String _formatNumber(dynamic value) {
    if (value == null) return '0';
    if (value is int) {
      return value.toString().replaceAllMapped(
            RegExp(r'(\d{1,3})(?=(\d{3})+(?!\d))'),
            (Match m) => '${m[1]},',
          );
    }
    if (value is double) {
      return value.toStringAsFixed(0).replaceAllMapped(
            RegExp(r'(\d{1,3})(?=(\d{3})+(?!\d))'),
            (Match m) => '${m[1]},',
          );
    }
    return value.toString();
  }

  @override
  void initState() {
    // getData();
    super.initState();
  }

  Future<void> getData() async {
    await GServiceDnf.getRecommendation();
  }
}
