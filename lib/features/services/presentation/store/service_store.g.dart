// GENERATED CODE - DO NOT MODIFY BY HAND

part of 'service_store.dart';

// **************************************************************************
// StoreGenerator
// **************************************************************************

// ignore_for_file: non_constant_identifier_names, unnecessary_brace_in_string_interps, unnecessary_lambdas, prefer_expression_function_bodies, lines_longer_than_80_chars, avoid_as, avoid_annotating_with_dynamic, no_leading_underscores_for_local_identifiers

mixin _$ServiceStore on _ServiceStore, Store {
  Computed<List<ServiceEntity>>? _$filteredServicesComputed;

  @override
  List<ServiceEntity> get filteredServices => (_$filteredServicesComputed ??=
          Computed<List<ServiceEntity>>(() => super.filteredServices,
              name: '_ServiceStore.filteredServices'))
      .value;

  late final _$servicesAtom =
      Atom(name: '_ServiceStore.services', context: context);

  @override
  ObservableList<ServiceEntity> get services {
    _$servicesAtom.reportRead();
    return super.services;
  }

  @override
  set services(ObservableList<ServiceEntity> value) {
    _$servicesAtom.reportWrite(value, super.services, () {
      super.services = value;
    });
  }

  late final _$isLoadingAtom =
      Atom(name: '_ServiceStore.isLoading', context: context);

  @override
  bool get isLoading {
    _$isLoadingAtom.reportRead();
    return super.isLoading;
  }

  @override
  set isLoading(bool value) {
    _$isLoadingAtom.reportWrite(value, super.isLoading, () {
      super.isLoading = value;
    });
  }

  late final _$errorMessageAtom =
      Atom(name: '_ServiceStore.errorMessage', context: context);

  @override
  String? get errorMessage {
    _$errorMessageAtom.reportRead();
    return super.errorMessage;
  }

  @override
  set errorMessage(String? value) {
    _$errorMessageAtom.reportWrite(value, super.errorMessage, () {
      super.errorMessage = value;
    });
  }

  late final _$searchQueryAtom =
      Atom(name: '_ServiceStore.searchQuery', context: context);

  @override
  String get searchQuery {
    _$searchQueryAtom.reportRead();
    return super.searchQuery;
  }

  @override
  set searchQuery(String value) {
    _$searchQueryAtom.reportWrite(value, super.searchQuery, () {
      super.searchQuery = value;
    });
  }

  late final _$selectedCategoryAtom =
      Atom(name: '_ServiceStore.selectedCategory', context: context);

  @override
  ServiceCategory? get selectedCategory {
    _$selectedCategoryAtom.reportRead();
    return super.selectedCategory;
  }

  @override
  set selectedCategory(ServiceCategory? value) {
    _$selectedCategoryAtom.reportWrite(value, super.selectedCategory, () {
      super.selectedCategory = value;
    });
  }

  late final _$loadServicesAsyncAction =
      AsyncAction('_ServiceStore.loadServices', context: context);

  @override
  Future<void> loadServices() {
    return _$loadServicesAsyncAction.run(() => super.loadServices());
  }

  late final _$_ServiceStoreActionController =
      ActionController(name: '_ServiceStore', context: context);

  @override
  void setSearchQuery(String query) {
    final _$actionInfo = _$_ServiceStoreActionController.startAction(
        name: '_ServiceStore.setSearchQuery');
    try {
      return super.setSearchQuery(query);
    } finally {
      _$_ServiceStoreActionController.endAction(_$actionInfo);
    }
  }

  @override
  void setCategory(ServiceCategory? category) {
    final _$actionInfo = _$_ServiceStoreActionController.startAction(
        name: '_ServiceStore.setCategory');
    try {
      return super.setCategory(category);
    } finally {
      _$_ServiceStoreActionController.endAction(_$actionInfo);
    }
  }

  @override
  String toString() {
    return '''
services: ${services},
isLoading: ${isLoading},
errorMessage: ${errorMessage},
searchQuery: ${searchQuery},
selectedCategory: ${selectedCategory},
filteredServices: ${filteredServices}
    ''';
  }
}
