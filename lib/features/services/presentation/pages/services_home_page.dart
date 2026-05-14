import 'dart:async';
import 'package:flutter/material.dart';
import 'package:mobx/mobx.dart';
import '../../../../core/widgets/glass.dart';
import 'package:flutter_mobx/flutter_mobx.dart';
import 'package:go_router/go_router.dart';
import '../../../../l10n/generated/app_localizations.dart';
import '../../../../core/di/injection_container.dart';
import '../../../../core/network/connectivity_service.dart';
import '../../../../core/widgets/app_layout.dart';
import '../../../../core/widgets/empty_state.dart';
import '../../domain/entities/service_category.dart';
import '../store/service_store.dart';
import '../widgets/service_card.dart';
import '../widgets/service_card_shimmer.dart';
import '../widgets/filter_bottom_sheet.dart';
import '../../../favorites/presentation/store/favorites_store.dart';
import '../../../banners/presentation/store/banner_store.dart';
import '../../../banners/presentation/widgets/banners_section.dart';

class ServicesHomePage extends StatefulWidget {
  const ServicesHomePage({super.key});

  @override
  State<ServicesHomePage> createState() => _ServicesHomePageState();
}

class _ServicesHomePageState extends State<ServicesHomePage> {
  final ServiceStore _store = sl<ServiceStore>();
  final FavoritesStore _favoritesStore = sl<FavoritesStore>();
  final BannerStore _bannerStore = sl<BannerStore>();
  final TextEditingController _searchController = TextEditingController();
  final ScrollController _scrollController = ScrollController();
  ReactionDisposer? _connectivityReaction;
  Timer? _searchDebounce;

  @override
  void initState() {
    super.initState();
    _searchController.addListener(() {
      _searchDebounce?.cancel();
      _searchDebounce = Timer(const Duration(milliseconds: 400), () {
        _store.setSearchQuery(_searchController.text);
      });
    });
    _store.loadServices();
    _bannerStore.loadBanners();
    _scrollController.addListener(_onScroll);
    _connectivityReaction = reaction(
      (_) => sl<ConnectivityService>().isConnected,
      (bool online) {
        if (online && _store.services.isEmpty) {
          _store.loadServices();
        }
      },
    );
  }

  @override
  void dispose() {
    _connectivityReaction?.call();
    _searchDebounce?.cancel();
    _searchController.dispose();
    _scrollController.removeListener(_onScroll);
    _scrollController.dispose();
    super.dispose();
  }

  void _onScroll() {
    if (!_scrollController.hasClients) return;
    final pos = _scrollController.position;
    if (pos.maxScrollExtent <= 0) return;
    final threshold = pos.maxScrollExtent * 0.85;
    if (pos.pixels >= threshold) {
      _store.loadMoreServices();
    }
  }

