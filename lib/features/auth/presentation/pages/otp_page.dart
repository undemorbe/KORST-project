import 'package:korst/core/widgets/glass.dart';
import 'package:flutter/material.dart';
import 'package:flutter_mobx/flutter_mobx.dart';
import 'package:get_it/get_it.dart';
import 'package:go_router/go_router.dart';
import 'package:pinput/pinput.dart';
import '../../../../core/widgets/app_layout.dart';
import '../../domain/entities/auth_user_status.dart';
import '../store/auth_store.dart';
import 'package:korst/l10n/generated/app_localizations.dart';

class OtpPage extends StatefulWidget {
  const OtpPage({super.key});

  @override
  State<OtpPage> createState() => _OtpPageState();
}

class _OtpPageState extends State<OtpPage> {
  final AuthStore _authStore = GetIt.I<AuthStore>();
  final TextEditingController _otpController = TextEditingController();
  final _scaffoldMessengerKey = GlobalKey<ScaffoldMessengerState>();

  @override
  void dispose() {
    _otpController.dispose();
    super.dispose();
  }

  Future<void> _onCompleted(String pin) async {
    // Hide previous banners/snackbars
    _scaffoldMessengerKey.currentState?.hideCurrentMaterialBanner();
    _scaffoldMessengerKey.currentState?.hideCurrentSnackBar();

    final status = await _authStore.verifyOtp(pin);

    if (!mounted) return;

    if (_authStore.errorMessage == null) {
      if (status == AuthUserStatus.notRegistered) {
        context.push('/auth/create-profile');
      } else {
        context.go('/'); // Home page
      }
    } else {
      // Clear pin on error
      _otpController.clear();

      _scaffoldMessengerKey.currentState?.showMaterialBanner(
        MaterialBanner(
          content: Text(
            _authStore.errorMessage!,
            style: const TextStyle(color: Colors.white),
          ),
          backgroundColor: Colors.red,
          actions: [
            TextButton(
              onPressed: () {
                _scaffoldMessengerKey.currentState?.hideCurrentMaterialBanner();
              },
              child: Text(
                AppLocalizations.of(context)!.close,
                style: TextStyle(color: Colors.white),
              ),
            ),
          ],
        ),
      );

      // Auto-hide after 3 seconds
      Future.delayed(const Duration(seconds: 3), () {
        if (mounted) {
          _scaffoldMessengerKey.currentState?.hideCurrentMaterialBanner();
        }
      });
    }
  }

  @override
  Widget build(BuildContext context) {
    return ScaffoldMessenger(
      key: _scaffoldMessengerKey,
      child: Scaffold(
        appBar: GlassAppBar(
          backgroundColor: Colors.transparent,
          elevation: 0,
          leading: BackButton(color: Theme.of(context).colorScheme.onSurface),
        ),
        body: SafeArea(
          child: Padding(
            padding: const EdgeInsets.all(24.0),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.stretch,
              children: [
                Observer(
                  builder: (_) => AppPageHeader(
                    title: AppLocalizations.of(context)!.enterSmsCode,
                    subtitle:
                        "${AppLocalizations.of(context)!.weSentCodeTo}${_authStore.phoneNumber ?? ''}",
                    icon: Icons.password,
                  ),
                ),
                const SizedBox(height: 12),
                Center(
                  child: Pinput(
                    length: 6,
                    controller: _otpController,
                    onCompleted: _onCompleted,
                    defaultPinTheme: PinTheme(
                      width: 56,
                      height: 56,
                      textStyle: TextStyle(
                        fontSize: 20,
                        color: Theme.of(context).colorScheme.onSurface,
                        fontWeight: FontWeight.w600,
                      ),
                      decoration: BoxDecoration(
                        border: Border.all(
                          color: Theme.of(context).colorScheme.outlineVariant,
                        ),
                        borderRadius: BorderRadius.circular(8),
                      ),
                    ),
                    focusedPinTheme: PinTheme(
                      width: 56,
                      height: 56,
                      textStyle: TextStyle(
                        fontSize: 20,
                        color: Theme.of(context).colorScheme.onSurface,
                        fontWeight: FontWeight.w600,
                      ),
                      decoration: BoxDecoration(
                        border: Border.all(
                          color: Theme.of(context).colorScheme.primary,
                          width: 2,
                        ),
                        borderRadius: BorderRadius.circular(8),
                      ),
                    ),
                    autofocus: true,
                  ),
                ),
                const Spacer(),
                Observer(
                  builder: (_) => _authStore.isLoading
                      ? const Center(child: CircularProgressIndicator())
                      : const SizedBox.shrink(),
                ),
                const SizedBox(height: 32),
              ],
            ),
          ),
        ),
      ),
    );
  }
}
