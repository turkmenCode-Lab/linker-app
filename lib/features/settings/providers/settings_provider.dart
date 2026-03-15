import 'dart:ui';
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:flutter_riverpod/legacy.dart';
import 'package:shared_preferences/shared_preferences.dart';
import '../../../core/l10n/app_strings.dart';

const _kThemeKey = 'settings_theme_mode';
const _kLocaleKey = 'settings_locale';
const _kAutoCopyKey = 'settings_auto_copy';

class SettingsState {
  final ThemeMode themeMode;
  final AppLocale locale;
  final bool autoCopy;

  const SettingsState({
    this.themeMode = ThemeMode.system,
    this.locale = AppLocale.en,
    this.autoCopy = true,
  });

  SettingsState copyWith({
    ThemeMode? themeMode,
    AppLocale? locale,
    bool? autoCopy,
  }) {
    return SettingsState(
      themeMode: themeMode ?? this.themeMode,
      locale: locale ?? this.locale,
      autoCopy: autoCopy ?? this.autoCopy,
    );
  }
}

class SettingsNotifier extends StateNotifier<SettingsState> {
  final SharedPreferences _prefs;

  SettingsNotifier(this._prefs) : super(const SettingsState()) {
    _load();
  }

  void _load() {
    final themeIndex = _prefs.getInt(_kThemeKey);
    final localeCode = _prefs.getString(_kLocaleKey);

    final themeMode = themeIndex != null
        ? ThemeMode.values[themeIndex]
        : ThemeMode.system;

    final locale = localeCode != null
        ? AppLocale.values.firstWhere(
            (l) => l.name == localeCode,
            orElse: () => _deviceLocale(),
          )
        : _deviceLocale();

    final autoCopy = _prefs.getBool(_kAutoCopyKey) ?? true;
    state = SettingsState(
      themeMode: themeMode,
      locale: locale,
      autoCopy: autoCopy,
    );
  }

  AppLocale _deviceLocale() {
    final tag = PlatformDispatcher.instance.locale.languageCode;
    return switch (tag) {
      'ru' => AppLocale.ru,
      'en' => AppLocale.en,
      _ => AppLocale.tk,
    };
  }

  Future<void> setThemeMode(ThemeMode mode) async {
    await _prefs.setInt(_kThemeKey, mode.index);
    state = state.copyWith(themeMode: mode);
  }

  Future<void> setLocale(AppLocale locale) async {
    await _prefs.setString(_kLocaleKey, locale.name);
    state = state.copyWith(locale: locale);
  }

  Future<void> setAutoCopy(bool value) async {
    await _prefs.setBool(_kAutoCopyKey, value);
    state = state.copyWith(autoCopy: value);
  }
}

final sharedPreferencesProvider = Provider<SharedPreferences>((ref) {
  throw UnimplementedError('Initialize via ProviderScope overrides');
});

final settingsProvider = StateNotifierProvider<SettingsNotifier, SettingsState>(
  (ref) {
    final prefs = ref.watch(sharedPreferencesProvider);
    return SettingsNotifier(prefs);
  },
);

final stringsProvider = Provider<AppStrings>((ref) {
  final locale = ref.watch(settingsProvider.select((s) => s.locale));
  return AppStrings.of(locale);
});

final themeModeProvider = Provider<ThemeMode>((ref) {
  return ref.watch(settingsProvider.select((s) => s.themeMode));
});

final autoCopyProvider = Provider<bool>((ref) {
  return ref.watch(settingsProvider.select((s) => s.autoCopy));
});
