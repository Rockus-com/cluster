import 'package:intl/intl.dart';

// Модель пользователя
class User {
  final int id;
  final String username;
  final String password;
  final String fullName;
  final String email;
  final String phone;
  final String position;
  final String department;
  final String role;
  final DateTime createdAt;

  User({
    this.id = 0,
    required this.username,
    required this.password,
    required this.fullName,
    this.email = '',
    this.phone = '',
    this.position = '',
    this.department = '',
    this.role = 'user',
    required this.createdAt,
  });

  Map<String, dynamic> toMap() {
    return {
      'id': id,
      'username': username,
      'password': password,
      'fullName': fullName,
      'email': email,
      'phone': phone,
      'position': position,
      'department': department,
      'role': role,
      'createdAt': createdAt.toIso8601String(),
    };
  }

  factory User.fromMap(Map<String, dynamic> map) {
    return User(
      id: map['id'],
      username: map['username'],
      password: map['password'],
      fullName: map['fullName'],
      email: map['email'] ?? '',
      phone: map['phone'] ?? '',
      position: map['position'] ?? '',
      department: map['department'] ?? '',
      role: map['role'] ?? 'user',
      createdAt: DateTime.parse(map['createdAt']),
    );
  }
}

// Модель задачи
class Task {
  final int? id;
  final String title;
  final String description;
  final String assignedBy;
  final int assignedTo;
  final DateTime assignedTime;
  final DateTime deadline;
  final String status;
  final List<Message> messages;
  final List<Attachment> attachments;

  Task({
    this.id,
    required this.title,
    required this.description,
    required this.assignedBy,
    required this.assignedTo,
    required this.assignedTime,
    required this.deadline,
    this.status = 'pending',
    this.messages = const [],
    this.attachments = const [],
  });

  Map<String, dynamic> toMap() {
    return {
      'id': id,
      'title': title,
      'description': description,
      'assignedBy': assignedBy,
      'assignedTo': assignedTo,
      'assignedTime': assignedTime.toIso8601String(),
      'deadline': deadline.toIso8601String(),
      'status': status,
    };
  }

  factory Task.fromMap(Map<String, dynamic> map) {
    return Task(
      id: map['id'],
      title: map['title'],
      description: map['description'] ?? '',
      assignedBy: map['assignedBy'],
      assignedTo: map['assignedTo'],
      assignedTime: DateTime.parse(map['assignedTime']),
      deadline: DateTime.parse(map['deadline']),
      status: map['status'] ?? 'pending',
      messages: [],
      attachments: [],
    );
  }
}

// Модель сообщения
class Message {
  final int? id;
  final String text;
  final String sender;
  final DateTime time;

  Message({
    this.id,
    required this.text,
    required this.sender,
    required this.time,
  });

  Map<String, dynamic> toMap() {
    return {
      'id': id,
      'text': text,
      'sender': sender,
      'time': time.toIso8601String(),
    };
  }

  factory Message.fromMap(Map<String, dynamic> map) {
    return Message(
      id: map['id'],
      text: map['text'],
      sender: map['sender'],
      time: DateTime.parse(map['time']),
    );
  }
}

// Модель вложения
class Attachment {
  final int? id;
  final String fileName;
  final String filePath;
  final DateTime uploadedAt;

  Attachment({
    this.id,
    required this.fileName,
    required this.filePath,
    required this.uploadedAt,
  });

  Map<String, dynamic> toMap() {
    return {
      'id': id,
      'fileName': fileName,
      'filePath': filePath,
      'uploadedAt': uploadedAt.toIso8601String(),
    };
  }

  factory Attachment.fromMap(Map<String, dynamic> map) {
    return Attachment(
      id: map['id'],
      fileName: map['fileName'],
      filePath: map['filePath'],
      uploadedAt: DateTime.parse(map['uploadedAt']),
    );
  }
}

// Модель коллеги
class Colleague {
  final int id;
  final String fullName;
  final String email;
  final String phone;
  final String position;
  final String department;

  Colleague({
    required this.id,
    required this.fullName,
    this.email = '',
    this.phone = '',
    required this.position,
    required this.department,
  });

  Map<String, dynamic> toMap() {
    return {
      'id': id,
      'fullName': fullName,
      'email': email,
      'phone': phone,
      'position': position,
      'department': department,
    };
  }