  @override
  Widget build(BuildContext context) {
    final l10n = AppLocalizations.of(context)!;
    final cs = Theme.of(context).colorScheme;

    return Scaffold(
      extendBodyBehindAppBar: true,
      extendBody: true,
      appBar: GlassAppBar(
        title: const SizedBox.shrink(),
        actions: [
          IconButton(
            tooltip: l10n.profileTitle,
            icon: const Icon(Icons.account_circle_outlined),
            onPressed: () => context.push('/user-profile/me'),
          ),
          IconButton(
            tooltip: l10n.filter,
            icon: const Icon(Icons.tune),
            onPressed: () {
              showModalBottomSheet(
                context: context,
                isScrollControlled: true,
                useRootNavigator: true,
                builder: (_) => const FilterBottomSheet(),
              );
            },
          ),
        ],
      ),
      floatingActionButton: Padding(
        padding: EdgeInsets.only(
          bottom: MediaQuery.of(context).padding.bottom - 4,
          right: 1,
        ),
        child: FloatingActionButton(
          heroTag: 'fab_add_retry_main_page',
          onPressed: () {
            context.push('/create-service');
          },
          child: const Icon(Icons.add),
        ),
      ),
      body: RefreshIndicator(
        color: cs.primary,
        backgroundColor: cs.surface,
        onRefresh: _store.loadServices,
        child: CustomScrollView(
          controller: _scrollController,
          slivers: [
            SliverToBoxAdapter(
              child: Padding(
                padding: EdgeInsets.only(
                  top: MediaQuery.of(context).padding.top + kToolbarHeight + 8,
                ),
                child: AppPageHeader(
                  title: l10n.homeTitle,
                  subtitle: l10n.findServicesNearby,
                  icon: Icons.view_agenda_outlined,
                  trailing: FilledButton(
                    onPressed: () => context.push('/create-service'),
                    child: const Icon(Icons.add),
                  ),
                ),
              ),
            ),
            SliverPadding(
              padding: const EdgeInsets.fromLTRB(20, 0, 20, 14),
              sliver: SliverToBoxAdapter(
                child: Row(
                  children: [
                    Expanded(
                      child: TextField(
                        controller: _searchController,
                        decoration: InputDecoration(
                          hintText: l10n.searchHint,
                          prefixIcon: const Icon(Icons.search),
                        ),
                      ),
                    ),
                    const SizedBox(width: 10),
                    SizedBox(
                      width: 52,
                      height: 52,
                      child: FilledButton(
                        onPressed: () {
                          showModalBottomSheet(
                            context: context,
                            isScrollControlled: true,
                            useRootNavigator: true,
                            builder: (_) => const FilterBottomSheet(),
                          );
                        },
                        style: FilledButton.styleFrom(padding: EdgeInsets.zero),
                        child: const Icon(Icons.tune),
                      ),
                    ),
                  ],
                ),
              ),
            ),
            SliverPadding(
              padding: const EdgeInsets.only(bottom: 16),
              sliver: SliverToBoxAdapter(
                child: BannersSection(store: _bannerStore),
              ),
            ),
            SliverPersistentHeader(
              pinned: false,
              delegate: _CategoryChipsDelegate(
                child: Container(
                  color: Theme.of(context).scaffoldBackgroundColor,
                  padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 8),
                  child: SingleChildScrollView(
                    scrollDirection: Axis.horizontal,
                    child: Row(
                      children: [
                        _buildCategoryChip(context, l10n.categoryAll, null),
                        const SizedBox(width: 8),
                        _buildCategoryChip(
                          context,
                          l10n.categoryCleaning,
                          ServiceCategory.cleaning,
                        ),
                        const SizedBox(width: 8),
                        _buildCategoryChip(
                          context,
                          l10n.categoryRepair,
                          ServiceCategory.repair,
                        ),
                        const SizedBox(width: 8),
                        _buildCategoryChip(
                          context,
                          l10n.categoryConsulting,
                          ServiceCategory.consulting,
                        ),
                        const SizedBox(width: 8),
                        _buildCategoryChip(context, 'Other', ServiceCategory.other),
                      ],
                    ),
                  ),
                ),
              ),
            ),
            SliverToBoxAdapter(
              child: Observer(
                builder: (_) => AppSectionTitle(
                  title: l10n.serviceDetailsTitle,
                  meta: '${_store.filteredServices.length}',
                ),
              ),
            ),
            SliverPadding(
              padding: EdgeInsets.only(
                bottom: MediaQuery.of(context).padding.bottom + 100,
              ),
              sliver: Observer(
                builder: (_) {
                  if (_store.isLoading) {
                    return const SliverToBoxAdapter(
                      child: ServiceCardShimmerList(itemCount: 6),
                    );
                  }

                  if (_store.errorMessage != null && _store.services.isEmpty) {
                    return SliverToBoxAdapter(
                      child: ErrorState(
                        icon: Icons.cloud_off_outlined,
                        message: l10n.errorLoading,
                        onRetry: _store.loadServices,
                      ),
                    );
                  }

                  if (_store.filteredServices.isEmpty) {
                    return SliverToBoxAdapter(
                      child: EmptyState(
                        icon: Icons.search_off,
                        title: l10n.emptyList,
                        subtitle: 'Try adjusting your search',
                      ),
                    );
                  }

                  return SliverList(
                    delegate: SliverChildBuilderDelegate((context, index) {
                      if (index == _store.filteredServices.length) {
                        if (_store.isLoadingMore) {
                          return SliverToBoxAdapter(
                            child: Padding(
                              padding: EdgeInsets.only(top: 4, bottom: 12),
                              child: Column(
                                mainAxisSize: MainAxisSize.min,
                                children: [
                                  ServiceCardShimmer(),
                                  ServiceCardShimmer(),
                                ],
                              ),
                            ),
                          );
                        }
                        if (!_store.hasMore) {
                          return Padding(
                            padding: EdgeInsets.symmetric(vertical: 24),
                            child: Center(
                              child: Text(
                                AppLocalizations.of(context)!.noMoreData,
                              ),
                            ),
                          );
                        }
                        return const SizedBox(height: 24);
                      }

                      final service = _store.filteredServices[index];
                      final heroTag = 'service-image-${service.id}-$index';
                      return Observer(
                        builder: (_) => ServiceCard(
                          service: service,
                          heroTag: heroTag,
                          isFavorite: _favoritesStore.isFavorite(service.id),
                          onFavoriteToggle: () =>
                              _favoritesStore.toggleFavorite(service.id),
                          onTap: () {
                            context.push(
                              '/service-details',
                              extra: {'service': service, 'heroTag': heroTag},
                            );
                          },
                        ),
                      );
                    }, childCount: _store.filteredServices.length + 1),
                  );
                },
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildCategoryChip(
    BuildContext context,
    String label,
    ServiceCategory? category,
  ) {
    return Observer(
      builder: (ctx) {
        final cs = Theme.of(ctx).colorScheme;
        final isSelected = _store.selectedCategory == category;
        return GestureDetector(
          onTap: () => _store.setCategory(isSelected ? null : category),
          child: AnimatedContainer(
            duration: const Duration(milliseconds: 180),
            padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 7),
            decoration: BoxDecoration(
              color: isSelected
                  ? cs.primary.withValues(alpha: 0.15)
                  : Colors.transparent,
              borderRadius: BorderRadius.circular(8),
              border: Border.all(
                color: isSelected ? cs.primary : cs.outlineVariant,
              ),
            ),
            child: Text(
              label,
              style: TextStyle(
                fontSize: 13,
                fontWeight: isSelected ? FontWeight.w600 : FontWeight.w400,
                color: isSelected ? cs.primary : cs.onSurface,
                letterSpacing: 0.02,
              ),
            ),
          ),
        );
      },
    );
  }
}

class _CategoryChipsDelegate extends SliverPersistentHeaderDelegate {
  final Widget child;

  _CategoryChipsDelegate({required this.child});

  @override
  double get minExtent => 60;

  @override
  double get maxExtent => 60;

  @override
  Widget build(BuildContext context, double shrinkOffset, bool overlapsContent) {
    return child;
  }

  @override
  bool shouldRebuild(covariant _CategoryChipsDelegate oldDelegate) {
    return child != oldDelegate.child;
  }
}
