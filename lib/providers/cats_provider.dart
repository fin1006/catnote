import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:uuid/uuid.dart';
import '../models/cat_profile.dart';

class CatsNotifier extends Notifier<List<CatProfile>> {
  @override
  List<CatProfile> build() {
    return const [
      CatProfile(id: 'cat_1', name: '냥이', sex: 'F', breed: '코리안숏헤어'),
      CatProfile(id: 'cat_2', name: '호두', sex: 'M', breed: '러시안블루'),
    ];
  }

  void upsert(CatProfile cat) {
    final idx = state.indexWhere((c) => c.id == cat.id);
    if (idx < 0) {
      state = [...state, cat];
    } else {
      final next = [...state];
      next[idx] = cat;
      state = next;
    }
  }

  void addNew(String name) {
    final id = const Uuid().v4();
    state = [...state, CatProfile(id: id, name: name)];
  }

  void removeById(String id) {
    state = state.where((c) => c.id != id).toList(growable: false);
  }
}

final catsProvider = NotifierProvider<CatsNotifier, List<CatProfile>>(CatsNotifier.new);
