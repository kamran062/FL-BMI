import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:provider/provider.dart';
import '../providers/app_provider.dart';
import '../theme/app_colors.dart';
import '../widgets/app_button.dart';
import '../widgets/app_card.dart';
import '../widgets/app_toggle.dart';
import '../widgets/overline_label.dart';
import '../widgets/screen_header.dart';

class SettingsScreen extends StatelessWidget {
  final VoidCallback onOpenPaywall;
  const SettingsScreen({super.key, required this.onOpenPaywall});

  @override
  Widget build(BuildContext context) {
    final isDark = Theme.of(context).brightness == Brightness.dark;
    final bgCanvas = isDark ? AppColors.darkBgCanvas : AppColors.bgCanvas;
    final fg1 = isDark ? AppColors.darkFg1 : AppColors.fg1;
    final fg3 = isDark ? AppColors.darkFg3 : AppColors.fg3;
    final bgTint = isDark ? AppColors.darkBgTint : AppColors.bgTint;
    final brand = isDark ? AppColors.darkBrand500 : AppColors.brand500;

    return Consumer<AppProvider>(
      builder: (context, provider, _) {
        final sections = [
          _Section(
            title: 'Appearance',
            rows: [
              _Row(
                icon: Icons.dark_mode_outlined,
                label: 'Dark mode',
                kind: _RowKind.toggle,
                toggleValue: provider.isDark,
                onToggle: (v) => provider.setTheme(
                    v ? ThemeMode.dark : ThemeMode.light),
              ),
            ],
          ),
          _Section(
            title: 'Units',
            rows: [
              _Row(
                icon: Icons.straighten_rounded,
                label: 'Height',
                kind: _RowKind.meta,
                meta: provider.profile.heightUnit == 'cm' ? 'cm' : 'ft / in',
              ),
              _Row(
                icon: Icons.monitor_weight_outlined,
                label: 'Weight',
                kind: _RowKind.meta,
                meta: provider.profile.weightUnit == 'kg' ? 'kg' : 'lbs',
              ),
            ],
          ),
          _Section(
            title: 'Notifications',
            rows: [
              _Row(
                icon: Icons.notifications_outlined,
                label: 'Daily reminders',
                kind: _RowKind.toggle,
                toggleValue: provider.dailyReminder,
                onToggle: provider.setDailyReminder,
              ),
              _Row(
                icon: Icons.calendar_today_outlined,
                label: 'Weekly check-in',
                kind: _RowKind.toggle,
                toggleValue: provider.weeklyCheckIn,
                onToggle: provider.setWeeklyCheckIn,
              ),
            ],
          ),
          _Section(
            title: 'About',
            rows: [
              _Row(
                icon: Icons.privacy_tip_outlined,
                label: 'Privacy',
                kind: _RowKind.nav,
                meta: 'On-device',
              ),
              _Row(
                icon: Icons.restore_rounded,
                label: 'Restore purchases',
                kind: _RowKind.nav,
              ),
              _Row(
                icon: Icons.info_outline_rounded,
                label: 'Version',
                kind: _RowKind.meta,
                meta: '1.0 (build 1)',
              ),
            ],
          ),
        ];

        return Scaffold(
          backgroundColor: bgCanvas,
          body: SafeArea(
            child: CustomScrollView(
              slivers: [
                const SliverToBoxAdapter(
                  child: ScreenHeader(title: 'Settings', large: true),
                ),
                SliverPadding(
                  padding: const EdgeInsets.fromLTRB(20, 0, 20, 24),
                  sliver: SliverList(
                    delegate: SliverChildListDelegate([
                      // Premium upsell card
                      AppCard(
                        padding: 20,
                        radius: 24,
                        tint: isDark ? AppColors.darkFg1 : AppColors.fg1,
                        onTap: onOpenPaywall,
                        child: Stack(
                          children: [
                            Positioned(
                              right: -40, top: -40,
                              child: Container(
                                width: 160, height: 160,
                                decoration: BoxDecoration(
                                  shape: BoxShape.circle,
                                  gradient: RadialGradient(
                                    colors: [
                                      AppColors.brand500.withOpacity(0.45),
                                      AppColors.brand500.withOpacity(0),
                                    ],
                                  ),
                                ),
                              ),
                            ),
                            Column(
                              crossAxisAlignment: CrossAxisAlignment.start,
                              children: [
                                Row(
                                  children: [
                                    Icon(Icons.auto_awesome_rounded,
                                        size: 16, color: brand),
                                    const SizedBox(width: 8),
                                    Text(
                                      'PREMIUM',
                                      style: GoogleFonts.inter(
                                        fontSize: 11,
                                        fontWeight: FontWeight.w600,
                                        letterSpacing: 0.12 * 11,
                                        color: brand,
                                      ),
                                    ),
                                  ],
                                ),
                                const SizedBox(height: 8),
                                Text(
                                  'Track your full journey',
                                  style: GoogleFonts.inter(
                                    fontSize: 19,
                                    fontWeight: FontWeight.w600,
                                    letterSpacing: -0.015 * 19,
                                    color: Colors.white,
                                  ),
                                ),
                                const SizedBox(height: 4),
                                Text(
                                  'Unlimited goals, advanced insights, and 500+ tips — from \$2.50 / mo.',
                                  style: GoogleFonts.inter(
                                    fontSize: 13,
                                    fontWeight: FontWeight.w400,
                                    color: Colors.white.withOpacity(0.65),
                                    height: 1.4,
                                  ),
                                ),
                                const SizedBox(height: 14),
                                AppButton(
                                  label: 'See plans',
                                  variant: AppButtonVariant.primary,
                                  size: AppButtonSize.sm,
                                  icon: Icons.arrow_forward_rounded,
                                  onPressed: onOpenPaywall,
                                ),
                              ],
                            ),
                          ],
                        ),
                      ),

                      ...sections.map((sec) => Padding(
                        padding: const EdgeInsets.only(top: 20),
                        child: Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            Padding(
                              padding: const EdgeInsets.only(left: 4, bottom: 8),
                              child: OverlineLabel(sec.title),
                            ),
                            AppCard(
                              padding: 0,
                              child: Column(
                                children: sec.rows.asMap().entries.map((e) {
                                  final ri = e.key;
                                  final r = e.value;
                                  return _SettingsRow(
                                    row: r, index: ri,
                                    isDark: isDark,
                                    bgTint: bgTint,
                                    brand: brand,
                                    fg1: fg1, fg3: fg3,
                                  );
                                }).toList(),
                              ),
                            ),
                          ],
                        ),
                      )),

                      const SizedBox(height: 24),
                      Text(
                        'Made with care.  ·  No account required.',
                        textAlign: TextAlign.center,
                        style: GoogleFonts.inter(
                          fontSize: 12,
                          fontWeight: FontWeight.w500,
                          color: fg3,
                          height: 1.4,
                        ),
                      ),
                    ]),
                  ),
                ),
              ],
            ),
          ),
        );
      },
    );
  }
}

