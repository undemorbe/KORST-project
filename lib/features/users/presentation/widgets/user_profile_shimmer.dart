import 'package:korst/core/widgets/glass.dart';
import 'package:flutter/material.dart';

class UserProfileShimmer extends StatelessWidget {
  const UserProfileShimmer({super.key});

  @override
  Widget build(BuildContext context) {
    return ListView(
      shrinkWrap: true,
      physics: const NeverScrollableScrollPhysics(),
      padding: const EdgeInsets.all(16),
      children: const [
        _ShimmerCard(height: 150),
        SizedBox(height: 12),
        _ShimmerCard(height: 140),
        SizedBox(height: 12),
        _ShimmerCard(height: 160),
        SizedBox(height: 12),
        _ShimmerCard(height: 230),
      ],
    );
  }
}

class _ShimmerCard extends StatelessWidget {
  final double height;

  const _ShimmerCard({required this.height});

  @override
  Widget build(BuildContext context) {
    final radius = BorderRadius.circular(14);
    final surface = Theme.of(
      context,
    ).colorScheme.surface.withValues(alpha: 0.62);
    return GlassCard(
      elevation: 0,
      color: surface,
      shape: RoundedRectangleBorder(borderRadius: radius),
      child: ClipRRect(
        borderRadius: radius,
        child: SizedBox(
          height: height,
          child: const Padding(
            padding: EdgeInsets.all(14),
            child: Column(
              children: [
                _ShimmerLine(widthFactor: 0.88, height: 20),
                SizedBox(height: 10),
                _ShimmerLine(widthFactor: 0.64, height: 16),
                SizedBox(height: 10),
                _ShimmerLine(widthFactor: 0.74, height: 16),
              ],
            ),
          ),
        ),
      ),
    );
  }
}

class _ShimmerLine extends StatefulWidget {
  final double widthFactor;
  final double height;

  const _ShimmerLine({required this.widthFactor, required this.height});

  @override
  State<_ShimmerLine> createState() => _ShimmerLineState();
}

class _ShimmerLineState extends State<_ShimmerLine>
    with SingleTickerProviderStateMixin {
  late final AnimationController _controller;

  @override
  void initState() {
    super.initState();
    _controller = AnimationController(
      vsync: this,
      duration: const Duration(milliseconds: 1200),
    )..repeat();
  }

  @override
  void dispose() {
    _controller.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final isDark = Theme.of(context).brightness == Brightness.dark;
    final base = isDark ? const Color(0xFF1F2430) : const Color(0xFFE8EBF2);
    final shine = isDark ? const Color(0xFF3A4357) : const Color(0xFFFFFFFF);

    return LayoutBuilder(
      builder: (context, constraints) {
        final width = constraints.maxWidth * widget.widthFactor;
        return Align(
          alignment: Alignment.centerLeft,
          child: SizedBox(
            width: width,
            height: widget.height,
            child: ClipRRect(
              borderRadius: BorderRadius.circular(10),
              child: Stack(
                fit: StackFit.expand,
                children: [
                  ColoredBox(color: base),
                  AnimatedBuilder(
                    animation: _controller,
                    builder: (context, child) {
                      return FractionalTranslation(
                        translation: Offset(-1.5 + (_controller.value * 3), 0),
                        child: child,
                      );
                    },
                    child: Container(
                      width: width * 0.5,
                      decoration: BoxDecoration(
                        gradient: LinearGradient(
                          colors: [
                            shine.withValues(alpha: 0),
                            shine.withValues(alpha: 0.55),
                            shine.withValues(alpha: 0.95),
                            shine.withValues(alpha: 0.55),
                            shine.withValues(alpha: 0),
                          ],
                        ),
                      ),
                    ),
                  ),
                ],
              ),
            ),
          ),
        );
      },
    );
  }
}
