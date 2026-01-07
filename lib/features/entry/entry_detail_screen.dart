import 'dart:io';

import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';
import 'package:intl/intl.dart';

import '../../models/entry.dart'; // ✅ EntryTypeX(label/icon) 사용 위해 필요
import '../../providers/entries_provider.dart';
import 'widgets/key_value_card.dart';

class EntryDetailScreen extends ConsumerWidget {
  final String entryId;
  const EntryDetailScreen({super.key, required this.entryId});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final notifier = ref.read(entriesProvider.notifier);
    final entry = notifier.byId(entryId);

    if (entry == null) {
      return Scaffold(
        appBar: AppBar(title: const Text('기록 상세')),
        body: const Center(child: Text('기록을 찾을 수 없어요.')),
      );
    }

    final df = DateFormat('yyyy.MM.dd (E) HH:mm', 'ko_KR');

    // ✅ 사진 표시용(EntryCreateScreen에서 data['photoPath']에 저장)
    final photoPath = (entry.data['photoPath'] as String?)?.trim();

    // ✅ 화면에는 photoPath를 "입력값" 카드에 노출하지 않음
    final dataForView = Map<String, dynamic>.from(entry.data)..remove('photoPath');

    return Scaffold(
      appBar: AppBar(
        title: const Text('기록 상세'),
        actions: [
          IconButton(
            tooltip: '삭제',
            onPressed: () async {
              final ok = await showDialog<bool>(
                context: context,
                builder: (context) => AlertDialog(
                  title: const Text('삭제할까요?'),
                  content: const Text('이 기록은 복구할 수 없어요.'),
                  actions: [
                    TextButton(
                      onPressed: () => Navigator.pop(context, false),
                      child: const Text('취소'),
                    ),
                    FilledButton(
                      onPressed: () => Navigator.pop(context, true),
                      child: const Text('삭제'),
                    ),
                  ],
                ),
              );

              if (ok == true) {
                notifier.remove(entry.id);
                if (context.mounted) context.pop();
              }
            },
            icon: const Icon(Icons.delete_outline),
          ),
        ],
      ),
      body: ListView(
        padding: const EdgeInsets.all(16),
        children: [
          Card(
            child: Padding(
              padding: const EdgeInsets.all(14),
              child: Row(
                children: [
                  CircleAvatar(child: Icon(entry.type.icon)), // ✅ OK
                  const SizedBox(width: 12),
                  Expanded(
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Text(
                          entry.type.label, // ✅ OK
                          style: const TextStyle(fontWeight: FontWeight.w900, fontSize: 16),
                        ),
                        const SizedBox(height: 4),
                        Text(df.format(entry.at)),
                      ],
                    ),
                  ),
                ],
              ),
            ),
          ),

          // ✅ 사진이 있으면 상세에 표시
          if (photoPath != null && photoPath.isNotEmpty) ...[
            const SizedBox(height: 12),
            Card(
              child: Padding(
                padding: const EdgeInsets.all(14),
                child: ClipRRect(
                  borderRadius: BorderRadius.circular(12),
                  child: Image.file(
                    File(photoPath),
                    height: 200,
                    width: double.infinity,
                    fit: BoxFit.cover,
                  ),
                ),
              ),
            ),
          ],

          const SizedBox(height: 12),
          KeyValueCard(title: '입력값', map: dataForView),

          if ((entry.memo ?? '').trim().isNotEmpty) ...[
            const SizedBox(height: 12),
            Card(
              child: Padding(
                padding: const EdgeInsets.all(14),
                child: Text(entry.memo!),
              ),
            ),
          ],
          const SizedBox(height: 14),
          SizedBox(
            width: double.infinity,
            child: FilledButton.tonal(
              onPressed: () {
                ScaffoldMessenger.of(context).showSnackBar(
                  const SnackBar(content: Text('수정 기능은 다음 단계에서 붙일게요.')),
                );
              },
              child: const Text('수정'),
            ),
          ),
        ],
      ),
    );
  }
}
