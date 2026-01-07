import 'package:flutter/material.dart';

ThemeData buildLightTheme({required double fontScale}) {
  final base = ThemeData(
    useMaterial3: true,
    colorSchemeSeed: Colors.teal,
  );
  return base.copyWith(
    appBarTheme: const AppBarTheme(
      centerTitle: true,
    ),
    textTheme: base.textTheme.apply(fontSizeFactor: fontScale),
  );
}

ThemeData buildDarkTheme({required double fontScale}) {
  final base = ThemeData(
    useMaterial3: true,
    brightness: Brightness.dark,
    colorSchemeSeed: Colors.teal,
  );
  return base.copyWith(
    appBarTheme: const AppBarTheme(
      centerTitle: true,
    ),
    textTheme: base.textTheme.apply(fontSizeFactor: fontScale),
  );
}
