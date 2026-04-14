import 'package:flutter/material.dart';
import '../store/service_store.dart';
import '../../../../core/di/injection_container.dart';

class FilterBottomSheet extends StatefulWidget {
  const FilterBottomSheet({super.key});

  @override
  State<FilterBottomSheet> createState() => _FilterBottomSheetState();
}

class _FilterBottomSheetState extends State<FilterBottomSheet> {
  final ServiceStore _store = sl<ServiceStore>();
  
  late double? _minPrice;
  late double? _maxPrice;
  late double? _minRating;
  late SortOption _sortBy;

  late TextEditingController _minPriceController;
  late TextEditingController _maxPriceController;

  @override
  void initState() {
    super.initState();
    _minPrice = _store.minPrice;
    _maxPrice = _store.maxPrice;
    _minRating = _store.minRating;
    _sortBy = _store.sortBy;

    _minPriceController = TextEditingController(text: _minPrice?.toString() ?? '');
    _maxPriceController = TextEditingController(text: _maxPrice?.toString() ?? '');
  }

  @override
  void dispose() {
    _minPriceController.dispose();
    _maxPriceController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);

    return Container(
      padding: EdgeInsets.only(
        left: 24,
        right: 24,
        top: 24,
        bottom: MediaQuery.of(context).padding.bottom + 24,
      ),
      child: Column(
        mainAxisSize: MainAxisSize.min,
        crossAxisAlignment: CrossAxisAlignment.stretch,
        children: [
          Text(
            'Filters & Sort',
            style: theme.textTheme.titleLarge?.copyWith(fontWeight: FontWeight.bold),
          ),
          const SizedBox(height: 24),
          
          Text('Price Range', style: theme.textTheme.titleMedium),
          Row(
            children: [
              Expanded(
                child: TextField(
                  keyboardType: TextInputType.number,
                  decoration: const InputDecoration(labelText: 'Min'),
                  onChanged: (val) => _minPrice = double.tryParse(val),
                  controller: _minPriceController,
                ),
              ),
              const SizedBox(width: 16),
              Expanded(
                child: TextField(
                  keyboardType: TextInputType.number,
                  decoration: const InputDecoration(labelText: 'Max'),
                  onChanged: (val) => _maxPrice = double.tryParse(val),
                  controller: _maxPriceController,
                ),
              ),
            ],
          ),
          const SizedBox(height: 24),
          
          Text('Minimum Rating', style: theme.textTheme.titleMedium),
          Slider(
            value: _minRating ?? 0.0,
            min: 0.0,
            max: 5.0,
            divisions: 5,
            label: _minRating?.toString() ?? 'Any',
            onChanged: (val) {
              setState(() {
                _minRating = val == 0.0 ? null : val;
              });
            },
          ),
          const SizedBox(height: 24),
          
          Text('Sort By', style: theme.textTheme.titleMedium),
          DropdownButton<SortOption>(
            value: _sortBy,
            isExpanded: true,
            items: const [
              DropdownMenuItem(value: SortOption.newest, child: Text('Newest')),
              DropdownMenuItem(value: SortOption.priceAsc, child: Text('Price: Low to High')),
              DropdownMenuItem(value: SortOption.priceDesc, child: Text('Price: High to Low')),
              DropdownMenuItem(value: SortOption.rating, child: Text('Highest Rating')),
            ],
            onChanged: (val) {
              if (val != null) {
                setState(() {
                  _sortBy = val;
                });
              }
            },
          ),
          
          const SizedBox(height: 32),
          ElevatedButton(
            onPressed: () {
              _store.setFilters(
                minPrice: _minPrice,
                maxPrice: _maxPrice,
                minRating: _minRating,
                sortBy: _sortBy,
              );
              Navigator.pop(context);
            },
            child: const Text('Apply'),
          ),
        ],
      ),
    );
  }
}
