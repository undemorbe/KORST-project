import 'dart:math' as math;
import 'package:flutter/material.dart';

class AnimatedGradientBackground extends StatefulWidget {
  final Widget child;

  const AnimatedGradientBackground({
    super.key,
    required this.child,
  });

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
        Color(0xFFFFFFFF),
        Color(0xFFF3F3F3),
        Color(0xFFDADDE3),
        Color(0xFFB3B9C5),
      ],
      stops: [
        0.0,
        0.35 + drift * 0.2,
        0.72 + drift * 0.08,
        1.0,
      ],
    );
  }

  LinearGradient _buildDarkGradient(double t) {
    final drift = math.cos(t * math.pi * 2) * 0.18;
    return LinearGradient(
      begin: Alignment(-1.0, -0.9 + drift),
      end: Alignment(1.0, 0.9 - drift),
      colors: const [
        Color(0xFF2A2E35),
        Color(0xFF1E222A),
        Color(0xFF12161E),
        Color(0xFF06080C),
      ],
      stops: [
        0.0,
        0.36 + drift * 0.16,
        0.74 + drift * 0.06,
        1.0,
      ],
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
