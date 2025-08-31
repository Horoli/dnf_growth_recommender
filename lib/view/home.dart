part of dnf_growth_recommender;

class ViewHome extends StatefulWidget {
  const ViewHome({super.key});

  @override
  State<ViewHome> createState() => ViewHomeState();
}

class ViewHomeState extends State<ViewHome> {
  // bool get isPort => MediaQuery.of(context).orientation == Orientation.portrait;
  double kMaxContentWidth = 1280; // 1920에서 좌우 320px 거터 확보
  double get fullHeight => MediaQuery.of(context).size.height;
  double get fullWidth => MediaQuery.of(context).size.width;
  bool get isPort => fullWidth < kMaxContentWidth;

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(),
      body: SingleChildScrollView(
          child: Column(
        children: [
          SizedBox(
            height: fullHeight * 1.2,
            child: isPort
                ? const ViewSearchPortrait()
                : const ViewSearchLandscape(),
          ),
          Container(
            color: Colors.grey,
            width: double.infinity,
            height: kToolbarHeight,
          )
        ],
      )),
    );
  }
}
