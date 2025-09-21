import 'package:equatable/equatable.dart';

class ChatModel extends Equatable {
  final String id;
  final String name;
  final List<String> members;
  final DateTime createdAt;
  final bool isGroup;

  const ChatModel({
    required this.id,
    required this.name,
    required this.members,
    required this.createdAt,
    this.isGroup = false,
  });

  factory ChatModel.fromJson(Map<String, dynamic> json) {
    return ChatModel(
      id: json['_id'] ?? json['id'],
      name: json['name'],
      members: List<String>.from(json['members']),
      createdAt: DateTime.parse(json['created_at'] ?? json['createdAt']),
      isGroup: json['is_group'] ?? json['isGroup'] ?? false,
    );
  }

  Map<String, dynamic> toJson() {
    return {
      '_id': id,
      'name': name,
      'members': members,
      'created_at': createdAt.toIso8601String(),
      'is_group': isGroup,
    };
  }

  ChatModel copyWith({
    String? id,
    String? name,
    List<String>? members,
    DateTime? createdAt,
    bool? isGroup,
  }) {
    return ChatModel(
      id: id ?? this.id,
      name: name ?? this.name,
      members: members ?? this.members,
      createdAt: createdAt ?? this.createdAt,
      isGroup: isGroup ?? this.isGroup,
    );
  }

  @override
  List<Object?> get props => [
        id,
        name,
        members,
        createdAt,
        isGroup,
      ];
}