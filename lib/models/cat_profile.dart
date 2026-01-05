import 'package:flutter/foundation.dart';

@immutable
class CatProfile {
  final String id;
  final String name;
  final DateTime? birthday;
  final String? sex;
  final String? breed;
  final String? photoUrl;

  const CatProfile({
    required this.id,
    required this.name,
    this.birthday,
    this.sex,
    this.breed,
    this.photoUrl,
  });

  CatProfile copyWith({
    String? name,
    DateTime? birthday,
    String? sex,
    String? breed,
    String? photoUrl,
  }) {
    return CatProfile(
      id: id,
      name: name ?? this.name,
      birthday: birthday ?? this.birthday,
      sex: sex ?? this.sex,
      breed: breed ?? this.breed,
      photoUrl: photoUrl ?? this.photoUrl,
    );
  }
}
