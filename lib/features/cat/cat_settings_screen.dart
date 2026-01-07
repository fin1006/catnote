import 'dart:io';

import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';

import '../../providers/cats_provider.dart';
import '../../providers/selected_cat_provider.dart';
import '../../models/cat_profile.dart';

class CatSettingsScreen extends ConsumerWidget {
  const CatSettingsScreen({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final cats = ref.watch(catsProvider);
    final selectedCatId = ref.watch(selectedCatIdProvider);

    return Scaffold(
      appBar: AppBar(
        title: const Text('반려묘 설정'),
        centerTitle: true,
      ),
      bottomNavigationBar: SafeArea(
        top: false,
        child: Padding(
          padding: const EdgeInsets.fromLTRB(16, 8, 16, 12),
          child: SizedBox(
            width: double.infinity,
            height: 54,
            child: FilledButton(
              style: FilledButton.styleFrom(
                backgroundColor: const Color(0xFF1B8A5A),
                foregroundColor: Colors.white,
              ),
              onPressed: () => context.push('/cats/new'),
              child: const Text('반려묘 추가', style: TextStyle(fontWeight: FontWeight.w800)),
            ),
          ),
        ),
      ),
      body: ReorderableListView.builder(
        padding: const EdgeInsets.symmetric(vertical: 8),
        itemCount: cats.length,
        onReorder: (oldIndex, newIndex) {
          // ✅ ReorderableListView 규칙: 아래로 이동 시 인덱스 보정
          if (newIndex > oldIndex) newIndex -= 1;

          ref.read(catsProvider.notifier).reorder(oldIndex, newIndex);
        },
        itemBuilder: (context, index) {
          final cat = cats[index];
          final isSelected = cat.id == selectedCatId;

          return Dismissible(
            key: ValueKey('cat_settings_${cat.id}'),
            direction: DismissDirection.endToStart,
            confirmDismiss: (_) async {
              return await showDialog<bool>(
                context: context,
                builder: (context) => AlertDialog(
                  title: const Text('삭제할까요?'),
                  content: Text('${cat.name} 프로필을 삭제할까요?'),
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
              ) ??
                  false;
            },
            onDismissed: (_) {
              ref.read(catsProvider.notifier).removeById(cat.id);

              // 삭제된 고양이가 선택되어 있으면 남은 첫 고양이로 선택 이동(있으면)
              final nextCats = ref.read(catsProvider);
              if (isSelected) {
                if (nextCats.isNotEmpty) {
                  ref.read(selectedCatIdProvider.notifier).select(nextCats.first.id);
                }
              }
            },
            background: Container(
              color: Colors.red.withOpacity(0.15),
              padding: const EdgeInsets.symmetric(horizontal: 16),
              alignment: Alignment.centerRight,
              child: const Icon(Icons.delete_outline),
            ),
            child: _CatSettingsTile(
              cat: cat,
              isSelected: isSelected,
              onTapEdit: () => context.push('/cats/${cat.id}/edit'),
              onTapDelete: () async {
                final ok = await showDialog<bool>(
                  context: context,
                  builder: (context) => AlertDialog(
                    title: const Text('삭제하시겠습니까?'),
                    content: Text('${cat.name} 프로필을 삭제할까요?'),
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
                ) ??
                    false;

                if (ok) {
                  ref.read(catsProvider.notifier).removeById(cat.id);

                  // 삭제된 고양이가 선택되어 있으면 남은 첫 고양이로 선택 이동(있으면)
                  final nextCats = ref.read(catsProvider);
                  if (isSelected) {
                    if (nextCats.isNotEmpty) {
                      ref.read(selectedCatIdProvider.notifier).select(nextCats.first.id);
                    }
                  }
                }
              },
              index: index, // ✅ 드래그 핸들에 정확한 index 전달
            ),
          );
        },
      ),
    );
  }
}

class _CatSettingsTile extends StatelessWidget {
  final CatProfile cat;
  final bool isSelected;
  final VoidCallback onTapEdit;
  final VoidCallback onTapDelete;
  final int index;

  const _CatSettingsTile({
    required this.cat,
    required this.isSelected,
    required this.onTapEdit,
    required this.onTapDelete,
    required this.index,
  });

  @override
  Widget build(BuildContext context) {
    return ListTile(
      leading: _CatThumb(photoUrl: cat.photoUrl, photoPath: cat.photoPath, size: 44),
      title: Row(
        children: [
          Expanded(
            child: Text(
              cat.name,
              overflow: TextOverflow.ellipsis,
              style: const TextStyle(fontWeight: FontWeight.w800),
            ),
          ),
        ],
      ),
      subtitle: Text([
        if ((cat.sex ?? '').isNotEmpty) '성별 ${cat.sex}',
        if ((cat.breed ?? '').isNotEmpty) '묘종 ${cat.breed}',
      ].join(' · ')),
      trailing: Row(
        mainAxisSize: MainAxisSize.min,
        children: [
          IconButton(
            tooltip: '수정',
            onPressed: onTapEdit,
            icon: const Icon(Icons.edit_outlined),
          ),
          IconButton(
            tooltip: '삭제',
            onPressed: onTapDelete,
            icon: const Icon(Icons.delete_outline),
          ),
          ReorderableDragStartListener(
            index: index,
            child: const Padding(
              padding: EdgeInsets.symmetric(horizontal: 6),
              child: Icon(Icons.drag_indicator),
            ),
          ),
        ],
      ),
    );
  }
}

class _CatThumb extends StatelessWidget {
  final String? photoUrl;
  final String? photoPath;
  final double size;

  const _CatThumb({required this.photoUrl, required this.photoPath, required this.size});

  @override
  Widget build(BuildContext context) {
    final url = (photoUrl ?? '').trim();
    final path = (photoPath ?? '').trim();
    final bg = Theme.of(context).colorScheme.surfaceContainerHighest;

    return Container(
      width: size,
      height: size,
      decoration: BoxDecoration(
        shape: BoxShape.circle,
        color: bg,
        image: path.isNotEmpty
            ? DecorationImage(image: FileImage(File(path)), fit: BoxFit.cover)
            : _isNetworkUrl(url)
            ? DecorationImage(image: NetworkImage(url), fit: BoxFit.cover)
            : null,
      ),
      child: (path.isEmpty && !_isNetworkUrl(url)) ? const Icon(Icons.pets) : null,
    );
  }
}

bool _isNetworkUrl(String s) => s.startsWith('http://') || s.startsWith('https://');
