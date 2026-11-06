import 'dart:ui';
import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:bmi_health/shared/theme/app_colors.dart';
import 'package:bmi_health/features/ads/banner_ad_widget.dart';
import 'package:bmi_health/l10n/l10n.dart';
import 'package:bmi_health/shared/theme/text_tracking.dart';
import 'package:provider/provider.dart';
import 'package:bmi_health/app/settings_provider.dart';
import 'package:bmi_health/core/notifications/reminder_service.dart';
import 'package:bmi_health/features/movement/movement_provider.dart';
import 'package:bmi_health/features/profile/profile_provider.dart';
import 'package:bmi_health/features/train/wear/wear_bridge.dart';

/// Tab shell: floating pill nav bar + banner ad above it.
/// Full-screen pages (result, goal, share) are pushed above this shell by the
/// router, so they cover the nav bar and banner automatically.
class AppShell extends StatefulWidget {
  final StatefulNavigationShell navigationShell;
  const AppShell({super.key, required this.navigationShell});

  @override
  State<AppShell> createState() => _AppShellState();
}

class _AppShellState extends State<AppShell> {
  double _bannerH = 0.0; // set by BannerAdWidget once an ad has loaded
  Object? _reminderKey;

  @override
  void didChangeDependencies() {
    super.didChangeDependencies();
    // Keep scheduled reminders in step with the settings and the language
    // (notification text is localised when it is scheduled).
    final s = context.watch<SettingsProvider>();
    final l = context.l10n;
    final perWeek = context.watch<ProfileProvider>().profile.daysPerWeek;
    final key = (s.reminders.signature, perWeek, l.localeName);
    if (key == _reminderKey) return;
    _reminderKey = key;
    ReminderService.instance.sync(s.reminders, l: l, perWeek: perWeek);
    context.read<WearBridge>().locale = l.localeName;
    // Restart location tracking after a relaunch if the user left it on
    context.read<MovementProvider>().resume(l);
  }

  // Order must match the router's StatefulShellRoute branches.
  static const _tabs = [
    (icon: Icons.today_outlined,      iconActive: Icons.today_rounded),
    (icon: Icons.monitor_weight_outlined, iconActive: Icons.monitor_weight_rounded),
    (icon: Icons.fitness_center_outlined, iconActive: Icons.fitness_center_rounded),
    (icon: Icons.restaurant_outlined, iconActive: Icons.restaurant_rounded),
    (icon: Icons.settings_outlined,   iconActive: Icons.settings_rounded),
  ];

  void _goTab(int i) {
    final shell = widget.navigationShell;
    // Tapping the active tab again returns it to its first page.
    shell.goBranch(i, initialLocation: i == shell.currentIndex);
  }

  @override
  Widget build(BuildContext context) {
    final isDark = Theme.of(context).brightness == Brightness.dark;
    final brand = isDark ? AppColors.darkBrand500 : AppColors.brand500;
    final fg3 = isDark ? AppColors.darkFg3 : AppColors.fg3;
    final border = isDark ? AppColors.darkBorderFaint : AppColors.borderFaint;
    final navBg = (isDark ? AppColors.darkBgSurface : AppColors.bgSurface)
        .withValues(alpha: 0.85);
    final current = widget.navigationShell.currentIndex;
    final l = context.l10n;
    final labels = [l.navToday, l.navBody, l.navTrain, l.navFuel, l.navSettings];

    final bottomPad = MediaQuery.of(context).padding.bottom;
    // Nav bar: 64px height + 12px bottom margin + safe area
    final navTotalH = 64.0 + 12.0 + bottomPad;

    // System back on any tab but the first returns to Calculate instead of
    // closing the app.
    return PopScope(
      canPop: current == 0,
      onPopInvokedWithResult: (didPop, _) {
        if (!didPop) _goTab(0);
      },
      child: Scaffold(
        body: Stack(
          children: [
            // Tab content — padded so it never hides behind the floating nav or banner
            Padding(
              padding: EdgeInsets.only(bottom: navTotalH + _bannerH),
              child: widget.navigationShell,
            ),

            // Banner ad — sits just above the nav bar
            Positioned(
              left: 0, right: 0,
              bottom: navTotalH,
              child: BannerAdWidget(
                onHeightChanged: (h) {
                  if (_bannerH != h) setState(() => _bannerH = h);
                },
              ),
            ),

            // ── Floating pill nav bar ───────────────────────────────────────
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
                            final on = i == current;
                            return Expanded(
                              child: Semantics(
                                button: true,
                                selected: on,
                                label: labels[i],
                                excludeSemantics: true, // the visible text would repeat the label
                                child: GestureDetector(
                                  behavior: HitTestBehavior.opaque,
                                  onTap: () => _goTab(i),
                                  child: Center(
                                    child: AnimatedContainer(
                                      duration: const Duration(milliseconds: 240),
                                      curve: Curves.easeOutCubic,
                                      padding: const EdgeInsets.symmetric(
                                          horizontal: 12, vertical: 5),
                                      decoration: BoxDecoration(
                                        color: on
                                            ? brand.withAlpha(30)
                                            : Colors.transparent,
                                        borderRadius: BorderRadius.circular(16),
                                      ),
                                      child: Column(
                                        mainAxisSize: MainAxisSize.min,
                                        children: [
                                          AnimatedSwitcher(
                                            duration: const Duration(milliseconds: 200),
                                            transitionBuilder: (child, anim) =>
                                                ScaleTransition(scale: anim, child: child),
                                            // Icons such as the trend chart must
                                            // not mirror in Urdu (a rising line
                                            // would read as falling).
                                            child: Directionality(
                                              key: ValueKey('nav_${i}_$on'),
                                              textDirection: TextDirection.ltr,
                                              child: Icon(
                                                on ? t.iconActive : t.icon,
                                                size: 20,
                                                color: on ? brand : fg3,
                                              ),
                                            ),
                                          ),
                                          const SizedBox(height: 2),
                                          Text(
                                            labels[i],
                                            style: GoogleFonts.inter(
                                              fontSize: 10,
                                              fontWeight: on
                                                  ? FontWeight.w700
                                                  : FontWeight.w500,
                                              color: on ? brand : fg3,
                                              letterSpacing: tracking(context, -0.01 * 10),
                                              height: 1,
                                            ),
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
          ],
        ),
      ),
    );
  }
}
