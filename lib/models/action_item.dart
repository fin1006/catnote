import 'package:flutter/foundation.dart';
import 'package:flutter/material.dart';

@immutable
class ActionItem {
  final String id;
  final String name;
  final int colorValue; // Color 저장용 (ARGB int)
  final int iconCodePoint; // IconData 저장용 (codePoint)
  final String iconFontFamily;
  final String? iconFontPackage;

  final List<String> units; // 섭취량 단위 등 (예: g, ml, 캔, 정...)
  final bool isHidden;
  final bool isBuiltIn; // 기본 항목이면 삭제 불가
  final int order;

  const ActionItem({
    required this.id,
    required this.name,
    required this.colorValue,
    required this.iconCodePoint,
    required this.iconFontFamily,
    this.iconFontPackage,
    required this.units,
    required this.isHidden,
    required this.isBuiltIn,
    required this.order,
  });

  Color get color => Color(colorValue);

  IconData get icon => IconData(
    iconCodePoint,
    fontFamily: iconFontFamily,
    fontPackage: iconFontPackage,
  );

  ActionItem copyWith({
    String? name,
    int? colorValue,
    int? iconCodePoint,
    String? iconFontFamily,
    String? iconFontPackage,
    List<String>? units,
    bool? isHidden,
    bool? isBuiltIn,
    int? order,
  }) {
    return ActionItem(
      id: id,
      name: name ?? this.name,
      colorValue: colorValue ?? this.colorValue,
      iconCodePoint: iconCodePoint ?? this.iconCodePoint,
      iconFontFamily: iconFontFamily ?? this.iconFontFamily,
      iconFontPackage: iconFontPackage ?? this.iconFontPackage,
      units: units ?? this.units,
      isHidden: isHidden ?? this.isHidden,
      isBuiltIn: isBuiltIn ?? this.isBuiltIn,
      order: order ?? this.order,
    );
  }
}
