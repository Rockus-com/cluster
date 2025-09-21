import '../models/task_model.dart';

abstract class TaskRepository {
  Future<List<TaskModel>> getTasks();
  Future<TaskModel> getTask(String id);
  Future<TaskModel> createTask(TaskModel task);
  Future<TaskModel> updateTask(TaskModel task);
  Future<void> deleteTask(String id);
  Future<void> completeTask(String id);
  Future<List<TaskModel>> getTasksByUser(String userId);
  Future<List<TaskModel>> getTasksAssignedToUser(String userId);
}