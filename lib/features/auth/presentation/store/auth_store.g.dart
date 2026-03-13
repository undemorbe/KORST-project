// GENERATED CODE - DO NOT MODIFY BY HAND

part of 'auth_store.dart';

// **************************************************************************
// StoreGenerator
// **************************************************************************

// ignore_for_file: non_constant_identifier_names, unnecessary_brace_in_string_interps, unnecessary_lambdas, prefer_expression_function_bodies, lines_longer_than_80_chars, avoid_as, avoid_annotating_with_dynamic, no_leading_underscores_for_local_identifiers

mixin _$AuthStore on _AuthStore, Store {
  late final _$isLoadingAtom =
      Atom(name: '_AuthStore.isLoading', context: context);

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

  late final _$isLoggedInAtom =
      Atom(name: '_AuthStore.isLoggedIn', context: context);

  @override
  bool get isLoggedIn {
    _$isLoggedInAtom.reportRead();
    return super.isLoggedIn;
  }

  @override
  set isLoggedIn(bool value) {
    _$isLoggedInAtom.reportWrite(value, super.isLoggedIn, () {
      super.isLoggedIn = value;
    });
  }

  late final _$userProfileAtom =
      Atom(name: '_AuthStore.userProfile', context: context);

  @override
  UserEntity? get userProfile {
    _$userProfileAtom.reportRead();
    return super.userProfile;
  }

  @override
  set userProfile(UserEntity? value) {
    _$userProfileAtom.reportWrite(value, super.userProfile, () {
      super.userProfile = value;
    });
  }

  late final _$errorMessageAtom =
      Atom(name: '_AuthStore.errorMessage', context: context);

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

  late final _$phoneNumberAtom =
      Atom(name: '_AuthStore.phoneNumber', context: context);

  @override
  String? get phoneNumber {
    _$phoneNumberAtom.reportRead();
    return super.phoneNumber;
  }

  @override
  set phoneNumber(String? value) {
    _$phoneNumberAtom.reportWrite(value, super.phoneNumber, () {
      super.phoneNumber = value;
    });
  }

  late final _$checkLoginStatusAsyncAction =
      AsyncAction('_AuthStore.checkLoginStatus', context: context);

  @override
  Future<void> checkLoginStatus() {
    return _$checkLoginStatusAsyncAction.run(() => super.checkLoginStatus());
  }

  late final _$sendOtpAsyncAction =
      AsyncAction('_AuthStore.sendOtp', context: context);

  @override
  Future<void> sendOtp(String phone) {
    return _$sendOtpAsyncAction.run(() => super.sendOtp(phone));
  }

  late final _$verifyOtpAsyncAction =
      AsyncAction('_AuthStore.verifyOtp', context: context);

  @override
  Future<bool> verifyOtp(String code) {
    return _$verifyOtpAsyncAction.run(() => super.verifyOtp(code));
  }

  late final _$registerAsyncAction =
      AsyncAction('_AuthStore.register', context: context);

  @override
  Future<void> register(String name, String? photoUrl, String contacts) {
    return _$registerAsyncAction
        .run(() => super.register(name, photoUrl, contacts));
  }

  late final _$updateProfileAsyncAction =
      AsyncAction('_AuthStore.updateProfile', context: context);

  @override
  Future<void> updateProfile(UserEntity user) {
    return _$updateProfileAsyncAction.run(() => super.updateProfile(user));
  }

  late final _$logoutAsyncAction =
      AsyncAction('_AuthStore.logout', context: context);

  @override
  Future<void> logout() {
    return _$logoutAsyncAction.run(() => super.logout());
  }

  @override
  String toString() {
    return '''
isLoading: ${isLoading},
isLoggedIn: ${isLoggedIn},
userProfile: ${userProfile},
errorMessage: ${errorMessage},
phoneNumber: ${phoneNumber}
    ''';
  }
}
