import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:provider/provider.dart';
import 'app.dart';
import 'providers/app_provider.dart';
import 'services/ad_service.dart';

void main() async {
  WidgetsFlutterBinding.ensureInitialized();

  SystemChrome.setPreferredOrientations([
    DeviceOrientation.portraitUp,
    DeviceOrientation.portraitDown,
  ]);

  // Initialize AdMob
  await AdService.initialize();

  // Preload interstitial and app open ads so they're ready immediately
  await AdService.instance.preload();

  // Load app data
  final provider = AppProvider();
  await provider.init();

  runApp(
    ChangeNotifierProvider<AppProvider>.value(
      value: provider,
      child: const BmiHealthApp(),
    ),
  );
}
