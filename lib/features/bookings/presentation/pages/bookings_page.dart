import 'package:flutter/material.dart';
import 'package:flutter_mobx/flutter_mobx.dart';
import 'package:intl/intl.dart';
import '../../../../l10n/generated/app_localizations.dart';
import '../../../../core/di/injection_container.dart';
import '../store/bookings_store.dart';

class BookingsPage extends StatelessWidget {
  const BookingsPage({super.key});

  @override
  Widget build(BuildContext context) {
    final l10n = AppLocalizations.of(context)!;
    final store = sl<BookingsStore>();

    return Scaffold(
      appBar: AppBar(
        title: Text(l10n.bookingsTitle),
      ),
      body: Observer(
        builder: (_) {
          if (store.bookings.isEmpty) {
            return Center(
              child: Text(l10n.noBookings),
            );
          }

          return ListView.builder(
            itemCount: store.bookings.length,
            itemBuilder: (context, index) {
              final booking = store.bookings[index];
              return Card(
                margin: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
                child: ListTile(
                  title: Text(booking.serviceTitle),
                  subtitle: Text(DateFormat.yMMMd().add_jm().format(booking.date)),
                  trailing: Text(
                    '\$${booking.price.toStringAsFixed(2)}',
                    style: TextStyle(
                      color: Theme.of(context).primaryColor,
                      fontWeight: FontWeight.bold,
                    ),
                  ),
                ),
              );
            },
          );
        },
      ),
    );
  }
}
