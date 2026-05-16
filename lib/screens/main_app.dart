import 'dart:ui';
import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:provider/provider.dart';
import '../providers/app_provider.dart';
import '../services/purchase_service.dart';
import '../theme/app_colors.dart';
import '../widgets/banner_ad_widget.dart';
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
    final isPremium = context.watch<PurchaseService>().isPremium;

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

    final bottomPad = MediaQuery.of(context).padding.bottom;
    // Nav bar: 64px height + 12px bottom margin + safe area
    final navTotalH = 64.0 + 12.0 + bottomPad;

    return Scaffold(
      body: Stack(
        children: [
          // Tab content — padded so it never hides behind the floating nav
          Padding(
            padding: EdgeInsets.only(bottom: _overlay == null ? navTotalH : 0),
            child: tabBody,
          ),

          // Banner ad (free users) — sits just above the nav bar
          if (_overlay == null && !isPremium)
            Positioned(
              left: 0, right: 0,
              bottom: navTotalH,
              child: const BannerAdWidget(),
            ),

          // ── Floating pill nav bar ─────────────────────────────────────────
          if (_overlay == null)
            Positioned(
              left: 16, right: 16, bottom: 0,
              child: SafeArea(
                top: false,
                child: Padding(
                  padding: const EdgeInsets.only(bottom: 12),
                  child: Container(
                    height: 64,
                    decoration: BoxDecoration(
                      color: navBg,
                      borderRadius: BorderRadius.circular(28),
                      border: Border.all(color: border, width: 1),
                      boxShadow: [
                        BoxShadow(
                          color: Colors.black.withAlpha(isDark ? 90 : 18),
                          blurRadius: 32, offset: const Offset(0, 10),
                        ),
                        BoxShadow(
                          color: Colors.black.withAlpha(isDark ? 40 : 8),
                          blurRadius: 8, offset: const Offset(0, 2),
                        ),
                      ],
                    ),
                    child: ClipRRect(
                      borderRadius: BorderRadius.circular(28),
                      child: BackdropFilter(
                        filter: ImageFilter.blur(sigmaX: 20, sigmaY: 20),
                        child: Row(
                          children: _tabs.asMap().entries.map((e) {
                            final i  = e.key;
                            final t  = e.value;
                            final on = i == _tab;
                            return Expanded(
                              child: SizedBox(
                                height: 50,
                                child: GestureDetector(
                                  behavior: HitTestBehavior.opaque,
                                  onTap: () => setState(() => _tab = i),
                                  child: Padding(
                                    padding: const EdgeInsets.all(4),
                                    child: AnimatedContainer(
                                      duration:
                                          const Duration(milliseconds: 260),
                                      curve: Curves.easeOutCubic,
                                      decoration: BoxDecoration(
                                        color: on
                                            ? brand
                                            : Colors.transparent,
                                        borderRadius:
                                            BorderRadius.circular(10),
                                      ),
                                      child: Row(
                                        mainAxisAlignment:
                                            MainAxisAlignment.center,
                                        children: [
                                          // Icon with switch animation
                                          AnimatedSwitcher(
                                            duration: const Duration(
                                                milliseconds: 200),
                                            transitionBuilder: (child, anim) =>
                                                ScaleTransition(
                                                    scale: anim, child: child),
                                            child: Icon(
                                              on ? t.iconActive : t.icon,
                                              key: ValueKey(
                                                  'nav_${t.label}_$on'),
                                              size: 21,
                                              color: on
                                                  ? Colors.white
                                                  : fg3,
                                            ),
                                          ),
                                          // Label slides in when active
                                          AnimatedSize(
                                            duration: const Duration(
                                                milliseconds: 240),
                                            curve: Curves.easeOutCubic,
                                            child: on
                                                ? Padding(
                                                    padding:
                                                        const EdgeInsets.only(
                                                            left: 6),
                                                    child: Text(
                                                      t.label,
                                                      style: GoogleFonts.inter(
                                                        fontSize: 12,
                                                        fontWeight:
                                                            FontWeight.w700,
                                                        color: Colors.white,
                                                        letterSpacing: -0.01 * 12,
                                                        height: 1,
                                                      ),
                                                    ),
                                                  )
                                                : const SizedBox.shrink(),
                                          ),
                                        ],
                                      ),
                                    ),
                                  ),
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
