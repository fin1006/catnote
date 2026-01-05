import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../../providers/cats_provider.dart';
import '../../providers/selected_cat_provider.dart';
import '../../utils/iterable_ext.dart';

class CatEditScreen extends ConsumerStatefulWidget {
  final bool isNew;
  final String? catId;

  const CatEditScreen({super.key, required this.isNew, this.catId});

  @override
  ConsumerState<CatEditScreen> createState() => _CatEditScreenState();
}

class _CatEditScreenState extends ConsumerState<CatEditScreen> {
  final nameCtrl = TextEditingController();
  final sexCtrl = TextEditingController();
  final breedCtrl = TextEditingController();

  @override
  void initState() {
    super.initState();
    if (!widget.isNew && widget.catId != null) {
      final cats = ref.read(catsProvider);
      final cat = cats.where((c) => c.id == widget.catId).cast().firstOrNull;
      if (cat != null) {
        nameCtrl.text = cat.name;
        sexCtrl.text = cat.sex ?? '';
        breedCtrl.text = cat.breed ?? '';
      }
    }
  }

  @override
  void dispose() {
    nameCtrl.dispose();
    sexCtrl.dispose();
    breedCtrl.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final cats = ref.watch(catsProvider);
    final selectedCatId = ref.watch(selectedCatIdProvider); // String?
    final cat = (!widget.isNew && widget.catId != null)
        ? cats.where((c) => c.id == widget.catId).cast().firstOrNull
        : null;

    return Scaffold(
      appBar: AppBar(
        title: Text(widget.isNew ? '반려묘 추가' : '프로필 편집'),
        actions: [
          if (!widget.isNew && cat != null)
            IconButton(
              tooltip: '삭제',
              onPressed: () async {
                final ok = await showDialog<bool>(
                  context: context,
                  builder: (context) => AlertDialog(
                    title: const Text('삭제할까요?'),
                    content: const Text('해당 고양이 프로필이 삭제돼요. (기록 정리는 다음 단계에서 처리)'),
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
                  final deletingId = cat.id;

                  ref.read(catsProvider.notifier).removeById(deletingId);

                  // ✅ 삭제된 고양이가 "현재 선택"이라면, 남은 첫 고양이로 선택 변경
                  final nextCats = ref.read(catsProvider);
                  if (selectedCatId == deletingId && nextCats.isNotEmpty) {
                    ref.read(selectedCatIdProvider.notifier).select(nextCats.first.id);
                  }

                  if (mounted) Navigator.pop(context);
                }
              },
              icon: const Icon(Icons.delete_outline),
            ),
        ],
      ),
      body: ListView(
        padding: const EdgeInsets.all(16),
        children: [
          TextField(
            controller: nameCtrl,
            decoration: const InputDecoration(
              labelText: '이름 (필수)',
              border: OutlineInputBorder(),
            ),
          ),
          const SizedBox(height: 10),
          TextField(
            controller: sexCtrl,
            decoration: const InputDecoration(
              labelText: '성별 (선택)',
              border: OutlineInputBorder(),
            ),
          ),
          const SizedBox(height: 10),
          TextField(
            controller: breedCtrl,
            decoration: const InputDecoration(
              labelText: '묘종 (선택)',
              border: OutlineInputBorder(),
            ),
          ),
          const SizedBox(height: 14),
          SizedBox(
            width: double.infinity,
            child: FilledButton(
              onPressed: () {
                final name = nameCtrl.text.trim();
                if (name.isEmpty) {
                  ScaffoldMessenger.of(context).showSnackBar(
                    const SnackBar(content: Text('이름은 필수예요.')),
                  );
                  return;
                }

                if (widget.isNew) {
                  ref.read(catsProvider.notifier).addNew(name);

                  // 새로 추가된 고양이를 선택
                  final newCats = ref.read(catsProvider);
                  final newCat = newCats.last;
                  ref.read(selectedCatIdProvider.notifier).select(newCat.id);

                  Navigator.pop(context);
                } else if (cat != null) {
                  final next = cat.copyWith(
                    name: name,
                    sex: sexCtrl.text.trim().isEmpty ? null : sexCtrl.text.trim(),
                    breed: breedCtrl.text.trim().isEmpty ? null : breedCtrl.text.trim(),
                  );
                  ref.read(catsProvider.notifier).upsert(next);

                  // ✅ selectedCatId가 null이거나 비어있다면(방어 코드), 편집한 고양이로 선택
                  if (selectedCatId == null || selectedCatId.isEmpty) {
                    ref.read(selectedCatIdProvider.notifier).select(next.id);
                  }

                  Navigator.pop(context);
                }
              },
              child: const Text('저장'),
            ),
          ),
        ],
      ),
    );
  }
}
