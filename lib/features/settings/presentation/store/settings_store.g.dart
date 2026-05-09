// GENERATED CODE - DO NOT MODIFY BY HAND

part of 'settings_store.dart';

// **************************************************************************
// StoreGenerator
// **************************************************************************

// ignore_for_file: non_constant_identifier_names, unnecessary_brace_in_string_interps, unnecessary_lambdas, prefer_expression_function_bodies, lines_longer_than_80_chars, avoid_as, avoid_annotating_with_dynamic, no_leading_underscores_for_local_identifiers

mixin _$SettingsStore on _SettingsStore, Store {
  late final _$themeModeAtom =
      Atom(name: '_SettingsStore.themeMode', context: context);

  @override
  ThemeMode get themeMode {
    _$themeModeAtom.reportRead();
    return super.themeMode;
  }

  @override
  set themeMode(ThemeMode value) {
    _$themeModeAtom.reportWrite(value, super.themeMode, () {
      super.themeMode = value;
    });
  }

  late final _$localeAtom =
      Atom(name: '_SettingsStore.locale', context: context);

  @override
  Locale get locale {
    _$localeAtom.reportRead();
    return super.locale;
  }

  @override
  set locale(Locale value) {
    _$localeAtom.reportWrite(value, super.locale, () {
      super.locale = value;
    });
  }

  late final _$useSystemLocaleAtom =
      Atom(name: '_SettingsStore.useSystemLocale', context: context);

  @override
  bool get useSystemLocale {
    _$useSystemLocaleAtom.reportRead();
    return super.useSystemLocale;
  }

  @override
  set useSystemLocale(bool value) {
    _$useSystemLocaleAtom.reportWrite(value, super.useSystemLocale, () {
      super.useSystemLocale = value;
    });
  }

  late final _$_SettingsStoreActionController =
      ActionController(name: '_SettingsStore', context: context);

  @override
  void setThemeMode(ThemeMode mode) {
    final _$actionInfo = _$_SettingsStoreActionController.startAction(
        name: '_SettingsStore.setThemeMode');
    try {
      return super.setThemeMode(mode);
    } finally {
      _$_SettingsStoreActionController.endAction(_$actionInfo);
    }
  }

  @override
  void setLocale(Locale newLocale) {
    final _$actionInfo = _$_SettingsStoreActionController.startAction(
        name: '_SettingsStore.setLocale');
    try {
      return super.setLocale(newLocale);
    } finally {
      _$_SettingsStoreActionController.endAction(_$actionInfo);
    }
  }

  @override
  void setSystemLocale() {
    final _$actionInfo = _$_SettingsStoreActionController.startAction(
        name: '_SettingsStore.setSystemLocale');
    try {
      return super.setSystemLocale();
    } finally {
      _$_SettingsStoreActionController.endAction(_$actionInfo);
    }
  }

  @override
  String toString() {
    return '''
themeMode: ${themeMode},
locale: ${locale},
useSystemLocale: ${useSystemLocale}
    ''';
  }
}
