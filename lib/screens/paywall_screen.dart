import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';
import '../theme/app_colors.dart';
import '../widgets/app_button.dart';
import '../widgets/app_card.dart';

class PaywallScreen extends StatefulWidget {
  final VoidCallback onClose;
  const PaywallScreen({super.key, required this.onClose});

  @override
  State<PaywallScreen> createState() => _PaywallScreenState();
}

class _PaywallScreenState extends State<PaywallScreen> {
  String _plan = 'yearly';

  static const _plans = [
    (id: 'monthly',  label: 'Monthly',  price: '\$4.99',  sub: 'per month',              badge: ''),
    (id: 'yearly',   label: 'Yearly',   price: '\$29.99', sub: '\$2.50 / mo · save 50%', badge: 'BEST VALUE'),
    (id: 'lifetime', label: 'Lifetime', price: '\$79.99', sub: 'one-time',                badge: ''),
  ];

  static const _features = [
    (icon: Icons.block_outlined,             label: 'Remove ads'),
    (icon: Icons.show_chart_rounded,         label: 'Detailed history charts'),
    (icon: Icons.track_changes_rounded,      label: 'Unlimited goal tracking'),
    (icon: Icons.auto_awesome_rounded,       label: 'AI-personalized recommendations'),
    (icon: Icons.lightbulb_outline,          label: '500+ premium daily tips'),
    (icon: Icons.cloud_outlined,             label: 'Encrypted cloud backup'),
  ];

