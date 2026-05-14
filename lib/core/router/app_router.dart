import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';
import 'package:talker_flutter/talker_flutter.dart';
import '../../features/services/presentation/pages/create_service_page.dart';
import '../../features/services/presentation/pages/my_services_page.dart';
import '../../features/services/presentation/pages/service_deeplink_page.dart';
import '../../features/services/presentation/pages/service_editor_page.dart';
import '../../features/settings/presentation/pages/edit_profile_page.dart';
import '../../features/settings/presentation/pages/privacy_policy_page.dart';
import '../../features/settings/presentation/pages/terms_of_use_page.dart';
import '../../features/settings/presentation/pages/settings_page.dart';
import '../../features/favorites/presentation/pages/favorites_page.dart';
import '../../features/main/presentation/pages/main_shell_page.dart';
import '../../features/users/presentation/pages/user_profile_page.dart';
import '../../features/users/presentation/pages/my_reviews_page.dart';
import '../../features/messenger/presentation/pages/chat_list_page.dart';
import '../../features/messenger/presentation/pages/chat_page.dart';
import '../../features/messenger/presentation/store/messenger_store.dart';
import '../../features/auth/presentation/pages/splash_page.dart';
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

class AppRouter {
  static final _rootNavigatorKey = GlobalKey<NavigatorState>();

  static CustomTransitionPage<void> _buildTransitionPage(
    GoRouterState state,
    Widget child,
  ) {
    return CustomTransitionPage<void>(
      key: state.pageKey,
      child: child,
      transitionDuration: const Duration(milliseconds: 420),
      reverseTransitionDuration: const Duration(milliseconds: 320),
      transitionsBuilder: (context, animation, secondaryAnimation, child) {
        final curved = CurvedAnimation(
          parent: animation,
          curve: Curves.easeOutCubic,
          reverseCurve: Curves.easeInCubic,
        );
        return FadeTransition(
          opacity: Tween<double>(begin: 0.0, end: 1.0).animate(curved),
          child: SlideTransition(
            position: Tween<Offset>(
              begin: const Offset(0.06, 0.02),
              end: Offset.zero,
            ).animate(curved),
            child: ScaleTransition(
              scale: Tween<double>(begin: 0.985, end: 1.0).animate(curved),
              child: child,
            ),
          ),
        );
      },
    );
  }

  static ServiceEntity? _serviceFromExtra(Object? extra) {
    if (extra is ServiceEntity) return extra;
    if (extra is Map) {
      final raw = extra['service'];
      if (raw is ServiceEntity) return raw;
      if (raw is Map) {
        return ServiceEntity.fromJson(Map<String, dynamic>.from(raw));
      }
    }
    return null;
  }

