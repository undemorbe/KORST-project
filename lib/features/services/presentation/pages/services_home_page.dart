import 'package:flutter/material.dart';
import 'package:flutter_mobx/flutter_mobx.dart';
import 'package:go_router/go_router.dart';
import '../../../../l10n/generated/app_localizations.dart';
import '../../../../core/di/injection_container.dart';
import '../../domain/entities/service_category.dart';
import '../store/service_store.dart';
import '../widgets/service_card.dart';
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

  @override
  void initState() {
    super.initState();
    // Initial load handled by MainShellPage, but we can set listeners here if needed
    _searchController.addListener(() {
      _store.setSearchQuery(_searchController.text);
    });
  }

  @override
  void dispose() {
    _searchController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final l10n = AppLocalizations.of(context)!;

    return Scaffold(
      appBar: AppBar(
        title: Text(l10n.homeTitle),
      ),
      body: Column(
        children: [
          // Search Bar
          Padding(
            padding: const EdgeInsets.all(16.0),
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

          // Category Filter
          SingleChildScrollView(
            scrollDirection: Axis.horizontal,
            padding: const EdgeInsets.symmetric(horizontal: 16),
            child: Observer(
              builder: (_) => Row(
                children: [
                  _buildCategoryChip(context, l10n.categoryAll, null),
                  const SizedBox(width: 8),
                  _buildCategoryChip(context, l10n.categoryCleaning, ServiceCategory.cleaning),
                  const SizedBox(width: 8),
                  _buildCategoryChip(context, l10n.categoryRepair, ServiceCategory.repair),
                  const SizedBox(width: 8),
                  _buildCategoryChip(context, l10n.categoryConsulting, ServiceCategory.consulting),
                  const SizedBox(width: 8),
                  _buildCategoryChip(context, 'Other', ServiceCategory.other),
                ],
              ),
            ),
          ),
          const SizedBox(height: 16),

          // Service List
          Expanded(
            child: Observer(
              builder: (_) {
                if (_store.isLoading) {
                  return const Center(child: CircularProgressIndicator());
                }

                if (_store.errorMessage != null) {
                  return Center(child: Text('${l10n.errorLoading}: ${_store.errorMessage}'));
                }

                if (_store.filteredServices.isEmpty) {
                  return Center(child: Text(l10n.emptyList));
                }

                return ListView.builder(
                  itemCount: _store.filteredServices.length,
                  itemBuilder: (context, index) {
                    final service = _store.filteredServices[index];
                    return Observer(
                      builder: (_) => ServiceCard(
                        service: service,
                        isFavorite: _favoritesStore.isFavorite(service.id),
                        onFavoriteToggle: () => _favoritesStore.toggleFavorite(service.id),
                        onTap: () {
                          context.push('/service-details', extra: service);
                        },
                      ),
                    );
                  },
                );
              },
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildCategoryChip(BuildContext context, String label, ServiceCategory? category) {
    final isSelected = _store.selectedCategory == category;
    return FilterChip(
      label: Text(label),
      selected: isSelected,
      onSelected: (bool selected) {
        _store.setCategory(selected ? category : null);
      },
      backgroundColor: Theme.of(context).colorScheme.surfaceContainerHighest,
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
          color: isSelected ? Colors.transparent : Theme.of(context).colorScheme.outline.withValues(alpha: 0.5),
        ),
      ),
      showCheckmark: false,
    );
  }
}
