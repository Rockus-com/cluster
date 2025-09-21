import 'package:dio/dio.dart';

import '../../../domain/models/task_model.dart';
import '../../../domain/repositories/task_repository.dart';
import '../../services/http_service.dart';

class TaskRepositoryImpl implements TaskRepository {
  final HttpService httpService;

  TaskRepositoryImpl({required this.httpService});

  @override
  Future<List<TaskModel>> getTasks() async {
    try {
      final response = await httpService.get('/tasks');
      final List<dynamic> tasksData = response.data;
      return tasksData.map((data) => TaskModel.fromJson(data)).toList();
    } on DioError catch (e) {
      throw Exception(e.response?.data['detail'] ?? 'Failed to load tasks');
    }
  }

  @override
  Future<TaskModel> getTask(String id) async {
    try {
      final response = await httpService.get('/tasks/$id');
      return TaskModel.fromJson(response.data);
    } on DioError catch (e) {
      throw Exception(e.response?.data['detail'] ?? 'Failed to load task');
    }
  }

  @override
  Future<TaskModel> createTask(TaskModel task) async {
    try {
      final response = await httpService.post(
        '/tasks',
        data: task.toJson(),
      );
      return TaskModel.fromJson(response.data);
    } on DioError catch (e) {
      throw Exception(e.response?.data['detail'] ?? 'Failed to create task');
    }
  }

  @override
  Future<TaskModel> updateTask(TaskModel task) async {
    try {
      final response = await httpService.put(
        '/tasks/${task.id}',
        data: task.toJson(),
      );
      return TaskModel.fromJson(response.data);
    } on DioError catch (e) {
      throw Exception(e.response?.data['detail'] ?? 'Failed to update task');
    }
  }

  @override
  Future<void> deleteTask(String id) async {
    try {
      await httpService.delete('/tasks/$id');
    } on DioError catch (e) {
      throw Exception(e.response?.data['detail'] ?? 'Failed to delete task');
    }
  }

  @override
  Future<void> completeTask(String id) async {
    try {
      await httpService.post('/tasks/$id/complete');
    } on DioError catch (e) {
      throw Exception(e.response?.data['detail'] ?? 'Failed to complete task');
    }
  }

  @override
  Future<List<TaskModel>> getTasksByUser(String userId) async {
    try {
      final response = await httpService.get('/tasks', queryParameters: {
        'creator_id': userId,
      });
      final List<dynamic> tasksData = response.data;
      return tasksData.map((data) => TaskModel.fromJson(data)).toList();
    } on DioError catch (e) {
      throw Exception(e.response?.data['detail'] ?? 'Failed to load user tasks');
    }
  }

  @override
  Future<List<TaskModel>> getTasksAssignedToUser(String userId) async {
    try {
      final response = await httpService.get('/tasks', queryParameters: {
        'assignee_id': userId,
      });
      final List<dynamic> tasksData = response.data;
      return tasksData.map((data) => TaskModel.fromJson(data)).toList();
    } on DioError catch (e) {
      throw Exception(e.response?.data['detail'] ?? 'Failed to load assigned tasks');
    }
  }
}