import 'package:flutter/material.dart';
import 'package:flutter_mobx/flutter_mobx.dart';
import 'package:go_router/go_router.dart';
import '../../../../core/di/injection_container.dart';
import '../../../auth/presentation/store/auth_store.dart';
import '../../domain/entities/service_entity.dart';
import '../store/service_store.dart';
import '../widgets/service_card.dart';
import '../widgets/service_card_shimmer.dart';

class MyServicesPage extends StatefulWidget {
  const MyServicesPage({super.key});

  @override
  State<MyServicesPage> createState() => _MyServicesPageState();
}

class _MyServicesPageState extends State<MyServicesPage> {
  final ServiceStore _serviceStore = sl<ServiceStore>();
  final AuthStore _authStore = sl<AuthStore>();

  @override
  void initState() {
    super.initState();
    _serviceStore.loadServices();
  }

  Future<void> _refresh() async {
    await _serviceStore.loadServices();
  }

  bool _isMine(ServiceEntity service, String userId, String userName, String userPhone) {
    final author = service.author;
    if (author == null) return false;
    if (author.uid.isNotEmpty && userId.isNotEmpty) return author.uid == userId;
    if (author.phone.isNotEmpty && userPhone.isNotEmpty) return author.phone == userPhone;
    return author.name.trim().toLowerCase() == userName.trim().toLowerCase();
  }

  @override
  Widget build(BuildContext context) {
    final user = _authStore.userProfile;
    final userId = user?.uid ?? '';
    final userName = user?.name ?? '';
    final userPhone = user?.phone ?? '';

    return Scaffold(
      appBar: AppBar(
        title: const Text('Мои карточки'),
      ),
      floatingActionButton: FloatingActionButton.extended(
        onPressed: () async {
          await context.push('/create-service');
          if (!mounted) return;
          await _serviceStore.loadServices();
        },
        label: const Text('Новая карточка'),
        icon: const Icon(Icons.add),
      ),
      body: Observer(
        builder: (_) {
          if (_serviceStore.isLoading && _serviceStore.services.isEmpty) {
            return const ServiceCardShimmerList(itemCount: 5);
          }

          final mine = _serviceStore.services
              .where((s) => _isMine(s, userId, userName, userPhone))
              .toList(growable: false);

          if (mine.isEmpty) {
            return RefreshIndicator(
              onRefresh: _refresh,
              child: ListView(
                physics: const AlwaysScrollableScrollPhysics(),
                children: const [
                  SizedBox(height: 240),
                  Center(
                    child: Padding(
                      padding: EdgeInsets.all(24),
                      child: Text('У вас пока нет карточек. Создайте первую.'),
                    ),
                  ),
                ],
              ),
            );
          }

          return RefreshIndicator(
            onRefresh: _refresh,
            child: ListView.separated(
              padding: const EdgeInsets.all(12),
              physics: const AlwaysScrollableScrollPhysics(),
              itemCount: mine.length,
              separatorBuilder: (context, index) => const SizedBox(height: 8),
              itemBuilder: (context, index) {
                final service = mine[index];
                return Card(
                  child: Column(
                    children: [
                      ServiceCard(
                        service: service,
                        isFavorite: false,
                        onFavoriteToggle: () {},
                        onTap: () async {
                          await context.push('/service-details', extra: service);
                          if (!mounted) return;
                          await _serviceStore.loadServices();
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
                              await _serviceStore.loadServices();
                            },
                            icon: const Icon(Icons.edit),
                            label: const Text('Редактировать карточку'),
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