  static String? _heroTagFromExtra(Object? extra) {
    if (extra is Map) {
      final v = extra['heroTag'];
      return v is String && v.trim().isNotEmpty ? v : null;
    }
    return null;
  }

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
        pageBuilder: (context, state) =>
            _buildTransitionPage(state, const SplashPage()),
      ),
      GoRoute(
        path: '/onboarding',
        pageBuilder: (context, state) =>
            _buildTransitionPage(state, const OnboardingPage()),
      ),
      GoRoute(
        path: '/auth/phone',
        pageBuilder: (context, state) =>
            _buildTransitionPage(state, const PhoneNumberPage()),
      ),
      GoRoute(
        path: '/auth/otp',
        pageBuilder: (context, state) =>
            _buildTransitionPage(state, const OtpPage()),
      ),
      GoRoute(
        path: '/auth/create-profile',
        pageBuilder: (context, state) =>
            _buildTransitionPage(state, const CreateProfilePage()),
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
                pageBuilder: (context, state) =>
                    _buildTransitionPage(state, const ServicesHomePage()),
              ),
            ],
          ),
          StatefulShellBranch(
            routes: [
              GoRoute(
                path: '/favorites',
                pageBuilder: (context, state) =>
                    _buildTransitionPage(state, const FavoritesPage()),
              ),
            ],
          ),
          StatefulShellBranch(
            routes: [
              GoRoute(
                path: '/chats',
                pageBuilder: (context, state) =>
                    _buildTransitionPage(state, const ChatListPage()),
              ),
            ],
          ),
          StatefulShellBranch(
            routes: [
              GoRoute(
                path: '/settings',
                pageBuilder: (context, state) =>
                    _buildTransitionPage(state, const SettingsPage()),
              ),
            ],
          ),
        ],
      ),
      GoRoute(
        path: '/service-details',
        parentNavigatorKey: _rootNavigatorKey,
        pageBuilder: (context, state) {
          final service = _serviceFromExtra(state.extra);
          if (service == null) {
            return _buildTransitionPage(
              state,
              const Scaffold(body: Center(child: Text('Invalid service data'))),
            );
          }
          final heroTag = _heroTagFromExtra(state.extra);
          return _buildTransitionPage(
            state,
            ServiceDetailsPage(service: service, heroTag: heroTag),
          );
        },
      ),
      GoRoute(
        path: '/service/:serviceId',
        parentNavigatorKey: _rootNavigatorKey,
        pageBuilder: (context, state) {
          final id = state.pathParameters['serviceId'] ?? '';
          return _buildTransitionPage(state, ServiceDeeplinkPage(serviceId: id));
        },
      ),
      GoRoute(
        path: '/create-service',
        parentNavigatorKey: _rootNavigatorKey,
        pageBuilder: (context, state) =>
            _buildTransitionPage(state, const CreateServicePage()),
      ),
      GoRoute(
        path: '/edit-service',
        parentNavigatorKey: _rootNavigatorKey,
        pageBuilder: (context, state) {
          final service =
              state.extra is ServiceEntity
                  ? state.extra as ServiceEntity
                  : state.extra is Map
                  ? ServiceEntity.fromJson(
                      Map<String, dynamic>.from(state.extra as Map),
                    )
                  : null;
          if (service == null) {
            return _buildTransitionPage(
              state,
              const Scaffold(body: Center(child: Text('Invalid service data'))),
            );
          }
          return _buildTransitionPage(
            state,
            ServiceEditorPage(initialService: service),
          );
        },
      ),
      GoRoute(
        path: '/my-services',
        parentNavigatorKey: _rootNavigatorKey,
        pageBuilder: (context, state) =>
            _buildTransitionPage(state, const MyServicesPage()),
      ),
      GoRoute(
        path: '/my-reviews',
        parentNavigatorKey: _rootNavigatorKey,
        pageBuilder: (context, state) =>
            _buildTransitionPage(state, const MyReviewsPage()),
      ),
      GoRoute(
        path: '/edit-profile',
        parentNavigatorKey: _rootNavigatorKey,
        pageBuilder: (context, state) =>
            _buildTransitionPage(state, const EditProfilePage()),
      ),
      GoRoute(
        path: '/privacy',
        parentNavigatorKey: _rootNavigatorKey,
        pageBuilder: (context, state) =>
            _buildTransitionPage(state, const PrivacyPolicyPage()),
      ),
      GoRoute(
        path: '/terms',
        parentNavigatorKey: _rootNavigatorKey,
        pageBuilder: (context, state) =>
            _buildTransitionPage(state, const TermsOfUsePage()),
      ),
      GoRoute(
        path: '/user-profile/:userId',
        parentNavigatorKey: _rootNavigatorKey,
        pageBuilder: (context, state) {
          final userId = state.pathParameters['userId'] ?? '';
          return _buildTransitionPage(
            state,
            UserProfilePage(
              userId: userId,
              isOwnProfileHint: userId == 'me',
            ),
          );
        },
      ),
      GoRoute(
        path: '/chat',
        parentNavigatorKey: _rootNavigatorKey,
        pageBuilder: (context, state) {
          final store = state.extra as MessengerStore;
          return _buildTransitionPage(state, ChatPage(store: store));
        },
      ),
      GoRoute(
        path: '/logs',
        parentNavigatorKey: _rootNavigatorKey,
        pageBuilder: (context, state) =>
            _buildTransitionPage(state, TalkerScreen(talker: sl<Talker>())),
      ),
    ],
  );
}
