import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../models/settings.dart';

class SettingsNotifier extends Notifier<AppSettings> {
  @override
  AppSettings build() => const AppSettings(themeMode: ThemeMode.system, fontScale: 1.0);

  void setThemeMode(ThemeMode mode) => state = state.copyWith(themeMode: mode);
  void setFontScale(double scale) => state = state.copyWith(fontScale: scale);
}

final settingsProvider = NotifierProvider<SettingsNotifier, AppSettings>(SettingsNotifier.new);
