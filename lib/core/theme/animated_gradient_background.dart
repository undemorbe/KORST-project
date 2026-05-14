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
      duration: const Duration(seconds: 20),
    )..repeat(reverse: true);
  }

  @override
  void dispose() {
    _controller.dispose();
    super.dispose();
  }

  LinearGradient _buildGradient(double t, bool isDark) {
    final drift = math.sin(t * math.pi * 2) * 0.12;
    final colors = isDark
        ? const [
            Color(0xFF080604),
            Color(0xFF0F0C08),
            Color(0xFF14100A),
            Color(0xFF080604),
          ]
        : const [
            Color(0xFFF5EDDB),
            Color(0xFFEDE4CC),
            Color(0xFFE8DCC0),
            Color(0xFFF0E8D4),
          ];
    return LinearGradient(
      begin: Alignment(-1.0, -0.8 + drift),
      end: Alignment(1.0, 0.8 - drift),
      colors: colors,
      stops: [0.0, 0.35 + drift * 0.1, 0.70 + drift * 0.05, 1.0],
    );
  }

  @override
  Widget build(BuildContext context) {
    final isDark = Theme.of(context).brightness == Brightness.dark;
    return AnimatedBuilder(
      animation: _controller,
      builder: (context, _) => DecoratedBox(
        decoration: BoxDecoration(
          gradient: _buildGradient(_controller.value, isDark),
        ),
        child: widget.child,
      ),
    );
  }
}
