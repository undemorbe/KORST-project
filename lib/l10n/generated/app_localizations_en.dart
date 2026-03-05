// ignore: unused_import
import 'package:intl/intl.dart' as intl;
import 'app_localizations.dart';

// ignore_for_file: type=lint

/// The translations for English (`en`).
class AppLocalizationsEn extends AppLocalizations {
  AppLocalizationsEn([String locale = 'en']) : super(locale);

  @override
  String get appTitle => 'Korst Services';

  @override
  String get homeTitle => 'Services';

  @override
  String get settingsTitle => 'Settings';

  @override
  String get themeTitle => 'Theme';

  @override
  String get languageTitle => 'Language';

  @override
  String get lightTheme => 'Light';

  @override
  String get darkTheme => 'Dark';

  @override
  String get serviceDetailsTitle => 'Service Details';

  @override
  String get priceLabel => 'Price: ';

  @override
  String get errorLoading => 'Error loading services';

  @override
  String get emptyList => 'No services available';

  @override
  String get navHome => 'Home';

  @override
  String get navFavorites => 'Favorites';

  @override
  String get navBookings => 'Bookings';

  @override
  String get navSettings => 'Settings';

  @override
  String get favoritesTitle => 'Favorites';

  @override
  String get bookingsTitle => 'My Bookings';

  @override
  String get bookNow => 'Book Now';

  @override
  String get bookingSuccess => 'Service booked successfully!';

  @override
  String get noFavorites => 'No favorites yet.';

  @override
  String get noBookings => 'No bookings yet.';

  @override
  String get searchHint => 'Search services...';

  @override
  String get categoryAll => 'All';

  @override
  String get categoryCleaning => 'Cleaning';

  @override
  String get categoryRepair => 'Repair';

  @override
  String get categoryConsulting => 'Consulting';
}
