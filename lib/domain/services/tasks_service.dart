// lib/domain/services/tasks_service.dart
import 'package:cluster/data/repositories/tasks_repo.dart';
import 'package:cluster/domain/entities/task.dart';

class TasksService {
  final TasksRepo _repo;

  TasksService(this._repo);

  Future<List<Task>> loadTasks() => _repo.loadTasks();
  Future<Task> createTask(Task task) => _repo.createTask(task);
  Future<void> editTask(String taskId, Task task) => _repo.editTask(taskId, task);
  Future<void> deleteTask(String taskId) => _repo.deleteTask(taskId);
  Future<void> completeTask(String taskId) => _repo.completeTask(taskId);
}