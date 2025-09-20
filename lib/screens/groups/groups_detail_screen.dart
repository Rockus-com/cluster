import 'package:cluster/screens/tasks/task_detail.dart';
import 'package:flutter/material.dart';
import 'package:file_picker/file_picker.dart';
import 'package:intl/intl.dart';
import 'package:cluster/database/models.dart';
import 'package:cluster/repositories/repositories.dart';

class GroupDetailScreen extends StatefulWidget {
  final Group group;

  const GroupDetailScreen({super.key, required this.group});

  @override
  _GroupDetailScreenState createState() => _GroupDetailScreenState();
}

class _GroupDetailScreenState extends State<GroupDetailScreen> {
  final TaskRepository _taskRepository = TaskRepository();
  final GroupMessageRepository _messageRepository = GroupMessageRepository();
  final ColleagueRepository _colleagueRepository = ColleagueRepository();
  final GroupNotificationRepository _notificationRepository =
      GroupNotificationRepository();
  final TextEditingController _messageController = TextEditingController();

  List<Task> _tasks = [];
  List<GroupMessage> _messages = [];
  List<Colleague> _members = [];
  List<Colleague> _allColleagues = [];
  List<String> _attachments = [];
  int _unreadCount = 0;
  bool _isLoading = true;
  bool _isEditing = false;
  final TextEditingController _groupNameController = TextEditingController();
  final TextEditingController _groupDescriptionController =
      TextEditingController();

  @override
  void initState() {
    super.initState();
    _groupNameController.text = widget.group.name;
    _groupDescriptionController.text = widget.group.description;
    _loadGroupData();
  }

