import 'dart:async';
import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:korst/l10n/generated/app_localizations.dart';
import '../../../../core/theme/app_colors.dart';

class OnboardingPage extends StatefulWidget {
  const OnboardingPage({super.key});

  @override
  State<OnboardingPage> createState() => _OnboardingPageState();
}

class _OnboardingPageState extends State<OnboardingPage> {
  final PageController _pageController = PageController();
  int _currentPage = 0;
  Timer? _timer;

  static const int _slideCount = 5;
  static const Duration _autoAdvance = Duration(seconds: 10);

  @override
  void initState() {
    super.initState();
    _startTimer();
  }

  void _startTimer() {
    _timer?.cancel();
    _timer = Timer.periodic(_autoAdvance, (_) {
      if (!mounted) return;
      final next = (_currentPage + 1) % _slideCount;
      _pageController.animateToPage(
        next,
        duration: const Duration(milliseconds: 500),
        curve: Curves.easeInOut,
      );
    });
  }

  void _onPageChanged(int index) {
    setState(() => _currentPage = index);
    _startTimer(); // reset timer on manual swipe
  }

  @override
  void dispose() {
    _timer?.cancel();
    _pageController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final l10n = AppLocalizations.of(context)!;
    final cs = Theme.of(context).colorScheme;

    final slides = _buildSlides(l10n);

    return Scaffold(
      body: SafeArea(
        child: Column(
          children: [
            // ── Slider ──────────────────────────────────────────────────────
            Expanded(
              child: PageView.builder(
                controller: _pageController,
                onPageChanged: _onPageChanged,
                itemCount: _slideCount,
                itemBuilder: (context, index) =>
                    _SlidePage(slide: slides[index]),
              ),
            ),

            // ── Dot indicators ──────────────────────────────────────────────
            Padding(
              padding: const EdgeInsets.only(bottom: 20),
              child: Row(
                mainAxisAlignment: MainAxisAlignment.center,
                children: List.generate(_slideCount, (i) {
                  final active = i == _currentPage;
                  return AnimatedContainer(
                    duration: const Duration(milliseconds: 300),
                    curve: Curves.easeInOut,
                    margin: const EdgeInsets.symmetric(horizontal: 4),
                    width: active ? 22 : 7,
                    height: 7,
                    decoration: BoxDecoration(
                      color: active
                          ? cs.primary
                          : cs.primary.withValues(alpha: 0.28),
                      borderRadius: BorderRadius.circular(4),
                    ),
                  );
                }),
              ),
            ),

            // ── Start button ─────────────────────────────────────────────────
            Padding(
              padding: const EdgeInsets.fromLTRB(24, 0, 24, 32),
              child: SizedBox(
                width: double.infinity,
                child: FilledButton.icon(
                  onPressed: () => context.push('/auth/phone'),
                  style: FilledButton.styleFrom(
                    padding: const EdgeInsets.symmetric(vertical: 16),
                    shape: RoundedRectangleBorder(
                      borderRadius: BorderRadius.circular(8),
                    ),
                  ),
                  icon: const Icon(Icons.arrow_forward),
                  label: Text(
                    l10n.start,
                    style: const TextStyle(
                      fontSize: 18,
                      fontWeight: FontWeight.bold,
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

  List<_SlideData> _buildSlides(AppLocalizations l10n) => [
        _SlideData(
          icon: Icons.explore_rounded,
          accentIcon: Icons.location_on_rounded,
          title: l10n.onboardSlide1Title,
          subtitle: l10n.onboardSlide1Subtitle,
        ),
        _SlideData(
          icon: Icons.post_add_rounded,
          accentIcon: Icons.layers_rounded,
          title: l10n.onboardSlide2Title,
          subtitle: l10n.onboardSlide2Subtitle,
        ),
        _SlideData(
          icon: Icons.send_rounded,
          accentIcon: Icons.chat_bubble_rounded,
          title: l10n.onboardSlide3Title,
          subtitle: l10n.onboardSlide3Subtitle,
        ),
        _SlideData(
          icon: Icons.verified_rounded,
          accentIcon: Icons.star_rounded,
          title: l10n.onboardSlide4Title,
          subtitle: l10n.onboardSlide4Subtitle,
        ),
        _SlideData(
          icon: Icons.notifications_active_rounded,
          accentIcon: Icons.bolt_rounded,
          title: l10n.onboardSlide5Title,
          subtitle: l10n.onboardSlide5Subtitle,
        ),
      ];
}

// ── Slide data model ──────────────────────────────────────────────────────────
class _SlideData {
  final IconData icon;
  final IconData accentIcon;
  final String title;
  final String subtitle;

  const _SlideData({
    required this.icon,
    required this.accentIcon,
    required this.title,
    required this.subtitle,
  });
}

// ── Single slide widget ───────────────────────────────────────────────────────
class _SlidePage extends StatelessWidget {
  final _SlideData slide;

  const _SlidePage({required this.slide});

  @override
  Widget build(BuildContext context) {
    final cs = Theme.of(context).colorScheme;

    return Padding(
      padding: const EdgeInsets.symmetric(horizontal: 24),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          const Spacer(flex: 2),

          // ── Illustration card ─────────────────────────────────────────────
          Container(
            width: double.infinity,
            height: 220,
            decoration: BoxDecoration(
              color: cs.surface.withValues(alpha: 0.88),
              borderRadius: BorderRadius.circular(12),
              border: Border.all(color: cs.outlineVariant),
              boxShadow: [
                BoxShadow(
                  color: cs.primary.withValues(alpha: 0.08),
                  blurRadius: 20,
                  spreadRadius: 2,
                ),
              ],
            ),
            child: Stack(
              children: [
                Positioned(
                  left: 24,
                  top: 24,
                  child: Icon(
                    slide.icon,
                    size: 76,
                    color: cs.primary,
                  ),
                ),
                Positioned(
                  right: 18,
                  bottom: 18,
                  child: Icon(
                    slide.accentIcon,
                    size: 120,
                    color: cs.primary.withValues(alpha: 0.12),
                  ),
                ),
                // Gold accent dot
                Positioned(
                  right: 28,
                  top: 28,
                  child: Container(
                    width: 10,
                    height: 10,
                    decoration: BoxDecoration(
                      color: AppColors.primary.withValues(alpha: 0.7),
                      shape: BoxShape.circle,
                    ),
                  ),
                ),
              ],
            ),
          ),

          const SizedBox(height: 32),

          // ── Title ─────────────────────────────────────────────────────────
          Text(
            slide.title,
            style: GoogleFonts.cinzel(
              fontSize: 24,
              fontWeight: FontWeight.w800,
              color: cs.onSurface,
              height: 1.15,
              letterSpacing: 0.04,
            ),
          ),

          const SizedBox(height: 14),

          // ── Subtitle ──────────────────────────────────────────────────────
          Text(
            slide.subtitle,
            style: Theme.of(context).textTheme.bodyLarge?.copyWith(
              color: cs.onSurfaceVariant,
              height: 1.45,
            ),
          ),

          const Spacer(flex: 3),
        ],
      ),
    );
  }
}
