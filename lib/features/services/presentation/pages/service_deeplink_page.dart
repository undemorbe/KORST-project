import 'package:korst/core/widgets/glass.dart';
import 'package:flutter/material.dart';
import '../../../../core/di/injection_container.dart';
import '../../../../l10n/generated/app_localizations.dart';
import '../../domain/entities/service_entity.dart';
import '../../domain/repositories/service_repository.dart';
import 'service_details_page.dart';
import '../widgets/service_card_shimmer.dart';

class ServiceDeeplinkPage extends StatelessWidget {
  final String serviceId;

  const ServiceDeeplinkPage({super.key, required this.serviceId});

  @override
  Widget build(BuildContext context) {
    final l10n = AppLocalizations.of(context)!;
    final repo = sl<ServiceRepository>();
    return FutureBuilder<ServiceEntity>(
      future: repo.getService(serviceId),
      builder: (context, snapshot) {
        if (snapshot.connectionState != ConnectionState.done) {
          return Scaffold(
            backgroundColor: Theme.of(context).colorScheme.surface,
            extendBodyBehindAppBar: true, 
            extendBody: true,
            body: const SafeArea(
              child: SingleChildScrollView(
                child: ServiceCardShimmerList(itemCount: 3),
              ),
            ),
          );
        }

        if (snapshot.hasError) {
          return Scaffold(
            backgroundColor: Theme.of(context).colorScheme.surface,
            extendBodyBehindAppBar: true, 
            extendBody: true,
            appBar: GlassAppBar(title: Text(l10n.serviceDetailsTitle)),
            body: Padding(
              padding: const EdgeInsets.all(16),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.stretch,
                children: [
                  Text('${l10n.errorLoading}: ${snapshot.error}'),
                  const SizedBox(height: 12),
                  OutlinedButton(
                    onPressed: () {
                      Navigator.of(context).pushReplacement(
                        MaterialPageRoute(
                          builder: (_) =>
                              ServiceDeeplinkPage(serviceId: serviceId),
                        ),
                      );
                    },
                    child: Text(l10n.retry),
                  ),
                ],
              ),
            ),
          );
        }

        final service = snapshot.data;
        if (service == null || service.id.isEmpty) {
          return Scaffold(
            backgroundColor: Theme.of(context).colorScheme.surface,
            extendBodyBehindAppBar: true, 
            extendBody: true,
            body: Center(child: Text(AppLocalizations.of(context)!.taskNotFound)),
          );
        }

        return ServiceDetailsPage(service: service);
      },
    );
  }
}
