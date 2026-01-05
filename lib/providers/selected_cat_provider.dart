import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'cats_provider.dart';

class SelectedCatNotifier extends Notifier<String?> {
  @override
  String? build() {
    final cats = ref.watch(catsProvider);
    return cats.isNotEmpty ? cats.first.id : null;
  }

  void select(String catId) => state = catId;
}

final selectedCatIdProvider =
NotifierProvider<SelectedCatNotifier, String?>(SelectedCatNotifier.new);
