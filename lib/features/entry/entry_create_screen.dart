import 'dart:io';

import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:image_picker/image_picker.dart';
import 'package:intl/intl.dart';
import 'package:uuid/uuid.dart';

import '../../models/entry.dart';
import '../../providers/entries_provider.dart';

class EntryCreateScreen extends ConsumerStatefulWidget {
  final String? catId;
  final String? type;

  const EntryCreateScreen({super.key, required this.catId, required this.type});

  @override
  ConsumerState<EntryCreateScreen> createState() => _EntryCreateScreenState();
}

class _EntryCreateScreenState extends ConsumerState<EntryCreateScreen> {
  static final Map<String, int> _lastIntAmountByType = {};
  static final Map<String, double> _lastDoubleAmountByType = {};
  static final Map<String, String> _lastUnitByType = {};

  final _memoCtrl = TextEditingController();
  final _nameCtrl = TextEditingController(); // 간식/약/병원 등 이름
  final _statusCtrl = TextEditingController(); // 배변 상태
  final _picker = ImagePicker();

  DateTime _at = DateTime.now();

  // 공통(정수량) - 사료/물/간식/병원
  int _amountInt = 0;

  // 체중(소수)
  double _amountDouble = 0.0;

  // 옵션들
  String _foodKind = '건식'; // 사료: 건식/습식
  String _litterKind = '소변'; // 배변: 소변/대변

  // 약 단위
  String _medicineUnit = '정';

  // 사진
  XFile? _pickedPhoto;

  EntryType? get _entryType {
    final s = (widget.type ?? '').trim();
    if (s.isEmpty) return null;
    for (final t in EntryType.values) {
      if (t.name == s) return t;
    }
    return null;
  }

  String get _typeKey => (_entryType?.name ?? 'unknown');

  @override
  void initState() {
    super.initState();

    // 마지막 입력값 복원(항목별)
    final t = _entryType;
    if (t != null) {
      final key = t.name;
      if (t == EntryType.weight) {
        _amountDouble = _lastDoubleAmountByType[key] ?? 0.0;
      } else {
        _amountInt = _lastIntAmountByType[key] ?? 0;
      }
      if (t == EntryType.medicine) {
        _medicineUnit = _lastUnitByType[key] ?? _medicineUnit;
      }
    }
  }

  @override
  void dispose() {
    _memoCtrl.dispose();
    _nameCtrl.dispose();
    _statusCtrl.dispose();
    super.dispose();
  }

  void _bumpTime(Duration d) {
    setState(() => _at = _at.add(d));
  }

  void _bumpInt(int delta) {
    setState(() {
      _amountInt = (_amountInt + delta);
      if (_amountInt < 0) _amountInt = 0;
    });
  }

  void _bumpDouble(double delta) {
    setState(() {
      _amountDouble = (_amountDouble + delta);
      if (_amountDouble < 0) _amountDouble = 0.0;
      // 보기 좋게 소수 1자리로 정리
      _amountDouble = double.parse(_amountDouble.toStringAsFixed(1));
    });
  }

  Future<void> _pickCamera() async {
    final x = await _picker.pickImage(source: ImageSource.camera, imageQuality: 85);
    if (x != null) {
      if (!mounted) return;
      setState(() => _pickedPhoto = x);
    }
  }

  Future<void> _pickGallery() async {
    final x = await _picker.pickImage(source: ImageSource.gallery, imageQuality: 85);
    if (x != null) {
      if (!mounted) return;
      setState(() => _pickedPhoto = x);
    }
  }

