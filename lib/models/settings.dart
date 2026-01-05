import 'package:flutter/material.dart';

class AppSettings {
  final ThemeMode themeMode;
  final double fontScale;

  const AppSettings({
    required this.themeMode,
    required this.fontScale,
  });

  AppSettings copyWith({ThemeMode? themeMode, double? fontScale}) {
    return AppSettings(
      themeMode: themeMode ?? this.themeMode,
      fontScale: fontScale ?? this.fontScale,
    );
  }
}
