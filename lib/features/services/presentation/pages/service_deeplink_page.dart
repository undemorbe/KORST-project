import 'package:flutter/material.dart';
import '../../../../core/di/injection_container.dart';
import '../../domain/entities/service_entity.dart';
import '../../domain/repositories/service_repository.dart';
import 'service_details_page.dart';
import '../widgets/service_card_shimmer.dart';

class ServiceDeeplinkPage extends StatelessWidget {
  final String serviceId;

  const ServiceDeeplinkPage({
    super.key,
    required this.serviceId,
  });

  @override
  Widget build(BuildContext context) {
    final repo = sl<ServiceRepository>();
    return FutureBuilder<ServiceEntity>(
      future: repo.getService(serviceId),
      builder: (context, snapshot) {
        if (snapshot.connectionState != ConnectionState.done) {
          return const Scaffold(
            body: SafeArea(
              child: ServiceCardShimmerList(itemCount: 3),
            ),
          );
        }

        if (snapshot.hasError) {
          return Scaffold(
            appBar: AppBar(
              title: const Text('Карточка услуги'),
            ),
            body: Padding(
              padding: const EdgeInsets.all(16),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.stretch,
                children: [
                  Text('Не удалось открыть карточку: ${snapshot.error}'),
                  const SizedBox(height: 12),
                  OutlinedButton(
                    onPressed: () {
                      Navigator.of(context).pushReplacement(
                        MaterialPageRoute(
                          builder: (_) => ServiceDeeplinkPage(serviceId: serviceId),
                        ),
                      );
                    },
                    child: const Text('Повторить'),
                  ),
                ],
              ),
            ),
          );
        }

        final service = snapshot.data;
        if (service == null || service.id.isEmpty) {
          return const Scaffold(
            body: Center(child: Text('Карточка не найдена')),
          );
        }

        return ServiceDetailsPage(service: service);
      },
    );
  }
}
