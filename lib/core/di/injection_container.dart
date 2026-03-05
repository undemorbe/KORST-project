import 'package:get_it/get_it.dart';
import '../../core/storage/local_storage.dart';
import '../../features/services/data/repositories/service_repository_impl.dart';
import '../../features/services/domain/repositories/service_repository.dart';
import '../../features/services/domain/usecases/get_services.dart';
import '../../features/services/presentation/store/service_store.dart';
import '../../features/settings/presentation/store/settings_store.dart';
import '../../features/favorites/presentation/store/favorites_store.dart';
import '../../features/bookings/presentation/store/bookings_store.dart';

final sl = GetIt.instance;

Future<void> init() async {
  // Core
  final storageService = LocalStorageServiceImpl();
  await storageService.init();
  sl.registerSingleton<LocalStorageService>(storageService);

  // Features - Services
  sl.registerLazySingleton<ServiceRepository>(() => ServiceRepositoryImpl());
  sl.registerLazySingleton(() => GetServices(sl()));
  sl.registerLazySingleton(() => ServiceStore(sl()));

  // Features - Settings
  sl.registerLazySingleton(() => SettingsStore());

  // Features - Favorites
  sl.registerLazySingleton(() => FavoritesStore(sl()));

  // Features - Bookings
  sl.registerLazySingleton(() => BookingsStore(sl()));
}
