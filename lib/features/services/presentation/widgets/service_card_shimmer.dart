import 'package:flutter/material.dart';
import '../../../../core/theme/app_colors.dart';

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
    return Padding(
      padding: padding,
      child: Column(
        children: List.generate(
          itemCount * 2 - 1,
          (index) {
            if (index.isEven) {
              return const ServiceCardShimmer();
            } else {
              return const SizedBox(height: 8);
            }
          },
        ),
      ),
    );
  }
}

class ServiceCardShimmer extends StatelessWidget {
  const ServiceCardShimmer({super.key});

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 6),
      child: DecoratedBox(
        decoration: BoxDecoration(
          gradient: const LinearGradient(
            begin: Alignment.topLeft,
            end: Alignment.bottomRight,
            colors: [AppColors.surfaceCard, AppColors.surfaceCardEnd],
          ),
          borderRadius: BorderRadius.circular(8),
          border: Border.all(color: AppColors.border),
          boxShadow: const [
            BoxShadow(color: AppColors.goldGlow, blurRadius: 16, spreadRadius: 0),
          ],
        ),
        child: ClipRRect(
          borderRadius: BorderRadius.circular(8),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              const _ShimmerBlock(height: 160, width: double.infinity, borderRadius: 0),
              Padding(
                padding: const EdgeInsets.all(14),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    const _ShimmerBlock(height: 18, width: double.infinity, borderRadius: 4),
                    const SizedBox(height: 8),
                    const _ShimmerBlock(height: 14, width: 180, borderRadius: 4),
                    const SizedBox(height: 14),
                    Row(
                      children: [
                        Container(
                          width: 28,
                          height: 28,
                          decoration: const BoxDecoration(
                            color: AppColors.borderSubtle,
                            shape: BoxShape.circle,
                          ),
                        ),
                        const SizedBox(width: 10),
                        const _ShimmerBlock(height: 14, width: 100, borderRadius: 4),
                        const Spacer(),
                        Container(
                          width: 48,
                          height: 26,
                          decoration: BoxDecoration(
                            color: AppColors.mutedDark,
                            borderRadius: BorderRadius.circular(4),
                          ),
                        ),
                      ],
                    ),
                    const SizedBox(height: 12),
                    Wrap(
                      spacing: 6,
                      children: [
                        _shimmerTag(),
                        _shimmerTag(),
                        _shimmerTag(),
                      ],
                    ),
                  ],
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }

  Widget _shimmerTag() {
    return Container(
      width: 64,
      height: 24,
      decoration: BoxDecoration(
        color: AppColors.borderSubtle,
        borderRadius: BorderRadius.circular(4),
      ),
    );
  }
}

class _ShimmerBlock extends StatefulWidget {
  final double height;
  final double width;
  final double borderRadius;

  const _ShimmerBlock({
    required this.height,
    required this.width,
    this.borderRadius = 10,
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
    const base = Color(0xFF1A1608);
    const glowA = Color(0xFF2A2010);
    const glowB = Color(0xFF3A3018);

    return ClipRRect(
      borderRadius: BorderRadius.all(Radius.circular(widget.borderRadius)),
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
