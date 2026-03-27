import 'package:flutter/material.dart';
import 'package:flutter_mobx/flutter_mobx.dart';
import 'package:get_it/get_it.dart';
import 'package:go_router/go_router.dart';
import '../../domain/entities/auth_user_status.dart';
import '../store/auth_store.dart';

class AuthGatePage extends StatefulWidget {
  const AuthGatePage({super.key});

  @override
  State<AuthGatePage> createState() => _AuthGatePageState();
}

class _AuthGatePageState extends State<AuthGatePage> {
  final AuthStore _authStore = GetIt.I<AuthStore>();
  bool _navigated = false;

  @override
  void initState() {
    super.initState();
    _bootstrap();
  }

  Future<void> _bootstrap() async {
    await _authStore.bootstrap();
    if (!mounted || _navigated) return;
    _navigated = true;

    if (!_authStore.isLoggedIn) {
      context.go('/onboarding');
      return;
    }

    if (_authStore.userStatus == AuthUserStatus.notRegistered) {
      context.go('/auth/create-profile');
      return;
    }

    context.go('/');
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: SafeArea(
        child: Center(
          child: Observer(
            builder: (_) {
              if (_authStore.isLoading) {
                return const CircularProgressIndicator();
              }
              return const CircularProgressIndicator();
            },
          ),
        ),
      ),
    );
  }
}

