import 'package:flutter/material.dart';
import 'service_editor_page.dart';

class CreateServicePage extends StatefulWidget {
  const CreateServicePage({super.key});

  @override
  State<CreateServicePage> createState() => _CreateServicePageState();
}

class _CreateServicePageState extends State<CreateServicePage> {
  @override
  Widget build(BuildContext context) {
    return const ServiceEditorPage();
  }
}