enum _RowKind { toggle, meta, nav }

class _Row {
  final IconData icon;
  final String label;
  final _RowKind kind;
  final String? meta;
  final bool? toggleValue;
  final ValueChanged<bool>? onToggle;

  const _Row({
    required this.icon,
    required this.label,
    required this.kind,
    this.meta,
    this.toggleValue,
    this.onToggle,
  });
}

class _Section {
  final String title;
  final List<_Row> rows;
  const _Section({required this.title, required this.rows});
}

class _SettingsRow extends StatelessWidget {
  final _Row row;
  final int index;
  final bool isDark;
  final Color bgTint;
  final Color brand;
  final Color fg1;
  final Color fg3;

  const _SettingsRow({
    required this.row,
    required this.index,
    required this.isDark,
    required this.bgTint,
    required this.brand,
    required this.fg1,
    required this.fg3,
  });

  @override
  Widget build(BuildContext context) {
    final border = isDark ? AppColors.darkBorderFaint : AppColors.borderFaint;
    return Container(
      padding: const EdgeInsets.symmetric(vertical: 14, horizontal: 18),
      decoration: BoxDecoration(
        border: index > 0
            ? Border(top: BorderSide(color: border, width: 1))
            : null,
      ),
      child: Row(
        children: [
          Container(
            width: 32, height: 32,
            decoration: BoxDecoration(
              color: bgTint,
              borderRadius: BorderRadius.circular(10),
            ),
            child: Icon(row.icon, size: 16, color: brand),
          ),
          const SizedBox(width: 14),
          Expanded(
            child: Text(
              row.label,
              style: GoogleFonts.inter(
                fontSize: 15, fontWeight: FontWeight.w500, color: fg1,
              ),
            ),
          ),
          if (row.kind == _RowKind.toggle)
            AppToggle(value: row.toggleValue ?? false, onChanged: row.onToggle),
          if (row.kind == _RowKind.meta && row.meta != null)
            Text(
              row.meta!,
              style: GoogleFonts.inter(
                fontSize: 13, fontWeight: FontWeight.w500, color: fg3,
                fontFeatures: const [FontFeature.tabularFigures()],
              ),
            ),
          if (row.kind == _RowKind.nav) ...[
            if (row.meta != null) ...[
              Text(row.meta!,
                  style: GoogleFonts.inter(
                      fontSize: 13, fontWeight: FontWeight.w500, color: fg3)),
              const SizedBox(width: 4),
            ],
            Icon(Icons.chevron_right_rounded, size: 18, color: fg3),
          ],
        ],
      ),
    );
  }
}
