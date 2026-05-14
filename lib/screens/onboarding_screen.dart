import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:provider/provider.dart';
import '../providers/app_provider.dart';
import '../theme/app_colors.dart';
import '../widgets/app_button.dart';

class OnboardingScreen extends StatefulWidget {
  const OnboardingScreen({super.key});

  @override
  State<OnboardingScreen> createState() => _OnboardingScreenState();
}

class _OnboardingScreenState extends State<OnboardingScreen> {
  int _index = 0;

  static const _steps = [
    (
      icon: Icons.calculate_outlined,
      title: 'Track your health easily',
      subtitle: 'Calculate your BMI in seconds, no account needed.',
    ),
    (
      icon: Icons.lightbulb_outline,
      title: 'Get smart recommendations',
      subtitle: 'Personalized advice based on your body and goals.',
    ),
    (
      icon: Icons.show_chart_rounded,
      title: 'Track progress over time',
      subtitle: 'See your weight journey visually, week by week.',
    ),
  ];

  void _next() {
    if (_index < _steps.length - 1) {
      setState(() => _index++);
    } else {
      context.read<AppProvider>().completeOnboarding();
    }
  }

  @override
  Widget build(BuildContext context) {
    final step = _steps[_index];
    final isLast = _index == _steps.length - 1;

    return Scaffold(
      backgroundColor: AppColors.bgCanvas,
      body: SafeArea(
        child: Column(
          children: [
            // Top bar with skip
            Padding(
              padding: const EdgeInsets.fromLTRB(20, 12, 20, 0),
              child: Align(
                alignment: Alignment.centerRight,
                child: !isLast
                    ? GestureDetector(
                        onTap: () => context.read<AppProvider>().completeOnboarding(),
                        child: Text(
                          'Skip',
                          style: GoogleFonts.inter(
                            fontSize: 15,
                            fontWeight: FontWeight.w600,
                            color: AppColors.brand500,
                          ),
                        ),
                      )
                    : const SizedBox(height: 20),
              ),
            ),

            // Art + text
            Expanded(
              child: AnimatedSwitcher(
                duration: const Duration(milliseconds: 280),
                transitionBuilder: (child, anim) => FadeTransition(
                  opacity: anim,
                  child: SlideTransition(
                    position: Tween(begin: const Offset(0.06, 0), end: Offset.zero)
                        .animate(anim),
                    child: child,
                  ),
                ),
                child: _StepContent(
                  key: ValueKey(_index),
                  icon: step.icon,
                  title: step.title,
                  subtitle: step.subtitle,
                ),
              ),
            ),

            // Dots
            Row(
              mainAxisAlignment: MainAxisAlignment.center,
              children: List.generate(_steps.length, (i) {
                final active = i == _index;
                return AnimatedContainer(
                  duration: const Duration(milliseconds: 240),
                  curve: const Cubic(0.22, 0.61, 0.36, 1),
                  width: active ? 22 : 8,
                  height: 8,
                  margin: const EdgeInsets.symmetric(horizontal: 4),
                  decoration: BoxDecoration(
                    color: active ? AppColors.brand500 : AppColors.borderSubtle,
                    borderRadius: BorderRadius.circular(999),
                  ),
                );
              }),
            ),

            const SizedBox(height: 28),

            // CTA
            Padding(
              padding: const EdgeInsets.fromLTRB(20, 0, 20, 48),
              child: AppButton(
                label: isLast ? 'Get started' : 'Continue',
                variant: AppButtonVariant.primary,
                size: AppButtonSize.lg,
                fullWidth: true,
                onPressed: _next,
              ),
            ),
          ],
        ),
      ),
    );
  }
}

class _StepContent extends StatelessWidget {
  final IconData icon;
  final String title;
  final String subtitle;

  const _StepContent({
    super.key,
    required this.icon,
    required this.title,
    required this.subtitle,
  });

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.fromLTRB(32, 24, 32, 40),
      child: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          Container(
            width: 200, height: 200,
            decoration: BoxDecoration(
              gradient: const LinearGradient(
                begin: Alignment.topLeft,
                end: Alignment.bottomRight,
                colors: [Color(0xFFE8F7EF), Color(0xFFC6EFDA)],
              ),
              shape: BoxShape.circle,
              boxShadow: [
                BoxShadow(
                  color: AppColors.brand500.withOpacity(0.12),
                  blurRadius: 48,
                  offset: const Offset(0, 24),
                ),
              ],
            ),
            child: Icon(icon, size: 80, color: AppColors.bmiNormalInk),
          ),
          const SizedBox(height: 40),
          Text(
            title,
            textAlign: TextAlign.center,
            style: GoogleFonts.inter(
              fontSize: 28,
              fontWeight: FontWeight.w700,
              letterSpacing: -0.02 * 28,
              color: AppColors.fg1,
              height: 1.2,
            ),
          ),
          const SizedBox(height: 12),
          Text(
            subtitle,
            textAlign: TextAlign.center,
            style: GoogleFonts.inter(
              fontSize: 17,
              fontWeight: FontWeight.w400,
              color: AppColors.fg2,
              height: 1.4,
            ),
          ),
        ],
      ),
    );
  }
}
