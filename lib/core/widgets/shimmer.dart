import 'package:flutter/material.dart';

class Shimmer extends StatefulWidget {
  final Widget child;
  final Duration duration;

  const Shimmer({
    super.key,
    required this.child,
    this.duration = const Duration(milliseconds: 1500),
  });

  @override
  State<Shimmer> createState() => _ShimmerState();
}

class _ShimmerState extends State<Shimmer> with SingleTickerProviderStateMixin {
  late AnimationController _controller;

  @override
  void initState() {
    super.initState();
    _controller = AnimationController(
      vsync: this,
      duration: widget.duration,
    )..repeat();
  }

  @override
  void dispose() {
    _controller.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return AnimatedBuilder(
      animation: _controller,
      builder: (context, child) {
        return ShaderMask(
          shaderCallback: (bounds) {
            return LinearGradient(
              begin: const Alignment(-1.0, -0.3),
              end: const Alignment(1.0, 0.3),
              colors: const [
                Colors.transparent,
                Color(0x80FFFFFF),
                Colors.transparent,
              ],
              stops: [0.0, 0.5, 1.0],
              transform: _SlidingGradientTransform(_controller.value),
            ).createShader(bounds);
          },
          child: child,
        );
      },
      child: widget.child,
    );
  }
}

class _SlidingGradientTransform extends GradientTransform {
  final double percent;

  const _SlidingGradientTransform(this.percent);

  @override
  Matrix4? transform(Rect bounds, {TextDirection? textDirection}) {
    return Matrix4.translationValues(bounds.width * (percent * 2 - 0.5), 0, 0);
  }
}

class ShimmerContainer extends StatelessWidget {
  final double height;
  final double width;
  final double borderRadius;
  final EdgeInsets margin;

  const ShimmerContainer({
    super.key,
    required this.height,
    this.width = double.infinity,
    this.borderRadius = 12,
    this.margin = EdgeInsets.zero,
  });

  @override
  Widget build(BuildContext context) {
    final isDark = Theme.of(context).brightness == Brightness.dark;
    final baseColor = isDark ? const Color(0xFF1E293B) : const Color(0xFFE2E8F0);

    return Shimmer(
      child: Container(
        height: height,
        width: width,
        margin: margin,
        decoration: BoxDecoration(
          color: baseColor,
          borderRadius: BorderRadius.circular(borderRadius),
        ),
      ),
    );
  }
}

class ShimmerCircle extends StatelessWidget {
  final double size;
  final EdgeInsets margin;

  const ShimmerCircle({
    super.key,
    required this.size,
    this.margin = EdgeInsets.zero,
  });

  @override
  Widget build(BuildContext context) {
    final isDark = Theme.of(context).brightness == Brightness.dark;
    final baseColor = isDark ? const Color(0xFF1E293B) : const Color(0xFFE2E8F0);

    return Shimmer(
      child: Container(
        height: size,
        width: size,
        margin: margin,
        decoration: BoxDecoration(
          color: baseColor,
          shape: BoxShape.circle,
        ),
      ),
    );
  }
}

class ChatShimmer extends StatelessWidget {
  const ChatShimmer({super.key});

  @override
  Widget build(BuildContext context) {
    return ListView.builder(
      shrinkWrap: true,
      physics: const NeverScrollableScrollPhysics(),
      padding: const EdgeInsets.symmetric(vertical: 8),
      itemCount: 8,
      itemBuilder: (context, index) => Container(
        padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 12),
        child: Row(
          children: [
            const ShimmerCircle(size: 48),
            const SizedBox(width: 12),
            Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Row(
                    children: [
                      Expanded(
                        child: ShimmerContainer(
                          height: 16,
                          width: 120,
                          borderRadius: 8,
                        ),
                      ),
                      const SizedBox(width: 8),
                      ShimmerContainer(
                        height: 12,
                        width: 40,
                        borderRadius: 6,
                      ),
                    ],
                  ),
                  const SizedBox(height: 8),
                  ShimmerContainer(
                    height: 14,
                    width: double.infinity,
                    borderRadius: 7,
                  ),
                ],
              ),
            ),
          ],
        ),
      ),
    );
  }
}

class ProfileShimmer extends StatelessWidget {
  const ProfileShimmer({super.key});

  @override
  Widget build(BuildContext context) {
    return SingleChildScrollView(
      padding: const EdgeInsets.all(16),
      child: Column(
        children: [
          const ShimmerCircle(size: 100),
          const SizedBox(height: 16),
          ShimmerContainer(
            height: 24,
            width: 200,
            borderRadius: 12,
          ),
          const SizedBox(height: 8),
          ShimmerContainer(
            height: 16,
            width: 150,
            borderRadius: 8,
          ),
          const SizedBox(height: 32),
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceEvenly,
            children: [
              _buildStatShimmer(),
              _buildStatShimmer(),
              _buildStatShimmer(),
            ],
          ),
          const SizedBox(height: 32),
          for (int i = 0; i < 4; i++) ...[
            ShimmerContainer(
              height: 80,
              borderRadius: 16,
            ),
            const SizedBox(height: 12),
          ],
        ],
      ),
    );
  }

  Widget _buildStatShimmer() {
    return Column(
      children: [
        ShimmerContainer(
          height: 28,
          width: 50,
          borderRadius: 8,
        ),
        const SizedBox(height: 4),
        ShimmerContainer(
          height: 14,
          width: 60,
          borderRadius: 7,
        ),
      ],
    );
  }
}

class AuthShimmer extends StatelessWidget {
  const AuthShimmer({super.key});

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.all(24),
      child: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          ShimmerContainer(
            height: 80,
            width: 80,
            borderRadius: 20,
          ),
          const SizedBox(height: 32),
          ShimmerContainer(
            height: 32,
            width: 200,
            borderRadius: 8,
          ),
          const SizedBox(height: 16),
          ShimmerContainer(
            height: 56,
            borderRadius: 12,
          ),
          const SizedBox(height: 16),
          ShimmerContainer(
            height: 56,
            borderRadius: 12,
          ),
        ],
      ),
    );
  }
}
