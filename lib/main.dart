import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:provider/provider.dart';
import 'app.dart';
import 'providers/app_provider.dart';

void main() async {
  WidgetsFlutterBinding.ensureInitialized();

  SystemChrome.setPreferredOrientations([
    DeviceOrientation.portraitUp,
    DeviceOrientation.portraitDown,
  ]);

  final provider = AppProvider();
  await provider.init();

  runApp(
    ChangeNotifierProvider<AppProvider>.value(
      value: provider,
      child: const BmiHealthApp(),
    ),
  );
}
