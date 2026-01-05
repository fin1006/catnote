import 'package:flutter/material.dart';
import '../../../models/entry.dart';

class QuickActions extends StatelessWidget {
  final void Function(EntryType type) onTap;

  const QuickActions({super.key, required this.onTap});

  @override
  Widget build(BuildContext context) {
    const types = [
      EntryType.food,
      EntryType.water,
      EntryType.snack,
      EntryType.litter,
      EntryType.medicine,
      EntryType.hospital,
    ];

    return SizedBox(
      height: 104,
      child: ListView.separated(
        scrollDirection: Axis.horizontal,
        itemCount: types.length,
        separatorBuilder: (_, __) => const SizedBox(width: 12),
        itemBuilder: (context, i) {
          final t = types[i];
          final c = _typeColor(t);

          return InkWell(
            borderRadius: BorderRadius.circular(999),
            onTap: () => onTap(t),
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
    }
  }
}
