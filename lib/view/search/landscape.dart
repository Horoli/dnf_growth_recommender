part of dnf_growth_recommender;

class ViewSearchLandscape extends AbstractViewSearch {
  const ViewSearchLandscape({super.key});

  @override
  ViewSearchLandscapeState createState() => ViewSearchLandscapeState();
}

class ViewSearchLandscapeState
    extends AbstractViewSearchState<AbstractViewSearch> {
  @override
  Widget build(BuildContext context) {
    // 1920×1080 기준으로 보기 좋은 치수들
    const double _kHeaderHeight = 72;
    const double _kFooterHeight = 56;
    const double kMaxContentWidth = 1280; // 1920에서 좌우 320px 거터 확보
    const double _kSidePadding = 24; // 중앙 콘텐츠 내부 여백

    return Scaffold(
      body: SafeArea(
        top: false,
        child: LayoutBuilder(
          builder: (context, constraints) {
            return Align(
              alignment: Alignment.topCenter,
              child: ConstrainedBox(
                constraints: const BoxConstraints(
                  maxWidth: kMaxContentWidth,
                ),
                child: Column(
                  children: [
                    buildSearchFields().sizedBox(height: 100),
                    buildMainContents().expand(),
                  ],
                ),
              ),
            );
          },
        ),
      ),
    );
  }

  Widget buildMainContents() {
    return StreamBuilder(
      stream: GServiceDnf.subject.browse,
      builder: (context, AsyncSnapshot<MRecommended> snapshot) {
        if (snapshot.connectionState == ConnectionState.waiting) {
          return const Row(
            spacing: SIZE.SPACING,
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              Text('캐릭터를 검색하세요'),
              Icon(Icons.search),
            ],
          ).center;
        }

        final MRecommended data = snapshot.data!;
        final Map<String, MSlotRecommendation> slots =
            data.enchantRecommendations;

        final String charUrl = "${PATH.URL_BASE}/${PATH.URL_IMAGE}"
            "?type=char&server=${data.character.serverId}"
            "&id=${data.character.characterId}&zoom=1";

        return Row(
          children: [
            Column(
              children: [
                buildCharacterDetails(charUrl, slots),
                buildCommonCard(
                    child: Container(
                  width: double.infinity,
                )).expand(),
              ],
            ).expand(),
            if (data.plan != null) buildBudgetCard(data).expand(),
            Column(
              children: [
                buildEnchantRecommendationsList(data).expand(),
                buildBestPerSlotList(data).expand(),
              ],
            ).expand(),
          ],
        );
      },
    );
  }
}