  Future<void> _loadGroupData() async {
    try {
      // Загружаем задачи для участников группы
      final allTasks = await _taskRepository.getTasks();
      _tasks = allTasks
          .where((task) => widget.group.memberIds.contains(task.assignedTo))
          .toList();

      // Загружаем сообщения группы
      _messages = await _messageRepository.getMessagesForGroup(widget.group.id);

      // Загружаем информацию об участниках
      final allColleagues = await _colleagueRepository.getColleagues();
      _members = allColleagues
          .where((colleague) => widget.group.memberIds.contains(colleague.id))
          .toList();
      _allColleagues = allColleagues;

      // Загружаем количество непрочитанных сообщений
      _unreadCount = await _notificationRepository.getUnreadCount(
          widget.group.id, 1); // 1 - ID текущего пользователя

      setState(() {
        _isLoading = false;
      });
    } catch (e) {
      setState(() {
        _isLoading = false;
      });
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text('Ошибка загрузки данных группы: $e')),
      );
    }
  }

  void _navigateToTaskDetail(BuildContext context, Task task) {
    Navigator.push(
      context,
      MaterialPageRoute(
        builder: (context) => TaskDetailScreen(task: task),
      ),
    );
  }

  Future<void> _sendMessage() async {
    if (_messageController.text.trim().isEmpty) return;

    final newMessage = GroupMessage(
      id: 0, // Будет присвоен автоматически
      groupId: widget.group.id,
      senderId: 1, // ID текущего пользователя
      message: _messageController.text,
      sentAt: DateTime.now(),
      attachments: _attachments,
    );

    try {
      await _messageRepository.insertMessage(newMessage);

      // Отправляем уведомления другим участникам группы
      for (final member in _members) {
        if (member.id != 1) {
          // Не отправляем уведомление себе
          // В реальном приложении здесь будет вызов сервиса уведомлений
          // await NotificationService().showGroupMessageNotification(...);
        }
      }

      _messageController.clear();
      _attachments.clear();
      await _loadGroupData(); // Перезагружаем сообщения

      // Помечаем сообщения как прочитанные
      await _notificationRepository.markAsRead(widget.group.id, 1);
      setState(() {
        _unreadCount = 0;
      });
    } catch (e) {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text('Ошибка отправки сообщения: $e')),
      );
    }
  }

  Future<void> _updateGroup() async {
    try {
      final updatedGroup = Group(
        id: widget.group.id,
        name: _groupNameController.text,
        description: _groupDescriptionController.text,
        memberIds: widget.group.memberIds,
        createdAt: widget.group.createdAt,
        createdBy: widget.group.createdBy,
      );

      await GroupRepository().updateGroup(updatedGroup);
      setState(() {
        _isEditing = false;
      });
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('Группа обновлена')),
      );
    } catch (e) {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text('Ошибка обновления группы: $e')),
      );
    }
  }

  Future<void> _addMembers(List<int> newMemberIds) async {
    setState(() {
      widget.group.memberIds.addAll(newMemberIds);
      widget.group.memberIds =
          widget.group.memberIds.toSet().toList(); // Убираем дубликаты
    });
    await _updateGroup();
    await _loadGroupData(); // Перезагружаем данные
  }

  Future<void> _removeMember(int memberId) async {
    setState(() {
      widget.group.memberIds.remove(memberId);
    });
    await _updateGroup();
    await _loadGroupData(); // Перезагружаем данные
  }

  Future<void> _attachFile() async {
    try {
      FilePickerResult? result = await FilePicker.platform.pickFiles(
        type: FileType.any,
        allowMultiple: true,
      );

      if (result != null) {
        setState(() {
          _attachments.addAll(result.files.map((file) => file.name));
        });
      }
    } catch (e) {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text('Ошибка при выборе файла: $e')),
      );
    }
  }

  void _showAddMembersDialog() {
    showDialog(
      context: context,
      builder: (BuildContext context) {
        return AddMembersDialog(
          allColleagues: _allColleagues,
          currentMemberIds: widget.group.memberIds,
          onMembersAdded: _addMembers,
        );
      },
    );
  }

  @override
  Widget build(BuildContext context) {
    return DefaultTabController(
      length: 3,
      child: Scaffold(
        appBar: AppBar(
          title: _isEditing
              ? TextField(
                  controller: _groupNameController,
                  onChanged: (value) => widget.group.name = value,
                  style: const TextStyle(color: Colors.white),
                  decoration: const InputDecoration(
                    hintText: 'Название группы',
                    border: InputBorder.none,
                  ),
                )
              : Text(widget.group.name),
          backgroundColor: Colors.blue[700],
          foregroundColor: Colors.white,
          actions: [
            if (!_isEditing)
              IconButton(
                icon: const Icon(Icons.edit),
                onPressed: () => setState(() => _isEditing = true),
                tooltip: 'Редактировать группу',
              ),
            if (_isEditing)
              IconButton(
                icon: const Icon(Icons.save),
                onPressed: _updateGroup,
                tooltip: 'Сохранить изменения',
              ),
            if (_isEditing)
              IconButton(
                icon: const Icon(Icons.cancel),
                onPressed: () => setState(() => _isEditing = false),
                tooltip: 'Отменить редактирование',
              ),
          ],
          bottom: const TabBar(
            tabs: [
              Tab(icon: Icon(Icons.assignment), text: 'Задачи'),
              Tab(icon: Icon(Icons.chat), text: 'Чат'),
              Tab(icon: Icon(Icons.people), text: 'Участники'),
            ],
          ),
        ),
        body: _isLoading
            ? const Center(child: CircularProgressIndicator())
            : TabBarView(
                children: [
                  // Вкладка задач
                  _buildTasksTab(),

                  // Вкладка чата
                  _buildChatTab(),

                  // Вкладка участников
                  _buildMembersTab(),
                ],
              ),
      ),
    );
  }

  Widget _buildTasksTab() {
    return _tasks.isEmpty
        ? const Center(child: Text('Нет задач в этой группе'))
        : ListView.builder(
            padding: const EdgeInsets.all(16),
            itemCount: _tasks.length,
            itemBuilder: (context, index) {
              final task = _tasks[index];
              final isOverdue = task.status != 'completed' &&
                  task.deadline.isBefore(DateTime.now());

              return Card(
                margin: const EdgeInsets.only(bottom: 16),
                child: ListTile(
                  title: Text(
                    task.title,
                    style: const TextStyle(fontWeight: FontWeight.bold),
                  ),
                  subtitle: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(task.description),
                      const SizedBox(height: 4),
                      Text(
                        'Срок: ${DateFormat('dd.MM.yyyy').format(task.deadline)}',
                        style: TextStyle(
                          color: isOverdue ? Colors.red : Colors.grey,
                          fontWeight:
                              isOverdue ? FontWeight.bold : FontWeight.normal,
                        ),
                      ),
                    ],
                  ),
                  trailing: Container(
                    padding:
                        const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
                    decoration: BoxDecoration(
                      color: _getStatusColor(task.status),
                      borderRadius: BorderRadius.circular(12),
                    ),
                    child: Text(
                      _getStatusText(task.status),
                      style: const TextStyle(
                        color: Colors.white,
                        fontSize: 12,
                        fontWeight: FontWeight.bold,
                      ),
                    ),
                  ),
                  onTap: () => _navigateToTaskDetail(context, task),
                ),
              );
            },
          );
  }

  Widget _buildChatTab() {
    return Column(
      children: [
        Expanded(
          child: ListView.builder(
            padding: const EdgeInsets.all(16),
            itemCount: _messages.length,
            itemBuilder: (context, index) {
              return _buildMessageBubble(_messages[index]);
            },
          ),
        ),
        Container(
          padding: const EdgeInsets.all(8),
          color: Colors.grey[100],
          child: Column(
            children: [
              if (_attachments.isNotEmpty) ...[
                SizedBox(
                  height: 40,
                  child: ListView.builder(
                    scrollDirection: Axis.horizontal,
                    itemCount: _attachments.length,
                    itemBuilder: (context, index) {
                      return Chip(
                        label: Text(_attachments[index]),
                        onDeleted: () {
                          setState(() {
                            _attachments.removeAt(index);
                          });
                        },
                      );
                    },
                  ),
                ),
                const SizedBox(height: 8),
              ],
              Row(
                children: [
                  IconButton(
                    icon: const Icon(Icons.attach_file),
                    onPressed: _attachFile,
                  ),
                  Expanded(
                    child: TextField(
                      controller: _messageController,
                      decoration: const InputDecoration(
                        hintText: 'Введите сообщение...',
                        border: OutlineInputBorder(),
                      ),
                    ),
                  ),
                  IconButton(
                    icon: const Icon(Icons.send),
                    onPressed: _sendMessage,
                  ),
                ],
              ),
            ],
          ),
        ),
      ],
    );
  }

  Widget _buildMembersTab() {
    return Column(
      children: [
        if (_isEditing)
          Padding(
            padding: const EdgeInsets.all(16),
            child: ElevatedButton.icon(
              onPressed: () => _showAddMembersDialog(),
              icon: const Icon(Icons.person_add),
              label: const Text('Добавить участников'),
            ),
          ),
        Expanded(
          child: ListView.builder(
            padding: const EdgeInsets.all(16),
            itemCount: _members.length,
            itemBuilder: (context, index) {
              final member = _members[index];
              return Card(
                margin: const EdgeInsets.only(bottom: 16),
                child: ListTile(
                  leading: CircleAvatar(
                    backgroundColor: Colors.blue[100],
                    child: Text(
                      member.fullName
                          .split(' ')
                          .map((n) => n[0])
                          .take(2)
                          .join(),
                      style: const TextStyle(fontWeight: FontWeight.bold),
                    ),
                  ),
                  title: Text(member.fullName),
                  subtitle: Text(member.position),
                  trailing:
                      _isEditing && member.id != 1 // Не позволяем удалить себя
                          ? IconButton(
                              icon: const Icon(Icons.remove_circle,
                                  color: Colors.red),
                              onPressed: () => _removeMember(member.id),
                            )
                          : null,
                ),
              );
            },
          ),
        ),
      ],
    );
  }

  Widget _buildMessageBubble(GroupMessage message) {
    // В реальном приложении нужно получить данные отправителя из базы
    final isMe =
        message.senderId == 1; // Заглушка: текущий пользователь имеет ID=1

    return Container(
      margin: const EdgeInsets.symmetric(vertical: 4),
      child: Row(
        crossAxisAlignment: CrossAxisAlignment.start,
        mainAxisAlignment:
            isMe ? MainAxisAlignment.end : MainAxisAlignment.start,
        children: [
          if (!isMe)
            const CircleAvatar(
              radius: 16,
              child: Icon(Icons.person, size: 16),
            ),
          if (!isMe) const SizedBox(width: 8),
          Expanded(
            child: Column(
              crossAxisAlignment:
                  isMe ? CrossAxisAlignment.end : CrossAxisAlignment.start,
              children: [
                Container(
                  padding: const EdgeInsets.all(12),
                  decoration: BoxDecoration(
                    color: isMe ? Colors.blue[100] : Colors.grey[200],
                    borderRadius: BorderRadius.circular(16),
                  ),
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(message.message),
                      if (message.attachments.isNotEmpty) ...[
                        const SizedBox(height: 8),
                        Wrap(
                          spacing: 4,
                          children: message.attachments.map((attachment) {
                            return Chip(
                              label: Text(attachment),
                              backgroundColor: Colors.blue[50],
                            );
                          }).toList(),
                        ),
                      ],
                    ],
                  ),
                ),
                const SizedBox(height: 4),
                Text(
                  '${isMe ? 'Вы' : 'Коллега'}, ${DateFormat('HH:mm').format(message.sentAt)}',
                  style: const TextStyle(fontSize: 12, color: Colors.grey),
                ),
              ],
            ),
          ),
          if (isMe) const SizedBox(width: 8),
          if (isMe)
            const CircleAvatar(
              radius: 16,
              backgroundColor: Colors.blue,
              child: Icon(Icons.person, size: 16, color: Colors.white),
            ),
        ],
      ),
    );
  }

  Color _getStatusColor(String status) {
    switch (status) {
      case 'completed':
        return Colors.green;
      case 'inProgress':
        return Colors.blue;
      case 'pending':
        return Colors.orange;
      default:
        return Colors.grey;
    }
  }

  String _getStatusText(String status) {
    switch (status) {
      case 'completed':
        return 'Завершена';
      case 'inProgress':
        return 'В работе';
      case 'pending':
        return 'Ожидает';
      default:
        return 'Неизвестно';
    }
  }
}

