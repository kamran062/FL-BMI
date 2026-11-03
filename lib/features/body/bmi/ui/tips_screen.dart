import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:bmi_health/shared/theme/app_colors.dart';
import 'package:bmi_health/shared/widgets/app_card.dart';
import 'package:bmi_health/shared/widgets/screen_header.dart';
import 'package:bmi_health/l10n/l10n.dart';
import 'package:bmi_health/shared/theme/text_tracking.dart';

class TipsScreen extends StatefulWidget {
  const TipsScreen({super.key});

  @override
  State<TipsScreen> createState() => _TipsScreenState();
}

class _TipsScreenState extends State<TipsScreen> {
  String _cat = 'all';

  static const _tips = [
    (
      cat: 'diet', icon: Icons.eco_outlined, id: 1,
      color: Color(0xFF16A34A), tint: Color(0xFFE6F7EC),
    ),
    (
      cat: 'hydration', icon: Icons.water_drop_outlined, id: 2,
      color: Color(0xFF3B82F6), tint: Color(0xFFEAF1FE),
    ),
    (
      cat: 'exercise', icon: Icons.directions_walk_rounded, id: 3,
      color: Color(0xFFF59E0B), tint: Color(0xFFFEF4E2),
    ),
    (
      cat: 'lifestyle', icon: Icons.bedtime_outlined, id: 4,
      color: Color(0xFF8B5CF6), tint: Color(0xFFF0EBFE),
    ),
    (
      cat: 'diet', icon: Icons.lunch_dining_outlined, id: 5,
      color: Color(0xFF16A34A), tint: Color(0xFFE6F7EC),
    ),
    (
      cat: 'exercise', icon: Icons.fitness_center_outlined, id: 6,
      color: Color(0xFFF59E0B), tint: Color(0xFFFEF4E2),
    ),
    (
      cat: 'hydration', icon: Icons.local_drink_outlined, id: 7,
      color: Color(0xFF3B82F6), tint: Color(0xFFEAF1FE),
    ),
    (
      cat: 'lifestyle', icon: Icons.self_improvement_outlined, id: 8,
      color: Color(0xFF8B5CF6), tint: Color(0xFFF0EBFE),
    ),
  ];

  static String _catLabel(AppLocalizations l, String cat) => switch (cat) {
        'diet' => l.tipCatDiet,
        'exercise' => l.tipCatExercise,
        'hydration' => l.tipCatHydration,
        'lifestyle' => l.tipCatLifestyle,
        _ => l.categoryAll,
      };

  static String _tipTitle(AppLocalizations l, int id) => switch (id) {
        1 => l.tip1Title, 2 => l.tip2Title, 3 => l.tip3Title, 4 => l.tip4Title,
        5 => l.tip5Title, 6 => l.tip6Title, 7 => l.tip7Title, _ => l.tip8Title,
      };

  static String _tipBody(AppLocalizations l, int id) => switch (id) {
        1 => l.tip1Body, 2 => l.tip2Body, 3 => l.tip3Body, 4 => l.tip4Body,
        5 => l.tip5Body, 6 => l.tip6Body, 7 => l.tip7Body, _ => l.tip8Body,
      };

  // (key, icon, color, tint); labels come from _catLabel.
  static const _cats = [
    ('all',       Icons.apps_rounded,                Color(0xFF1FB573), Color(0xFFE8F7EF)),
    ('diet',      Icons.eco_outlined,                Color(0xFF16A34A), Color(0xFFE6F7EC)),
    ('exercise',  Icons.fitness_center_outlined,     Color(0xFFF59E0B), Color(0xFFFEF4E2)),
    ('hydration', Icons.water_drop_outlined,         Color(0xFF3B82F6), Color(0xFFEAF1FE)),
    ('lifestyle', Icons.self_improvement_outlined,   Color(0xFF8B5CF6), Color(0xFFF0EBFE)),
  ];

