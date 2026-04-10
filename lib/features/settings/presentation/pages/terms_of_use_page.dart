import 'package:flutter/material.dart';

class TermsOfUsePage extends StatelessWidget {
  const TermsOfUsePage({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Условия пользования'),
      ),
      body: const Padding(
        padding: EdgeInsets.all(16),
        child: SelectableText(
          'Условия пользования\n\n'
          'Здесь будут условия пользования приложением.',
        ),
      ),
    );
  }
}
