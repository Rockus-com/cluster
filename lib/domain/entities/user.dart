// lib/domain/entities/user.dart
import 'package:json_annotation/json_annotation.dart';

part 'user.g.dart';

@JsonSerializable()
class User {
  final String? id;
  final String username;
  final String email;
  final String? password;
  final String? fullName;
  final String? profilePic;
  final DateTime? createdAt;

  User({
    this.id,
    required this.username,
    required this.email,
    this.password,
    this.fullName,
    this.profilePic,
    this.createdAt,
  });

  factory User.fromJson(Map<String, dynamic> json) => _$UserFromJson(json);
  Map<String, dynamic> toJson() => _$UserToJson(this);
}