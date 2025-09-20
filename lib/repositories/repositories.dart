import 'package:cluster/database/database_helper.dart';
import 'package:cluster/database/models.dart';

// Репозиторий для работы с пользователями
class UserRepository {
  final DatabaseHelper _dbHelper = DatabaseHelper();

  Future<int> insertUser(User user) async {
    return await _dbHelper.insertUser(user);
  }

  Future<User?> getUserById(int id) async {
    return await _dbHelper.getUserById(id);
  }

  Future<User?> getUserByUsername(String username) async {
    return await _dbHelper.getUserByUsername(username);
  }

  Future<int> updateUser(User user) async {
    return await _dbHelper.updateUser(user);
  }

  Future<List<User>> getAllUsers() async {
    // В реальном приложении здесь будет обращение к базе данных
    // Для примера возвращаем пустой список
    return [];
  }
}

// Репозиторий для работы с задачами
class TaskRepository {
  final DatabaseHelper _dbHelper = DatabaseHelper();
// В классе TaskRepository добавьте следующий метод:
Future<int> removeAttachmentFromTask(int taskId, int attachmentId) async {
  try {
    final db = await _dbHelper.database;
    return await db.delete(
      'task_attachments',
      where: 'id = ? AND taskId = ?',
      whereArgs: [attachmentId, taskId],
    );
  } catch (e) {
    throw Exception('Ошибка удаления вложения: $e');
  }
}

// В классе DatabaseHelper добавьте следующий метод:

  Future<int> insertTask(Task task) async {
    return await _dbHelper.insertTask(task);
  }

  Future<List<Task>> getTasks() async {
    return await _dbHelper.getTasks();
  }

  Future<List<Task>> getTasksForColleague(int colleagueId) async {
    final allTasks = await _dbHelper.getTasks();
    return allTasks.where((task) => task.assignedTo == colleagueId).toList();
  }

  Future<int> updateTask(Task task) async {
    return await _dbHelper.updateTask(task);
  }

  Future<int> deleteTask(int id) async {
    return await _dbHelper.deleteTask(id);
  }

  Future<int> addMessageToTask(int taskId, Message message) async {
    return await _dbHelper.addMessageToTask(taskId, message);
  }

  Future<List<Message>> getMessagesForTask(int taskId) async {
    // В реальном приложении здесь будет обращение к базе данных
    // Для примера возвращаем пустой список
    return [];
  }
}

// Репозиторий для работы с коллегами
class ColleagueRepository {
  final DatabaseHelper _dbHelper = DatabaseHelper();

  Future<int> insertColleague(Colleague colleague) async {
    return await _dbHelper.insertColleague(colleague);
  }

  Future<List<Colleague>> getColleagues() async {
    return await _dbHelper.getColleagues();
  }

  Future<List<Task>> getTasksForColleague(int colleagueId) async {
    final taskRepository = TaskRepository();
    final allTasks = await taskRepository.getTasks();
    return allTasks.where((task) => task.assignedTo == colleagueId).toList();
  }

  Future<int> updateColleague(Colleague colleague) async {
    // В реальном приложении здесь будет обращение к базе данных
    // Для примера возвращаем 0
    return 0;
  }

  Future<int> deleteColleague(int id) async {
    // В реальном приложении здесь будет обращение к базе данных
    // Для примера возвращаем 0
    return 0;
  }
}

// Репозиторий для работы с группами
class GroupRepository {
  final DatabaseHelper _dbHelper = DatabaseHelper();

  Future<int> insertGroup(Group group) async {
    return await _dbHelper.insertGroup(group);
  }

  Future<List<Group>> getGroups() async {
    return await _dbHelper.getGroups();
  }

  Future<List<Group>> getGroupsForColleague(int colleagueId) async {
    final allGroups = await _dbHelper.getGroups();
    return allGroups
        .where((group) => group.memberIds.contains(colleagueId))
        .toList();
  }

  Future<int> updateGroup(Group group) async {
    return await _dbHelper.updateGroup(group);
  }

  Future<int> deleteGroup(int id) async {
    return await _dbHelper.deleteGroup(id);
  }
}

// Репозиторий для работы с сообщениями групп
class GroupMessageRepository {
  final DatabaseHelper _dbHelper = DatabaseHelper();

  Future<int> insertMessage(GroupMessage message) async {
    return await _dbHelper.insertGroupMessage(message);
  }

  Future<List<GroupMessage>> getMessagesForGroup(int groupId) async {
    return await _dbHelper.getMessagesForGroup(groupId);
  }

  Future<int> deleteMessage(int id) async {
    // В реальном приложении здесь будет обращение к базе данных
    // Для примера возвращаем 0
    return 0;
  }
}

// Репозиторий для работы с уведомлениями групп
class GroupNotificationRepository {
  final DatabaseHelper _dbHelper = DatabaseHelper();

  Future<int> getUnreadCount(int groupId, int userId) async {
    // В реальном приложении здесь будет обращение к базе данных
    // Для примера возвращаем 0
    return 0;
  }

  Future<int> markAsRead(int groupId, int userId) async {
    // В реальном приложении здесь будет обращение к базе данных
    // Для примера возвращаем 0
    return 0;
  }

  Future<int> addNotification(GroupNotification notification) async {
    // В реальном приложении здесь будет обращение к базе данных
    // Для примера возвращаем 0
    return 0;
  }
}

// Репозиторий для работы с расписанием
class ScheduleRepository {
  final DatabaseHelper _dbHelper = DatabaseHelper();

  Future<int> insertScheduleItem(ScheduleItem item) async {
    return await _dbHelper.insertScheduleItem(item);
  }

  Future<List<ScheduleItem>> getScheduleForDate(DateTime date) async {
    return await _dbHelper.getScheduleForDate(date);
  }

  Future<List<ScheduleItem>> getScheduleForRange(
      DateTime startDate, DateTime endDate) async {
    // В реальном приложении здесь будет обращение к базе данных
    // Для примера возвращаем пустой список
    return [];
  }

  Future<int> updateScheduleItem(ScheduleItem item) async {
    // В реальном приложении здесь будет обращение к базе данных
    // Для примера возвращаем 0
    return 0;
  }

  Future<int> deleteScheduleItem(int id) async {
    return await _dbHelper.deleteScheduleItem(id);
  }
}
