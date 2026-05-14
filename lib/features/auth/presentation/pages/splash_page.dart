import 'dart:math' as math;
import 'package:flutter/material.dart';
import 'package:get_it/get_it.dart';
import 'package:go_router/go_router.dart';
import 'package:google_fonts/google_fonts.dart';
import '../../domain/entities/auth_user_status.dart';
import '../store/auth_store.dart';
import '../../../../features/services/presentation/store/service_store.dart';

class SplashPage extends StatefulWidget {
  const SplashPage({super.key});

  @override
  State<SplashPage> createState() => _SplashPageState();
}

class _SplashPageState extends State<SplashPage>
    with TickerProviderStateMixin {
  late final AnimationController _introCtrl;
  late final AnimationController _glowCtrl;
  late final AnimationController _runeCtrl;

  // Intro animations
  late final Animation<double> _bgFade;
  late final Animation<double> _logoScale;
  late final Animation<double> _logoFade;
  late final Animation<double> _tagFade;
  late final Animation<double> _spinnerFade;

  bool _navigated = false;

  @override
  void initState() {
    super.initState();

    _introCtrl = AnimationController(
      vsync: this,
      duration: const Duration(milliseconds: 1800),
    );

    _glowCtrl = AnimationController(
      vsync: this,
      duration: const Duration(milliseconds: 2400),
    )..repeat(reverse: true);

    _runeCtrl = AnimationController(
      vsync: this,
      duration: const Duration(milliseconds: 8000),
    )..repeat();

    _bgFade = CurvedAnimation(
      parent: _introCtrl,
      curve: const Interval(0.0, 0.3, curve: Curves.easeIn),
    );
    _logoScale = Tween<double>(begin: 0.72, end: 1.0).animate(
      CurvedAnimation(
        parent: _introCtrl,
        curve: const Interval(0.15, 0.65, curve: Curves.easeOutBack),
      ),
    );
    _logoFade = CurvedAnimation(
      parent: _introCtrl,
      curve: const Interval(0.15, 0.55, curve: Curves.easeOut),
    );
    _tagFade = CurvedAnimation(
      parent: _introCtrl,
      curve: const Interval(0.5, 0.85, curve: Curves.easeOut),
    );
    _spinnerFade = CurvedAnimation(
      parent: _introCtrl,
      curve: const Interval(0.7, 1.0, curve: Curves.easeOut),
    );

    _introCtrl.forward();
    _bootstrap();
  }

  Future<void> _bootstrap() async {
    final authStore = GetIt.I<AuthStore>();
    final serviceStore = GetIt.I<ServiceStore>();

    // Run auth + preload in parallel; wait at least 1.8s for animation
    await Future.wait([
      authStore.bootstrap(),
      Future<void>.delayed(const Duration(milliseconds: 1800)),
    ]);

    // Fire-and-forget preload (don't block navigation)
    if (authStore.isLoggedIn) {
      serviceStore.loadServices();
    }

    if (!mounted || _navigated) return;
    _navigated = true;

    if (!authStore.isLoggedIn) {
      context.go('/onboarding');
      return;
    }
    if (authStore.userStatus == AuthUserStatus.notRegistered) {
      context.go('/auth/create-profile');
      return;
    }
    context.go('/');
  }

  @override
  void dispose() {
    _introCtrl.dispose();
    _glowCtrl.dispose();
    _runeCtrl.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final isDark = Theme.of(context).brightness == Brightness.dark;
    final bgColor =
        isDark ? const Color(0xFF080604) : const Color(0xFFF5EDDB);
    final primaryGold =
        isDark ? const Color(0xFFC49A22) : const Color(0xFF7A4F0A);
    final glowColor = primaryGold.withValues(alpha: 0.18);
    final textColor =
        isDark ? const Color(0xFFE8D4A0) : const Color(0xFF1C1208);
    final mutedColor =
        isDark ? const Color(0xFF7A6A3A) : const Color(0xFF8B7355);

    return Scaffold(
      backgroundColor: bgColor,
      body: AnimatedBuilder(
        animation: Listenable.merge([_introCtrl, _glowCtrl, _runeCtrl]),
        builder: (context, _) {
          return Stack(
            fit: StackFit.expand,
            children: [
              // ── Background glow orb ─────────────────────────────────────
              FadeTransition(
                opacity: _bgFade,
                child: CustomPaint(
                  painter: _GlowOrbPainter(
                    progress: _glowCtrl.value,
                    primaryGold: primaryGold,
                    isDark: isDark,
                  ),
                ),
              ),

              // ── Rotating rune ring ──────────────────────────────────────
              FadeTransition(
                opacity: _bgFade,
                child: CustomPaint(
                  painter: _RuneRingPainter(
                    angle: _runeCtrl.value * 2 * math.pi,
                    gold: primaryGold,
                  ),
                ),
              ),

              // ── Main content ────────────────────────────────────────────
              Center(
                child: Column(
                  mainAxisSize: MainAxisSize.min,
                  children: [
                    // Logo
                    FadeTransition(
                      opacity: _logoFade,
                      child: ScaleTransition(
                        scale: _logoScale,
                        child: _buildLogo(
                          primaryGold: primaryGold,
                          glowColor: glowColor,
                          textColor: textColor,
                          isDark: isDark,
                        ),
                      ),
                    ),

                    const SizedBox(height: 16),

                    // Tagline
                    FadeTransition(
                      opacity: _tagFade,
                      child: Text(
                        'УСЛУГИ РЯДОМ',
                        style: GoogleFonts.cinzel(
                          color: mutedColor,
                          fontSize: 11,
                          letterSpacing: 5,
                          fontWeight: FontWeight.w400,
                        ),
                      ),
                    ),

                    const SizedBox(height: 56),

                    // Spinner
                    FadeTransition(
                      opacity: _spinnerFade,
                      child: SizedBox(
                        width: 22,
                        height: 22,
                        child: CircularProgressIndicator(
                          strokeWidth: 1.5,
                          color: primaryGold.withValues(alpha: 0.7),
                        ),
                      ),
                    ),
                  ],
                ),
              ),
            ],
          );
        },
      ),
    );
  }

  Widget _buildLogo({
    required Color primaryGold,
    required Color glowColor,
    required Color textColor,
    required bool isDark,
  }) {
    return Stack(
      alignment: Alignment.center,
      children: [
        // Glow behind text
        AnimatedBuilder(
          animation: _glowCtrl,
          builder: (_, __) {
            final glowRadius =
                60.0 + _glowCtrl.value * 20.0;
            return Container(
              width: glowRadius * 2,
              height: glowRadius * 2,
              decoration: BoxDecoration(
                shape: BoxShape.circle,
                gradient: RadialGradient(
                  colors: [
                    primaryGold.withValues(alpha: 0.12 + _glowCtrl.value * 0.07),
                    Colors.transparent,
                  ],
                ),
              ),
            );
          },
        ),
        // Ornamental lines
        CustomPaint(
          size: const Size(200, 80),
          painter: _OrnamentPainter(gold: primaryGold),
        ),
        // Title
        Text(
          'KORST',
          style: GoogleFonts.cinzel(
            color: primaryGold,
            fontSize: 48,
            fontWeight: FontWeight.w700,
            letterSpacing: 12,
            shadows: [
              Shadow(
                color: primaryGold.withValues(alpha: 0.45),
                blurRadius: 24,
              ),
              Shadow(
                color: primaryGold.withValues(alpha: 0.20),
                blurRadius: 48,
              ),
            ],
          ),
        ),
      ],
    );
  }
}