  @override
  Widget build(BuildContext context) {
    final l = context.l10n;
    final isDark = Theme.of(context).brightness == Brightness.dark;
    final bgCanvas = isDark ? AppColors.darkBgCanvas : AppColors.bgCanvas;
    final fg1 = isDark ? AppColors.darkFg1 : AppColors.fg1;
    final fg2 = isDark ? AppColors.darkFg2 : AppColors.fg2;
    final surfaceBg = isDark ? AppColors.darkBgSurface : AppColors.bgSurface;

    final visible = _cat == 'all'
        ? _tips
        : _tips.where((t) => t.cat == _cat).toList();
    final featured = visible.isNotEmpty ? visible.first : null;

    return Scaffold(
      backgroundColor: bgCanvas,
      body: SafeArea(
        child: CustomScrollView(
          slivers: [
            SliverToBoxAdapter(
              child: ScreenHeader(
                title: l.tipsTitle,
                large: true,
              ),
            ),

            // Category tabs
            SliverToBoxAdapter(
              child: SizedBox(
                height: 90,
                child: ListView(
                  padding: const EdgeInsets.fromLTRB(20, 0, 20, 0),
                  scrollDirection: Axis.horizontal,
                  children: _cats.map((c) {
                    final label = _catLabel(l, c.$1);
                    final active = c.$1 == _cat;
                    final catColor = c.$3;
                    final catTint  = c.$4;
                    return GestureDetector(
                      onTap: () => setState(() => _cat = c.$1),
                      child: AnimatedContainer(
                        duration: const Duration(milliseconds: 180),
                        curve: Curves.easeOut,
                        margin: const EdgeInsetsDirectional.only(end: 10),
                        width: 80,
                        decoration: BoxDecoration(
                          color: active ? catColor : surfaceBg,
                          borderRadius: BorderRadius.circular(18),
                          boxShadow: active
                              ? [
                                  BoxShadow(
                                    color: catColor.withAlpha(60),
                                    blurRadius: 12,
                                    offset: const Offset(0, 4),
                                  ),
                                ]
                              : [
                                  BoxShadow(
                                    color: Colors.black.withAlpha(8),
                                    blurRadius: 4,
                                    offset: const Offset(0, 2),
                                  ),
                                ],
                        ),
                        child: Column(
                          mainAxisAlignment: MainAxisAlignment.center,
                          children: [
                            AnimatedContainer(
                              duration: const Duration(milliseconds: 180),
                              width: 38, height: 38,
                              decoration: BoxDecoration(
                                color: active
                                    ? Colors.white.withAlpha(30)
                                    : catTint,
                                borderRadius: BorderRadius.circular(12),
                              ),
                              child: Icon(
                                c.$2,
                                size: 20,
                                color: active ? Colors.white : catColor,
                              ),
                            ),
                            const SizedBox(height: 6),
                            Text(
                              label,
                              style: GoogleFonts.inter(
                                fontSize: 11,
                                fontWeight: FontWeight.w600,
                                color: active
                                    ? Colors.white
                                    : (isDark ? AppColors.darkFg2 : AppColors.fg2),
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
            const SliverToBoxAdapter(child: SizedBox(height: 4)),

            SliverPadding(
              padding: const EdgeInsets.fromLTRB(20, 8, 20, 24),
              sliver: SliverList(
                delegate: SliverChildListDelegate([
                  // Featured tip
                  if (featured != null) ...[
                    AppCard(
                      padding: 22,
                      radius: 24,
                      tint: featured.tint,
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Row(
                            children: [
                              Container(
                                width: 32, height: 32,
                                decoration: BoxDecoration(
                                  color: Colors.white,
                                  borderRadius: BorderRadius.circular(10),
                                ),
                                child: Icon(featured.icon,
                                    size: 18, color: featured.color),
                              ),
                              const SizedBox(width: 10),
                              Text(
                                l.tipToday(_catLabel(l, featured.cat)).toUpperCase(),
                                style: GoogleFonts.inter(
                                  fontSize: 11,
                                  fontWeight: FontWeight.w600,
                                  letterSpacing: tracking(context, 0.08 * 11),
                                  color: featured.color,
                                ),
                              ),
                            ],
                          ),
                          const SizedBox(height: 16),
                          Text(
                            _tipTitle(l, featured.id),
                            style: GoogleFonts.inter(
                              fontSize: 24,
                              fontWeight: FontWeight.w700,
                              letterSpacing: -0.02 * 24,
                              color: fg1,
                              height: 1.25,
                            ),
                          ),
                          const SizedBox(height: 8),
                          Text(
                            _tipBody(l, featured.id),
                            style: GoogleFonts.inter(
                              fontSize: 15,
                              fontWeight: FontWeight.w400,
                              color: fg2,
                              height: 1.5,
                            ),
                          ),
                        ],
                      ),
                    ),
                    const SizedBox(height: 14),
                  ],

                  // Remaining tips
                  ...visible.skip(1).map((t) => Padding(
                    padding: const EdgeInsets.only(bottom: 14),
                    child: AppCard(
                      padding: 16,
                      child: Row(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Container(
                            width: 40, height: 40,
                            decoration: BoxDecoration(
                              color: t.tint,
                              borderRadius: BorderRadius.circular(12),
                            ),
                            child: Icon(t.icon, size: 20, color: t.color),
                          ),
                          const SizedBox(width: 14),
                          Expanded(
                            child: Column(
                              crossAxisAlignment: CrossAxisAlignment.start,
                              children: [
                                Text(
                                  _tipTitle(l, t.id),
                                  style: GoogleFonts.inter(
                                    fontSize: 15,
                                    fontWeight: FontWeight.w600,
                                    color: fg1, height: 1.3,
                                  ),
                                ),
                                const SizedBox(height: 2),
                                Text(
                                  _tipBody(l, t.id),
                                  style: GoogleFonts.inter(
                                    fontSize: 13,
                                    fontWeight: FontWeight.w400,
                                    color: fg2, height: 1.4,
                                  ),
                                ),
                              ],
                            ),
                          ),
                        ],
                      ),
                    ),
                  )),

                ]),
              ),
            ),
          ],
        ),
      ),
    );
  }
}
