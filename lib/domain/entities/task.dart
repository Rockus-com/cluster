// lib/domain/entities/task.dart
import 'package:json_annotation/json_annotation.dart';

part 'task.g.dart';

@JsonSerializable()
class Task {
  final String? id;
  final String title;
  final String? description;
  final String assigneeId;
  final String creatorId;
  final DateTime? dueDate;
  final String status;
  final DateTime? createdAt;

  Task({
    this.id,
    required this.title,
    this.description,
    required this.assigneeId,
    required this.creatorId,
    this.dueDate,
    this.status = 'pending',
    this.createdAt,
  });

  factory Task.fromJson(Map<String, dynamic> json) => _$TaskFromJson(json);
  Map<String, dynamic> toJson() => _$TaskToJson(this);
}