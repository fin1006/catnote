import 'package:flutter/material.dart';

class KeyValueCard extends StatelessWidget {
  final String title;
  final Map<String, dynamic> map;

  const KeyValueCard({super.key, required this.title, required this.map});

  @override
  Widget build(BuildContext context) {
    return Card(
      child: Padding(
        padding: const EdgeInsets.all(14),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text(title, style: const TextStyle(fontWeight: FontWeight.w800)),
            const SizedBox(height: 10),
            for (final e in map.entries)
              Padding(
                padding: const EdgeInsets.only(bottom: 6),
                child: Row(
                  children: [
                    Expanded(flex: 4, child: Text(e.key, style: TextStyle(color: Theme.of(context).hintColor))),
                    Expanded(flex: 6, child: Text('${e.value}')),
                  ],
                ),
              ),
          ],
        ),
      ),
    );
  }
}
