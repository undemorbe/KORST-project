import 'package:korst/core/widgets/glass.dart';
import 'package:flutter/material.dart';
import '../../../../l10n/generated/app_localizations.dart';

class PrivacyPolicyPage extends StatelessWidget {
  const PrivacyPolicyPage({super.key});

  @override
  Widget build(BuildContext context) {
    final l10n = AppLocalizations.of(context)!;
    return Scaffold(extendBodyBehindAppBar: true, extendBody: true,
      appBar: GlassAppBar(title: Text(l10n.privacyPolicy)),
      body: Padding(
        padding: const EdgeInsets.all(16),
        child: SelectableText(
          '${l10n.privacyPolicy}\n\n'
          'Privacy policy text will be added here.',
        ),
      ),
    );
  }
}
