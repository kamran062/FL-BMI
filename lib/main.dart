import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:provider/provider.dart';
import 'app.dart';
import 'providers/app_provider.dart';
import 'services/ad_service.dart';
import 'services/purchase_service.dart';

void main() async {
  WidgetsFlutterBinding.ensureInitialized();

  SystemChrome.setPreferredOrientations([
    DeviceOrientation.portraitUp,
    DeviceOrientation.portraitDown,
  ]);

  // Initialize AdMob
  await AdService.initialize();

  // Initialize IAP and restore premium status from local cache
  await PurchaseService.instance.init();

  // Load app data
  final provider = AppProvider();
  await provider.init();

  runApp(
    MultiProvider(
      providers: [
        ChangeNotifierProvider<AppProvider>.value(value: provider),
        ChangeNotifierProvider<PurchaseService>.value(
            value: PurchaseService.instance),
      ],
      child: const BmiHealthApp(),
    ),
  );
}
