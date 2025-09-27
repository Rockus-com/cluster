// lib/domain/entities/chat.dart
import 'package:json_annotation/json_annotation.dart';

part 'chat.g.dart';

@JsonSerializable()
class Chat {
  final String? id;
  final String name;
  final List<String> members;
  final DateTime? createdAt;
  final bool isGroup;

  Chat({
    this.id,
    required this.name,
    required this.members,
    this.createdAt,
    this.isGroup = false,
  });

  factory Chat.fromJson(Map<String, dynamic> json) => _$ChatFromJson(json);
  Map<String, dynamic> toJson() => _$ChatToJson(this);
}