  @override
  Widget build(BuildContext context) {
    final catId = widget.catId;
    final type = _entryType;

    if (catId == null || catId.trim().isEmpty || type == null) {
      return Scaffold(
        appBar: AppBar(title: const Text('입력')),
        body: const Center(child: Text('잘못된 접근입니다.')),
      );
    }

    final tf = DateFormat('HH:mm', 'ko_KR');

    return Scaffold(
      appBar: AppBar(
        title: Text(type.label),
        centerTitle: true, // ✅ 앞으로 모든 페이지 상단 제목 가운데
      ),
      bottomNavigationBar: SafeArea(
        top: false,
        child: Padding(
          padding: const EdgeInsets.fromLTRB(16, 10, 16, 12),
          child: Row(
            children: [
              Expanded(
                child: SizedBox(
                  height: 54, // ✅ 저장 버튼과 동일 높이
                  child: OutlinedButton(
                    style: OutlinedButton.styleFrom(
                      foregroundColor: Colors.black, // ✅ 취소 글씨 검정
                    ),
                    onPressed: () => Navigator.pop(context),
                    child: const Text('취소', style: TextStyle(fontWeight: FontWeight.w800)),
                  ),
                ),
              ),
              const SizedBox(width: 12),
              Expanded(
                child: SizedBox(
                  height: 54,
                  child: FilledButton(
                    style: FilledButton.styleFrom(
                      backgroundColor: const Color(0xFF1B8A5A),
                      foregroundColor: Colors.white,
                    ),
                    onPressed: () => _save(catId, type),
                    child: const Text('저장', style: TextStyle(fontWeight: FontWeight.w800)),
                  ),
                ),
              ),
            ],
          ),
        ),
      ),
      body: ListView(
        padding: const EdgeInsets.fromLTRB(16, 14, 16, 90),
        children: [
          // ✅ 시간(제목 + 입력창 스타일 박스) + 버튼으로 조절
          const Text('시간', style: TextStyle(fontWeight: FontWeight.w900)),
          const SizedBox(height: 8),
          Container(
            padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 12),
            decoration: BoxDecoration(
              border: Border.all(color: Theme.of(context).dividerColor),
              borderRadius: BorderRadius.circular(14),
            ),
            child: Center(
              child: Text(
                tf.format(_at),
                style: const TextStyle(fontWeight: FontWeight.w900, fontSize: 18),
              ),
            ),
          ),
          const SizedBox(height: 10),

          // ✅ 요청: 시간 버튼 6개 "무조건 한 줄" + 동일 가로길이
          _FixedSixButtonsRow(
            labels: const ['-1h', '-10m', '-1m', '+1m', '+10m', '+1h'],
            onPressed: [
                  () => _bumpTime(const Duration(hours: -1)),
                  () => _bumpTime(const Duration(minutes: -10)),
                  () => _bumpTime(const Duration(minutes: -1)),
                  () => _bumpTime(const Duration(minutes: 1)),
                  () => _bumpTime(const Duration(minutes: 10)),
                  () => _bumpTime(const Duration(hours: 1)),
            ],
          ),

          const SizedBox(height: 16),
          ..._buildTypeFields(type),

          const SizedBox(height: 14),

          // ✅ 메모(제목 따로) + 높이 줄이기
          const Text('메모', style: TextStyle(fontWeight: FontWeight.w900)),
          const SizedBox(height: 8),
          TextField(
            controller: _memoCtrl,
            maxLines: 2,
            decoration: const InputDecoration(
              border: OutlineInputBorder(),
              hintText: '메모 (선택)',
            ),
          ),

          const SizedBox(height: 14),

          // ✅ 파일 첨부(제목 + 버튼 2개)
          const Text('파일 첨부', style: TextStyle(fontWeight: FontWeight.w900)),
          const SizedBox(height: 8),
          Row(
            children: [
              Expanded(
                child: SizedBox(
                  height: 44,
                  child: OutlinedButton.icon(
                    onPressed: _pickCamera,
                    icon: const Icon(Icons.photo_camera_outlined),
                    label: const Text('사진 촬영', style: TextStyle(fontWeight: FontWeight.w800)),
                  ),
                ),
              ),
              const SizedBox(width: 10),
              Expanded(
                child: SizedBox(
                  height: 44,
                  child: OutlinedButton.icon(
                    onPressed: _pickGallery,
                    icon: const Icon(Icons.photo_library_outlined),
                    label: const Text('이미지 선택', style: TextStyle(fontWeight: FontWeight.w800)),
                  ),
                ),
              ),
            ],
          ),

          if (_pickedPhoto != null) ...[
            const SizedBox(height: 12),
            ClipRRect(
              borderRadius: BorderRadius.circular(12),
              child: Image.file(
                File(_pickedPhoto!.path),
                height: 170,
                width: double.infinity,
                fit: BoxFit.cover,
              ),
            ),
          ],
        ],
      ),
    );
  }

  List<Widget> _buildTypeFields(EntryType type) {
    switch (type) {
      case EntryType.food:
        return [
          // ✅ 건식/습식 (선택: 연두+흰글씨 / 미선택: 검정 테두리)
          _PastelSegmented(
            left: '건식',
            right: '습식',
            value: _foodKind,
            onChanged: (v) => setState(() => _foodKind = v),
          ),
          const SizedBox(height: 12),

          // ✅ 섭취량(0 + 버튼 증감)
          _AmountStepperInt(
            label: '섭취량 (g)',
            value: _amountInt,
            onDelta: _bumpInt,
          ),
        ];

      case EntryType.water:
        return [
          _AmountStepperInt(
            label: '섭취량 (ml)',
            value: _amountInt,
            onDelta: _bumpInt,
          ),
        ];

      case EntryType.snack:
        return [
          TextField(
            controller: _nameCtrl,
            decoration: const InputDecoration(labelText: '간식 종류/이름', border: OutlineInputBorder()),
          ),
          const SizedBox(height: 12),
          _AmountStepperInt(
            label: '섭취량 (g)',
            value: _amountInt,
            onDelta: _bumpInt,
          ),
        ];

      case EntryType.litter:
        return [
          _PastelSegmented(
            left: '소변',
            right: '대변',
            value: _litterKind,
            onChanged: (v) => setState(() => _litterKind = v),
          ),
          const SizedBox(height: 12),
          TextField(
            controller: _statusCtrl,
            decoration: const InputDecoration(labelText: '상태', border: OutlineInputBorder()),
          ),
        ];

      case EntryType.weight:
        return [
          _AmountStepperDouble(
            label: '체중 (kg)',
            value: _amountDouble,
            onDelta: _bumpDouble,
          ),
        ];

      case EntryType.medicine:
        return [
          TextField(
            controller: _nameCtrl,
            decoration: const InputDecoration(labelText: '약 이름', border: OutlineInputBorder()),
          ),
          const SizedBox(height: 12),

          // ✅ 용량 + 단위 선택
          Row(
            children: [
              Expanded(
                child: _AmountStepperInt(
                  label: '섭취량',
                  value: _amountInt,
                  onDelta: _bumpInt,
                  compact: true,
                ),
              ),
              const SizedBox(width: 10),
              SizedBox(
                width: 110,
                child: DropdownButtonFormField<String>(
                  value: _medicineUnit,
                  items: const [
                    DropdownMenuItem(value: '정', child: Text('정')),
                    DropdownMenuItem(value: 'ml', child: Text('ml')),
                    DropdownMenuItem(value: 'mg', child: Text('mg')),
                    DropdownMenuItem(value: '캡슐', child: Text('캡슐')),
                  ],
                  onChanged: (v) => setState(() => _medicineUnit = v ?? _medicineUnit),
                  decoration: const InputDecoration(border: OutlineInputBorder(), labelText: '단위'),
                ),
              ),
            ],
          ),
        ];

      case EntryType.hospital:
        return [
          TextField(
            controller: _nameCtrl,
            decoration: const InputDecoration(labelText: '병원명', border: OutlineInputBorder()),
          ),
          const SizedBox(height: 12),
          _AmountStepperInt(
            label: '비용 (원)',
            value: _amountInt,
            onDelta: _bumpInt,
          ),
        ];
    }
  }

  void _save(String catId, EntryType type) {
    // 마지막 입력값 저장(항목별)
    final key = type.name;
    if (type == EntryType.weight) {
      _lastDoubleAmountByType[key] = _amountDouble;
    } else {
      _lastIntAmountByType[key] = _amountInt;
    }
    if (type == EntryType.medicine) {
      _lastUnitByType[key] = _medicineUnit;
    }

    final data = <String, dynamic>{};

    // 사진 경로(임시: data에 저장)
    final photoPath = _pickedPhoto?.path;
    if (photoPath != null && photoPath.trim().isNotEmpty) {
      data['photoPath'] = photoPath;
    }

    switch (type) {
      case EntryType.food:
        data['kind'] = _foodKind;
        data['amount_g'] = _amountInt;
        break;

      case EntryType.water:
        data['amount_ml'] = _amountInt;
        break;

      case EntryType.snack:
        data['name'] = _nameCtrl.text.trim();
        data['amount_g'] = _amountInt;
        break;

      case EntryType.litter:
        data['kind'] = _litterKind;
        data['status'] = _statusCtrl.text.trim();
        break;

      case EntryType.weight:
        data['weight_kg'] = _amountDouble;
        break;

      case EntryType.medicine:
        data['name'] = _nameCtrl.text.trim();
        data['amount'] = _amountInt;
        data['unit'] = _medicineUnit;
        break;

      case EntryType.hospital:
        data['name'] = _nameCtrl.text.trim();
        data['cost'] = _amountInt;
        break;
    }

    final entry = Entry(
      id: const Uuid().v4(),
      catId: catId,
      type: type,
      at: _at,
      data: data,
      memo: _memoCtrl.text.trim().isEmpty ? null : _memoCtrl.text.trim(),
    );

    ref.read(entriesProvider.notifier).add(entry);
    Navigator.pop(context);
  }
}

