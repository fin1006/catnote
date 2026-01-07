import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../../providers/actions_provider.dart';

class ActionAddScreen extends ConsumerStatefulWidget {
  const ActionAddScreen({super.key});

  @override
  ConsumerState<ActionAddScreen> createState() => _ActionAddScreenState();
}

class _ActionAddScreenState extends ConsumerState<ActionAddScreen> {
  final nameCtrl = TextEditingController();
  final unitCtrl = TextEditingController();

  // 기본 선택값
  Color selectedColor = Colors.teal;
  IconData selectedIcon = Icons.star_outline;

  final List<String> units = [];

  @override
  void dispose() {
    nameCtrl.dispose();
    unitCtrl.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final border = OutlineInputBorder(borderRadius: BorderRadius.circular(14));

    return Scaffold(
      appBar: AppBar(
        title: const Text('항목 추가'),
        centerTitle: true,
      ),
      bottomNavigationBar: SafeArea(
        top: false,
        child: Padding(
          padding: const EdgeInsets.fromLTRB(16, 8, 16, 12),
          child: Row(
            children: [
              Expanded(
                child: OutlinedButton(
                  onPressed: () => Navigator.pop(context),
                  child: const Text('취소', style: TextStyle(fontWeight: FontWeight.w800)),
                ),
              ),
              const SizedBox(width: 10),
              Expanded(
                child: SizedBox(
                  height: 48,
                  child: FilledButton(
                    style: FilledButton.styleFrom(
                      backgroundColor: const Color(0xFF1B8A5A),
                      foregroundColor: Colors.white,
                    ),
                    onPressed: _save,
                    child: const Text('저장', style: TextStyle(fontWeight: FontWeight.w800)),
                  ),
                ),
              ),
            ],
          ),
        ),
      ),
      body: ListView(
        padding: const EdgeInsets.fromLTRB(16, 16, 16, 90),
        children: [
          TextField(
            controller: nameCtrl,
            decoration: InputDecoration(
              labelText: '항목 이름',
              border: border,
              enabledBorder: border,
              focusedBorder: border,
            ),
          ),
          const SizedBox(height: 16),

          const Text('동그란 배경 색상', style: TextStyle(fontWeight: FontWeight.w900)),
          const SizedBox(height: 10),
          _ColorPicker(
            selected: selectedColor,
            onSelect: (c) => setState(() => selectedColor = c),
          ),
          const SizedBox(height: 18),

          const Text('아이콘', style: TextStyle(fontWeight: FontWeight.w900)),
          const SizedBox(height: 10),
          _IconPicker(
            selected: selectedIcon,
            onSelect: (i) => setState(() => selectedIcon = i),
          ),
          const SizedBox(height: 18),

          const Text('입력 단위 (여러 개 추가 가능)', style: TextStyle(fontWeight: FontWeight.w900)),
          const SizedBox(height: 10),
          Row(
            children: [
              Expanded(
                child: TextField(
                  controller: unitCtrl,
                  decoration: InputDecoration(
                    hintText: '예: g, ml, 캔, 정, 스푼...',
                    border: border,
                    enabledBorder: border,
                    focusedBorder: border,
                  ),
                ),
              ),
              const SizedBox(width: 10),
              SizedBox(
                height: 48,
                child: OutlinedButton(
                  onPressed: _addUnit,
                  child: const Text('추가', style: TextStyle(fontWeight: FontWeight.w800)),
                ),
              ),
            ],
          ),
          const SizedBox(height: 10),

          Wrap(
            spacing: 8,
            runSpacing: 8,
            children: [
              for (final u in units)
                InputChip(
                  label: Text(u),
                  onDeleted: () => setState(() => units.remove(u)),
                ),
            ],
          ),

          const SizedBox(height: 18),

          // 미리보기
          const Text('미리보기', style: TextStyle(fontWeight: FontWeight.w900)),
          const SizedBox(height: 10),
          ListTile(
            leading: Container(
              width: 44,
              height: 44,
              decoration: BoxDecoration(
                shape: BoxShape.circle,
                color: selectedColor.withOpacity(0.16),
              ),
              child: Icon(selectedIcon, color: selectedColor),
            ),
            title: Text(
              (nameCtrl.text.trim().isEmpty ? '항목 이름' : nameCtrl.text.trim()),
              style: const TextStyle(fontWeight: FontWeight.w800),
            ),
            subtitle: units.isEmpty ? null : Text(units.join(' · ')),
          ),
        ],
      ),
    );
  }

