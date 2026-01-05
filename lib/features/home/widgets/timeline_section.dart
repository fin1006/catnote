import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';
import 'package:intl/intl.dart';

import '../../../models/entry.dart';
import '../../../utils/group_by_day.dart';

class TimelineSection extends StatelessWidget {
  final List<Entry> entries;

  const TimelineSection({super.key, required this.entries});

  @override
  Widget build(BuildContext context) {
    if (entries.isEmpty) {
      return Padding(
        padding: const EdgeInsets.only(top: 18),
        child: Text(
          '아직 기록이 없어요. 위에서 빠르게 추가해보세요!',
          style: TextStyle(color: Theme.of(context).hintColor),
        ),
      );
    }

    final grouped = groupByDay(entries);
    final days = grouped.keys.toList()..sort((a, b) => b.compareTo(a));
    final df = DateFormat('yyyy.MM.dd');
    final tf = DateFormat('HH:mm');

    final hint = Theme.of(context).hintColor;

    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        for (final day in days) ...[
          Padding(
            padding: const EdgeInsets.fromLTRB(0, 10, 0, 8),
            child: Text(
              df.format(day),
              style: TextStyle(color: hint, fontWeight: FontWeight.w800),
            ),
          ),

          for (int i = 0; i < grouped[day]!.length; i++) ...[
            _TimelineRow(
              entry: grouped[day]![i],
              timeText: tf.format(grouped[day]![i].at),
              onTap: () => context.push('/entries/${grouped[day]![i].id}'),
            ),
            const Divider(height: 1),
          ],

          const SizedBox(height: 8),
        ],
      ],
    );
  }
}

class _TimelineRow extends StatelessWidget {
  final Entry entry;
  final String timeText;
  final VoidCallback onTap;

  const _TimelineRow({
    required this.entry,
    required this.timeText,
    required this.onTap,
  });

  @override
  Widget build(BuildContext context) {
    final title = _entryTitle(entry);
    final memo = (entry.memo ?? '').trim();

    return InkWell(
      onTap: onTap,
      child: Padding(
        padding: const EdgeInsets.symmetric(vertical: 10),
        child: Row(
          children: [
            Icon(entry.type.icon, size: 20),
            const SizedBox(width: 10),
            Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(title, style: const TextStyle(fontWeight: FontWeight.w800)),
                  if (memo.isNotEmpty) ...[
                    const SizedBox(height: 4),
                    Text(
                      memo,
                      style: TextStyle(color: Theme.of(context).hintColor),
                      overflow: TextOverflow.ellipsis,
                    ),
                  ],
                ],
              ),
            ),
            const SizedBox(width: 10),
            Text(
              timeText,
              style: TextStyle(color: Theme.of(context).hintColor, fontWeight: FontWeight.w700),
            ),
          ],
        ),
      ),
    );
  }

  String _entryTitle(Entry e) {
    switch (e.type) {
      case EntryType.food:
        return '사료 ${(e.data['amount_g'] ?? '-')}g · ${(e.data['kind'] ?? '미분류')}';
      case EntryType.water:
        return '물 ${(e.data['amount_ml'] ?? '-')}ml';
      case EntryType.snack:
        final name = e.data['name'] ?? '간식';
        final amount = e.data['amount'] ?? '';
        return '간식 $name ${amount.toString().isEmpty ? '' : '· $amount'}';
      case EntryType.litter:
        final kind = e.data['kind'] ?? '배변';
        final status = e.data['status'] ?? '';
        return '$kind ${status.toString().isEmpty ? '' : '· $status'}';
      case EntryType.medicine:
        final name = e.data['name'] ?? '약';
        final dose = e.data['dose'] ?? '';
        return '약 $name ${dose.toString().isEmpty ? '' : '· $dose'}';
      case EntryType.hospital:
        final name = e.data['name'] ?? '병원';
        final cost = e.data['cost'] ?? '';
        return '병원 $name ${cost.toString().isEmpty ? '' : '· $cost'}';
    }
  }
}
