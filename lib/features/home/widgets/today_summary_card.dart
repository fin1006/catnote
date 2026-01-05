import 'package:flutter/material.dart';
import '../../../providers/computed_providers.dart';

class TodaySummaryCard extends StatelessWidget {
  final TodaySummary summary;

  const TodaySummaryCard({super.key, required this.summary});

  @override
  Widget build(BuildContext context) {
    TextStyle valueStyle = const TextStyle(fontWeight: FontWeight.w900, fontSize: 16);
    TextStyle labelStyle = TextStyle(color: Theme.of(context).hintColor, fontWeight: FontWeight.w700);

    Widget item(IconData icon, String label, String value) {
      return Row(
        mainAxisSize: MainAxisSize.min,
        children: [
          Icon(icon, size: 18),
          const SizedBox(width: 8),
          Text(label, style: labelStyle),
          const SizedBox(width: 8),
          Text(value, style: valueStyle),
        ],
      );
    }

    return Wrap(
      spacing: 18,
      runSpacing: 12,
      children: [
        item(Icons.restaurant, '사료', '${summary.foodG}g'),
        item(Icons.water_drop, '물', '${summary.waterMl}ml'),
        item(Icons.pets, '배변', '소변 ${summary.peeCount} · 대변 ${summary.pooCount}'),
        item(Icons.medication, '약', summary.tookMedicine ? '복용' : '미복용'),
      ],
    );
  }
}
