import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:uuid/uuid.dart';

import '../models/action_item.dart';

class ActionsNotifier extends Notifier<List<ActionItem>> {
  @override
  List<ActionItem> build() {
    // ✅ 기본 항목 7개 + 체중 + 설정(설정은 실제 항목으로 저장하지 않음)
    // 기본 항목은 삭제 불가(isBuiltIn: true)
    const fontFamily = 'MaterialIcons';

    final base = <ActionItem>[
      ActionItem(
        id: 'action_food',
        name: '사료',
        colorValue: 0xFFFFA500, // orange
        iconCodePoint: Icons.restaurant.codePoint,
        iconFontFamily: fontFamily,
        units: ['g'],
        isHidden: false,
        isBuiltIn: true,
        order: 0,
      ),
      ActionItem(
        id: 'action_water',
        name: '물',
        colorValue: 0xFF2196F3, // blue
        iconCodePoint: Icons.water_drop.codePoint,
        iconFontFamily: fontFamily,
        units: ['ml'],
        isHidden: false,
        isBuiltIn: true,
        order: 1,
      ),
      ActionItem(
        id: 'action_snack',
        name: '간식',
        colorValue: 0xFFE91E63, // pink
        iconCodePoint: Icons.cookie.codePoint,
        iconFontFamily: fontFamily,
        units: ['g'],
        isHidden: false,
        isBuiltIn: true,
        order: 2,
      ),
      ActionItem(
        id: 'action_litter',
        name: '배변',
        colorValue: 0xFF795548, // brown
        iconCodePoint: Icons.pets.codePoint,
        iconFontFamily: fontFamily,
        units: [], // 배변은 단위 없음
        isHidden: false,
        isBuiltIn: true,
        order: 3,
      ),
      ActionItem(
        id: 'action_medicine',
        name: '약',
        colorValue: 0xFF9C27B0, // purple
        iconCodePoint: Icons.medication.codePoint,
        iconFontFamily: fontFamily,
        units: ['정', 'ml', 'g'],
        isHidden: false,
        isBuiltIn: true,
        order: 4,
      ),
      ActionItem(
        id: 'action_hospital',
        name: '병원',
        colorValue: 0xFFF44336, // red
        iconCodePoint: Icons.local_hospital.codePoint,
        iconFontFamily: fontFamily,
        units: ['원'],
        isHidden: false,
        isBuiltIn: true,
        order: 5,
      ),
      ActionItem(
        id: 'action_weight',
        name: '체중',
        colorValue: 0xFF009688, // teal
        iconCodePoint: Icons.monitor_weight.codePoint,
        iconFontFamily: fontFamily,
        units: ['kg'],
        isHidden: false,
        isBuiltIn: true,
        order: 6,
      ),
    ];

    return _normalizeOrder(base);
  }

  void addCustom({
    required String name,
    required Color color,
    required IconData icon,
    required List<String> units,
  }) {
    final id = const Uuid().v4();
    final nextOrder = state.isEmpty ? 0 : (state.map((e) => e.order).reduce((a, b) => a > b ? a : b) + 1);

    final item = ActionItem(
      id: id,
      name: name,
      colorValue: color.value,
      iconCodePoint: icon.codePoint,
      iconFontFamily: icon.fontFamily ?? 'MaterialIcons',
      iconFontPackage: icon.fontPackage,
      units: units,
      isHidden: false,
      isBuiltIn: false,
      order: nextOrder,
    );

    state = _normalizeOrder([...state, item]);
  }

  void toggleHidden(String id) {
    state = _normalizeOrder([
      for (final a in state)
        if (a.id == id) a.copyWith(isHidden: !a.isHidden) else a,
    ]);
  }

  void reorder(int oldIndex, int newIndex) {
    if (oldIndex < 0 || oldIndex >= state.length) return;
    if (newIndex < 0 || newIndex >= state.length) return;
    if (oldIndex == newIndex) return;

    final next = [...state]..sort((a, b) => a.order.compareTo(b.order));
    final item = next.removeAt(oldIndex);
    next.insert(newIndex, item);
    state = _normalizeOrder(next);
  }

  void removeCustomById(String id) {
    final target = state.where((e) => e.id == id).cast<ActionItem?>().firstWhere((e) => e != null, orElse: () => null);
    if (target == null) return;
    if (target.isBuiltIn) return; // ✅ 기본 항목은 삭제 불가

    state = _normalizeOrder(state.where((e) => e.id != id).toList(growable: false));
  }

  List<ActionItem> _normalizeOrder(List<ActionItem> list) {
    final sorted = [...list]..sort((a, b) => a.order.compareTo(b.order));
    return [
      for (int i = 0; i < sorted.length; i++)
        sorted[i].copyWith(order: i),
    ];
  }
}

final actionsProvider = NotifierProvider<ActionsNotifier, List<ActionItem>>(ActionsNotifier.new);
