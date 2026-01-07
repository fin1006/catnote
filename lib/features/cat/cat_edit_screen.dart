import 'dart:io';

import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:image_picker/image_picker.dart';

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
  final traitsCtrl = TextEditingController();

  XFile? _pickedPhoto;

  final _picker = ImagePicker();

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
        traitsCtrl.text = cat.traits ?? '';
      }
    }
  }

  @override
  void dispose() {
    nameCtrl.dispose();
    sexCtrl.dispose();
    breedCtrl.dispose();
    traitsCtrl.dispose();
    super.dispose();
  }

  Future<void> _pickFromCamera() async {
    final x = await _picker.pickImage(
      source: ImageSource.camera,
      imageQuality: 85,
    );
    if (x != null) {
      setState(() => _pickedPhoto = x);
    }
  }

  Future<void> _pickFromGallery() async {
    final x = await _picker.pickImage(
      source: ImageSource.gallery,
      imageQuality: 85,
    );
    if (x != null) {
      setState(() => _pickedPhoto = x);
    }
  }

  @override
  Widget build(BuildContext context) {
    final cats = ref.watch(catsProvider);
    final selectedCatId = ref.watch(selectedCatIdProvider); // String?
    final cat = (!widget.isNew && widget.catId != null)
        ? cats.where((c) => c.id == widget.catId).cast().firstOrNull
        : null;

    final border = OutlineInputBorder(
      borderRadius: BorderRadius.circular(14), // ✅ 모서리 조금 더 둥글게
    );

    return Scaffold(
      appBar: AppBar(
        title: Text(widget.isNew ? '반려묘 추가' : '프로필 편집'),
        centerTitle: true,
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

      // ✅ 저장 버튼 하단 고정 + 진한 연두색 배경/흰 글씨
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
              onPressed: () {
                final name = nameCtrl.text.trim();
                if (name.isEmpty) {
                  ScaffoldMessenger.of(context).showSnackBar(
                    const SnackBar(content: Text('이름은 필수예요.')),
                  );
                  return;
                }

                final traits = traitsCtrl.text.trim().isEmpty ? null : traitsCtrl.text.trim();
                final photoPath = _pickedPhoto?.path;

                if (widget.isNew) {
                  ref.read(catsProvider.notifier).addNew(
                    name,
                    photoPath: photoPath,
                    traits: traits,
                  );

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
                    traits: traits,
                    photoPath: photoPath ?? cat.photoPath,
                  );
                  ref.read(catsProvider.notifier).upsert(next);

                  // ✅ selectedCatId가 null이거나 비어있다면(방어 코드), 편집한 고양이로 선택
                  if (selectedCatId == null || selectedCatId.isEmpty) {
                    ref.read(selectedCatIdProvider.notifier).select(next.id);
                  }

                  Navigator.pop(context);
                }
              },
              child: const Text('저장', style: TextStyle(fontWeight: FontWeight.w800)),
            ),
          ),
        ),
      ),

      body: ListView(
        padding: const EdgeInsets.fromLTRB(16, 16, 16, 90), // ✅ 하단 버튼 공간
        children: [
          // ✅ 사진 영역: 촬영/업로드
          Center(
            child: Column(
              children: [
                Container(
                  width: 110,
                  height: 110,
                  decoration: BoxDecoration(
                    shape: BoxShape.circle,
                    color: Theme.of(context).colorScheme.surfaceContainerHighest,
                    image: _pickedPhoto != null
                        ? DecorationImage(
                      image: FileImage(File(_pickedPhoto!.path)),
                      fit: BoxFit.cover,
                    )
                        : (cat?.photoPath != null && (cat!.photoPath!.trim().isNotEmpty))
                        ? DecorationImage(
                      image: FileImage(File(cat.photoPath!)),
                      fit: BoxFit.cover,
                    )
                        : null,
                  ),
                  child: (_pickedPhoto == null && (cat?.photoPath == null || cat!.photoPath!.trim().isEmpty))
                      ? const Icon(Icons.pets, size: 44)
                      : null,
                ),
                const SizedBox(height: 12),
                Row(
                  mainAxisAlignment: MainAxisAlignment.center,
                  children: [
                    OutlinedButton.icon(
                      onPressed: _pickFromCamera,
                      icon: const Icon(Icons.photo_camera_outlined),
                      label: const Text('촬영'),
                    ),
                    const SizedBox(width: 10),
                    OutlinedButton.icon(
                      onPressed: _pickFromGallery,
                      icon: const Icon(Icons.photo_library_outlined),
                      label: const Text('업로드'),
                    ),
                  ],
                ),
              ],
            ),
          ),

          const SizedBox(height: 18),

          TextField(
            controller: nameCtrl,
            decoration: InputDecoration(
              labelText: '이름 (필수)',
              border: border,
              enabledBorder: border,
              focusedBorder: border,
            ),
          ),
          const SizedBox(height: 10),
          TextField(
            controller: sexCtrl,
            decoration: InputDecoration(
              labelText: '성별 (선택)',
              border: border,
              enabledBorder: border,
              focusedBorder: border,
            ),
          ),
          const SizedBox(height: 10),
          TextField(
            controller: breedCtrl,
            decoration: InputDecoration(
              labelText: '묘종 (선택)',
              border: border,
              enabledBorder: border,
              focusedBorder: border,
            ),
          ),
          const SizedBox(height: 10),
          TextField(
            controller: traitsCtrl,
            minLines: 2,
            maxLines: 4,
            decoration: InputDecoration(
              labelText: '특징 (선택)',
              border: border,
              enabledBorder: border,
              focusedBorder: border,
            ),
          ),
        ],
      ),
    );
  }
}
