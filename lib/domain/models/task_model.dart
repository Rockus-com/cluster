import 'package:equatable/equatable.dart';

enum TaskStatus { pending, inProgress, completed }

class TaskModel extends Equatable {
  final String id;
  final String title;
  final String? description;
  final String assigneeId;
  final String creatorId;
  final DateTime? dueDate;
  final TaskStatus status;
  final DateTime createdAt;

  const TaskModel({
    required this.id,
    required this.title,
    this.description,
    required this.assigneeId,
    required this.creatorId,
    this.dueDate,
    required this.status,
    required this.createdAt,
  });

  factory TaskModel.fromJson(Map<String, dynamic> json) {
    return TaskModel(
      id: json['_id'] ?? json['id'],
      title: json['title'],
      description: json['description'],
      assigneeId: json['assignee_id'] ?? json['assigneeId'],
      creatorId: json['creator_id'] ?? json['creatorId'],
      dueDate: json['due_date'] != null ? DateTime.parse(json['due_date']) : null,
      status: _parseStatus(json['status']),
      createdAt: DateTime.parse(json['created_at'] ?? json['createdAt']),
    );
  }

  static TaskStatus _parseStatus(String status) {
    switch (status) {
      case 'in_progress':
        return TaskStatus.inProgress;
      case 'completed':
        return TaskStatus.completed;
      default:
        return TaskStatus.pending;
    }
  }

  static String _statusToString(TaskStatus status) {
    switch (status) {
      case TaskStatus.inProgress:
        return 'in_progress';
      case TaskStatus.completed:
        return 'completed';
      default:
        return 'pending';
    }
  }

  Map<String, dynamic> toJson() {
    return {
      '_id': id,
      'title': title,
      'description': description,
      'assignee_id': assigneeId,
      'creator_id': creatorId,
      'due_date': dueDate?.toIso8601String(),
      'status': _statusToString(status),
      'created_at': createdAt.toIso8601String(),
    };
  }

  TaskModel copyWith({
    String? id,
    String? title,
    String? description,
    String? assigneeId,
    String? creatorId,
    DateTime? dueDate,
    TaskStatus? status,
    DateTime? createdAt,
  }) {
    return TaskModel(
      id: id ?? this.id,
      title: title ?? this.title,
      description: description ?? this.description,
      assigneeId: assigneeId ?? this.assigneeId,
      creatorId: creatorId ?? this.creatorId,
      dueDate: dueDate ?? this.dueDate,
      status: status ?? this.status,
      createdAt: createdAt ?? this.createdAt,
    );
  }

  @override
  List<Object?> get props => [
        id,
        title,
        description,
        assigneeId,
        creatorId,
        dueDate,
        status,
        createdAt,
      ];
}