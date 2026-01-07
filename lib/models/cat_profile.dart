import 'package:flutter/foundation.dart';

@immutable
class CatProfile {
  final String id;
  final String name;
  final DateTime? birthday;
  final String? sex;
  final String? breed;
  final String? photoUrl;   // 기존: 네트워크용
  final String? photoPath;  // ✅ 추가: 로컬 사진 경로
  final String? traits;     // ✅ 추가: 특징/메모

  const CatProfile({
    required this.id,
    required this.name,
    this.birthday,
    this.sex,
    this.breed,
    this.photoUrl,
    this.photoPath,
    this.traits,
  });

  CatProfile copyWith({
    String? name,
    DateTime? birthday,
    String? sex,
    String? breed,
    String? photoUrl,
    String? photoPath,
    String? traits,
  }) {
    return CatProfile(
      id: id,
      name: name ?? this.name,
      birthday: birthday ?? this.birthday,
      sex: sex ?? this.sex,
      breed: breed ?? this.breed,
      photoUrl: photoUrl ?? this.photoUrl,
      photoPath: photoPath ?? this.photoPath,
      traits: traits ?? this.traits,
    );
  }
}
