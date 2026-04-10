import 'package:flutter/material.dart';
import '../../../auth/presentation/pages/profile_form_page.dart';

class EditProfilePage extends StatefulWidget {
  const EditProfilePage({super.key});

  @override
  State<EditProfilePage> createState() => _EditProfilePageState();
}

class _EditProfilePageState extends State<EditProfilePage> {
  @override
  Widget build(BuildContext context) {
    return const ProfileFormPage(isEditing: true);
  }
}
