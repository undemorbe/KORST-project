import 'package:korst/core/widgets/glass.dart';
import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';
import '../../../../core/di/injection_container.dart';
import '../../../../l10n/generated/app_localizations.dart';
import '../../../users/domain/entities/user_profile_entity.dart';
import '../../../users/domain/repositories/user_profile_repository.dart';
import '../../domain/entities/service_entity.dart';
import '../widgets/service_card.dart';
import '../widgets/service_card_shimmer.dart';

class MyServicesPage extends StatefulWidget {
  const MyServicesPage({super.key});

  @override
  State<MyServicesPage> createState() => _MyServicesPageState();
}

class _MyServicesPageState extends State<MyServicesPage> {
  final UserProfileRepository _repository = sl<UserProfileRepository>();
  late Future<UserProfileEntity> _profileFuture;

  @override
  void initState() {
    super.initState();
    _profileFuture = _repository.getOwnProfile();
  }

  Future<void> _refresh() async {
    setState(() {
      _profileFuture = _repository.getOwnProfile();
    });
    await _profileFuture;
  }

  @override
  Widget build(BuildContext context) {
    final l10n = AppLocalizations.of(context)!;

    return Scaffold(
      extendBodyBehindAppBar: true,
      extendBody: true,
      appBar: GlassAppBar(title: Text(l10n.profileServices)),
      floatingActionButton: FloatingActionButton.extended(
        heroTag: 'my_services_fab',
        onPressed: () async {
          await context.push('/create-service');
          if (!mounted) return;
          _refresh();
        },
        label: Text(l10n.profileAddService),
        icon: const Icon(Icons.add),
      ),
      body: FutureBuilder<UserProfileEntity>(
        future: _profileFuture,
        builder: (context, snapshot) {
          if (snapshot.connectionState == ConnectionState.waiting) {
            return const ServiceCardShimmerList(itemCount: 5);
          }

          if (snapshot.hasError) {
            return Center(
              child: Column(
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  Text("${AppLocalizations.of(context)!.errorLoadingPrefix}${snapshot.error}"),
                  const SizedBox(height: 16),
                  ElevatedButton(
                    onPressed: _refresh,
                    child: Text(l10n.retry),
                  ),
                ],
              ),
            );
          }

          final mine = snapshot.data?.cards ?? <ServiceEntity>[];

          if (mine.isEmpty) {
            return RefreshIndicator(
              onRefresh: _refresh,
              child: ListView(
                physics: const AlwaysScrollableScrollPhysics(),
                children: [
                  const SizedBox(height: 240),
                  Center(
                    child: Padding(
                      padding: const EdgeInsets.all(24),
                      child: Text(l10n.profileNoServices),
                    ),
                  ),
                ],
              ),
            );
          }

          return RefreshIndicator(
            onRefresh: _refresh,
            child: ListView.separated(
              padding: EdgeInsets.only(
                top: MediaQuery.of(context).padding.top + kToolbarHeight + 16,
                left: 12,
                right: 12,
                bottom: MediaQuery.of(context).padding.bottom + 100,
              ),
              physics: const AlwaysScrollableScrollPhysics(),
              itemCount: mine.length,
              separatorBuilder: (context, index) => const SizedBox(height: 8),
              itemBuilder: (context, index) {
                final service = mine[index];
                final heroTag = 'service-image-${service.id}-mine-$index';
                return GlassCard(
                  child: Column(
                    children: [
                      ServiceCard(
                        service: service,
                        heroTag: heroTag,
                        isFavorite: false,
                        onFavoriteToggle: () {},
                        onTap: () async {
                          await context.push(
                            '/service-details',
                            extra: {'service': service, 'heroTag': heroTag},
                          );
                          if (!mounted) return;
                          _refresh();
                        },
                      ),
                      Padding(
                        padding: const EdgeInsets.fromLTRB(12, 0, 12, 12),
                        child: SizedBox(
                          width: double.infinity,
                          child: OutlinedButton.icon(
                            onPressed: () async {
                              await context.push('/edit-service', extra: service);
                              if (!mounted) return;
                              _refresh();
                            },
                            icon: const Icon(Icons.edit),
                            label: Text(l10n.edit),
                          ),
                        ),
                      ),
                    ],
                  ),
                );
              },
            ),
          );
        },
      ),
    );
  }
}
