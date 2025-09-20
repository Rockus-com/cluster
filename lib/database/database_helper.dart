import 'package:cluster/database/models.dart';
import 'package:intl/intl.dart';
import 'package:sqflite/sqflite.dart';
import 'package:path/path.dart';


class DatabaseHelper {
  static final DatabaseHelper _instance = DatabaseHelper._internal();
  factory DatabaseHelper() => _instance;
  DatabaseHelper._internal();

  static Database? _database;

  Future<Database> get database async {
    if (_database != null) return _database!;
    _database = await _initDatabase();
    return _database!;
  }

  Future<Database> _initDatabase() async {
    final path = join(await getDatabasesPath(), 'secretary.db');
    return await openDatabase(
      path,
      version: 1,
      onCreate: _createDatabase,
    );
  }

  Future<void> _createDatabase(Database db, int version) async {
    // Таблица пользователей
    await db.execute('''
      CREATE TABLE users(
        id INTEGER PRIMARY KEY AUTOINCREMENT,
        username TEXT UNIQUE NOT NULL,
        password TEXT NOT NULL,
        fullName TEXT NOT NULL,
        email TEXT,
        phone TEXT,
        position TEXT,
        department TEXT,
        role TEXT,
        createdAt TEXT NOT NULL
      )
    ''');

    // Таблица задач
    await db.execute('''
      CREATE TABLE tasks(
        id INTEGER PRIMARY KEY AUTOINCREMENT,
        title TEXT NOT NULL,
        description TEXT,
        assignedBy TEXT NOT NULL,
        assignedTo INTEGER NOT NULL,
        assignedTime TEXT NOT NULL,
        deadline TEXT NOT NULL,
        status TEXT NOT NULL,
        FOREIGN KEY (assignedTo) REFERENCES users (id)
      )
    ''');

    // Таблица сообщений задач
    await db.execute('''
      CREATE TABLE task_messages(
        id INTEGER PRIMARY KEY AUTOINCREMENT,
        taskId INTEGER NOT NULL,
        senderId INTEGER NOT NULL,
        message TEXT NOT NULL,
        sentAt TEXT NOT NULL,
        FOREIGN KEY (taskId) REFERENCES tasks (id),
        FOREIGN KEY (senderId) REFERENCES users (id)
      )
    ''');

    // Таблица вложений задач
    await db.execute('''
      CREATE TABLE task_attachments(
        id INTEGER PRIMARY KEY AUTOINCREMENT,
        taskId INTEGER NOT NULL,
        fileName TEXT NOT NULL,
        filePath TEXT NOT NULL,
        uploadedAt TEXT NOT NULL,
        FOREIGN KEY (taskId) REFERENCES tasks (id)
      )
    ''');

    // Таблица коллег
    await db.execute('''
      CREATE TABLE colleagues(
        id INTEGER PRIMARY KEY AUTOINCREMENT,
        fullName TEXT NOT NULL,
        email TEXT,
        phone TEXT,
        position TEXT NOT NULL,
        department TEXT NOT NULL
      )
    ''');

    // Таблица групп
    await db.execute('''
      CREATE TABLE groups(
        id INTEGER PRIMARY KEY AUTOINCREMENT,
        name TEXT NOT NULL,
        description TEXT,
        memberIds TEXT NOT NULL,
        createdAt TEXT NOT NULL,
        createdBy INTEGER NOT NULL,
        FOREIGN KEY (createdBy) REFERENCES users (id)
      )
    ''');

    // Таблица сообщений групп
    await db.execute('''
      CREATE TABLE group_messages(
        id INTEGER PRIMARY KEY AUTOINCREMENT,
        groupId INTEGER NOT NULL,
        senderId INTEGER NOT NULL,
        message TEXT NOT NULL,
        sentAt TEXT NOT NULL,
        attachments TEXT,
        FOREIGN KEY (groupId) REFERENCES groups (id),
        FOREIGN KEY (senderId) REFERENCES users (id)
      )
    ''');

    // Таблица уведомлений групп
    await db.execute('''
      CREATE TABLE group_notifications(
        id INTEGER PRIMARY KEY AUTOINCREMENT,
        groupId INTEGER NOT NULL,
        userId INTEGER NOT NULL,
        messageId INTEGER NOT NULL,
        isRead INTEGER NOT NULL DEFAULT 0,
        FOREIGN KEY (groupId) REFERENCES groups (id),
        FOREIGN KEY (userId) REFERENCES users (id),
        FOREIGN KEY (messageId) REFERENCES group_messages (id)
      )
    ''');

    // Таблица расписания
    await db.execute('''
      CREATE TABLE schedule(
        id INTEGER PRIMARY KEY AUTOINCREMENT,
        date TEXT NOT NULL,
        startTime TEXT NOT NULL,
        endTime TEXT NOT NULL,
        subject TEXT NOT NULL,
        teacher TEXT,
        classroom TEXT,
        topics TEXT,
        isLesson INTEGER NOT NULL DEFAULT 1
      )
    ''');

    // Вставляем тестового пользователя
    await db.insert('users', {
      'username': 'admin',
      'password': '123456',
      'fullName': 'Администратор',
      'email': 'admin@school.ru',
      'phone': '+7 (999) 999-99-99',
      'position': 'Администратор',
      'department': 'Администрация',
      'role': 'admin',
      'createdAt': DateTime.now().toIso8601String(),
    });
  }

