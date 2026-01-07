import 'package:flutter/material.dart';

enum EntryType { food, water, snack, litter, medicine, hospital, weight }

extension EntryTypeX on EntryType {
  String get label {
    switch (this) {
      case EntryType.food:
        return '사료';
      case EntryType.water:
        return '물';
      case EntryType.snack:
        return '간식';
      case EntryType.litter:
        return '배변';
      case EntryType.medicine:
        return '약';
      case EntryType.hospital:
        return '병원';
      case EntryType.weight:
        return '체중';
    }
  }

  IconData get icon {
    switch (this) {
      case EntryType.food:
        return Icons.restaurant;
      case EntryType.water:
        return Icons.water_drop;
      case EntryType.snack:
        return Icons.cookie;
      case EntryType.litter:
        return Icons.pets;
      case EntryType.medicine:
        return Icons.medication;
      case EntryType.hospital:
        return Icons.local_hospital;
      case EntryType.weight:
        return Icons.monitor_weight;
    }
  }
}

@immutable
class Entry {
  final String id;
  final String catId;
  final EntryType type;
  final DateTime at;
  final Map<String, dynamic> data;
  final String? memo;
  final String? photoPath; // ✅ 추가: 사진 경로(촬영/갤러리)

  const Entry({
    required this.id,
    required this.catId,
    required this.type,
    required this.at,
    required this.data,
    this.memo,
    this.photoPath, // ✅ 추가
  });

  Entry copyWith({
    EntryType? type,
    DateTime? at,
    Map<String, dynamic>? data,
    String? memo,
    String? photoPath, // ✅ 추가
  }) {
    return Entry(
      id: id,
      catId: catId,
      type: type ?? this.type,
      at: at ?? this.at,
      data: data ?? this.data,
      memo: memo ?? this.memo,
      photoPath: photoPath ?? this.photoPath, // ✅ 추가
    );
  }
}