class _AmountStepperInt extends StatelessWidget {
  final String label;
  final int value;
  final void Function(int delta) onDelta;
  final bool compact;

  const _AmountStepperInt({
    required this.label,
    required this.value,
    required this.onDelta,
    this.compact = false,
  });

  @override
  Widget build(BuildContext context) {
    final title = Text(label, style: const TextStyle(fontWeight: FontWeight.w900));
    final val = Text('$value', style: const TextStyle(fontWeight: FontWeight.w900, fontSize: 18));

    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        if (!compact) title,
        if (!compact) const SizedBox(height: 8),
        Container(
          padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 12),
          decoration: BoxDecoration(
            border: Border.all(color: Theme.of(context).dividerColor),
            borderRadius: BorderRadius.circular(14),
          ),
          child: Row(
            children: [
              if (compact) ...[
                Expanded(child: title),
                val,
              ] else ...[
                Expanded(child: Center(child: val)), // ✅ 가운데 정렬
              ],
            ],
          ),
        ),
        const SizedBox(height: 10),

        // ✅ 요청: 섭취량 버튼 6개 "무조건 한 줄" + 동일 가로길이
        _FixedSixButtonsRow(
          labels: const ['-20', '-10', '-1', '+1', '+10', '+20'],
          onPressed: [
                () => onDelta(-20),
                () => onDelta(-10),
                () => onDelta(-1),
                () => onDelta(1),
                () => onDelta(10),
                () => onDelta(20),
          ],
        ),
      ],
    );
  }
}