  // Методы для работы с пользователями
  Future<int> insertUser(User user) async {
    final db = await database;
    return await db.insert('users', user.toMap());
  }

  Future<User?> getUserById(int id) async {
    final db = await database;
    final maps = await db.query(
      'users',
      where: 'id = ?',
      whereArgs: [id],
    );
    if (maps.isNotEmpty) {
      return User.fromMap(maps.first);
    }
    return null;
  }

  Future<User?> getUserByUsername(String username) async {
    final db = await database;
    final maps = await db.query(
      'users',
      where: 'username = ?',
      whereArgs: [username],
    );
    if (maps.isNotEmpty) {
      return User.fromMap(maps.first);
    }
    return null;
  }

  Future<int> updateUser(User user) async {
    final db = await database;
    return await db.update(
      'users',
      user.toMap(),
      where: 'id = ?',
      whereArgs: [user.id],
    );
  }

  // Методы для работы с задачами
  Future<int> insertTask(Task task) async {
    final db = await database;
    return await db.insert('tasks', task.toMap());
  }

  Future<List<Task>> getTasks() async {
    final db = await database;
    final maps = await db.query('tasks');
    return List.generate(maps.length, (i) {
      return Task.fromMap(maps[i]);
    });
  }

  Future<int> updateTask(Task task) async {
    final db = await database;
    return await db.update(
      'tasks',
      task.toMap(),
      where: 'id = ?',
      whereArgs: [task.id],
    );
  }

  Future<int> deleteTask(int id) async {
    final db = await database;
    return await db.delete(
      'tasks',
      where: 'id = ?',
      whereArgs: [id],
    );
  }

  // Методы для работы с сообщениями задач
  Future<int> addMessageToTask(int taskId, Message message) async {
    final db = await database;
    return await db.insert('task_messages', {
      'taskId': taskId,
      'senderId': 1, // ID текущего пользователя
      'message': message.text,
      'sentAt': DateTime.now().toIso8601String(),
    });
  }

  // Методы для работы с коллегами
  Future<int> insertColleague(Colleague colleague) async {
    final db = await database;
    return await db.insert('colleagues', colleague.toMap());
  }

  Future<List<Colleague>> getColleagues() async {
    final db = await database;
    final maps = await db.query('colleagues');
    return List.generate(maps.length, (i) {
      return Colleague.fromMap(maps[i]);
    });
  }

  // Методы для работы с группами
  Future<int> insertGroup(Group group) async {
    final db = await database;
    return await db.insert('groups', group.toMap());
  }

  Future<List<Group>> getGroups() async {
    final db = await database;
    final maps = await db.query('groups');
    return List.generate(maps.length, (i) {
      return Group.fromMap(maps[i]);
    });
  }

  Future<int> updateGroup(Group group) async {
    final db = await database;
    return await db.update(
      'groups',
      group.toMap(),
      where: 'id = ?',
      whereArgs: [group.id],
    );
  }

  Future<int> deleteGroup(int id) async {
    final db = await database;
    return await db.delete(
      'groups',
      where: 'id = ?',
      whereArgs: [id],
    );
  }

  // Методы для работы с сообщениями групп
  Future<int> insertGroupMessage(GroupMessage message) async {
    final db = await database;
    return await db.insert('group_messages', message.toMap());
  }

  Future<List<GroupMessage>> getMessagesForGroup(int groupId) async {
    final db = await database;
    final maps = await db.query(
      'group_messages',
      where: 'groupId = ?',
      whereArgs: [groupId],
      orderBy: 'sentAt DESC',
    );
    return List.generate(maps.length, (i) {
      return GroupMessage.fromMap(maps[i]);
    });
  }

  // Методы для работы с расписанием
  Future<int> insertScheduleItem(ScheduleItem item) async {
    final db = await database;
    return await db.insert('schedule', item.toMap());
  }

  Future<List<ScheduleItem>> getScheduleForDate(DateTime date) async {
    final db = await database;
    final formattedDate = DateFormat('yyyy-MM-dd').format(date);
    final maps = await db.query(
      'schedule',
      where: 'date = ?',
      whereArgs: [formattedDate],
      orderBy: 'startTime ASC',
    );
    return List.generate(maps.length, (i) {
      return ScheduleItem.fromMap(maps[i]);
    });
  }

  Future<int> deleteScheduleItem(int id) async {
    final db = await database;
    return await db.delete(
      'schedule',
      where: 'id = ?',
      whereArgs: [id],
    );
  }

  // Закрытие базы данных
  Future<void> close() async {
    final db = await database;
    db.close();
  }
}