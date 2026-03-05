// ignore: unused_import
import 'package:intl/intl.dart' as intl;
import 'app_localizations.dart';

// ignore_for_file: type=lint

/// The translations for Russian (`ru`).
class AppLocalizationsRu extends AppLocalizations {
  AppLocalizationsRu([String locale = 'ru']) : super(locale);

  @override
  String get appTitle => 'Korst Услуги';

  @override
  String get homeTitle => 'Услуги';

  @override
  String get settingsTitle => 'Настройки';

  @override
  String get themeTitle => 'Тема';

  @override
  String get languageTitle => 'Язык';

  @override
  String get lightTheme => 'Светлая';

  @override
  String get darkTheme => 'Темная';

  @override
  String get serviceDetailsTitle => 'Детали услуги';

  @override
  String get priceLabel => 'Цена: ';

  @override
  String get errorLoading => 'Ошибка загрузки услуг';

  @override
  String get emptyList => 'Нет доступных услуг';

  @override
  String get navHome => 'Главная';

  @override
  String get navFavorites => 'Избранное';

  @override
  String get navBookings => 'Бронирования';

  @override
  String get navSettings => 'Настройки';

  @override
  String get favoritesTitle => 'Избранное';

  @override
  String get bookingsTitle => 'Мои бронирования';

  @override
  String get bookNow => 'Забронировать';

  @override
  String get bookingSuccess => 'Услуга успешно забронирована!';

  @override
  String get noFavorites => 'В избранном пока пусто.';

  @override
  String get noBookings => 'Бронирований пока нет.';

  @override
  String get searchHint => 'Поиск услуг...';

  @override
  String get categoryAll => 'Все';

  @override
  String get categoryCleaning => 'Уборка';

  @override
  String get categoryRepair => 'Ремонт';

  @override
  String get categoryConsulting => 'Консультации';
}
