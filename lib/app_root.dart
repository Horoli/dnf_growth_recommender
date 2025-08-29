part of dnf_growth_recommender;

class AppRoot extends StatefulWidget {
  const AppRoot({super.key});

  @override
  State<AppRoot> createState() => AppRootState();
}

class AppRootState extends State<AppRoot> {
  @override
  Widget build(BuildContext context) {
    Map<String, Widget Function(BuildContext)> routes = {
      PATH.ROUTE_SEARCH: (BuildContext contxt) => const ViewHome(),
    };

    return MaterialApp(
      initialRoute: PATH.ROUTE_SEARCH,
      routes: routes,
    );
  }
}
