import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';
import 'package:talker_flutter/talker_flutter.dart';
import '../../features/services/presentation/pages/create_service_page.dart';
import '../../features/settings/presentation/pages/edit_profile_page.dart';
import '../../features/auth/presentation/pages/auth_gate_page.dart';
import '../../features/auth/presentation/pages/onboarding_page.dart';
import '../../features/auth/presentation/pages/phone_number_page.dart';
import '../../features/auth/presentation/pages/otp_page.dart';
import '../../features/auth/presentation/pages/create_profile_page.dart';
import '../../features/auth/presentation/store/auth_store.dart';
import '../../features/auth/domain/entities/auth_user_status.dart';
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
    initialLocation: '/auth-gate',
    redirect: (context, state) {
      final authStore = sl<AuthStore>();
      final path = state.uri.path;
      if (path == '/auth-gate') return null;

      final isLoggedIn = authStore.isLoggedIn;
      final isCreateProfile = path == '/auth/create-profile';
      final isAuthRoute = path.startsWith('/auth') || path == '/onboarding';

      if (!isLoggedIn && isCreateProfile) {
        return '/onboarding';
      }

      if (!isLoggedIn && !isAuthRoute) {
        return '/onboarding';
      }

      if (isLoggedIn && authStore.userStatus == AuthUserStatus.notRegistered && !isCreateProfile) {
        return '/auth/create-profile';
      }

      if (isLoggedIn && isAuthRoute && !(isCreateProfile && authStore.userStatus == AuthUserStatus.notRegistered)) {
        return '/';
      }

      return null;
    },
    routes: [
      GoRoute(
        path: '/auth-gate',
        builder: (context, state) => const AuthGatePage(),
      ),
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
      GoRoute(
        path: '/logs',
        parentNavigatorKey: _rootNavigatorKey,
        builder: (context, state) => TalkerScreen(talker: sl<Talker>()),
      ),
    ],
  );
}
