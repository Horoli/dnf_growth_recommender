import 'package:dnf_growth_recommender/dnf_growth_recommender.dart';
import 'package:flutter/material.dart';

Future<void> main() async {
  WidgetsFlutterBinding.ensureInitialized();

  await initService();
  runApp(const AppRoot());
}

Future initService() async {
  GServiceDnf = ServiceDnf.getInstance();
}
