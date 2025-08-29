part of dnf_growth_recommender;

class ViewHome extends StatefulWidget {
  const ViewHome({super.key});

  @override
  State<ViewHome> createState() => ViewHomeState();
}

class ViewHomeState extends State<ViewHome> {
  bool get isPort => MediaQuery.of(context).orientation == Orientation.portrait;
  double get fullHeight => MediaQuery.of(context).size.height;

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
            height: 100,
          )
        ],
      )),
    );
  }
}
