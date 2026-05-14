import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';
import '../theme/app_colors.dart';
import '../widgets/app_card.dart';
import '../widgets/screen_header.dart';

class TipsScreen extends StatefulWidget {
  final VoidCallback onOpenPaywall;
  const TipsScreen({super.key, required this.onOpenPaywall});

  @override
  State<TipsScreen> createState() => _TipsScreenState();
}

class _TipsScreenState extends State<TipsScreen> {
  String _cat = 'all';

  static const _tips = [
    (
      cat: 'diet', icon: Icons.eco_outlined, title: 'Half your plate, vegetables',
      copy: 'A simple visual rule that crowds out higher-calorie foods without counting.',
      color: Color(0xFF16A34A), tint: Color(0xFFE6F7EC),
    ),
    (
      cat: 'hydration', icon: Icons.water_drop_outlined, title: 'Water before coffee',
      copy: 'Drink 200 ml of water before your first coffee to reset overnight dehydration.',
      color: Color(0xFF3B82F6), tint: Color(0xFFEAF1FE),
    ),
    (
      cat: 'exercise', icon: Icons.directions_walk_rounded, title: 'A 10-min walk after meals',
      copy: 'Studies show short post-meal walks meaningfully lower blood-glucose spikes.',
      color: Color(0xFFF59E0B), tint: Color(0xFFFEF4E2),
    ),
    (
      cat: 'lifestyle', icon: Icons.bedtime_outlined, title: 'Sleep is the multiplier',
      copy: 'Under 7 hours raises hunger hormones the next day. Protect a wind-down ritual.',
      color: Color(0xFF8B5CF6), tint: Color(0xFFF0EBFE),
    ),
    (
      cat: 'diet', icon: Icons.lunch_dining_outlined, title: 'Protein first, every meal',
      copy: 'Eat the protein on your plate before carbs — satiety lasts longer.',
      color: Color(0xFF16A34A), tint: Color(0xFFE6F7EC),
    ),
    (
      cat: 'exercise', icon: Icons.fitness_center_outlined, title: 'Strength training twice a week',
      copy: 'Two sessions of resistance training weekly significantly improves metabolic health.',
      color: Color(0xFFF59E0B), tint: Color(0xFFFEF4E2),
    ),
    (
      cat: 'hydration', icon: Icons.local_drink_outlined, title: 'Hydrate with meals too',
      copy: 'Sipping water during meals helps digestion and reduces overeating.',
      color: Color(0xFF3B82F6), tint: Color(0xFFEAF1FE),
    ),
    (
      cat: 'lifestyle', icon: Icons.self_improvement_outlined, title: 'Stress fuels hunger',
      copy: 'Cortisol spikes increase appetite. Try 5 minutes of deep breathing before eating.',
      color: Color(0xFF8B5CF6), tint: Color(0xFFF0EBFE),
    ),
  ];

  static const _cats = [
    ('all', 'All'),
    ('diet', 'Diet'),
    ('exercise', 'Exercise'),
    ('hydration', 'Hydration'),
    ('lifestyle', 'Lifestyle'),
  ];

  @override
  Widget build(BuildContext context) {
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
                title: 'Daily tips',
                large: true,
                trailing: Icon(Icons.bookmark_border_rounded,
                    color: isDark ? AppColors.darkBrand500 : AppColors.brand500,
                    size: 22),
              ),
            ),

            // Category chips
            SliverToBoxAdapter(
              child: SizedBox(
                height: 44,
                child: ListView(
                  padding: const EdgeInsets.fromLTRB(20, 0, 20, 16),
                  scrollDirection: Axis.horizontal,
                  children: _cats.map((c) {
                    final active = c.$1 == _cat;
                    return GestureDetector(
                      onTap: () => setState(() => _cat = c.$1),
                      child: AnimatedContainer(
                        duration: const Duration(milliseconds: 150),
                        margin: const EdgeInsets.only(right: 8),
                        padding: const EdgeInsets.symmetric(
                            vertical: 9, horizontal: 14),
                        decoration: BoxDecoration(
                          color: active ? fg1 : surfaceBg,
                          borderRadius: BorderRadius.circular(999),
                          boxShadow: active
                              ? []
                              : [
                                  BoxShadow(
                                    color: const Color(0xFF0E1411)
                                        .withOpacity(0.04),
                                    blurRadius: 2,
                                    offset: const Offset(0, 1),
                                  )
                                ],
                        ),
                        child: Text(
                          c.$2,
                          style: GoogleFonts.inter(
                            fontSize: 13,
                            fontWeight: FontWeight.w600,
                            color: active ? Colors.white : fg1,
                            height: 1,
                          ),
                        ),
                      ),
                    );
                  }).toList(),
                ),
              ),
            ),

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
                                'Today · ${featured.cat}'.toUpperCase(),
                                style: GoogleFonts.inter(
                                  fontSize: 11,
                                  fontWeight: FontWeight.w600,
                                  letterSpacing: 0.08 * 11,
                                  color: featured.color,
                                ),
                              ),
                            ],
                          ),
                          const SizedBox(height: 16),
                          Text(
                            featured.title,
                            style: GoogleFonts.inter(
                              fontSize: 24,
                              fontWeight: FontWeight.w700,
                              letterSpacing: -0.02 * 24,
                              color: AppColors.fg1,
                              height: 1.25,
                            ),
                          ),
                          const SizedBox(height: 8),
                          Text(
                            featured.copy,
                            style: GoogleFonts.inter(
                              fontSize: 15,
                              fontWeight: FontWeight.w400,
                              color: AppColors.fg2,
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
                                  t.title,
                                  style: GoogleFonts.inter(
                                    fontSize: 15,
                                    fontWeight: FontWeight.w600,
                                    color: fg1, height: 1.3,
                                  ),
                                ),
                                const SizedBox(height: 2),
                                Text(
                                  t.copy,
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

                  // Premium nudge
                  AppCard(
                    padding: 18,
                    radius: 24,
                    tint: isDark ? AppColors.darkFg1 : AppColors.fg1,
                    onTap: widget.onOpenPaywall,
                    child: Row(
                      children: [
                        Container(
                          width: 36, height: 36,
                          decoration: BoxDecoration(
                            color: Colors.white.withOpacity(0.12),
                            borderRadius: BorderRadius.circular(10),
                          ),
                          child: const Icon(Icons.auto_awesome_rounded,
                              size: 18, color: Colors.white),
                        ),
                        const SizedBox(width: 12),
                        Expanded(
                          child: Column(
                            crossAxisAlignment: CrossAxisAlignment.start,
                            children: [
                              Text(
                                'Unlock 500+ premium tips',
                                style: GoogleFonts.inter(
                                  fontSize: 14,
                                  fontWeight: FontWeight.w600,
                                  color: Colors.white,
                                ),
                              ),
                              Text(
                                'Personalized to your BMI and goals',
                                style: GoogleFonts.inter(
                                  fontSize: 12,
                                  fontWeight: FontWeight.w400,
                                  color: Colors.white.withOpacity(0.7),
                                ),
                              ),
                            ],
                          ),
                        ),
                        Icon(Icons.chevron_right_rounded,
                            size: 18,
                            color: Colors.white.withOpacity(0.7)),
                      ],
                    ),
                  ),
                ]),
              ),
            ),
          ],
        ),
      ),
    );
  }
}