// Диалог добавления участников
class AddMembersDialog extends StatefulWidget {
  final List<Colleague> allColleagues;
  final List<int> currentMemberIds;
  final Function(List<int>) onMembersAdded;

  const AddMembersDialog({
    super.key,
    required this.allColleagues,
    required this.currentMemberIds,
    required this.onMembersAdded,
  });

  @override
  _AddMembersDialogState createState() => _AddMembersDialogState();
}

class _AddMembersDialogState extends State<AddMembersDialog> {
  List<int> _selectedColleagueIds = [];

  @override
  Widget build(BuildContext context) {
    final availableColleagues = widget.allColleagues
        .where((colleague) => !widget.currentMemberIds.contains(colleague.id))
        .toList();

    return AlertDialog(
      title: const Text('Добавить участников'),
      content: SizedBox(
        width: double.maxFinite,
        child: availableColleagues.isEmpty
            ? const Text('Все сотрудники уже добавлены в группу')
            : ListView.builder(
                shrinkWrap: true,
                itemCount: availableColleagues.length,
                itemBuilder: (context, index) {
                  final colleague = availableColleagues[index];
                  return CheckboxListTile(
                    title: Text(colleague.fullName),
                    subtitle: Text(colleague.position),
                    value: _selectedColleagueIds.contains(colleague.id),
                    onChanged: (bool? value) {
                      setState(() {
                        if (value == true) {
                          _selectedColleagueIds.add(colleague.id);
                        } else {
                          _selectedColleagueIds.remove(colleague.id);
                        }
                      });
                    },
                  );
                },
              ),
      ),
      actions: [
        TextButton(
          onPressed: () => Navigator.of(context).pop(),
          child: const Text('Отмена'),
        ),
        ElevatedButton(
          onPressed: () {
            widget.onMembersAdded(_selectedColleagueIds);
            Navigator.of(context).pop();
          },
          child: const Text('Добавить'),
        ),
      ],
    );
  }
}
