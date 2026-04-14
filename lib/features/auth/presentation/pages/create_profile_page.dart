import 'package:flutter/material.dart';
import 'profile_form_page.dart';

class CreateProfilePage extends StatefulWidget {
  const CreateProfilePage({super.key});

  @override
  State<CreateProfilePage> createState() => _CreateProfilePageState();
}

class _CreateProfilePageState extends State<CreateProfilePage> {
  @override
  Widget build(BuildContext context) {
    return const ProfileFormPage(isEditing: false);
  }
}
