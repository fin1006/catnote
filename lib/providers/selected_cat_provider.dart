import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'cats_provider.dart';

class SelectedCatNotifier extends Notifier<String?> {
  String? _selectedId;

  @override
  String? build() {
    final cats = ref.watch(catsProvider);

    if (cats.isEmpty) {
      _selectedId = null;
      return null;
    }

    // ✅ 선택이 없거나, 존재하지 않는 id면 첫번째로 보정
    if (_selectedId == null || !cats.any((c) => c.id == _selectedId)) {
      _selectedId = cats.first.id;
    }

    return _selectedId;
  }

  void select(String catId) {
    _selectedId = catId;
    state = catId;
  }
}

final selectedCatIdProvider =
NotifierProvider<SelectedCatNotifier, String?>(SelectedCatNotifier.new);
