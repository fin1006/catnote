import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../providers/settings_provider.dart';
import 'router.dart';
import 'theme.dart';

class CatNoteApp extends ConsumerWidget {
  const CatNoteApp({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final settings = ref.watch(settingsProvider);
    final router = ref.watch(routerProvider);

    return MaterialApp.router(
      title: 'CatNote',
      debugShowCheckedModeBanner: false,
      routerConfig: router,
      theme: buildLightTheme(fontScale: settings.fontScale),
      darkTheme: buildDarkTheme(fontScale: settings.fontScale),
      themeMode: settings.themeMode,
    );
  }
}
