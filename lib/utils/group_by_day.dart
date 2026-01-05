import '../models/entry.dart';

Map<DateTime, List<Entry>> groupByDay(List<Entry> entries) {
  final map = <DateTime, List<Entry>>{};
  for (final e in entries) {
    final dayKey = DateTime(e.at.year, e.at.month, e.at.day);
    map.putIfAbsent(dayKey, () => []).add(e);
  }
  for (final k in map.keys) {
    map[k]!.sort((a, b) => b.at.compareTo(a.at));
  }
  return map;
}
