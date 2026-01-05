import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../models/entry.dart';
import 'entries_provider.dart';
import 'selected_cat_provider.dart';

final selectedCatEntriesProvider = Provider<List<Entry>>((ref) {
  final catId = ref.watch(selectedCatIdProvider);
  final entries = ref.watch(entriesProvider);
  if (catId == null) return const [];
  return entries.where((e) => e.catId == catId).toList(growable: false);
});

class TodaySummary {
  final int foodG;
  final int waterMl;
  final int peeCount;
  final int pooCount;
  final bool tookMedicine;

  const TodaySummary({
    required this.foodG,
    required this.waterMl,
    required this.peeCount,
    required this.pooCount,
    required this.tookMedicine,
  });
}

final todaySummaryProvider = Provider<TodaySummary>((ref) {
  final entries = ref.watch(selectedCatEntriesProvider);
  final now = DateTime.now();
  final startOfDay = DateTime(now.year, now.month, now.day);
  final today = entries.where((e) => e.at.isAfter(startOfDay)).toList();

  int foodG = 0;
  int waterMl = 0;
  int pee = 0;
  int poo = 0;
  bool tookMedicine = false;

  for (final e in today) {
    switch (e.type) {
      case EntryType.food:
        foodG += (e.data['amount_g'] as int?) ?? 0;
        break;
      case EntryType.water:
        waterMl += (e.data['amount_ml'] as int?) ?? 0;
        break;
      case EntryType.litter:
        final kind = (e.data['kind'] as String?) ?? '';
        if (kind.contains('소변')) pee++;
        if (kind.contains('대변')) poo++;
        break;
      case EntryType.medicine:
        tookMedicine = tookMedicine || ((e.data['taken'] as bool?) ?? false);
        break;
      case EntryType.snack:
      case EntryType.hospital:
        break;
    }
  }

  return TodaySummary(
    foodG: foodG,
    waterMl: waterMl,
    peeCount: pee,
    pooCount: poo,
    tookMedicine: tookMedicine,
  );
});
