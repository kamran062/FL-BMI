import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:provider/provider.dart';
import 'package:bmi_health/app/app.dart';
import 'package:bmi_health/app/app_provider.dart';
import 'package:bmi_health/features/ads/ad_service.dart';

void main() async {
  WidgetsFlutterBinding.ensureInitialized();

  SystemChrome.setPreferredOrientations([
    DeviceOrientation.portraitUp,
    DeviceOrientation.portraitDown,
  ]);

  // Load app data
  final provider = AppProvider();
  await provider.init();

  runApp(
    ChangeNotifierProvider<AppProvider>.value(
      value: provider,
      child: const BmiHealthApp(),
    ),
  );

  // Ads start after the first frame so launch is never blocked by the network.
  // Consent (UMP) is gathered first; no ad is requested before it completes.
  AdService.instance.initialize();
}