// ── Painters ──────────────────────────────────────────────────────────────────

class _GlowOrbPainter extends CustomPainter {
  final double progress;
  final Color primaryGold;
  final bool isDark;
  const _GlowOrbPainter({
    required this.progress,
    required this.primaryGold,
    required this.isDark,
  });

  @override
  void paint(Canvas canvas, Size size) {
    final cx = size.width / 2;
    final cy = size.height * 0.42;
    final radius = size.width * (0.45 + progress * 0.08);

    final paint = Paint()
      ..shader = RadialGradient(
        colors: [
          primaryGold.withValues(alpha: 0.10 + progress * 0.05),
          primaryGold.withValues(alpha: 0.03),
          Colors.transparent,
        ],
        stops: const [0.0, 0.45, 1.0],
      ).createShader(Rect.fromCircle(
        center: Offset(cx, cy),
        radius: radius,
      ));

    canvas.drawCircle(Offset(cx, cy), radius, paint);
  }

  @override
  bool shouldRepaint(_GlowOrbPainter old) => old.progress != progress;
}

class _RuneRingPainter extends CustomPainter {
  final double angle;
  final Color gold;
  const _RuneRingPainter({required this.angle, required this.gold});

  static const _runes = '᛫ᚱ᛫ᚢ᛫ᚾ᛫ᛖ᛫ᛊ᛫';

  @override
  void paint(Canvas canvas, Size size) {
    final cx = size.width / 2;
    final cy = size.height * 0.42;
    const ringRadius = 110.0;

    final textPainter = TextPainter(textDirection: TextDirection.ltr);
    final chars = _runes.characters.toList();
    final step = (2 * math.pi) / chars.length;

    for (int i = 0; i < chars.length; i++) {
      final a = angle + i * step;
      final x = cx + ringRadius * math.cos(a);
      final y = cy + ringRadius * math.sin(a);

      textPainter.text = TextSpan(
        text: chars[i],
        style: TextStyle(
          color: gold.withValues(alpha: 0.18),
          fontSize: 11,
          fontFamily: 'serif',
        ),
      );
      textPainter.layout();
      canvas.save();
      canvas.translate(x, y);
      canvas.rotate(a + math.pi / 2);
      textPainter.paint(
        canvas,
        Offset(-textPainter.width / 2, -textPainter.height / 2),
      );
      canvas.restore();
    }
  }

  @override
  bool shouldRepaint(_RuneRingPainter old) => old.angle != angle;
}

class _OrnamentPainter extends CustomPainter {
  final Color gold;
  const _OrnamentPainter({required this.gold});

  @override
  void paint(Canvas canvas, Size size) {
    final paint = Paint()
      ..color = gold.withValues(alpha: 0.35)
      ..strokeWidth = 0.8
      ..style = PaintingStyle.stroke;

    final cy = size.height / 2;
    const textWidth = 168.0; // approximate KORST width
    const gap = 12.0;
    const lineLen = 18.0;
    const dotR = 2.0;

    final leftEnd = (size.width - textWidth) / 2 - gap;
    final rightStart = (size.width + textWidth) / 2 + gap;

    // Left ornament
    canvas.drawLine(
      Offset(leftEnd - lineLen, cy),
      Offset(leftEnd, cy),
      paint,
    );
    canvas.drawCircle(
      Offset(leftEnd - lineLen - dotR, cy),
      dotR,
      paint..style = PaintingStyle.fill,
    );

    // Right ornament
    paint.style = PaintingStyle.stroke;
    canvas.drawLine(
      Offset(rightStart, cy),
      Offset(rightStart + lineLen, cy),
      paint,
    );
    paint.style = PaintingStyle.fill;
    canvas.drawCircle(
      Offset(rightStart + lineLen + dotR, cy),
      dotR,
      paint,
    );
  }

  @override
  bool shouldRepaint(_OrnamentPainter old) => false;
}
