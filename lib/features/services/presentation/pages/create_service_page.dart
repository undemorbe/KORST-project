import 'package:flutter/material.dart';
import 'package:flutter_mobx/flutter_mobx.dart';
import 'package:get_it/get_it.dart';
import 'package:go_router/go_router.dart';
import '../../domain/entities/service_entity.dart';
import '../../domain/entities/service_category.dart';
import '../store/service_store.dart';
import '../../../auth/presentation/store/auth_store.dart';

class CreateServicePage extends StatefulWidget {
  const CreateServicePage({super.key});

  @override
  State<CreateServicePage> createState() => _CreateServicePageState();
}

class _CreateServicePageState extends State<CreateServicePage> {
  final ServiceStore _serviceStore = GetIt.I<ServiceStore>();
  final AuthStore _authStore = GetIt.I<AuthStore>();
  final _formKey = GlobalKey<FormState>();
  
  final _titleController = TextEditingController();
  final _descriptionController = TextEditingController();
  final _priceController = TextEditingController();
  final _tagsController = TextEditingController();
  
  ServiceCategory _selectedCategory = ServiceCategory.other;

  @override
  void dispose() {
    _titleController.dispose();
    _descriptionController.dispose();
    _priceController.dispose();
    _tagsController.dispose();
    super.dispose();
  }

  Future<void> _create() async {
    if (_formKey.currentState!.validate()) {
      final user = _authStore.userProfile;
      if (user == null) {
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(content: Text('Ошибка: Пользователь не найден')),
        );
        return;
      }

      final tags = _tagsController.text.split(',').map((e) => e.trim()).where((e) => e.isNotEmpty).toList();

      final service = ServiceEntity(
        uid: DateTime.now().millisecondsSinceEpoch.toString(),
        title: _titleController.text,
        description: _descriptionController.text,
        price: double.tryParse(_priceController.text) ?? 0.0,
        currency: 'RUB', // Default
        type: 'service', // Default
        author: user,
        timesBooked: 0,
        rating: 0,
        reviews: [],
        tags: tags,
        created: DateTime.now(),
        updated: DateTime.now(),
        category: _selectedCategory,
        imageUrl: 'https://placehold.co/600x400', // Placeholder
      );

      await _serviceStore.createService(service);
      
      if (_serviceStore.errorMessage != null) {
        if (mounted) {
          ScaffoldMessenger.of(context).showSnackBar(
            SnackBar(content: Text(_serviceStore.errorMessage!)),
          );
        }
      } else {
        if (mounted) {
          context.pop();
        }
      }
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Создать услугу'),
      ),
      body: SingleChildScrollView(
        padding: const EdgeInsets.all(16),
        child: Form(
          key: _formKey,
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.stretch,
            children: [
              TextFormField(
                controller: _titleController,
                decoration: const InputDecoration(labelText: 'Название услуги'),
                validator: (v) => v?.isEmpty == true ? 'Введите название' : null,
              ),
              const SizedBox(height: 16),
              TextFormField(
                controller: _descriptionController,
                decoration: const InputDecoration(labelText: 'Описание'),
                maxLines: 3,
                validator: (v) => v?.isEmpty == true ? 'Введите описание' : null,
              ),
              const SizedBox(height: 16),
              TextFormField(
                controller: _priceController,
                decoration: const InputDecoration(labelText: 'Цена'),
                keyboardType: TextInputType.number,
                validator: (v) {
                  if (v == null || v.isEmpty) return 'Введите цену';
                  if (double.tryParse(v) == null) return 'Некорректная цена';
                  return null;
                },
              ),
              const SizedBox(height: 16),
              DropdownButtonFormField<ServiceCategory>(
                value: _selectedCategory,
                decoration: const InputDecoration(labelText: 'Категория'),
                items: ServiceCategory.values.map((c) {
                  return DropdownMenuItem(
                    value: c,
                    child: Text(c.name.toUpperCase()),
                  );
                }).toList(),
                onChanged: (v) {
                  if (v != null) setState(() => _selectedCategory = v);
                },
              ),
              const SizedBox(height: 16),
              TextFormField(
                controller: _tagsController,
                decoration: const InputDecoration(
                  labelText: 'Теги (через запятую)',
                  hintText: 'ремонт, быстро, качественно',
                ),
              ),
              const SizedBox(height: 32),
              Observer(
                builder: (_) => ElevatedButton(
                  onPressed: _serviceStore.isLoading ? null : _create,
                  style: ElevatedButton.styleFrom(
                    padding: const EdgeInsets.symmetric(vertical: 16),
                  ),
                  child: _serviceStore.isLoading
                      ? const SizedBox(
                          height: 20, 
                          width: 20, 
                          child: CircularProgressIndicator(strokeWidth: 2, color: Colors.white)
                        )
                      : const Text('Создать'),
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}
