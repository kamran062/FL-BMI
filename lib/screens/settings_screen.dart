import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:provider/provider.dart';
import '../providers/app_provider.dart';
import '../services/purchase_service.dart';
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
                onTap: () => _showPrivacyDialog(context, isDark, fg1, fg3, brand),
              ),
              _Row(
                icon: Icons.restore_rounded,
                label: 'Restore purchases',
                kind: _RowKind.nav,
                onTap: () => _restorePurchases(context, brand, fg3),
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
                      GestureDetector(
                        onTap: onOpenPaywall,
                        child: Container(
                          decoration: BoxDecoration(
                            borderRadius: BorderRadius.circular(24),
                            gradient: LinearGradient(
                              begin: Alignment.topLeft,
                              end: Alignment.bottomRight,
                              colors: isDark
                                  ? const [Color(0xFF1A3028), Color(0xFF0C1510)]
                                  : const [Color(0xFF0E1411), Color(0xFF1A2E20)],
                            ),
                            border: isDark
                                ? Border.all(
                                    color: AppColors.darkBrand500.withAlpha(60),
                                    width: 1.5,
                                  )
                                : null,
                            boxShadow: [
                              BoxShadow(
                                color: brand.withAlpha(isDark ? 50 : 30),
                                blurRadius: 24,
                                offset: const Offset(0, 8),
                              ),
                            ],
                          ),
                          clipBehavior: Clip.antiAlias,
                          child: Stack(
                            children: [
                              // Radial glow
                              Positioned(
                                right: -40, top: -40,
                                child: Container(
                                  width: 180, height: 180,
                                  decoration: BoxDecoration(
                                    shape: BoxShape.circle,
                                    gradient: RadialGradient(
                                      colors: [
                                        brand.withAlpha(isDark ? 90 : 70),
                                        brand.withAlpha(0),
                                      ],
                                    ),
                                  ),
                                ),
                              ),
                              Padding(
                                padding: const EdgeInsets.all(20),
                                child: Column(
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
                                    const SizedBox(height: 10),
                                    Text(
                                      'Track your full journey',
                                      style: GoogleFonts.inter(
                                        fontSize: 20,
                                        fontWeight: FontWeight.w700,
                                        letterSpacing: -0.02 * 20,
                                        color: Colors.white,
                                        height: 1.2,
                                      ),
                                    ),
                                    const SizedBox(height: 6),
                                    Text(
                                      'Unlimited goals, advanced insights, and 500+ tips — from \$2.50 / mo.',
                                      style: GoogleFonts.inter(
                                        fontSize: 13,
                                        fontWeight: FontWeight.w400,
                                        color: Colors.white.withAlpha(165),
                                        height: 1.45,
                                      ),
                                    ),
                                    const SizedBox(height: 16),
                                    AppButton(
                                      label: 'See plans',
                                      variant: AppButtonVariant.primary,
                                      size: AppButtonSize.sm,
                                      icon: Icons.arrow_forward_rounded,
                                      onPressed: onOpenPaywall,
                                    ),
                                  ],
                                ),
                              ),
                            ],
                          ),
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

  // ── Privacy dialog ─────────────────────────────────────────────────────────
  void _showPrivacyDialog(BuildContext context, bool isDark,
      Color fg1, Color fg3, Color brand) {
    final bg = isDark ? AppColors.darkBgSurface : AppColors.bgSurface;
    showDialog(
      context: context,
      builder: (_) => AlertDialog(
        backgroundColor: bg,
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(20)),
        title: Row(
          children: [
            Icon(Icons.privacy_tip_outlined, color: brand, size: 20),
            const SizedBox(width: 10),
            Text(
              'Privacy Policy',
              style: GoogleFonts.inter(
                fontSize: 17, fontWeight: FontWeight.w700, color: fg1,
              ),
            ),
          ],
        ),
        content: SingleChildScrollView(
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              _privacySection(
                '🔒 Data stays on your device',
                'BMI Health stores all your data — weight entries, goals, and profile — '
                'locally on your device using SQLite. Nothing is sent to any server.',
                fg1, fg3,
              ),
              _privacySection(
                '📊 No analytics or tracking',
                'We do not use any analytics SDKs, crash reporters, or user-tracking tools. '
                'We have no idea who you are, and we prefer it that way.',
                fg1, fg3,
              ),
              _privacySection(
                '📢 Ads (free plan only)',
                'Free users see banner ads powered by Google AdMob. AdMob may use a '
                'device advertising ID for ad personalisation. Upgrade to Premium to '
                'remove all ads entirely.',
                fg1, fg3,
              ),
              _privacySection(
                '🗑 Deleting your data',
                'Uninstalling the app permanently deletes all your data from the device. '
                'There is no cloud backup unless you subscribe to Premium.',
                fg1, fg3,
              ),
            ],
          ),
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(context),
            child: Text(
              'Got it',
              style: GoogleFonts.inter(
                fontWeight: FontWeight.w600, color: brand,
              ),
            ),
          ),
        ],
      ),
    );
  }

  Widget _privacySection(
      String title, String body, Color fg1, Color fg3) {
    return Padding(
      padding: const EdgeInsets.only(bottom: 16),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(title,
              style: GoogleFonts.inter(
                  fontSize: 13, fontWeight: FontWeight.w600, color: fg1)),
          const SizedBox(height: 4),
          Text(body,
              style: GoogleFonts.inter(
                  fontSize: 13, fontWeight: FontWeight.w400,
                  color: fg3, height: 1.5)),
        ],
      ),
    );
  }

  // ── Restore purchases ──────────────────────────────────────────────────────
  Future<void> _restorePurchases(
      BuildContext context, Color brand, Color fg3) async {
    final svc = PurchaseService.instance;

    // Show loading snack
    ScaffoldMessenger.of(context).showSnackBar(SnackBar(
      content: Row(
        children: [
          SizedBox(
            width: 16, height: 16,
            child: CircularProgressIndicator(
              strokeWidth: 2, color: brand,
            ),
          ),
          const SizedBox(width: 12),
          Text('Restoring purchases…',
              style: GoogleFonts.inter(fontSize: 14)),
        ],
      ),
      duration: const Duration(seconds: 3),
      behavior: SnackBarBehavior.floating,
      shape: RoundedRectangleBorder(
          borderRadius: BorderRadius.circular(12)),
    ));

    await svc.restore();

    if (!context.mounted) return;
    ScaffoldMessenger.of(context).clearSnackBars();

    if (svc.isPremium) {
      ScaffoldMessenger.of(context).showSnackBar(SnackBar(
        content: Row(
          children: [
            Icon(Icons.check_circle_outline_rounded,
                color: brand, size: 18),
            const SizedBox(width: 10),
            Text('Premium restored successfully!',
                style: GoogleFonts.inter(fontSize: 14)),
          ],
        ),
        behavior: SnackBarBehavior.floating,
        shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(12)),
      ));
    } else {
      ScaffoldMessenger.of(context).showSnackBar(SnackBar(
        content: Text(
          svc.error ?? 'No active purchases found for this account.',
          style: GoogleFonts.inter(fontSize: 14),
        ),
        behavior: SnackBarBehavior.floating,
        shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(12)),
      ));
    }
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
  final VoidCallback? onTap;

  const _Row({
    required this.icon,
    required this.label,
    required this.kind,
    this.meta,
    this.toggleValue,
    this.onToggle,
    this.onTap,
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
    final canTap = row.onTap != null || row.kind == _RowKind.nav;

    return InkWell(
      onTap: row.onTap,
      borderRadius: BorderRadius.circular(0),
      splashColor: brand.withAlpha(20),
      highlightColor: brand.withAlpha(10),
      child: Container(
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
            Icon(Icons.chevron_right_rounded, size: 18,
                color: canTap ? fg3 : fg3.withAlpha(80)),
          ],
        ],
      ),
      ),
    );
  }
}
