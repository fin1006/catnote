import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';

import '../../../models/entry.dart';

class QuickActions extends StatelessWidget {
  final String catId;

  const QuickActions({super.key, required this.catId});

  @override
  Widget build(BuildContext context) {
    const types = [
      EntryType.food,
      EntryType.water,
      EntryType.snack,
      EntryType.litter,
      EntryType.medicine,
      EntryType.hospital,
      EntryType.weight, // ✅ 추가: 체중
    ];

    // ✅ 추가: 설정(EntryType이 아님)
    const hasSettings = true;

    final itemCount = types.length + (hasSettings ? 1 : 0);

    return SizedBox(
      height: 104,
      child: ListView.separated(
        scrollDirection: Axis.horizontal,
        itemCount: itemCount,
        separatorBuilder: (_, __) => const SizedBox(width: 12),
        itemBuilder: (context, i) {
          final isSettings = hasSettings && i == itemCount - 1;

          if (isSettings) {
            final c = Colors.grey;

            return InkWell(
              borderRadius: BorderRadius.circular(999),
              onTap: () => context.push('/actions/settings'),
              child: const SizedBox(
                width: 84,
                child: Column(
                  mainAxisAlignment: MainAxisAlignment.center,
                  children: [
                    _SettingsCircle(),
                    SizedBox(height: 10),
                    Text(
                      '설정',
                      style: TextStyle(fontWeight: FontWeight.w700),
                    ),
                  ],
                ),
              ),
            );
          }

          final t = types[i];
          final c = _typeColor(t);

          return InkWell(
            borderRadius: BorderRadius.circular(999),
            onTap: () => context.push('/entries/new?catId=$catId&type=${t.name}'),
            child: SizedBox(
              width: 84,
              child: Column(
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  Container(
                    width: 62,
                    height: 62,
                    decoration: BoxDecoration(
                      shape: BoxShape.circle,
                      color: c.withOpacity(0.16), // ✅ 반투명 배경
                    ),
                    child: Icon(t.icon, color: c, size: 28),
                  ),
                  const SizedBox(height: 10),
                  Text(
                    t.label,
                    style: const TextStyle(fontWeight: FontWeight.w700),
                  ),
                ],
              ),
            ),
          );
        },
      ),
    );
  }

  Color _typeColor(EntryType t) {
    switch (t) {
      case EntryType.food:
        return Colors.orange;
      case EntryType.water:
        return Colors.blue;
      case EntryType.snack:
        return Colors.pink;
      case EntryType.litter:
        return Colors.brown;
      case EntryType.medicine:
        return Colors.purple;
      case EntryType.hospital:
        return Colors.red;
      case EntryType.weight:
        return Colors.teal;
    }
  }
}

class _SettingsCircle extends StatelessWidget {
  const _SettingsCircle();

  @override
  Widget build(BuildContext context) {
    const c = Colors.grey;
    return Container(
      width: 62,
      height: 62,
      decoration: BoxDecoration(
        shape: BoxShape.circle,
        color: c.withOpacity(0.16),
      ),
      child: const Icon(Icons.settings, color: c, size: 28),
    );
  }
}
