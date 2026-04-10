import 'package:flutter/material.dart';
import 'package:flutter_mobx/flutter_mobx.dart';
import 'package:go_router/go_router.dart';
import 'package:share_plus/share_plus.dart';
import '../../../../l10n/generated/app_localizations.dart';
import '../../../../core/di/injection_container.dart';
import '../../domain/entities/service_entity.dart';
import '../store/service_store.dart';
import '../../../favorites/presentation/store/favorites_store.dart';
import '../../../bookings/presentation/store/bookings_store.dart';
import '../../../bookings/domain/entities/booking_entity.dart';
import '../../../auth/presentation/store/auth_store.dart';

class ServiceDetailsPage extends StatefulWidget {
  final ServiceEntity service;

  const ServiceDetailsPage({super.key, required this.service});

  @override
  State<ServiceDetailsPage> createState() => _ServiceDetailsPageState();
}

class _ServiceDetailsPageState extends State<ServiceDetailsPage> {
  final ServiceStore _serviceStore = sl<ServiceStore>();

  bool _canEdit(ServiceEntity service) {
    final user = sl<AuthStore>().userProfile;
    final author = service.author;
    if (user == null || author == null) return false;
    if (author.uid.isNotEmpty && user.uid.isNotEmpty) return author.uid == user.uid;
    if (author.phone.isNotEmpty && user.phone.isNotEmpty) return author.phone == user.phone;
    return author.name.trim().toLowerCase() == user.name.trim().toLowerCase();
  }

  Future<void> _shareService(ServiceEntity service) async {
    final link = 'korst:///service/${service.id}';
    final title = service.title.trim().isEmpty ? 'Карточка услуги' : service.title.trim();
    final price = '${service.price.toStringAsFixed(0)} ${service.currency}';
    await SharePlus.instance.share(
      ShareParams(
        text: '$title\n$price\n\nОткрыть в Korst: $link',
        subject: title,
      ),
    );
  }

  @override
  void initState() {
    super.initState();
    _serviceStore.loadServiceDetails(widget.service.id);
  }

