import 'package:flutter/material.dart';

class PrivacyPolicyPage extends StatelessWidget {
  const PrivacyPolicyPage({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Политика конфиденциальности'),
      ),
      body: const Padding(
        padding: EdgeInsets.all(16),
        child: SelectableText(
          'Политика конфиденциальности\n\n'
          'Здесь будет текст политики конфиденциальности приложения.',
        ),
      ),
    );
  }
}
