import 'package:korst/core/widgets/glass.dart';
import 'package:flutter/material.dart';
import 'package:flutter_mobx/flutter_mobx.dart';
import 'package:get_it/get_it.dart';
import 'package:go_router/go_router.dart';
import 'package:mask_text_input_formatter/mask_text_input_formatter.dart';
import '../store/auth_store.dart';
import 'package:korst/l10n/generated/app_localizations.dart';

class PhoneNumberPage extends StatefulWidget {
  const PhoneNumberPage({super.key});

  @override
  State<PhoneNumberPage> createState() => _PhoneNumberPageState();
}

class _PhoneNumberPageState extends State<PhoneNumberPage> {
  final AuthStore _authStore = GetIt.I<AuthStore>();
  final TextEditingController _phoneController = TextEditingController();

  final _maskFormatter = MaskTextInputFormatter(
    mask: '+7 (###) ###-##-##',
    filter: {"#": RegExp(r'[0-9]')},
    type: MaskAutoCompletionType.lazy,
  );

  @override
  void dispose() {
    _phoneController.dispose();
    super.dispose();
  }

  Future<void> _onContinue() async {
    final phone = _maskFormatter.getUnmaskedText();
    if (phone.length == 10) {
      await _authStore.sendOtp('+7$phone');

      if (!mounted) return;

      if (_authStore.errorMessage == null) {
        context.push('/auth/otp');
      } else {
        ScaffoldMessenger.of(
          context,
        ).showSnackBar(SnackBar(content: Text(_authStore.errorMessage!)));
      }
    } else {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text(AppLocalizations.of(context)!.pleaseEnterValidNumber)),
      );
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: GlassAppBar(
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
              Text(
                AppLocalizations.of(context)!.yourPhoneNumber,
                style: TextStyle(fontSize: 24, fontWeight: FontWeight.bold),
              ),
              const SizedBox(height: 8),
              Text(
                AppLocalizations.of(context)!.weWillSendVerificationCode,
                style: TextStyle(color: Colors.grey, fontSize: 16),
              ),
              const SizedBox(height: 32),
              TextField(
                controller: _phoneController,
                inputFormatters: [_maskFormatter],
                keyboardType: TextInputType.phone,
                style: const TextStyle(fontSize: 18),
                decoration: InputDecoration(
                  labelText: AppLocalizations.of(context)!.phoneNumber,
                  hintText: '+7 (999) 000-00-00',
                  border: OutlineInputBorder(
                    borderRadius: BorderRadius.circular(12),
                  ),
                  contentPadding: const EdgeInsets.symmetric(
                    horizontal: 16,
                    vertical: 16,
                  ),
                ),
                autofocus: true,
              ),
              const Spacer(),
              Observer(
                builder: (_) => ElevatedButton(
                  onPressed: _authStore.isLoading ? null : _onContinue,
                  style: ElevatedButton.styleFrom(
                    padding: const EdgeInsets.symmetric(vertical: 16),
                    shape: RoundedRectangleBorder(
                      borderRadius: BorderRadius.circular(12),
                    ),
                  ),
                  child: _authStore.isLoading
                      ? const SizedBox(
                          height: 20,
                          width: 20,
                          child: CircularProgressIndicator(
                            strokeWidth: 2,
                            color: Colors.white,
                          ),
                        )
                      : Text(
                          AppLocalizations.of(context)!.continueAction,
                          style: TextStyle(
                            fontSize: 18,
                            fontWeight: FontWeight.bold,
                          ),
                        ),
                ),
              ),
              const SizedBox(height: 16),
            ],
          ),
        ),
      ),
    );
  }
}
