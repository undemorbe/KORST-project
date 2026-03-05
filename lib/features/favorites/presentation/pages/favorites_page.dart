import 'package:flutter/material.dart';
import 'package:flutter_mobx/flutter_mobx.dart';
import 'package:go_router/go_router.dart';
import '../../../../l10n/generated/app_localizations.dart';
import '../../../../core/di/injection_container.dart';
import '../../../services/presentation/store/service_store.dart';
import '../../../services/presentation/widgets/service_card.dart';
import '../store/favorites_store.dart';

class FavoritesPage extends StatelessWidget {
  const FavoritesPage({super.key});

  @override
  Widget build(BuildContext context) {
    final l10n = AppLocalizations.of(context)!;
    final favoritesStore = sl<FavoritesStore>();
    final serviceStore = sl<ServiceStore>();

    return Scaffold(
      appBar: AppBar(
        title: Text(l10n.favoritesTitle),
      ),
      body: Observer(
        builder: (_) {
          final favoriteServices = serviceStore.services
              .where((s) => favoritesStore.favoriteIds.contains(s.id))
              .toList();

          if (favoriteServices.isEmpty) {
            return Center(
              child: Text(l10n.noFavorites),
            );
          }

          return ListView.builder(
            itemCount: favoriteServices.length,
            itemBuilder: (context, index) {
              final service = favoriteServices[index];
              return ServiceCard(
                service: service,
                isFavorite: true,
                onFavoriteToggle: () => favoritesStore.toggleFavorite(service.id),
                onTap: () {
                  context.push('/service-details', extra: service);
                },
              );
            },
          );
        },
      ),
    );
  }
}
