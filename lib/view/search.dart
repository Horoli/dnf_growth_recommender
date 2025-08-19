part of dnf_growth_recommender;

class ViewSearch extends StatefulWidget {
  const ViewSearch({super.key});

  @override
  State<ViewSearch> createState() => ViewSearchState();
}

class ViewSearchState extends State<ViewSearch> {
  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: StreamBuilder(
        stream: GServiceDnf.subject.browse,
        builder: (context, snapshot) {
          if (snapshot.connectionState == ConnectionState.waiting) {
            return const Center(child: CircularProgressIndicator());
          }

          final data = snapshot.data!;
          final slots = data.enchantRecommendations;

          // (선택) 캐릭터 전신 이미지
          final charUrl = "${PATH.URL_BASE}/${PATH.URL_CHAR_IMAGE}"
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

          return Center(
            child: SizedBox(
              height: 1000,
              width: 1000,
              child: Row(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  // 전신
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
          );
        },
      ),
    );
  }

  // 슬롯들을 2열 그리드로 렌더링
  Widget buildSlotGrid(
    List<MapEntry<String, SlotRecommendation>> entries,
  ) {
    return GridView.builder(
      shrinkWrap: true,
      physics: const NeverScrollableScrollPhysics(),
      itemCount: entries.length,
      gridDelegate: const SliverGridDelegateWithFixedCrossAxisCount(
        crossAxisCount: 2, // ← 한 줄 최대 2개
        mainAxisSpacing: 8,
        crossAxisSpacing: 8,
        childAspectRatio: 2.78, // 필요하면 카드 비율 조정
      ),
      itemBuilder: (context, i) {
        final slot = entries[i].value;
        final itemId = slot.equippedItemId;
        final itemUrl = (itemId == null)
            ? null
            : "${PATH.URL_BASE}/${PATH.URL_CHAR_IMAGE}?type=item&id=$itemId";

        return Column(
          crossAxisAlignment: CrossAxisAlignment.center,
          children: [
            Tooltip(
              message: '${entries[i].value.currentStats}',
              child: Text(
                slot.slotName, // 예: 무기/상의/하의 ...
                maxLines: 1,
                overflow: TextOverflow.ellipsis,
                style: Theme.of(context).textTheme.bodySmall,
              ),
            ),
            const SizedBox(height: 4),
            (itemUrl != null
                    ? Image.network(
                        itemUrl,
                        fit: BoxFit.contain,
                        errorBuilder: (_, __, ___) =>
                            const Icon(Icons.hide_image),
                      )
                    : const Icon(Icons.hide_image))
                .expand(),
          ],
        );
      },
    );
  }

  @override
  void initState() {
    getData();
    super.initState();
  }

  Future<void> getData() async {
    await GServiceDnf.getRecommendation();
  }
}
