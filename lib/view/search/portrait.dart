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
                    buildSearchFields().sizedBox(height: 150),
                    // buildMainContents().expand(),
                  ],
                ),
              ),
            );
          },
        ),
      ),
    );
  }
}
