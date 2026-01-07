import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:intl/intl.dart';
import 'package:uuid/uuid.dart';

import '../../../models/entry.dart';
import '../../../providers/entries_provider.dart';

class QuickEntrySheet extends ConsumerStatefulWidget {
  final String catId;
  final EntryType type;

  const QuickEntrySheet({super.key, required this.catId, required this.type});

  @override
  ConsumerState<QuickEntrySheet> createState() => _QuickEntrySheetState();
}

class _QuickEntrySheetState extends ConsumerState<QuickEntrySheet> {
  DateTime at = DateTime.now();
  final memoCtrl = TextEditingController();
  final amountCtrl = TextEditingController();
  final nameCtrl = TextEditingController();

  String optionA = '건식';
  bool taken = true;

  @override
  void dispose() {
    memoCtrl.dispose();
    amountCtrl.dispose();
    nameCtrl.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final tf = DateFormat('yyyy.MM.dd (E) HH:mm', 'ko_KR');

    return Padding(
      padding: EdgeInsets.only(
        left: 16,
        right: 16,
        top: 6,
        bottom: MediaQuery.of(context).viewInsets.bottom + 16,
      ),
      child: Column(
        mainAxisSize: MainAxisSize.min,
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            children: [
              CircleAvatar(child: Icon(widget.type.icon)),
              const SizedBox(width: 10),
              Text(widget.type.label, style: const TextStyle(fontWeight: FontWeight.w900, fontSize: 18)),
              const Spacer(),
              TextButton(
                onPressed: () async {
                  final picked = await showDatePicker(
                    context: context,
                    initialDate: at,
                    firstDate: DateTime(2020),
                    lastDate: DateTime(2100),
                  );
                  if (picked == null) return;
                  final time = await showTimePicker(context: context, initialTime: TimeOfDay.fromDateTime(at));
                  if (time == null) return;
                  setState(() {
                    at = DateTime(picked.year, picked.month, picked.day, time.hour, time.minute);
                  });
                },
                child: Text(tf.format(at)),
              ),
            ],
          ),
          const SizedBox(height: 10),
          ..._buildFields(),
          const SizedBox(height: 10),
          TextField(
            controller: memoCtrl,
            maxLines: 2,
            decoration: const InputDecoration(labelText: '메모 (선택)', border: OutlineInputBorder()),
          ),
          const SizedBox(height: 12),
          SizedBox(
            width: double.infinity,
            child: FilledButton(onPressed: _save, child: const Text('저장')),
          ),
        ],
      ),
    );
  }

  List<Widget> _buildFields() {
    switch (widget.type) {
      case EntryType.food:
        return [
          TextField(
            controller: amountCtrl,
            keyboardType: TextInputType.number,
            decoration: const InputDecoration(labelText: '섭취량 (g)', border: OutlineInputBorder()),
          ),
          const SizedBox(height: 10),
          SegmentedButton<String>(
            segments: const [
              ButtonSegment(value: '건식', label: Text('건식')),
              ButtonSegment(value: '습식', label: Text('습식')),
            ],
            selected: {optionA},
            onSelectionChanged: (s) => setState(() => optionA = s.first),
          ),
        ];
      case EntryType.water:
        return [
          TextField(
            controller: amountCtrl,
            keyboardType: TextInputType.number,
            decoration: const InputDecoration(labelText: '섭취량 (ml)', border: OutlineInputBorder()),
          ),
        ];
      case EntryType.snack:
        return [
          TextField(controller: nameCtrl, decoration: const InputDecoration(labelText: '종류/이름', border: OutlineInputBorder())),
          const SizedBox(height: 10),
          TextField(controller: amountCtrl, decoration: const InputDecoration(labelText: '양 (선택)', border: OutlineInputBorder())),
        ];
      case EntryType.litter:
        return [
          SegmentedButton<String>(
            segments: const [
              ButtonSegment(value: '소변', label: Text('소변')),
              ButtonSegment(value: '대변', label: Text('대변')),
            ],
            selected: {optionA == '건식' ? '소변' : optionA},
            onSelectionChanged: (s) => setState(() => optionA = s.first),
          ),
          const SizedBox(height: 10),
          TextField(
            controller: amountCtrl,
            decoration: const InputDecoration(labelText: '상태 (예: 정상/묽음/혈뇨...)', border: OutlineInputBorder()),
          ),
        ];
      case EntryType.medicine:
        return [
          TextField(controller: nameCtrl, decoration: const InputDecoration(labelText: '약 이름', border: OutlineInputBorder())),
          const SizedBox(height: 10),
          TextField(controller: amountCtrl, decoration: const InputDecoration(labelText: '용량/단위 (예: 1정, 2ml)', border: OutlineInputBorder())),
          const SizedBox(height: 10),
          SwitchListTile(
            contentPadding: EdgeInsets.zero,
            title: const Text('복용 여부'),
            value: taken,
            onChanged: (v) => setState(() => taken = v),
          ),
        ];
      case EntryType.hospital:
        return [
          TextField(controller: nameCtrl, decoration: const InputDecoration(labelText: '병원명', border: OutlineInputBorder())),
          const SizedBox(height: 10),
          TextField(
            controller: amountCtrl,
            keyboardType: TextInputType.number,
            decoration: const InputDecoration(labelText: '비용 (원)', border: OutlineInputBorder()),
          ),
        ];
      case EntryType.weight:
        return [
          TextField(
            controller: amountCtrl,
            keyboardType: const TextInputType.numberWithOptions(decimal: true),
            decoration: const InputDecoration(labelText: '체중 (kg)', border: OutlineInputBorder()),
          ),
        ];
    }
  }

  void _save() {
    final data = <String, dynamic>{};
    switch (widget.type) {
      case EntryType.food:
        data['amount_g'] = int.tryParse(amountCtrl.text.trim()) ?? 0;
        data['kind'] = optionA;
        break;
      case EntryType.water:
        data['amount_ml'] = int.tryParse(amountCtrl.text.trim()) ?? 0;
        break;
      case EntryType.snack:
        data['name'] = nameCtrl.text.trim();
        data['amount'] = amountCtrl.text.trim();
        break;
      case EntryType.litter:
        data['kind'] = optionA;
        data['status'] = amountCtrl.text.trim();
        break;
      case EntryType.medicine:
        data['name'] = nameCtrl.text.trim();
        data['dose'] = amountCtrl.text.trim();
        data['taken'] = taken;
        break;
      case EntryType.hospital:
        data['name'] = nameCtrl.text.trim();
        data['cost'] = int.tryParse(amountCtrl.text.trim()) ?? 0;
        break;
      case EntryType.weight:
        data['kg'] = double.tryParse(amountCtrl.text.trim()) ?? 0.0;
        break;
    }

    final entry = Entry(
      id: const Uuid().v4(),
      catId: widget.catId,
      type: widget.type,
      at: at,
      data: data,
      memo: memoCtrl.text.trim().isEmpty ? null : memoCtrl.text.trim(),
    );

    ref.read(entriesProvider.notifier).add(entry);
    Navigator.pop(context);
  }
}
