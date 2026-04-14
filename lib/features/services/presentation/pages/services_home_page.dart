import 'package:korst/core/widgets/glass.dart';
import 'package:flutter/material.dart';
import 'package:flutter_mobx/flutter_mobx.dart';
import 'package:go_router/go_router.dart';
import '../../../../l10n/generated/app_localizations.dart';
import '../../../../core/di/injection_container.dart';
import '../../../../core/widgets/empty_state.dart';
import '../../domain/entities/service_category.dart';
import '../store/service_store.dart';
import '../widgets/service_card.dart';
import '../widgets/service_card_shimmer.dart';
import '../widgets/filter_bottom_sheet.dart';
import '../../../favorites/presentation/store/favorites_store.dart';

class ServicesHomePage extends StatefulWidget {
  const ServicesHomePage({super.key});

  @override
  State<ServicesHomePage> createState() => _ServicesHomePageState();
}

class _ServicesHomePageState extends State<ServicesHomePage> {
  final ServiceStore _store = sl<ServiceStore>();
  final FavoritesStore _favoritesStore = sl<FavoritesStore>();
  final TextEditingController _searchController = TextEditingController();
  final ScrollController _scrollController = ScrollController();

  @override
  void initState() {
    super.initState();
    _searchController.addListener(() {
      _store.setSearchQuery(_searchController.text);
    });
    _store.loadServices();
    _scrollController.addListener(_onScroll);
  }

  @override
  void dispose() {
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

    return Scaffold(extendBodyBehindAppBar: true, extendBody: true,
      appBar: GlassAppBar(
        title: Text(l10n.homeTitle),
        actions: [
          IconButton(
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
      floatingActionButton: FloatingActionButton(
        heroTag: 'services_home_fab',
        onPressed: () {
          context.push('/create-service');
        },
        child: const Icon(Icons.add),
      ),
      body: RefreshIndicator(
        onRefresh: _store.loadServices,
        child: CustomScrollView(
        controller: _scrollController,
        slivers: [
          SliverPadding(
            padding: EdgeInsets.only(
              top: MediaQuery.of(context).padding.top + kToolbarHeight + 16,
              left: 16,
              right: 16,
              bottom: 16,
            ),
            sliver: SliverToBoxAdapter(
              child: TextField(
                controller: _searchController,
                decoration: InputDecoration(
                  hintText: l10n.searchHint,
                  prefixIcon: const Icon(Icons.search),
                  border: OutlineInputBorder(
                    borderRadius: BorderRadius.circular(12),
                  ),
                  contentPadding: const EdgeInsets.symmetric(horizontal: 16),
                ),
              ),
            ),
          ),
          SliverToBoxAdapter(
            child: SingleChildScrollView(
              scrollDirection: Axis.horizontal,
              padding: const EdgeInsets.symmetric(horizontal: 16),
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
          const SliverToBoxAdapter(child: SizedBox(height: 16)),
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

                if (_store.errorMessage != null) {
                  return SliverToBoxAdapter(
                    child: Center(
                      child: Padding(
                        padding: const EdgeInsets.all(16),
                        child: Column(
                          mainAxisSize: MainAxisSize.min,
                          children: [
                            Text('${l10n.errorLoading}: ${_store.errorMessage}'),
                            const SizedBox(height: 12),
                            OutlinedButton(
                              onPressed: _store.loadServices,
                              child: Text(l10n.retry),
                            ),
                          ],
                        ),
                      ),
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
                  delegate: SliverChildBuilderDelegate(
                    (context, index) {
                      if (index == _store.filteredServices.length) {
                        if (_store.isLoadingMore) {
                          return Padding(
                            padding: EdgeInsets.only(top: 4, bottom: 12),
                            child: Column(
                              children: [
                                ServiceCardShimmer(),
                                ServiceCardShimmer(),
                              ],
                            ),
                          );
                        }
                        if (!_store.hasMore) {
                          return Padding(
                            padding: EdgeInsets.symmetric(vertical: 24),
                            child: Center(child: Text(AppLocalizations.of(context)!.noMoreData)),
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
                    },
                    childCount: _store.filteredServices.length + 1,
                  ),
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
      builder: (_) {
        final isSelected = _store.selectedCategory == category;
        return FilterChip(
          label: Text(label),
          selected: isSelected,
          onSelected: (bool selected) {
            _store.setCategory(selected ? category : null);
          },
          backgroundColor: Theme.of(
            context,
          ).colorScheme.surfaceContainerHighest,
          selectedColor: Theme.of(context).colorScheme.primaryContainer,
          checkmarkColor: Theme.of(context).colorScheme.onPrimaryContainer,
          labelStyle: TextStyle(
            color: isSelected
                ? Theme.of(context).colorScheme.onPrimaryContainer
                : Theme.of(context).colorScheme.onSurfaceVariant,
          ),
          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(20),
            side: BorderSide(
              color: isSelected
                  ? Colors.transparent
                  : Theme.of(
                      context,
                    ).colorScheme.outline.withValues(alpha: 0.5),
            ),
          ),
          showCheckmark: false,
        );
      },
    );
  }
}
