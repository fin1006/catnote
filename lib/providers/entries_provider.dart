import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../models/entry.dart';

class EntriesNotifier extends Notifier<List<Entry>> {
  @override
  List<Entry> build() {
    final now = DateTime.now();

    return [
      Entry(
        id: 'e01',
        catId: 'cat_1',
        type: EntryType.food,
        at: now.subtract(const Duration(minutes: 20)),
        data: {'amount_g': 35, 'kind': '건식'},
      ),
      Entry(
        id: 'e02',
        catId: 'cat_1',
        type: EntryType.water,
        at: now.subtract(const Duration(minutes: 45)),
        data: {'amount_ml': 60},
        memo: '정수기 교체',
      ),
      Entry(
        id: 'e03',
        catId: 'cat_1',
        type: EntryType.litter,
        at: now.subtract(const Duration(hours: 1, minutes: 10)),
        data: {'kind': '소변', 'status': '정상'},
      ),
      Entry(
        id: 'e04',
        catId: 'cat_1',
        type: EntryType.snack,
        at: now.subtract(const Duration(hours: 2)),
        data: {'name': '츄르', 'amount': '1개'},
      ),
      Entry(
        id: 'e05',
        catId: 'cat_1',
        type: EntryType.food,
        at: now.subtract(const Duration(hours: 3)),
        data: {'amount_g': 30, 'kind': '습식'},
      ),
      Entry(
        id: 'e06',
        catId: 'cat_1',
        type: EntryType.litter,
        at: now.subtract(const Duration(hours: 4)),
        data: {'kind': '대변', 'status': '정상'},
      ),
      Entry(
        id: 'e07',
        catId: 'cat_1',
        type: EntryType.water,
        at: now.subtract(const Duration(hours: 5)),
        data: {'amount_ml': 50},
      ),
      Entry(
        id: 'e08',
        catId: 'cat_1',
        type: EntryType.medicine,
        at: now.subtract(const Duration(hours: 6)),
        data: {'name': '신장약', 'dose': '1정', 'taken': true},
      ),
      Entry(
        id: 'e09',
        catId: 'cat_1',
        type: EntryType.food,
        at: now.subtract(const Duration(hours: 7)),
        data: {'amount_g': 40, 'kind': '건식'},
      ),
      Entry(
        id: 'e10',
        catId: 'cat_1',
        type: EntryType.litter,
        at: now.subtract(const Duration(hours: 8)),
        data: {'kind': '소변', 'status': '정상'},
      ),
      Entry(
        id: 'e11',
        catId: 'cat_1',
        type: EntryType.water,
        at: now.subtract(const Duration(hours: 9)),
        data: {'amount_ml': 70},
      ),
      Entry(
        id: 'e12',
        catId: 'cat_1',
        type: EntryType.hospital,
        at: now.subtract(const Duration(days: 1, hours: 2)),
        data: {'name': '동물병원', 'cost': 45000},
        memo: '정기검진',
      ),
    ]..sort((a, b) => b.at.compareTo(a.at));
  }

  void add(Entry entry) {
    state = [entry, ...state]..sort((a, b) => b.at.compareTo(a.at));
  }

  void update(String entryId, Entry next) {
    state = [
      for (final e in state) if (e.id == entryId) next else e,
    ]..sort((a, b) => b.at.compareTo(a.at));
  }

  void remove(String entryId) {
    state = state.where((e) => e.id != entryId).toList(growable: false);
  }

  Entry? byId(String entryId) {
    for (final e in state) {
      if (e.id == entryId) return e;
    }
    return null;
  }
}

final entriesProvider =
NotifierProvider<EntriesNotifier, List<Entry>>(EntriesNotifier.new);
