import 'package:flutter/material.dart';

class ServiceCardShimmerList extends StatelessWidget {
  final int itemCount;
  final EdgeInsetsGeometry padding;

  const ServiceCardShimmerList({
    super.key,
    required this.itemCount,
    this.padding = const EdgeInsets.symmetric(vertical: 8),
  });

  @override
  Widget build(BuildContext context) {
    return ListView.separated(
      physics: const NeverScrollableScrollPhysics(),
      padding: padding,
      itemCount: itemCount,
      separatorBuilder: (context, index) => const SizedBox(height: 8),
      itemBuilder: (context, index) => const ServiceCardShimmer(),
    );
  }
}

class ServiceCardShimmer extends StatelessWidget {
  const ServiceCardShimmer({super.key});

  @override
  Widget build(BuildContext context) {
    final surface = Theme.of(context).colorScheme.surface.withValues(alpha: 0.55);
    final radius = BorderRadius.circular(12);
    return Card(
      margin: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
      elevation: 0,
      shape: RoundedRectangleBorder(borderRadius: radius),
      color: surface,
      child: ClipRRect(
        borderRadius: radius,
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            const _ShimmerBlock(height: 150, width: double.infinity),
            Padding(
              padding: const EdgeInsets.all(16),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: const [
                  _ShimmerBlock(height: 22, width: 210),
                  SizedBox(height: 12),
                  _ShimmerBlock(height: 16, width: 130),
                ],
              ),
            ),
          ],
        ),
      ),
    );
  }
}

class _ShimmerBlock extends StatefulWidget {
  final double height;
  final double width;

  const _ShimmerBlock({
    required this.height,
    required this.width,
  });

  @override
  State<_ShimmerBlock> createState() => _ShimmerBlockState();
}

class _ShimmerBlockState extends State<_ShimmerBlock>
    with SingleTickerProviderStateMixin {
  late final AnimationController _controller;

  @override
  void initState() {
    super.initState();
    _controller = AnimationController(
      vsync: this,
      duration: const Duration(milliseconds: 1300),
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
    final base = isDark ? const Color(0xFF1D2128) : const Color(0xFFE6E9EF);
    final glowA = isDark ? const Color(0xFF303745) : const Color(0xFFF5F7FC);
    final glowB = isDark ? const Color(0xFF3B4456) : const Color(0xFFFFFFFF);

    return ClipRRect(
      borderRadius: const BorderRadius.all(Radius.circular(10)),
      child: SizedBox(
        height: widget.height,
        width: widget.width,
        child: Stack(
          fit: StackFit.expand,
          children: [
            ColoredBox(color: base),
            AnimatedBuilder(
              animation: _controller,
              builder: (context, child) {
                return FractionalTranslation(
                  translation: Offset(-1.4 + (_controller.value * 2.8), 0),
                  child: child,
                );
              },
              child: Container(
                width: widget.width * 0.55,
                decoration: BoxDecoration(
                  gradient: LinearGradient(
                    colors: [
                      glowA.withValues(alpha: 0),
                      glowA.withValues(alpha: 0.6),
                      glowB.withValues(alpha: 0.95),
                      glowA.withValues(alpha: 0.6),
                      glowA.withValues(alpha: 0),
                    ],
                    stops: const [0, 0.3, 0.5, 0.7, 1],
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
