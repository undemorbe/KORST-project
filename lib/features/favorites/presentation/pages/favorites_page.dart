import 'package:korst/core/widgets/glass.dart';
import 'package:flutter/material.dart';
import 'package:flutter_mobx/flutter_mobx.dart';
import 'package:go_router/go_router.dart';
import '../../../../l10n/generated/app_localizations.dart';
import '../../../../core/di/injection_container.dart';
import '../../../services/presentation/store/service_store.dart';
import '../../../services/presentation/widgets/service_card.dart';
import '../../../services/presentation/widgets/service_card_shimmer.dart';
import '../store/favorites_store.dart';

class FavoritesPage extends StatelessWidget {
  const FavoritesPage({super.key});

  @override
  Widget build(BuildContext context) {
    final l10n = AppLocalizations.of(context)!;
    final favoritesStore = sl<FavoritesStore>();
    final serviceStore = sl<ServiceStore>();

    return Scaffold(extendBodyBehindAppBar: true, extendBody: true,
      appBar: GlassAppBar(title: Text(l10n.favoritesTitle)),
      body: Observer(
        builder: (_) {
          if (serviceStore.services.isEmpty && !serviceStore.isLoading) {
            serviceStore.loadServices();
          }

          if (serviceStore.isLoading) {
            return const ServiceCardShimmerList(itemCount: 6);
          }

          final favoriteServices = serviceStore.services
              .where((s) => favoritesStore.favoriteIds.contains(s.id))
              .toList();

          if (favoriteServices.isEmpty) {
            return Center(child: Text(l10n.noFavorites));
          }

          return ListView.builder(
            padding: EdgeInsets.only(
              top: MediaQuery.of(context).padding.top + kToolbarHeight + 16,
              bottom: MediaQuery.of(context).padding.bottom + 100,
            ),
            itemCount: favoriteServices.length,
            itemBuilder: (context, index) {
              final service = favoriteServices[index];
              final heroTag = 'service-image-${service.id}-fav-$index';
              return ServiceCard(
                service: service,
                heroTag: heroTag,
                isFavorite: true,
                onFavoriteToggle: () =>
                    favoritesStore.toggleFavorite(service.id),
                onTap: () {
                  context.push(
                    '/service-details',
                    extra: {'service': service, 'heroTag': heroTag},
                  );
                },
              );
            },
          );
        },
      ),
    );
  }
}
