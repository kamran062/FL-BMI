import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';
import '../services/purchase_service.dart';
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
  final _svc = PurchaseService.instance;
  String _selectedId = kProductYearly;

  // Fallback display data while products load from store
  static const _planMeta = {
    kProductMonthly:  (label: 'Monthly',  sub: 'per month',              badge: '',           fallbackPrice: '\$4.99'),
    kProductYearly:   (label: 'Yearly',   sub: '\$2.50 / mo · save 50%', badge: 'BEST VALUE', fallbackPrice: '\$29.99'),
    kProductLifetime: (label: 'Lifetime', sub: 'one-time payment',       badge: '',           fallbackPrice: '\$79.99'),
  };

  static const _orderedIds = [kProductMonthly, kProductYearly, kProductLifetime];

  static const _features = [
    (icon: Icons.block_outlined,          label: 'Remove all ads'),
    (icon: Icons.show_chart_rounded,      label: 'Detailed history charts'),
    (icon: Icons.track_changes_rounded,   label: 'Unlimited goal tracking'),
    (icon: Icons.auto_awesome_rounded,    label: 'AI-personalized recommendations'),
    (icon: Icons.lightbulb_outline,       label: '500+ premium daily tips'),
    (icon: Icons.cloud_outlined,          label: 'Encrypted cloud backup'),
  ];

  @override
  void initState() {
    super.initState();
    _svc.addListener(_onServiceChange);
  }

  @override
  void dispose() {
    _svc.removeListener(_onServiceChange);
    super.dispose();
  }

  void _onServiceChange() {
    if (!mounted) return;
    setState(() {});
    // Close paywall automatically on successful purchase
    if (_svc.isPremium) {
      Future.delayed(const Duration(milliseconds: 600), () {
        if (mounted) widget.onClose();
      });
    }
  }

  String _priceFor(String id) {
    final storeProduct = _svc.products.where((p) => p.id == id).firstOrNull;
    return storeProduct?.price ?? _planMeta[id]!.fallbackPrice;
  }

  Future<void> _purchase() async {
    if (!_svc.available) {
      _showSnack('Store not available on this device.');
      return;
    }
    await _svc.buy(_selectedId);
  }

  Future<void> _restore() async {
    if (!_svc.available) {
      _showSnack('Store not available on this device.');
      return;
    }
    await _svc.restore();
    if (_svc.error != null && mounted) _showSnack(_svc.error!);
  }

  void _showSnack(String msg) {
    ScaffoldMessenger.of(context).showSnackBar(SnackBar(
      content: Text(msg, style: GoogleFonts.inter(fontSize: 14)),
      behavior: SnackBarBehavior.floating,
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
    ));
  }

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

    final loading = _svc.loading;

    return Scaffold(
      backgroundColor: bgCanvas,
      body: Stack(
        children: [
          SafeArea(
            child: CustomScrollView(
              slivers: [
                // Header
                SliverToBoxAdapter(
                  child: Padding(
                    padding: const EdgeInsets.fromLTRB(20, 6, 20, 0),
                    child: Row(
                      children: [
                        GestureDetector(
                          onTap: loading ? null : widget.onClose,
                          child: Container(
                            width: 36, height: 36,
                            decoration: BoxDecoration(
                              color: isDark
                                  ? AppColors.darkBgSurface
                                  : AppColors.bgSunken,
                              borderRadius: BorderRadius.circular(10),
                            ),
                            child: Icon(Icons.close_rounded,
                                size: 20, color: fg1),
                          ),
                        ),
                        const Spacer(),
                        GestureDetector(
                          onTap: loading ? null : _restore,
                          child: Text(
                            'Restore',
                            style: GoogleFonts.inter(
                              fontSize: 15,
                              fontWeight: FontWeight.w500,
                              color: loading ? fg3 : brand,
                            ),
                          ),
                        ),
                      ],
                    ),
                  ),
                ),

                // Hero copy
                SliverPadding(
                  padding: const EdgeInsets.fromLTRB(20, 14, 20, 0),
                  sliver: SliverToBoxAdapter(
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Row(
                          children: [
                            Icon(Icons.auto_awesome_rounded,
                                size: 14, color: brand),
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
                          _svc.isPremium
                              ? 'Welcome to Premium!'
                              : 'Unlock your full health journey',
                          style: GoogleFonts.inter(
                            fontSize: 28, fontWeight: FontWeight.w700,
                            letterSpacing: -0.025 * 28,
                            color: fg1, height: 1.15,
                          ),
                        ),
                        const SizedBox(height: 6),
                        Text(
                          _svc.isPremium
                              ? 'Ads removed. All features unlocked. Enjoy BMI Health Premium.'
                              : 'Everything in BMI Health, plus the long-term tools to turn one reading into a habit.',
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
                                width: 28, height: 28,
                                decoration: BoxDecoration(
                                  color: _svc.isPremium
                                      ? AppColors.bmiNormalTint
                                      : brandTint,
                                  borderRadius: BorderRadius.circular(8),
                                ),
                                child: Icon(
                                  _svc.isPremium
                                      ? Icons.check_rounded
                                      : f.icon,
                                  size: 15,
                                  color: _svc.isPremium
                                      ? AppColors.bmiNormalInk
                                      : brand,
                                ),
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

                // Plans (hidden once premium)
                if (!_svc.isPremium)
                  SliverPadding(
                    padding: const EdgeInsets.fromLTRB(20, 20, 20, 0),
                    sliver: SliverList(
                      delegate: SliverChildBuilderDelegate(
                        (_, i) {
                          final id = _orderedIds[i];
                          final meta = _planMeta[id]!;
                          final on = id == _selectedId;
                          return Padding(
                            padding: const EdgeInsets.only(bottom: 10),
                            child: GestureDetector(
                              onTap: loading
                                  ? null
                                  : () => setState(() => _selectedId = id),
                              child: AnimatedContainer(
                                duration: const Duration(milliseconds: 150),
                                padding: const EdgeInsets.all(16),
                                decoration: BoxDecoration(
                                  color: on
                                      ? brandTint
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
                                            color: Colors.black.withAlpha(10),
                                            blurRadius: 3,
                                            offset: const Offset(0, 1),
                                          )
                                        ],
                                ),
                                child: Row(
                                  children: [
                                    // Radio
                                    AnimatedContainer(
                                      duration:
                                          const Duration(milliseconds: 150),
                                      width: 22, height: 22,
                                      decoration: BoxDecoration(
                                        shape: BoxShape.circle,
                                        color: on
                                            ? brand
                                            : Colors.transparent,
                                        border: Border.all(
                                          color: on ? brand : borderSubtle,
                                          width: 2,
                                        ),
                                      ),
                                      child: on
                                          ? const Icon(Icons.check_rounded,
                                              size: 12,
                                              color: Colors.white)
                                          : null,
                                    ),
                                    const SizedBox(width: 14),
                                    Expanded(
                                      child: Column(
                                        crossAxisAlignment:
                                            CrossAxisAlignment.start,
                                        children: [
                                          Row(
                                            children: [
                                              Text(
                                                meta.label,
                                                style: GoogleFonts.inter(
                                                  fontSize: 16,
                                                  fontWeight: FontWeight.w600,
                                                  color: fg1,
                                                ),
                                              ),
                                              if (meta.badge.isNotEmpty) ...[
                                                const SizedBox(width: 8),
                                                Container(
                                                  padding: const EdgeInsets
                                                      .symmetric(
                                                      vertical: 3,
                                                      horizontal: 8),
                                                  decoration: BoxDecoration(
                                                    color: brand,
                                                    borderRadius:
                                                        BorderRadius.circular(
                                                            999),
                                                  ),
                                                  child: Text(
                                                    meta.badge,
                                                    style: GoogleFonts.inter(
                                                      fontSize: 10,
                                                      fontWeight:
                                                          FontWeight.w700,
                                                      letterSpacing: 0.5,
                                                      color: Colors.white,
                                                    ),
                                                  ),
                                                ),
                                              ],
                                            ],
                                          ),
                                          const SizedBox(height: 2),
                                          Text(
                                            meta.sub,
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
                                      _priceFor(id),
                                      style: GoogleFonts.inter(
                                        fontSize: 19,
                                        fontWeight: FontWeight.w700,
                                        color: fg1,
                                        letterSpacing: -0.02 * 19,
                                        fontFeatures: const [
                                          FontFeature.tabularFigures(),
                                        ],
                                      ),
                                    ),
                                  ],
                                ),
                              ),
                            ),
                          );
                        },
                        childCount: _orderedIds.length,
                      ),
                    ),
                  ),

                // CTA button
                SliverToBoxAdapter(
                  child: Padding(
                    padding: const EdgeInsets.fromLTRB(20, 8, 20, 0),
                    child: _svc.isPremium
                        ? AppButton(
                            label: 'You\'re all set!',
                            variant: AppButtonVariant.secondary,
                            size: AppButtonSize.lg,
                            icon: Icons.check_circle_outline_rounded,
                            fullWidth: true,
                            onPressed: widget.onClose,
                          )
                        : AppButton(
                            label: loading ? 'Processing…' : 'Upgrade now',
                            variant: AppButtonVariant.primary,
                            size: AppButtonSize.lg,
                            icon: loading
                                ? Icons.hourglass_top_rounded
                                : Icons.auto_awesome_rounded,
                            fullWidth: true,
                            disabled: loading,
                            onPressed: loading ? null : _purchase,
                          ),
                  ),
                ),

                // Error message
                if (_svc.error != null)
                  SliverToBoxAdapter(
                    child: Padding(
                      padding:
                          const EdgeInsets.fromLTRB(20, 10, 20, 0),
                      child: Text(
                        _svc.error!,
                        textAlign: TextAlign.center,
                        style: GoogleFonts.inter(
                          fontSize: 13,
                          color: AppColors.bmiObese,
                          fontWeight: FontWeight.w500,
                        ),
                      ),
                    ),
                  ),

                SliverToBoxAdapter(
                  child: Padding(
                    padding: const EdgeInsets.fromLTRB(20, 12, 20, 40),
                    child: Text(
                      _svc.isPremium
                          ? 'Thank you for supporting BMI Health.'
                          : 'Auto-renews. Cancel anytime in your account settings.\nNo tracking. No data sold.',
                      textAlign: TextAlign.center,
                      style: GoogleFonts.inter(
                        fontSize: 12,
                        fontWeight: FontWeight.w400,
                        color: fg3, height: 1.5,
                      ),
                    ),
                  ),
                ),
              ],
            ),
          ),

          // Full-screen loading overlay
          if (loading)
            Container(
              color: Colors.black.withAlpha(80),
              child: const Center(
                child: CircularProgressIndicator(
                  color: AppColors.brand500,
                ),
              ),
            ),
        ],
      ),
    );
  }
}
