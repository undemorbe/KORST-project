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

  late final _$isLoadingMoreAtom =
      Atom(name: '_ServiceStore.isLoadingMore', context: context);

  @override
  bool get isLoadingMore {
    _$isLoadingMoreAtom.reportRead();
    return super.isLoadingMore;
  }

  @override
  set isLoadingMore(bool value) {
    _$isLoadingMoreAtom.reportWrite(value, super.isLoadingMore, () {
      super.isLoadingMore = value;
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

  late final _$replyErrorAtom =
      Atom(name: '_ServiceStore.replyError', context: context);

  @override
  String? get replyError {
    _$replyErrorAtom.reportRead();
    return super.replyError;
  }

  @override
  set replyError(String? value) {
    _$replyErrorAtom.reportWrite(value, super.replyError, () {
      super.replyError = value;
    });
  }

  late final _$executorsAtom =
      Atom(name: '_ServiceStore.executors', context: context);

  @override
  ObservableList<ExecutorEntity> get executors {
    _$executorsAtom.reportRead();
    return super.executors;
  }

  @override
  set executors(ObservableList<ExecutorEntity> value) {
    _$executorsAtom.reportWrite(value, super.executors, () {
      super.executors = value;
    });
  }

  late final _$isLoadingExecutorsAtom =
      Atom(name: '_ServiceStore.isLoadingExecutors', context: context);

  @override
  bool get isLoadingExecutors {
    _$isLoadingExecutorsAtom.reportRead();
    return super.isLoadingExecutors;
  }

  @override
  set isLoadingExecutors(bool value) {
    _$isLoadingExecutorsAtom.reportWrite(value, super.isLoadingExecutors, () {
      super.isLoadingExecutors = value;
    });
  }

  late final _$executorsErrorAtom =
      Atom(name: '_ServiceStore.executorsError', context: context);

  @override
  String? get executorsError {
    _$executorsErrorAtom.reportRead();
    return super.executorsError;
  }

  @override
  set executorsError(String? value) {
    _$executorsErrorAtom.reportWrite(value, super.executorsError, () {
      super.executorsError = value;
    });
  }

  late final _$repliedCardIdsAtom =
      Atom(name: '_ServiceStore.repliedCardIds', context: context);

  @override
  ObservableSet<String> get repliedCardIds {
    _$repliedCardIdsAtom.reportRead();
    return super.repliedCardIds;
  }

  @override
  set repliedCardIds(ObservableSet<String> value) {
    _$repliedCardIdsAtom.reportWrite(value, super.repliedCardIds, () {
      super.repliedCardIds = value;
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

  late final _$nextKeyAtom =
      Atom(name: '_ServiceStore.nextKey', context: context);

  @override
  String? get nextKey {
    _$nextKeyAtom.reportRead();
    return super.nextKey;
  }

  @override
  set nextKey(String? value) {
    _$nextKeyAtom.reportWrite(value, super.nextKey, () {
      super.nextKey = value;
    });
  }

  late final _$hasMoreAtom =
      Atom(name: '_ServiceStore.hasMore', context: context);

  @override
  bool get hasMore {
    _$hasMoreAtom.reportRead();
    return super.hasMore;
  }

  @override
  set hasMore(bool value) {
    _$hasMoreAtom.reportWrite(value, super.hasMore, () {
      super.hasMore = value;
    });
  }

  late final _$minPriceAtom =
      Atom(name: '_ServiceStore.minPrice', context: context);

  @override
  double? get minPrice {
    _$minPriceAtom.reportRead();
    return super.minPrice;
  }

  @override
  set minPrice(double? value) {
    _$minPriceAtom.reportWrite(value, super.minPrice, () {
      super.minPrice = value;
    });
  }

  late final _$maxPriceAtom =
      Atom(name: '_ServiceStore.maxPrice', context: context);

  @override
  double? get maxPrice {
    _$maxPriceAtom.reportRead();
    return super.maxPrice;
  }

  @override
  set maxPrice(double? value) {
    _$maxPriceAtom.reportWrite(value, super.maxPrice, () {
      super.maxPrice = value;
    });
  }

  late final _$minRatingAtom =
      Atom(name: '_ServiceStore.minRating', context: context);

  @override
  double? get minRating {
    _$minRatingAtom.reportRead();
    return super.minRating;
  }

  @override
  set minRating(double? value) {
    _$minRatingAtom.reportWrite(value, super.minRating, () {
      super.minRating = value;
    });
  }

  late final _$sortByAtom =
      Atom(name: '_ServiceStore.sortBy', context: context);

  @override
  SortOption get sortBy {
    _$sortByAtom.reportRead();
    return super.sortBy;
  }

  @override
  set sortBy(SortOption value) {
    _$sortByAtom.reportWrite(value, super.sortBy, () {
      super.sortBy = value;
    });
  }

  late final _$loadServicesAsyncAction =
      AsyncAction('_ServiceStore.loadServices', context: context);

  @override
  Future<void> loadServices() {
    return _$loadServicesAsyncAction.run(() => super.loadServices());
  }

  late final _$loadMoreServicesAsyncAction =
      AsyncAction('_ServiceStore.loadMoreServices', context: context);

  @override
  Future<void> loadMoreServices() {
    return _$loadMoreServicesAsyncAction.run(() => super.loadMoreServices());
  }

  late final _$createServiceAsyncAction =
      AsyncAction('_ServiceStore.createService', context: context);

  @override
  Future<String?> createService(ServiceEntity service) {
    return _$createServiceAsyncAction.run(() => super.createService(service));
  }

  late final _$uploadCardImageAsyncAction =
      AsyncAction('_ServiceStore.uploadCardImage', context: context);

  @override
  Future<void> uploadCardImage(String cardId, String filePath) {
    return _$uploadCardImageAsyncAction
        .run(() => super.uploadCardImage(cardId, filePath));
  }

  late final _$updateServiceAsyncAction =
      AsyncAction('_ServiceStore.updateService', context: context);

  @override
  Future<void> updateService(ServiceEntity service) {
    return _$updateServiceAsyncAction.run(() => super.updateService(service));
  }

  late final _$addReviewAsyncAction =
      AsyncAction('_ServiceStore.addReview', context: context);

  @override
  Future<void> addReview(String serviceId, ReviewEntity review) {
    return _$addReviewAsyncAction.run(() => super.addReview(serviceId, review));
  }

  late final _$createReplyAsyncAction =
      AsyncAction('_ServiceStore.createReply', context: context);

  @override
  Future<void> createReply(String cardId) {
    return _$createReplyAsyncAction.run(() => super.createReply(cardId));
  }

  late final _$approveExecutorAsyncAction =
      AsyncAction('_ServiceStore.approveExecutor', context: context);

  @override
  Future<void> approveExecutor(
      {required String cardId, required String executorId}) {
    return _$approveExecutorAsyncAction.run(
        () => super.approveExecutor(cardId: cardId, executorId: executorId));
  }

  late final _$rejectExecutorAsyncAction =
      AsyncAction('_ServiceStore.rejectExecutor', context: context);

  @override
  Future<void> rejectExecutor(
      {required String cardId, required String executorId}) {
    return _$rejectExecutorAsyncAction.run(
        () => super.rejectExecutor(cardId: cardId, executorId: executorId));
  }

  late final _$closeCardAsyncAction =
      AsyncAction('_ServiceStore.closeCard', context: context);

  @override
  Future<void> closeCard({required String cardId, required String status}) {
    return _$closeCardAsyncAction
        .run(() => super.closeCard(cardId: cardId, status: status));
  }

  late final _$loadServiceDetailsAsyncAction =
      AsyncAction('_ServiceStore.loadServiceDetails', context: context);

  @override
  Future<void> loadServiceDetails(String id) {
    return _$loadServiceDetailsAsyncAction
        .run(() => super.loadServiceDetails(id));
  }

  late final _$loadExecutorsAsyncAction =
      AsyncAction('_ServiceStore.loadExecutors', context: context);

  @override
  Future<void> loadExecutors(String cardId) {
    return _$loadExecutorsAsyncAction.run(() => super.loadExecutors(cardId));
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
  void setFilters(
      {double? minPrice,
      double? maxPrice,
      double? minRating,
      SortOption? sortBy}) {
    final _$actionInfo = _$_ServiceStoreActionController.startAction(
        name: '_ServiceStore.setFilters');
    try {
      return super.setFilters(
          minPrice: minPrice,
          maxPrice: maxPrice,
          minRating: minRating,
          sortBy: sortBy);
    } finally {
      _$_ServiceStoreActionController.endAction(_$actionInfo);
    }
  }

  @override
  String toString() {
    return '''
services: ${services},
isLoading: ${isLoading},
isLoadingMore: ${isLoadingMore},
errorMessage: ${errorMessage},
replyError: ${replyError},
executors: ${executors},
isLoadingExecutors: ${isLoadingExecutors},
executorsError: ${executorsError},
repliedCardIds: ${repliedCardIds},
searchQuery: ${searchQuery},
selectedCategory: ${selectedCategory},
nextKey: ${nextKey},
hasMore: ${hasMore},
minPrice: ${minPrice},
maxPrice: ${maxPrice},
minRating: ${minRating},
sortBy: ${sortBy},
filteredServices: ${filteredServices}
    ''';
  }
}
