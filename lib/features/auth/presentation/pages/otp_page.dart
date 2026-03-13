import 'package:flutter/material.dart';
import 'package:flutter_mobx/flutter_mobx.dart';
import 'package:get_it/get_it.dart';
import 'package:go_router/go_router.dart';
import 'package:pinput/pinput.dart';
import '../store/auth_store.dart';

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

    final exists = await _authStore.verifyOtp(pin);
    
    if (!mounted) return;

    if (_authStore.errorMessage == null) {
      if (exists) {
        context.go('/'); // Home page
      } else {
        context.push('/auth/create-profile');
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
              child: const Text(
                'Закрыть',
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
        appBar: AppBar(
          backgroundColor: Colors.transparent,
          elevation: 0,
          leading: BackButton(color: Colors.black),
        ),
        body: SafeArea(
          child: Padding(
            padding: const EdgeInsets.all(24.0),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.stretch,
              children: [
                const Text(
                  'Введите код из SMS',
                  style: TextStyle(fontSize: 24, fontWeight: FontWeight.bold),
                ),
                const SizedBox(height: 8),
                Observer(
                  builder: (_) => Text(
                    'Мы отправили код на номер ${_authStore.phoneNumber ?? ""}',
                    style: const TextStyle(color: Colors.grey, fontSize: 16),
                  ),
                ),
                const SizedBox(height: 32),
                Center(
                  child: Pinput(
                    length: 4,
                    controller: _otpController,
                    onCompleted: _onCompleted,
                    defaultPinTheme: PinTheme(
                      width: 56,
                      height: 56,
                      textStyle: const TextStyle(fontSize: 20, color: Color.fromRGBO(30, 60, 87, 1), fontWeight: FontWeight.w600),
                      decoration: BoxDecoration(
                        border: Border.all(color: Colors.grey.shade300),
                        borderRadius: BorderRadius.circular(12),
                      ),
                    ),
                    focusedPinTheme: PinTheme(
                      width: 56,
                      height: 56,
                      textStyle: const TextStyle(fontSize: 20, color: Colors.black, fontWeight: FontWeight.w600),
                      decoration: BoxDecoration(
                        border: Border.all(color: Colors.deepPurple, width: 2),
                        borderRadius: BorderRadius.circular(12),
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
