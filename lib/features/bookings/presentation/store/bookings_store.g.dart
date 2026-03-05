// GENERATED CODE - DO NOT MODIFY BY HAND

part of 'bookings_store.dart';

// **************************************************************************
// StoreGenerator
// **************************************************************************

// ignore_for_file: non_constant_identifier_names, unnecessary_brace_in_string_interps, unnecessary_lambdas, prefer_expression_function_bodies, lines_longer_than_80_chars, avoid_as, avoid_annotating_with_dynamic, no_leading_underscores_for_local_identifiers

mixin _$BookingsStore on _BookingsStore, Store {
  late final _$bookingsAtom =
      Atom(name: '_BookingsStore.bookings', context: context);

  @override
  ObservableList<BookingEntity> get bookings {
    _$bookingsAtom.reportRead();
    return super.bookings;
  }

  @override
  set bookings(ObservableList<BookingEntity> value) {
    _$bookingsAtom.reportWrite(value, super.bookings, () {
      super.bookings = value;
    });
  }

  late final _$addBookingAsyncAction =
      AsyncAction('_BookingsStore.addBooking', context: context);

  @override
  Future<void> addBooking(BookingEntity booking) {
    return _$addBookingAsyncAction.run(() => super.addBooking(booking));
  }

  late final _$_BookingsStoreActionController =
      ActionController(name: '_BookingsStore', context: context);

  @override
  void _loadBookings() {
    final _$actionInfo = _$_BookingsStoreActionController.startAction(
        name: '_BookingsStore._loadBookings');
    try {
      return super._loadBookings();
    } finally {
      _$_BookingsStoreActionController.endAction(_$actionInfo);
    }
  }

  @override
  String toString() {
    return '''
bookings: ${bookings}
    ''';
  }
}
