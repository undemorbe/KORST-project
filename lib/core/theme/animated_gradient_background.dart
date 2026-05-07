import 'dart:math' as math;
import 'package:flutter/material.dart';

class AnimatedGradientBackground extends StatefulWidget {
  final Widget child;

  const AnimatedGradientBackground({super.key, required this.child});

  @override
  State<AnimatedGradientBackground> createState() =>
      _AnimatedGradientBackgroundState();
}

class _AnimatedGradientBackgroundState extends State<AnimatedGradientBackground>
    with SingleTickerProviderStateMixin {
  late final AnimationController _controller;

  @override
  void initState() {
    super.initState();
    _controller = AnimationController(
      vsync: this,
      duration: const Duration(seconds: 12),
    )..repeat(reverse: true);
  }

  @override
  void dispose() {
    _controller.dispose();
    super.dispose();
  }

  LinearGradient _buildLightGradient(double t) {
    final drift = math.sin(t * math.pi * 2) * 0.18;
    return LinearGradient(
      begin: Alignment(-1.0 + drift, -1.0),
      end: Alignment(1.0 - drift, 1.0),
      colors: const [
        Color(0xFFF6F7F4),
        Color(0xFFEAF4EF),
        Color(0xFFDCEBE6),
        Color(0xFFF9EFE6),
      ],
      stops: [0.0, 0.35 + drift * 0.2, 0.72 + drift * 0.08, 1.0],
    );
  }

  LinearGradient _buildDarkGradient(double t) {
    final drift = math.cos(t * math.pi * 2) * 0.15;
    return LinearGradient(
      begin: Alignment(-1.0, -0.9 + drift),
      end: Alignment(1.0, 0.9 - drift),
      colors: const [
        Color(0xFF0B0F0D),
        Color(0xFF101412),
        Color(0xFF18231F),
        Color(0xFF0B0F0D),
      ],
      stops: [0.0, 0.4 + drift * 0.1, 0.7 + drift * 0.05, 1.0],
    );
  }

  @override
  Widget build(BuildContext context) {
    final isDark = Theme.of(context).brightness == Brightness.dark;
    return AnimatedBuilder(
      animation: _controller,
      builder: (context, _) {
        final gradient = isDark
            ? _buildDarkGradient(_controller.value)
            : _buildLightGradient(_controller.value);
        return DecoratedBox(
          decoration: BoxDecoration(gradient: gradient),
          child: widget.child,
        );
      },
    );
  }
}
