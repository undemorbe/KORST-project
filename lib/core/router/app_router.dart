import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';
import '../../features/services/presentation/pages/create_service_page.dart';
import '../../features/settings/presentation/pages/edit_profile_page.dart';
import '../../features/auth/presentation/pages/onboarding_page.dart';
import '../../features/auth/presentation/pages/phone_number_page.dart';
import '../../features/auth/presentation/pages/otp_page.dart';
import '../../features/auth/presentation/pages/create_profile_page.dart';
import '../../features/auth/presentation/store/auth_store.dart';
import '../di/injection_container.dart';
import '../../features/services/domain/entities/service_entity.dart';
import '../../features/services/presentation/pages/service_details_page.dart';
import '../../features/services/presentation/pages/services_home_page.dart';
import '../../features/settings/presentation/pages/settings_page.dart';
import '../../features/bookings/presentation/pages/bookings_page.dart';
import '../../features/favorites/presentation/pages/favorites_page.dart';
import '../../features/main/presentation/pages/main_shell_page.dart';

class AppRouter {
  static final _rootNavigatorKey = GlobalKey<NavigatorState>();

  static final GoRouter router = GoRouter(
    navigatorKey: _rootNavigatorKey,
    initialLocation: '/',
    redirect: (context, state) {
      final isLoggedIn = sl<AuthStore>().isLoggedIn;
      final isAuthRoute = state.uri.path.startsWith('/auth') || state.uri.path == '/onboarding';

      if (!isLoggedIn && !isAuthRoute) {
        return '/onboarding';
      }

      if (isLoggedIn && isAuthRoute) {
        return '/';
      }

      return null;
    },
    routes: [
      GoRoute(
        path: '/onboarding',
        builder: (context, state) => const OnboardingPage(),
      ),
      GoRoute(
        path: '/auth/phone',
        builder: (context, state) => const PhoneNumberPage(),
      ),
      GoRoute(
        path: '/auth/otp',
        builder: (context, state) => const OtpPage(),
      ),
      GoRoute(
        path: '/auth/create-profile',
        builder: (context, state) => const CreateProfilePage(),
      ),
      StatefulShellRoute.indexedStack(
        builder: (context, state, navigationShell) {
          return MainShellPage(navigationShell: navigationShell);
        },
        branches: [
          StatefulShellBranch(
            routes: [
              GoRoute(
                path: '/',
                builder: (context, state) => const ServicesHomePage(),
              ),
            ],
          ),
          StatefulShellBranch(
            routes: [
              GoRoute(
                path: '/favorites',
                builder: (context, state) => const FavoritesPage(),
              ),
            ],
          ),
          StatefulShellBranch(
            routes: [
              GoRoute(
                path: '/bookings',
                builder: (context, state) => const BookingsPage(),
              ),
            ],
          ),
          StatefulShellBranch(
            routes: [
              GoRoute(
                path: '/settings',
                builder: (context, state) => const SettingsPage(),
              ),
            ],
          ),
        ],
      ),
      GoRoute(
        path: '/service-details',
        parentNavigatorKey: _rootNavigatorKey,
        builder: (context, state) {
          final service = state.extra as ServiceEntity;
          return ServiceDetailsPage(service: service);
        },
      ),
      GoRoute(
        path: '/create-service',
        parentNavigatorKey: _rootNavigatorKey,
        builder: (context, state) => const CreateServicePage(),
      ),
      GoRoute(
        path: '/edit-profile',
        parentNavigatorKey: _rootNavigatorKey,
        builder: (context, state) => const EditProfilePage(),
      ),
    ],
  );
}
