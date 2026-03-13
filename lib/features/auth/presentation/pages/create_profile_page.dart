import 'package:flutter/material.dart';
import 'package:flutter_mobx/flutter_mobx.dart';
import 'package:get_it/get_it.dart';
import 'package:go_router/go_router.dart';
import '../store/auth_store.dart';

class CreateProfilePage extends StatefulWidget {
  const CreateProfilePage({super.key});

  @override
  State<CreateProfilePage> createState() => _CreateProfilePageState();
}

class _CreateProfilePageState extends State<CreateProfilePage> {
  final AuthStore _authStore = GetIt.I<AuthStore>();
  final _formKey = GlobalKey<FormState>();
  final _nameController = TextEditingController();
  final _contactsController = TextEditingController();

  @override
  void dispose() {
    _nameController.dispose();
    _contactsController.dispose();
    super.dispose();
  }

  Future<void> _onSave() async {
    if (_formKey.currentState!.validate()) {
      await _authStore.register(
        _nameController.text,
        null, // Photo URL placeholder
        _contactsController.text,
      );
      
      if (!mounted) return;

      if (_authStore.errorMessage == null) {
        context.go('/');
      } else {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(content: Text(_authStore.errorMessage!)),
        );
      }
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Создание профиля'),
        automaticallyImplyLeading: false,
      ),
      body: SafeArea(
        child: Padding(
          padding: const EdgeInsets.all(24.0),
          child: Form(
            key: _formKey,
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.stretch,
              children: [
                Center(
                  child: Stack(
                    children: [
                      CircleAvatar(
                        radius: 50,
                        backgroundColor: Colors.grey.shade200,
                        child: Icon(Icons.person, size: 50, color: Colors.grey),
                      ),
                      Positioned(
                        bottom: 0,
                        right: 0,
                        child: CircleAvatar(
                          radius: 18,
                          backgroundColor: Colors.deepPurple,
                          child: IconButton(
                            padding: EdgeInsets.zero,
                            icon: const Icon(Icons.camera_alt, size: 18, color: Colors.white),
                            onPressed: () {
                              // Pick image logic
                            },
                          ),
                        ),
                      ),
                    ],
                  ),
                ),
                const SizedBox(height: 32),
                TextFormField(
                  controller: _nameController,
                  decoration: const InputDecoration(
                    labelText: 'Имя',
                    border: OutlineInputBorder(),
                  ),
                  validator: (value) {
                    if (value == null || value.isEmpty) {
                      return 'Пожалуйста, введите имя';
                    }
                    return null;
                  },
                ),
                const SizedBox(height: 16),
                TextFormField(
                  controller: _contactsController,
                  decoration: const InputDecoration(
                    labelText: 'Контакты для связи (Telegram, WhatsApp)',
                    border: OutlineInputBorder(),
                  ),
                ),
                const Spacer(),
                Observer(
                  builder: (_) => ElevatedButton(
                    onPressed: _authStore.isLoading ? null : _onSave,
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
                          child: CircularProgressIndicator(strokeWidth: 2, color: Colors.white)
                        )
                      : const Text(
                          'Сохранить',
                          style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold),
                        ),
                  ),
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
