import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';

import '../features/home/home_screen.dart';
import '../features/settings/settings_screen.dart';
import '../features/action_settings/action_settings_screen.dart';
import '../features/action_settings/action_add_screen.dart';
import '../features/cat/cat_edit_screen.dart';
import '../features/cat/cat_settings_screen.dart';
import '../features/entry/entry_create_screen.dart';
import '../features/entry/entry_detail_screen.dart';

final routerProvider = Provider<GoRouter>((ref) {
  return GoRouter(
    initialLocation: '/',
    routes: [
      GoRoute(path: '/', builder: (_, __) => const HomeScreen()),
      GoRoute(path: '/settings', builder: (_, __) => const SettingsScreen()),

      GoRoute(path: '/cats/new', builder: (_, __) => const CatEditScreen(isNew: true)),
      GoRoute(
        path: '/cats/settings',
        builder: (_, __) => const CatSettingsScreen(),
      ),
      GoRoute(
        path: '/cats/:id/edit',
        builder: (_, state) => CatEditScreen(isNew: false, catId: state.pathParameters['id']!),
      ),

      GoRoute(
        path: '/actions/settings',
        builder: (_, __) => const ActionSettingsScreen(),
      ),
      GoRoute(
        path: '/actions/add',
        builder: (_, __) => const ActionAddScreen(),
      ),

      GoRoute(
        path: '/entries/new',
        builder: (_, state) => EntryCreateScreen(
          catId: state.uri.queryParameters['catId'],
          type: state.uri.queryParameters['type'],
        ),
      ),

      GoRoute(
        path: '/entries/:id',
        builder: (_, state) => EntryDetailScreen(entryId: state.pathParameters['id']!),
      ),
    ],
  );
});
