part of dnf_growth_recommender;

class ViewSearchPortrait extends AbstractViewSearch {
  const ViewSearchPortrait({super.key});

  @override
  ViewSearchPortraitState createState() => ViewSearchPortraitState();
}

class ViewSearchPortraitState
    extends AbstractViewSearchState<AbstractViewSearch> {
  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: Column(
        spacing: SIZE.SPACING,
        children: [
          buildSearchFields().sizedBox(height: 200),
          // 🧾 결과
          StreamBuilder(
            stream: GServiceDnf.subject.browse,
            builder: (context, AsyncSnapshot<MRecommended> snapshot) {
              if (snapshot.connectionState == ConnectionState.waiting) {
                return buildCommonCard(
                  child: const Row(
                    spacing: SIZE.SPACING,
                    mainAxisAlignment: MainAxisAlignment.center,
                    children: [
                      Text('캐릭터를 검색하세요'),
                      Icon(Icons.search),
                    ],
                  ).center,
                ).expand();
              }

              final MRecommended data = snapshot.data!;
              final slots = data.enchantRecommendations;

              final String charUrl = "${PATH.URL_BASE}/${PATH.URL_IMAGE}"
                  "?type=char&server=${data.character.serverId}"
                  "&id=${data.character.characterId}&zoom=3";

              final getLeftSlots = leftSlots
                  .where((k) => slots.containsKey(k))
                  .map((k) => MapEntry(k, slots[k]!))
                  .toList();

              final getRightSlots = rightSlots
                  .where((k) => slots.containsKey(k))
                  .map((k) => MapEntry(k, slots[k]!))
                  .toList();

              return SingleChildScrollView(
                child: Column(
                  spacing: SIZE.SPACING,
                  children: [
                    if (data.plan != null) buildBudgetCard(data),

                    // 🧍 캐릭터 + 슬롯 (좌/전신/우)
                    // Row(
                    //   spacing: SIZE.SPACING,
                    //   crossAxisAlignment: CrossAxisAlignment.start,
                    //   children: [
                    //     _buildSlotGrid(getLeftSlots).expand(),
                    //     Image.network(
                    //       charUrl,
                    //       height: 200,
                    //       errorBuilder: (_, __, ___) => const Icon(Icons.error),
                    //     ).align(alignment: Alignment.topCenter).expand(),
                    //     _buildSlotGrid(getRightSlots).expand(),
                    //   ],
                    // ).expand(),

                    // 🧩 슬롯별 최적 아이템
                    buildBestPerSlotList(data).expand(),
                  ],
                ),
              ).expand();
            },
          ),
        ],
      ),
    );
  }
}
