import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';
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
    routes: [
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
    ],
  );
}