class _AmountStepperDouble extends StatelessWidget {
  final String label;
  final double value;
  final void Function(double delta) onDelta;

  const _AmountStepperDouble({
    required this.label,
    required this.value,
    required this.onDelta,
  });

  @override
  Widget build(BuildContext context) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(label, style: const TextStyle(fontWeight: FontWeight.w900)),
        const SizedBox(height: 8),
        Container(
          padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 12),
          decoration: BoxDecoration(
            border: Border.all(color: Theme.of(context).dividerColor),
            borderRadius: BorderRadius.circular(14),
          ),
          child: Row(
            children: [
              Expanded(
                child: Center(
                  child: Text(
                    value.toStringAsFixed(1),
                    style: const TextStyle(fontWeight: FontWeight.w900, fontSize: 18),
                  ),
                ),
              ),
            ],
          ),
        ),
        const SizedBox(height: 10),
        Wrap(
          spacing: 8,
          runSpacing: 8,
          children: [
            _DeltaChip(label: '-0.5', onTap: () => onDelta(-0.5)),
            _DeltaChip(label: '-0.1', onTap: () => onDelta(-0.1)),
            _DeltaChip(label: '+0.1', onTap: () => onDelta(0.1)),
            _DeltaChip(label: '+0.5', onTap: () => onDelta(0.5)),
          ],
        ),
      ],
    );
  }
}

