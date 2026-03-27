import 'package:dio/dio.dart';
import 'package:get_it/get_it.dart';
import 'package:talker/talker.dart';
import 'package:talker_dio_logger/talker_dio_logger.dart';
import '../api/api_client.dart';
import '../api/token_storage.dart';
import '../logging/app_talker.dart';
import '../logging/safe_talker_dio_interceptor.dart';
import '../../core/storage/local_storage.dart';
import '../../features/services/data/repositories/service_repository_impl.dart';
import '../../features/services/domain/repositories/service_repository.dart';
import '../../features/services/presentation/store/service_store.dart';
import '../../features/settings/presentation/store/settings_store.dart';
import '../../features/favorites/presentation/store/favorites_store.dart';
import '../../features/bookings/presentation/store/bookings_store.dart';
import '../../features/auth/data/repositories/auth_repository_impl.dart';
import '../../features/auth/domain/repositories/auth_repository.dart';
import '../../features/auth/presentation/store/auth_store.dart';

final sl = GetIt.instance;

Future<void> init() async {
  // Core
  final storageService = LocalStorageServiceImpl();
  await storageService.init();
  sl.registerSingleton<LocalStorageService>(storageService);

  sl.registerLazySingleton<Talker>(() => createAppTalker());
  sl.registerLazySingleton(() => TokenStorage(sl()));
  sl.registerLazySingleton<Dio>(
    () {
      final dio = Dio();
      dio.interceptors.add(SafeTalkerDioInterceptor(sl<Talker>()));
      dio.interceptors.add(
        TalkerDioLogger(
          talker: sl<Talker>(),
          settings: const TalkerDioLoggerSettings(
            printRequestHeaders: false,
            printResponseHeaders: false,
            printRequestData: false,
            printResponseData: false,
            printResponseMessage: true,
          ),
        ),
      );
      return dio;
    },
    instanceName: 'api',
  );
  sl.registerLazySingleton<Dio>(
    () {
      final dio = Dio();
      dio.interceptors.add(SafeTalkerDioInterceptor(sl<Talker>()));
      dio.interceptors.add(
        TalkerDioLogger(
          talker: sl<Talker>(),
          settings: const TalkerDioLoggerSettings(
            printRequestHeaders: false,
            printResponseHeaders: false,
            printRequestData: false,
            printResponseData: false,
            printResponseMessage: true,
          ),
        ),
      );
      return dio;
    },
    instanceName: 'refresh',
  );
  sl.registerLazySingleton<ApiClient>(
    () => ApiClient(
      dio: sl<Dio>(instanceName: 'api'),
      refreshDio: sl<Dio>(instanceName: 'refresh'),
      tokenStorage: sl<TokenStorage>(),
    ),
  );

  // Features - Auth
  sl.registerLazySingleton<AuthRepository>(() => AuthRepositoryImpl(sl(), sl(), sl()));
  sl.registerLazySingleton(() => AuthStore(sl()));

  // Features - Services
  sl.registerLazySingleton<ServiceRepository>(() => ServiceRepositoryImpl(sl()));
  // sl.registerLazySingleton(() => GetServices(sl())); // Removed as we use Repo directly in Store
  sl.registerLazySingleton(() => ServiceStore(sl()));

  // Features - Settings
  sl.registerLazySingleton(() => SettingsStore());

  // Features - Favorites
  sl.registerLazySingleton(() => FavoritesStore(sl()));

  // Features - Bookings
  sl.registerLazySingleton(() => BookingsStore(sl()));
}
