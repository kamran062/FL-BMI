import 'dart:ui';
import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:provider/provider.dart';
import '../providers/app_provider.dart';
import '../theme/app_colors.dart';
import 'goal_screen.dart';
import 'history_screen.dart';
import 'home_screen.dart';
import 'paywall_screen.dart';
import 'result_screen.dart';
import 'settings_screen.dart';
import 'share_screen.dart';
import 'tips_screen.dart';

class MainApp extends StatefulWidget {
  const MainApp({super.key});

  @override
  State<MainApp> createState() => _MainAppState();
}

class _MainAppState extends State<MainApp> {
  int _tab = 0;
  String? _overlay; // 'result' | 'goal' | 'paywall' | 'share'

  static const _tabs = [
    (icon: Icons.calculate_outlined,  iconActive: Icons.calculate_rounded,   label: 'Calculate'),
    (icon: Icons.show_chart_rounded,   iconActive: Icons.show_chart_rounded,  label: 'History'),
    (icon: Icons.lightbulb_outline,   iconActive: Icons.lightbulb_rounded,   label: 'Tips'),
    (icon: Icons.settings_outlined,   iconActive: Icons.settings_rounded,    label: 'Settings'),
  ];

  void _openOverlay(String name) => setState(() => _overlay = name);
  void _closeOverlay() => setState(() => _overlay = null);

  void _calculate() {
    final provider = context.read<AppProvider>();
    final bmi = provider.currentBmi;
    if (bmi <= 0) {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Text(
            'Enter valid height and weight to calculate.',
            style: GoogleFonts.inter(fontSize: 14),
          ),
          backgroundColor: AppColors.fg1,
          behavior: SnackBarBehavior.floating,
          shape: RoundedRectangleBorder(
              borderRadius: BorderRadius.circular(12)),
        ),
      );
      return;
    }
    _openOverlay('result');
  }

  @override
  Widget build(BuildContext context) {
    final isDark = Theme.of(context).brightness == Brightness.dark;
    final brand = isDark ? AppColors.darkBrand500 : AppColors.brand500;
    final fg3 = isDark ? AppColors.darkFg3 : AppColors.fg3;
    final border = isDark ? AppColors.darkBorderFaint : AppColors.borderFaint;
    final navBg = (isDark ? AppColors.darkBgSurface : AppColors.bgSurface)
        .withOpacity(0.85);
    final provider = context.watch<AppProvider>();

    // Current tab body
    final tabBody = IndexedStack(
      index: _tab,
      children: [
        HomeScreen(
          onCalculate: _calculate,
          onOpenSettings: () => setState(() => _tab = 3),
        ),
        HistoryScreen(onAddEntry: () => setState(() => _tab = 0)),
        TipsScreen(onOpenPaywall: () => _openOverlay('paywall')),
        SettingsScreen(onOpenPaywall: () => _openOverlay('paywall')),
      ],
    );

    return Scaffold(
      body: Stack(
        children: [
          // Tab content
          tabBody,

          // Bottom nav
          if (_overlay == null)
            Positioned(
              left: 0, right: 0, bottom: 0,
              child: ClipRect(
                child: BackdropFilter(
                  filter: ImageFilter.blur(sigmaX: 14, sigmaY: 14),
                  child: Container(
                    decoration: BoxDecoration(
                      color: navBg,
                      border: Border(
                          top: BorderSide(color: border, width: 1)),
                    ),
                    child: SafeArea(
                      top: false,
                      child: SizedBox(
                        height: 64,
                        child: Row(
                          children: _tabs.asMap().entries.map((e) {
                            final i = e.key;
                            final t = e.value;
                            final on = i == _tab;
                            return Expanded(
                              child: GestureDetector(
                                behavior: HitTestBehavior.opaque,
                                onTap: () => setState(() => _tab = i),
                                child: Column(
                                  mainAxisAlignment: MainAxisAlignment.center,
                                  children: [
                                    Icon(
                                      on ? t.iconActive : t.icon,
                                      size: 22,
                                      color: on ? brand : fg3,
                                    ),
                                    const SizedBox(height: 4),
                                    Text(
                                      t.label,
                                      style: GoogleFonts.inter(
                                        fontSize: 10.5,
                                        fontWeight: FontWeight.w600,
                                        color: on ? brand : fg3,
                                        letterSpacing: 0.1,
                                        height: 1,
                                      ),
                                    ),
                                  ],
                                ),
                              ),
                            );
                          }).toList(),
                        ),
                      ),
                    ),
                  ),
                ),
              ),
            ),

          // Overlays
          if (_overlay == 'result')
            _Overlay(
              child: ResultScreen(
                bmi: provider.currentBmi > 0
                    ? provider.currentBmi
                    : 24.0,
                onClose: _closeOverlay,
                onSave: () async {
                  await provider.saveCurrentResult();
                  _closeOverlay();
                  setState(() => _tab = 1);
                },
                onSetGoal: () => _openOverlay('goal'),
                onShare: () => _openOverlay('share'),
              ),
            ),

          if (_overlay == 'goal')
            _Overlay(
              child: GoalScreen(
                currentWeight: provider.profile.weightInKg,
                onStart: () {
                  _closeOverlay();
                  setState(() => _tab = 1);
                },
                onClose: () => _openOverlay('result'),
              ),
            ),

          if (_overlay == 'paywall')
            _Overlay(
              child: PaywallScreen(onClose: _closeOverlay),
            ),

          if (_overlay == 'share')
            _Overlay(
              child: ShareScreen(
                bmi: provider.currentBmi > 0
                    ? provider.currentBmi
                    : 24.0,
                onClose: () => _openOverlay('result'),
              ),
            ),
        ],
      ),
    );
  }
}

class _Overlay extends StatelessWidget {
  final Widget child;
  const _Overlay({required this.child});

  @override
  Widget build(BuildContext context) {
    return Positioned.fill(child: child);
  }
}
