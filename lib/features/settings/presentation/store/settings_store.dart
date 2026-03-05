import 'package:flutter/material.dart';
import 'package:mobx/mobx.dart';

part 'settings_store.g.dart';

class SettingsStore = _SettingsStore with _$SettingsStore;

abstract class _SettingsStore with Store {
  @observable
  ThemeMode themeMode = ThemeMode.system;

  @observable
  Locale locale = const Locale('en');

  @action
  void setThemeMode(ThemeMode mode) {
    themeMode = mode;
  }

  @action
  void setLocale(Locale newLocale) {
    locale = newLocale;
  }
}
