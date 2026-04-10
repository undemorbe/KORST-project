import 'package:flutter/material.dart';
import 'package:flutter_mobx/flutter_mobx.dart';
import 'package:get_it/get_it.dart';
import 'package:go_router/go_router.dart';
import '../../domain/entities/service_category.dart';
import '../../domain/entities/service_entity.dart';
import '../store/service_store.dart';
import '../../../auth/presentation/store/auth_store.dart';

class ServiceEditorPage extends StatefulWidget {
  final ServiceEntity? initialService;

  const ServiceEditorPage({
    super.key,
    this.initialService,
  });

  bool get isEditing => initialService != null;

  @override
  State<ServiceEditorPage> createState() => _ServiceEditorPageState();
}

class _ServiceEditorPageState extends State<ServiceEditorPage> {
  final ServiceStore _serviceStore = GetIt.I<ServiceStore>();
  final AuthStore _authStore = GetIt.I<AuthStore>();
  final _formKey = GlobalKey<FormState>();

  late TextEditingController _titleController;
  late TextEditingController _descriptionController;
  late TextEditingController _priceController;
  late TextEditingController _tagsController;
  late ServiceCategory _selectedCategory;

  @override
  void initState() {
    super.initState();
    final service = widget.initialService;
    _titleController = TextEditingController(text: service?.title ?? '');
    _descriptionController = TextEditingController(text: service?.description ?? '');
    _priceController = TextEditingController(
      text: service != null ? service.price.toStringAsFixed(0) : '',
    );
    _tagsController = TextEditingController(text: service?.tags.join(', ') ?? '');
    _selectedCategory = service?.category ?? ServiceCategory.other;
  }

  @override
  void dispose() {
    _titleController.dispose();
    _descriptionController.dispose();
    _priceController.dispose();
    _tagsController.dispose();
    super.dispose();
  }

  Future<void> _save() async {
    if (!_formKey.currentState!.validate()) return;
    final user = _authStore.userProfile;
    if (user == null) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('Ошибка: пользователь не найден')),
      );
      return;
    }

    final tags = _tagsController.text
        .split(',')
        .map((e) => e.trim())
        .where((e) => e.isNotEmpty)
        .toList();

    final base = widget.initialService;
    final now = DateTime.now();
    final service = ServiceEntity(
      uid: base?.uid ?? now.millisecondsSinceEpoch.toString(),
      title: _titleController.text.trim(),
      description: _descriptionController.text.trim(),
      price: double.tryParse(_priceController.text.replaceAll(',', '.')) ?? 0,
      currency: base?.currency ?? 'USD',
      type: base?.type ?? 'услуга',
      author: base?.author ?? user,
      timesBooked: base?.timesBooked ?? 0,
      rating: base?.rating ?? 0,
      reviews: base?.reviews ?? const [],
      tags: tags,
      created: base?.created ?? now,
      updated: now,
      category: _selectedCategory,
      imageUrl: base?.imageUrl ?? 'https://placehold.co/600x400',
    );

    if (widget.isEditing) {
      await _serviceStore.updateService(service);
    } else {
      await _serviceStore.createService(service);
    }

    if (!mounted) return;
    if (_serviceStore.errorMessage != null) {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text(_serviceStore.errorMessage!)),
      );
      return;
    }
    context.pop();
  }

  @override
  Widget build(BuildContext context) {
    final title = widget.isEditing ? 'Редактирование карточки' : 'Новая карточка';
    final buttonText = widget.isEditing ? 'Обновить карточку' : 'Создать карточку';

    return Scaffold(
      appBar: AppBar(
        title: Text(title),
      ),
      body: SingleChildScrollView(
        padding: const EdgeInsets.all(16),
        child: Form(
          key: _formKey,
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.stretch,
            children: [
              Card(
                child: Padding(
                  padding: const EdgeInsets.all(16),
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text('Карточка услуги', style: Theme.of(context).textTheme.titleMedium),
                      const SizedBox(height: 12),
                      TextFormField(
                        controller: _titleController,
                        decoration: const InputDecoration(labelText: 'Название'),
                        validator: (v) => v == null || v.trim().isEmpty ? 'Введите название' : null,
                      ),
                      const SizedBox(height: 12),
                      TextFormField(
                        controller: _descriptionController,
                        decoration: const InputDecoration(labelText: 'Описание'),
                        maxLines: 3,
                      ),
                    ],
                  ),
                ),
              ),
              const SizedBox(height: 12),
              Card(
                child: Padding(
                  padding: const EdgeInsets.all(16),
                  child: Column(
                    children: [
                      TextFormField(
                        controller: _priceController,
                        decoration: const InputDecoration(labelText: 'Цена'),
                        keyboardType: const TextInputType.numberWithOptions(decimal: true),
                        validator: (v) {
                          if (v == null || v.trim().isEmpty) return 'Введите цену';
                          final parsed = double.tryParse(v.replaceAll(',', '.'));
                          if (parsed == null) return 'Некорректная цена';
                          return null;
                        },
                      ),
                      const SizedBox(height: 12),
                      DropdownButtonFormField<ServiceCategory>(
                        initialValue: _selectedCategory,
                        decoration: const InputDecoration(labelText: 'Категория'),
                        items: ServiceCategory.values
                            .map(
                              (c) => DropdownMenuItem(
                                value: c,
                                child: Text(c.name.toUpperCase()),
                              ),
                            )
                            .toList(),
                        onChanged: (v) {
                          if (v != null) {
                            setState(() {
                              _selectedCategory = v;
                            });
                          }
                        },
                      ),
                      const SizedBox(height: 12),
                      TextFormField(
                        controller: _tagsController,
                        decoration: const InputDecoration(
                          labelText: 'Теги',
                          hintText: 'ремонт, быстро, срочно',
                        ),
                      ),
                    ],
                  ),
                ),
              ),
              const SizedBox(height: 20),
              Observer(
                builder: (_) => ElevatedButton(
                  onPressed: _serviceStore.isLoading ? null : _save,
                  style: ElevatedButton.styleFrom(
                    padding: const EdgeInsets.symmetric(vertical: 16),
                  ),
                  child: _serviceStore.isLoading
                      ? const SizedBox(
                          height: 20,
                          width: 20,
                          child: CircularProgressIndicator(strokeWidth: 2, color: Colors.white),
                        )
                      : Text(buttonText),
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}
