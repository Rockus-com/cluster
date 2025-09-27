// lib/data/repositories/tasks_repo.dart
import 'package:cluster/data/repositories/http_repo.dart';
import 'package:cluster/data/repositories/websocket_repo.dart';
import 'package:cluster/data/repositories/cache_repo.dart';
import 'package:cluster/domain/entities/task.dart';

abstract class TasksRepo {
  Future<List<Task>> loadTasks();
  Future<Task> createTask(Task task);
  Future<void> editTask(String taskId, Task task);
  Future<void> deleteTask(String taskId);
  Future<void> completeTask(String taskId);
}

class TasksRepoImpl implements TasksRepo {
  final HttpRepo _httpRepo;
  final WebSocketRepo _wsRepo;
  final CacheRepo _cacheRepo;

  TasksRepoImpl(this._httpRepo, this._wsRepo, this._cacheRepo);

  @override
  Future<List<Task>> loadTasks() async {
    final response = await _httpRepo.get('/tasks');
    return (response.data as List).map((e) => Task.fromJson(e)).toList();
  }

  @override
  Future<Task> createTask(Task task) async {
    final response = await _httpRepo.post('/tasks', task.toJson());
    return Task.fromJson(response.data);
  }

  @override
  Future<void> editTask(String taskId, Task task) async {
    await _httpRepo.put('/tasks/$taskId', task.toJson());
  }

  @override
  Future<void> deleteTask(String taskId) async {
    await _httpRepo.delete('/tasks/$taskId');
  }

  @override
  Future<void> completeTask(String taskId) async {
    await _httpRepo.post('/tasks/$taskId/complete', {});
  }
}