  @override
  Widget build(BuildContext context) {
    final l10n = AppLocalizations.of(context)!;
    final favoritesStore = sl<FavoritesStore>();
    final bookingsStore = sl<BookingsStore>();
    final serviceStore = _serviceStore;

    return Scaffold(
      body: Observer(
        builder: (_) {
          final currentService = serviceStore.services.firstWhere(
            (s) => s.uid == widget.service.uid,
            orElse: () => widget.service,
          );

          return CustomScrollView(
            slivers: [
              SliverAppBar(
                expandedHeight: 300,
                pinned: true,
                actions: [
                  if (_canEdit(currentService))
                    IconButton(
                      icon: const Icon(Icons.edit),
                      onPressed: () => context.push('/edit-service', extra: currentService),
                    ),
                  IconButton(
                    icon: const Icon(Icons.share),
                    onPressed: () => _shareService(currentService),
                  ),
                  Observer(
                    builder: (_) {
                      final isFavorite = favoritesStore.isFavorite(currentService.id);
                      return IconButton(
                        icon: Icon(
                          isFavorite ? Icons.favorite : Icons.favorite_border,
                          color: isFavorite ? Colors.red : Colors.white,
                        ),
                        onPressed: () => favoritesStore.toggleFavorite(currentService.id),
                      );
                    },
                  ),
                ],
                flexibleSpace: FlexibleSpaceBar(
                  title: Text(
                    currentService.title,
                    style: const TextStyle(
                      color: Colors.white,
                      shadows: [
                        Shadow(
                          blurRadius: 10.0,
                          color: Colors.black,
                          offset: Offset(2.0, 2.0),
                        ),
                      ],
                    ),
                  ),
                  background: currentService.imageUrl.isNotEmpty
                      ? Image.network(
                          currentService.imageUrl,
                          fit: BoxFit.cover,
                          errorBuilder: (context, error, stackTrace) {
                            return Container(
                              color: Colors.grey.shade300,
                              child: const Center(
                                child: Icon(Icons.broken_image, size: 80, color: Colors.grey),
                              ),
                            );
                          },
                        )
                      : Container(
                          color: Colors.grey.shade300,
                          child: const Center(
                            child: Icon(Icons.image, size: 80, color: Colors.grey),
                          ),
                        ),
                ),
              ),
              SliverToBoxAdapter(
                child: Padding(
                  padding: const EdgeInsets.all(16.0),
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Row(
                        mainAxisAlignment: MainAxisAlignment.spaceBetween,
                        children: [
                          Expanded(
                            child: Text(
                              l10n.serviceDetailsTitle,
                              style: Theme.of(context).textTheme.headlineSmall?.copyWith(
                                    fontWeight: FontWeight.bold,
                                  ),
                            ),
                          ),
                          Container(
                            padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 6),
                            decoration: BoxDecoration(
                              color: Theme.of(context).primaryColor,
                              borderRadius: BorderRadius.circular(20),
                            ),
                            child: Text(
                              '${currentService.price.toStringAsFixed(0)} ${currentService.currency}',
                              style: Theme.of(context).textTheme.titleMedium?.copyWith(
                                    color: Colors.white,
                                    fontWeight: FontWeight.bold,
                                  ),
                            ),
                          ),
                        ],
                      ),
                      const SizedBox(height: 8),
                      if (currentService.author != null)
                        Padding(
                          padding: const EdgeInsets.only(bottom: 8.0),
                          child: InkWell(
                            onTap: currentService.author!.uid.isEmpty
                                ? null
                                : () => context.push('/user-profile/${currentService.author!.uid}'),
                            borderRadius: BorderRadius.circular(8),
                            child: Padding(
                              padding: const EdgeInsets.symmetric(vertical: 4),
                              child: Row(
                                children: [
                                  const Icon(Icons.person, size: 16, color: Colors.grey),
                                  const SizedBox(width: 4),
                                  Text(
                                    'Автор: ${_canEdit(currentService) ? 'Вы' : currentService.author!.name}',
                                    style: Theme.of(context).textTheme.bodyMedium?.copyWith(
                                          color: Colors.grey,
                                        ),
                                  ),
                                  const SizedBox(width: 8),
                                  ...List.generate(5, (index) {
                                    final raw = currentService.author?.contacts['rating'];
                                    final r = raw is num ? raw.toDouble() : currentService.rating;
                                    final filled = index < r.round();
                                    return Icon(
                                      filled ? Icons.star : Icons.star_border,
                                      size: 14,
                                      color: Colors.amber,
                                    );
                                  }),
                                  const SizedBox(width: 4),
                                  Builder(
                                    builder: (context) {
                                      final raw = currentService.author?.contacts['rating'];
                                      final r = raw is num ? raw.toDouble() : currentService.rating;
                                      return Text(
                                        r.toStringAsFixed(1),
                                        style: Theme.of(context).textTheme.bodySmall?.copyWith(color: Colors.grey),
                                      );
                                    },
                                  ),
                                  const SizedBox(width: 6),
                                  if (currentService.author!.uid.isNotEmpty)
                                    const Icon(Icons.open_in_new, size: 14, color: Colors.grey),
                                ],
                              ),
                            ),
                          ),
                        ),
                      
                      Row(
                        children: [
                          const Icon(Icons.star, color: Colors.amber, size: 20),
                          const SizedBox(width: 4),
                          Text(
                            currentService.rating.toStringAsFixed(1),
                            style: const TextStyle(fontWeight: FontWeight.bold),
                          ),
                        ],
                      ),
                      const SizedBox(height: 8),
                      Wrap(
                        spacing: 8,
                        children: currentService.tags.map((tag) => Chip(
                          label: Text(tag),
                          backgroundColor: Colors.grey.shade200,
                        )).toList(),
                      ),

                      const SizedBox(height: 16),
                      Text(
                        currentService.description,
                        style: Theme.of(context).textTheme.bodyLarge,
                      ),
                      const SizedBox(height: 32),
                      SizedBox(
                        width: double.infinity,
                        child: ElevatedButton(
                          onPressed: () async {
                            final date = await showDatePicker(
                              context: context,
                              initialDate: DateTime.now(),
                              firstDate: DateTime.now(),
                              lastDate: DateTime.now().add(const Duration(days: 365)),
                            );

                            if (date != null && context.mounted) {
                              final time = await showTimePicker(
                                context: context,
                                initialTime: TimeOfDay.now(),
                              );

                              if (time != null && context.mounted) {
                                final bookingDate = DateTime(
                                  date.year,
                                  date.month,
                                  date.day,
                                  time.hour,
                                  time.minute,
                                );

                                final booking = BookingEntity(
                                  id: DateTime.now().millisecondsSinceEpoch.toString(),
                                  serviceId: currentService.id,
                                  serviceTitle: currentService.title,
                                  price: currentService.price,
                                  date: bookingDate,
                                );

                                await bookingsStore.addBooking(booking);

                                if (context.mounted) {
                                  ScaffoldMessenger.of(context).showSnackBar(
                                    SnackBar(content: Text(l10n.bookingSuccess)),
                                  );
                                  context.go('/bookings');
                                }
                              }
                            }
                          },
                          style: ElevatedButton.styleFrom(
                            padding: const EdgeInsets.symmetric(vertical: 16),
                            shape: RoundedRectangleBorder(
                              borderRadius: BorderRadius.circular(12),
                            ),
                          ),
                          child: Text(l10n.bookNow),
                        ),
                      ),
                      const SizedBox(height: 32),
                    ],
                  ),
                ),
              ),
            ],
          );
        }
      ),
    );
  }
}
