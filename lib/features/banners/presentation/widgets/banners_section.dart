import 'dart:async';
import 'package:cached_network_image/cached_network_image.dart';
import 'package:flutter/material.dart';
import 'package:flutter_mobx/flutter_mobx.dart';
import 'package:url_launcher/url_launcher.dart';
import '../../../../core/theme/app_colors.dart';
import '../store/banner_store.dart';

class BannersSection extends StatefulWidget {
  final BannerStore store;
  const BannersSection({super.key, required this.store});

  @override
  State<BannersSection> createState() => _BannersSectionState();
}

class _BannersSectionState extends State<BannersSection> {
  late final PageController _pageController;
  Timer? _timer;
  int _currentPage = 0;

  @override
  void initState() {
    super.initState();
    _pageController = PageController();
    _startAutoScroll();
  }

  void _startAutoScroll() {
    _timer?.cancel();
    _timer = Timer.periodic(const Duration(seconds: 7), (_) {
      if (!mounted) return;
      final count = widget.store.banners.length;
      if (count <= 1) return;
      final next = (_currentPage + 1) % count;
      _pageController.animateToPage(
        next,
        duration: const Duration(milliseconds: 500),
        curve: Curves.easeInOut,
      );
    });
  }

  @override
  void dispose() {
    _timer?.cancel();
    _pageController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Observer(
      builder: (_) {
        if (widget.store.isLoading) {
          return _BannerShimmer();
        }

        if (widget.store.banners.isEmpty) return const SizedBox.shrink();

        final banners = widget.store.banners;
        // 16:7 aspect ratio — wide banner format
        final screenWidth = MediaQuery.of(context).size.width;
        final cardWidth = screenWidth - 32; // 16px padding each side
        final cardHeight = cardWidth * 7 / 16;

        return Column(
          children: [
            SizedBox(
              height: cardHeight,
              child: Padding(
                padding: const EdgeInsets.symmetric(horizontal: 16),
                child: PageView.builder(
                  controller: _pageController,
                  itemCount: banners.length,
                  onPageChanged: (i) {
                    setState(() => _currentPage = i);
                  },
                  itemBuilder: (_, i) => _BannerCard(banner: banners[i]),
                ),
              ),
            ),
            if (banners.length > 1) ...[
              const SizedBox(height: 8),
              _DotsIndicator(
                count: banners.length,
                current: _currentPage,
              ),
            ],
          ],
        );
      },
    );
  }
}

class _DotsIndicator extends StatelessWidget {
  final int count;
  final int current;
  const _DotsIndicator({required this.count, required this.current});

  @override
  Widget build(BuildContext context) {
    final primary = Theme.of(context).colorScheme.primary;
    final muted = Theme.of(context).colorScheme.outlineVariant;
    return Row(
      mainAxisAlignment: MainAxisAlignment.center,
      children: List.generate(count, (i) {
        final active = i == current;
        return AnimatedContainer(
          duration: const Duration(milliseconds: 250),
          margin: const EdgeInsets.symmetric(horizontal: 3),
          width: active ? 16 : 6,
          height: 6,
          decoration: BoxDecoration(
            color: active ? primary : muted,
            borderRadius: BorderRadius.circular(3),
          ),
        );
      }),
    );
  }
}

class _BannerCard extends StatelessWidget {
  final dynamic banner;
  const _BannerCard({required this.banner});

  Future<void> _open() async {
    final url = (banner.link as String).trim();
    if (url.isEmpty) return;
    final uri = Uri.tryParse(url);
    if (uri == null || !uri.hasScheme) return;
    try {
      await launchUrl(uri, mode: LaunchMode.externalApplication);
    } catch (_) {
      await launchUrl(uri, mode: LaunchMode.inAppBrowserView);
    }
  }

  @override
  Widget build(BuildContext context) {
    final cs = Theme.of(context).colorScheme;
    final glow = cs.primary.withValues(alpha: 0.08);
    return GestureDetector(
      onTap: _open,
      child: Container(
        decoration: BoxDecoration(
          color: cs.surface,
          borderRadius: BorderRadius.circular(14),
          border: Border.all(color: cs.outline, width: 1),
          boxShadow: [BoxShadow(color: glow, blurRadius: 10, spreadRadius: 1)],
        ),
        clipBehavior: Clip.hardEdge,
        child: Stack(
          fit: StackFit.expand,
          children: [
            if ((banner.imageUrl as String).isNotEmpty)
              CachedNetworkImage(
                imageUrl: banner.imageUrl as String,
                fit: BoxFit.cover,
                errorWidget: (_, __, ___) => const _BannerPlaceholder(),
              )
            else
              const _BannerPlaceholder(),
            // Bottom gradient + company label
            Positioned(
              left: 0,
              right: 0,
              bottom: 0,
              child: Container(
                padding:
                    const EdgeInsets.symmetric(horizontal: 14, vertical: 10),
                decoration: BoxDecoration(
                  gradient: LinearGradient(
                    begin: Alignment.topCenter,
                    end: Alignment.bottomCenter,
                    colors: [
                      Colors.transparent,
                      Colors.black.withValues(alpha: 0.55),
                    ],
                  ),
                ),
                child: Text(
                  banner.company as String,
                  maxLines: 1,
                  overflow: TextOverflow.ellipsis,
                  style: const TextStyle(
                    color: Colors.white,
                    fontSize: 13,
                    fontWeight: FontWeight.w600,
                    letterSpacing: 0.3,
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

class _BannerPlaceholder extends StatelessWidget {
  const _BannerPlaceholder();

  @override
  Widget build(BuildContext context) {
    return Container(
      color: AppColors.surfaceCardEnd,
      child: const Center(
        child: Icon(Icons.campaign_outlined, color: AppColors.muted, size: 40),
      ),
    );
  }
}

class _BannerShimmer extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    final cs = Theme.of(context).colorScheme;
    final screenWidth = MediaQuery.of(context).size.width;
    final cardWidth = screenWidth - 32;
    final cardHeight = cardWidth * 7 / 16;
    return Padding(
      padding: const EdgeInsets.symmetric(horizontal: 16),
      child: Container(
        width: cardWidth,
        height: cardHeight,
        decoration: BoxDecoration(
          color: cs.surface,
          borderRadius: BorderRadius.circular(14),
          border: Border.all(color: cs.outlineVariant),
        ),
      ),
    );
  }
}