  void _addUnit() {
    final u = unitCtrl.text.trim();
    if (u.isEmpty) return;
    if (units.contains(u)) {
      unitCtrl.clear();
      return;
    }
    setState(() {
      units.add(u);
      unitCtrl.clear();
    });
  }

  void _save() {
    final name = nameCtrl.text.trim();
    if (name.isEmpty) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('항목 이름은 필수예요.')),
      );
      return;
    }

    ref.read(actionsProvider.notifier).addCustom(
      name: name,
      color: selectedColor,
      icon: selectedIcon,
      units: units,
    );

    Navigator.pop(context);
  }
}

class _ColorPicker extends StatelessWidget {
  final Color selected;
  final void Function(Color c) onSelect;

  const _ColorPicker({required this.selected, required this.onSelect});

  @override
  Widget build(BuildContext context) {
    const colors = [
      Colors.teal,
      Colors.green,
      Colors.orange,
      Colors.blue,
      Colors.pink,
      Colors.purple,
      Colors.red,
      Colors.brown,
      Colors.indigo,
      Colors.cyan,
      Colors.lime,
      Colors.amber,
    ];

    return Wrap(
      spacing: 10,
      runSpacing: 10,
      children: [
        for (final c in colors)
          InkWell(
            borderRadius: BorderRadius.circular(999),
            onTap: () => onSelect(c),
            child: Container(
              width: 34,
              height: 34,
              decoration: BoxDecoration(
                shape: BoxShape.circle,
                color: c,
                border: Border.all(
                  width: selected.value == c.value ? 3 : 1,
                  color: selected.value == c.value ? Colors.black54 : Colors.black12,
                ),
              ),
            ),
          ),
      ],
    );
  }
}

class _IconPicker extends StatelessWidget {
  final IconData selected;
  final void Function(IconData i) onSelect;

  const _IconPicker({required this.selected, required this.onSelect});

  @override
  Widget build(BuildContext context) {
    // ✅ 기본 7개 외 추가 아이콘 포함해서 넉넉하게 제공
    const icons = [
      Icons.restaurant,
      Icons.water_drop,
      Icons.cookie,
      Icons.pets,
      Icons.medication,
      Icons.local_hospital,
      Icons.monitor_weight,

      Icons.bedtime,
      Icons.bathtub_outlined,
      Icons.cleaning_services_outlined,
      Icons.toys_outlined,
      Icons.thermostat,
      Icons.favorite_outline,
      Icons.bolt,
      Icons.wb_sunny_outlined,
      Icons.camera_alt_outlined,
      Icons.alarm,
      Icons.shopping_bag_outlined,
      Icons.star_outline,
    ];

    return Wrap(
      spacing: 10,
      runSpacing: 10,
      children: [
        for (final i in icons)
          InkWell(
            borderRadius: BorderRadius.circular(12),
            onTap: () => onSelect(i),
            child: Container(
              width: 44,
              height: 44,
              decoration: BoxDecoration(
                borderRadius: BorderRadius.circular(12),
                border: Border.all(
                  width: selected.codePoint == i.codePoint ? 2 : 1,
                  color: selected.codePoint == i.codePoint ? Colors.black54 : Colors.black12,
                ),
              ),
              child: Icon(i),
            ),
          ),
      ],
    );
  }
}