  @override
  Widget build(BuildContext context) {
    final isDark = Theme.of(context).brightness == Brightness.dark;
    final bgCanvas = isDark ? AppColors.darkBgCanvas : AppColors.bgCanvas;
    final fg1 = isDark ? AppColors.darkFg1 : AppColors.fg1;
    final fg2 = isDark ? AppColors.darkFg2 : AppColors.fg2;
    final fg3 = isDark ? AppColors.darkFg3 : AppColors.fg3;
    final brand = isDark ? AppColors.darkBrand500 : AppColors.brand500;
    final brandTint = isDark ? AppColors.darkBgTint : AppColors.brand100;
    final borderSubtle = isDark ? AppColors.darkBorderSubtle : AppColors.borderSubtle;

    return Scaffold(
      backgroundColor: bgCanvas,
      body: SafeArea(
        child: CustomScrollView(
          slivers: [
            SliverToBoxAdapter(
              child: Padding(
                padding: const EdgeInsets.fromLTRB(20, 6, 20, 0),
                child: Row(
                  children: [
                    GestureDetector(
                      onTap: widget.onClose,
                      child: Container(
                        width: 36, height: 36,
                        decoration: BoxDecoration(
                          color: isDark
                              ? AppColors.darkBgSurface
                              : AppColors.bgSunken,
                          borderRadius: BorderRadius.circular(10),
                        ),
                        child: Icon(Icons.close_rounded, size: 20, color: fg1),
                      ),
                    ),
                    const Spacer(),
                    GestureDetector(
                      onTap: widget.onClose,
                      child: Text(
                        'Restore',
                        style: GoogleFonts.inter(
                          fontSize: 15,
                          fontWeight: FontWeight.w500,
                          color: brand,
                        ),
                      ),
                    ),
                  ],
                ),
              ),
            ),

            SliverPadding(
              padding: const EdgeInsets.fromLTRB(20, 12, 20, 0),
              sliver: SliverToBoxAdapter(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Row(
                      children: [
                        Icon(Icons.auto_awesome_rounded, size: 14, color: brand),
                        const SizedBox(width: 6),
                        Text(
                          'PREMIUM',
                          style: GoogleFonts.inter(
                            fontSize: 11, fontWeight: FontWeight.w600,
                            letterSpacing: 0.12 * 11, color: brand,
                          ),
                        ),
                      ],
                    ),
                    const SizedBox(height: 6),
                    Text(
                      'Unlock your full health journey',
                      style: GoogleFonts.inter(
                        fontSize: 30, fontWeight: FontWeight.w700,
                        letterSpacing: -0.025 * 30, color: fg1, height: 1.15,
                      ),
                    ),
                    const SizedBox(height: 6),
                    Text(
                      'Everything in BMI Health, plus the long-term tools to turn one reading into a habit.',
                      style: GoogleFonts.inter(
                        fontSize: 15, fontWeight: FontWeight.w400,
                        color: fg2, height: 1.5,
                      ),
                    ),
                  ],
                ),
              ),
            ),

            // Feature list
            SliverPadding(
              padding: const EdgeInsets.fromLTRB(20, 20, 20, 0),
              sliver: SliverToBoxAdapter(
                child: AppCard(
                  padding: 18,
                  child: Column(
                    children: _features.map((f) => Padding(
                      padding: EdgeInsets.only(
                          bottom: f == _features.last ? 0 : 12),
                      child: Row(
                        children: [
                          Container(
                            width: 26, height: 26,
                            decoration: BoxDecoration(
                              color: brandTint,
                              borderRadius: BorderRadius.circular(8),
                            ),
                            child: Icon(f.icon, size: 14, color: brand),
                          ),
                          const SizedBox(width: 12),
                          Text(
                            f.label,
                            style: GoogleFonts.inter(
                              fontSize: 15, fontWeight: FontWeight.w500,
                              color: fg1,
                            ),
                          ),
                        ],
                      ),
                    )).toList(),
                  ),
                ),
              ),
            ),

            // Plans
            SliverPadding(
              padding: const EdgeInsets.fromLTRB(20, 20, 20, 0),
              sliver: SliverList(
                delegate: SliverChildBuilderDelegate(
                  (_, i) {
                    final p = _plans[i];
                    final on = p.id == _plan;
                    return Padding(
                      padding: const EdgeInsets.only(bottom: 10),
                      child: GestureDetector(
                        onTap: () => setState(() => _plan = p.id),
                        child: AnimatedContainer(
                          duration: const Duration(milliseconds: 150),
                          padding: const EdgeInsets.all(18),
                          decoration: BoxDecoration(
                            color: on ? brandTint
                                : (isDark
                                    ? AppColors.darkBgSurface
                                    : AppColors.bgSurface),
                            borderRadius: BorderRadius.circular(20),
                            border: Border.all(
                              color: on ? brand : Colors.transparent,
                              width: 2,
                            ),
                            boxShadow: on
                                ? []
                                : [
                                    BoxShadow(
                                      color: const Color(0xFF0E1411)
                                          .withOpacity(0.04),
                                      blurRadius: 3,
                                      offset: const Offset(0, 1),
                                    )
                                  ],
                          ),
                          child: Row(
                            children: [
                              // Radio circle
                              AnimatedContainer(
                                duration: const Duration(milliseconds: 150),
                                width: 22, height: 22,
                                decoration: BoxDecoration(
                                  shape: BoxShape.circle,
                                  color: on ? brand : Colors.transparent,
                                  border: Border.all(
                                    color: on ? brand : borderSubtle,
                                    width: 2,
                                  ),
                                ),
                                child: on
                                    ? const Icon(Icons.check_rounded,
                                        size: 12, color: Colors.white)
                                    : null,
                              ),
                              const SizedBox(width: 14),
                              Expanded(
                                child: Column(
                                  crossAxisAlignment: CrossAxisAlignment.start,
                                  children: [
                                    Row(
                                      children: [
                                        Text(
                                          p.label,
                                          style: GoogleFonts.inter(
                                            fontSize: 16,
                                            fontWeight: FontWeight.w600,
                                            color: fg1,
                                          ),
                                        ),
                                        if (p.badge.isNotEmpty) ...[
                                          const SizedBox(width: 8),
                                          Container(
                                            padding: const EdgeInsets.symmetric(
                                                vertical: 4, horizontal: 8),
                                            decoration: BoxDecoration(
                                              color: brand,
                                              borderRadius:
                                                  BorderRadius.circular(999),
                                            ),
                                            child: Text(
                                              p.badge,
                                              style: GoogleFonts.inter(
                                                fontSize: 10,
                                                fontWeight: FontWeight.w700,
                                                letterSpacing: 0.6,
                                                color: Colors.white,
                                              ),
                                            ),
                                          ),
                                        ],
                                      ],
                                    ),
                                    const SizedBox(height: 2),
                                    Text(
                                      p.sub,
                                      style: GoogleFonts.inter(
                                        fontSize: 13,
                                        fontWeight: FontWeight.w500,
                                        color: fg3,
                                      ),
                                    ),
                                  ],
                                ),
                              ),
                              Text(
                                p.price,
                                style: GoogleFonts.inter(
                                  fontSize: 19,
                                  fontWeight: FontWeight.w700,
                                  color: fg1,
                                  letterSpacing: -0.02 * 19,
                                  fontFeatures: const [
                                    FontFeature.tabularFigures()
                                  ],
                                ),
                              ),
                            ],
                          ),
                        ),
                      ),
                    );
                  },
                  childCount: _plans.length,
                ),
              ),
            ),

            SliverToBoxAdapter(
              child: Padding(
                padding: const EdgeInsets.fromLTRB(20, 8, 20, 8),
                child: AppButton(
                  label: 'Upgrade now',
                  variant: AppButtonVariant.primary,
                  size: AppButtonSize.lg,
                  icon: Icons.auto_awesome_rounded,
                  fullWidth: true,
                  onPressed: widget.onClose,
                ),
              ),
            ),

            SliverToBoxAdapter(
              child: Padding(
                padding: const EdgeInsets.fromLTRB(20, 0, 20, 36),
                child: Text(
                  'Auto-renews. Cancel anytime. No ads, no tracking.',
                  textAlign: TextAlign.center,
                  style: GoogleFonts.inter(
                    fontSize: 12, fontWeight: FontWeight.w500, color: fg3,
                    height: 1.4,
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