  factory Colleague.fromMap(Map<String, dynamic> map) {
    return Colleague(
      id: map['id'],
      fullName: map['fullName'],
      email: map['email'] ?? '',
      phone: map['phone'] ?? '',
      position: map['position'],
      department: map['department'],
    );
  }
}

// Модель группы
class Group {
  final int id;
  String name;
  final String description;
  List<int> memberIds;
  final DateTime createdAt;
  final int createdBy;

  Group({
    required this.id,
    required this.name,
    this.description = '',
    required this.memberIds,
    required this.createdAt,
    required this.createdBy,
  });

  Map<String, dynamic> toMap() {
    return {
      'id': id,
      'name': name,
      'description': description,
      'memberIds': memberIds.join(','),
      'createdAt': createdAt.toIso8601String(),
      'createdBy': createdBy,
    };
  }

  factory Group.fromMap(Map<String, dynamic> map) {
    return Group(
      id: map['id'],
      name: map['name'],
      description: map['description'] ?? '',
      memberIds: (map['memberIds'] as String)
          .split(',')
          .map((id) => int.parse(id))
          .toList(),
      createdAt: DateTime.parse(map['createdAt']),
      createdBy: map['createdBy'],
    );
  }
}

// Модель сообщения группы
class GroupMessage {
  final int id;
  final int groupId;
  final int senderId;
  final String message;
  final DateTime sentAt;
  final List<String> attachments;

  GroupMessage({
    required this.id,
    required this.groupId,
    required this.senderId,
    required this.message,
    required this.sentAt,
    this.attachments = const [],
  });

  Map<String, dynamic> toMap() {
    return {
      'id': id,
      'groupId': groupId,
      'senderId': senderId,
      'message': message,
      'sentAt': sentAt.toIso8601String(),
      'attachments': attachments.join(','),
    };
  }

  factory GroupMessage.fromMap(Map<String, dynamic> map) {
    return GroupMessage(
      id: map['id'],
      groupId: map['groupId'],
      senderId: map['senderId'],
      message: map['message'],
      sentAt: DateTime.parse(map['sentAt']),
      attachments: (map['attachments'] as String?)?.split(',') ?? [],
    );
  }
}

// Модель уведомления группы
class GroupNotification {
  final int id;
  final int groupId;
  final int userId;
  final int messageId;
  final bool isRead;

  GroupNotification({
    required this.id,
    required this.groupId,
    required this.userId,
    required this.messageId,
    this.isRead = false,
  });

  Map<String, dynamic> toMap() {
    return {
      'id': id,
      'groupId': groupId,
      'userId': userId,
      'messageId': messageId,
      'isRead': isRead ? 1 : 0,
    };
  }

  factory GroupNotification.fromMap(Map<String, dynamic> map) {
    return GroupNotification(
      id: map['id'],
      groupId: map['groupId'],
      userId: map['userId'],
      messageId: map['messageId'],
      isRead: map['isRead'] == 1,
    );
  }
}

// Модель элемента расписания
class ScheduleItem {
  final int? id;
  final DateTime date;
  final String startTime;
  final String endTime;
  final String subject;
  final String teacher;
  final String classroom;
  final List<String> topics;
  final bool isLesson;

  ScheduleItem({
    this.id,
    required this.date,
    required this.startTime,
    required this.endTime,
    required this.subject,
    this.teacher = '',
    this.classroom = '',
    this.topics = const [],
    this.isLesson = true,
  });

  Map<String, dynamic> toMap() {
    return {
      'id': id,
      'date': DateFormat('yyyy-MM-dd').format(date),
      'startTime': startTime,
      'endTime': endTime,
      'subject': subject,
      'teacher': teacher,
      'classroom': classroom,
      'topics': topics.join(';'),
      'isLesson': isLesson ? 1 : 0,
    };
  }

  factory ScheduleItem.fromMap(Map<String, dynamic> map) {
    return ScheduleItem(
      id: map['id'],
      date: DateTime.parse(map['date']),
      startTime: map['startTime'],
      endTime: map['endTime'],
      subject: map['subject'],
      teacher: map['teacher'] ?? '',
      classroom: map['classroom'] ?? '',
      topics: (map['topics'] as String?)?.split(';') ?? [],
      isLesson: map['isLesson'] == 1,
    );
  }
}