class _DeltaChip extends StatelessWidget {
  final String label;
  final VoidCallback onTap;

  const _DeltaChip({required this.label, required this.onTap});

  @override
  Widget build(BuildContext context) {
    return SizedBox(
      height: 34,
      child: OutlinedButton(
        onPressed: onTap,
        child: Text(label, style: const TextStyle(fontWeight: FontWeight.w800)),
      ),
    );
  }
}

class _PastelSegmented extends StatelessWidget {
  final String left;
  final String right;
  final String value;
  final void Function(String v) onChanged;

  const _PastelSegmented({
    required this.left,
    required this.right,
    required this.value,
    required this.onChanged,
  });

  @override
  Widget build(BuildContext context) {
    const selectedBg = Color(0xFF1B8A5A); // ✅ 연두(요청)
    const selectedFg = Colors.white;
    const unselectedFg = Colors.black;
    const unselectedBorder = Colors.black;

    Widget buildBtn(String text) {
      final selected = value == text;
      final radius = BorderRadius.circular(14);

      return Expanded(
        child: SizedBox(
          height: 44,
          child: selected
              ? FilledButton(
            style: FilledButton.styleFrom(
              backgroundColor: selectedBg,
              foregroundColor: selectedFg,
              shape: RoundedRectangleBorder(borderRadius: radius),
            ),
            onPressed: () => onChanged(text),
            child: Text(text, style: const TextStyle(fontWeight: FontWeight.w900)),
          )
              : OutlinedButton(
            style: OutlinedButton.styleFrom(
              foregroundColor: unselectedFg,
              side: const BorderSide(color: unselectedBorder),
              shape: RoundedRectangleBorder(borderRadius: radius),
            ),
            onPressed: () => onChanged(text),
            child: Text(text, style: const TextStyle(fontWeight: FontWeight.w900)),
          ),
        ),
      );
    }

    return Row(
      children: [
        buildBtn(left),
        const SizedBox(width: 10),
        buildBtn(right),
      ],
    );
  }
}

// ✅ 추가: 6개 버튼을 "무조건 한 줄"로 만들기(동일 가로길이, 간격 포함)
class _FixedSixButtonsRow extends StatelessWidget {
  final List<String> labels;
  final List<VoidCallback> onPressed;

  const _FixedSixButtonsRow({
    required this.labels,
    required this.onPressed,
  });

  @override
  Widget build(BuildContext context) {
    // labels/onPressed는 6개를 기대
    const gap = 8.0;
    const btnH = 34.0;

    return LayoutBuilder(
      builder: (context, c) {
        final w = c.maxWidth;
        final btnW = (w - gap * 5) / 6;

        return Row(
          children: [
            for (int i = 0; i < 6; i++) ...[
              SizedBox(
                width: btnW,
                height: btnH,
                child: OutlinedButton(
                  style: OutlinedButton.styleFrom(
                    padding: EdgeInsets.zero,
                    tapTargetSize: MaterialTapTargetSize.shrinkWrap,
                  ),
                  onPressed: onPressed[i],
                  child: Text(labels[i], style: const TextStyle(fontWeight: FontWeight.w800)),
                ),
              ),
              if (i != 5) const SizedBox(width: gap),
            ],
          ],
        );
      },
    );
  }
}
