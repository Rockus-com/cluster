import 'package:flutter/material.dart';
import 'package:intl/intl.dart';
import 'package:file_picker/file_picker.dart';
import 'package:cluster/database/models.dart';
import 'package:cluster/repositories/repositories.dart';

class TaskDetailScreen extends StatefulWidget {
  final Task task;

  const TaskDetailScreen({super.key, required this.task});

  @override
  _TaskDetailScreenState createState() => _TaskDetailScreenState();
}

class _TaskDetailScreenState extends State<TaskDetailScreen> {
  final TaskRepository _taskRepository = TaskRepository();
  final TextEditingController _messageController = TextEditingController();
  List<String> _attachments = [];
  bool _isLoading = false;

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Детали задачи'),
        backgroundColor: Colors.blue[700],
        foregroundColor: Colors.white,
        actions: [
          IconButton(
            icon: const Icon(Icons.edit),
            onPressed: _editTask,
            tooltip: 'Редактировать задачу',
          ),
          IconButton(
            icon: const Icon(Icons.delete),
            onPressed: _deleteTask,
            tooltip: 'Удалить задачу',
            color: Colors.red,
          ),
        ],
      ),
      body: Column(
        children: [
          // Информация о задаче
          Expanded(
            child: SingleChildScrollView(
              padding: const EdgeInsets.all(16),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  // Заголовок
                  Text(
                    widget.task.title,
                    style: const TextStyle(
                      fontSize: 24,
                      fontWeight: FontWeight.bold,
                    ),
                  ),
                  const SizedBox(height: 16),

                  // Описание
                  Text(
                    widget.task.description,
                    style: const TextStyle(fontSize: 16),
                  ),
                  const SizedBox(height: 16),

                  // Информация о задаче
                  _buildInfoRow('От:', widget.task.assignedBy),
                  _buildInfoRow(
                      'Поставлена:',
                      DateFormat('dd.MM.yyyy HH:mm')
                          .format(widget.task.assignedTime)),
                  _buildInfoRow(
                      'Срок:',
                      DateFormat('dd.MM.yyyy HH:mm')
                          .format(widget.task.deadline)),
                  _buildInfoRow('Статус:', _getStatusText(widget.task.status)),

                  const SizedBox(height: 16),

                  // Вложения
                  if (widget.task.attachments.isNotEmpty) ...[
                    const Text(
                      'Прикрепленные файлы:',
                      style: TextStyle(
                        fontWeight: FontWeight.bold,
                        fontSize: 16,
                      ),
                    ),
                    const SizedBox(height: 8),
                    Wrap(
                      spacing: 8,
                      children: widget.task.attachments.map((attachment) {
                        return Chip(
                          label: Text(attachment.fileName),
                          onDeleted: () => _removeAttachment(attachment),
                          deleteIcon: const Icon(Icons.close, size: 16),
                        );
                      }).toList(),
                    ),
                    const SizedBox(height: 16),
                  ],

                  // Чат задачи
                  const Text(
                    'Чат задачи:',
                    style: TextStyle(
                      fontWeight: FontWeight.bold,
                      fontSize: 16,
                    ),
                  ),
                  const SizedBox(height: 8),

                  // Сообщения
                  _buildMessagesList(),
                ],
              ),
            ),
          ),

          // Поле ввода сообщения
          Container(
            padding: const EdgeInsets.all(8),
            color: Colors.grey[100],
            child: Row(
              children: [
                IconButton(
                  icon: const Icon(Icons.attach_file),
                  onPressed: _attachFile,
                  tooltip: 'Прикрепить файл',
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
                  tooltip: 'Отправить сообщение',
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildInfoRow(String label, String value) {
    return Padding(
      padding: const EdgeInsets.symmetric(vertical: 4),
      child: Row(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(
            label,
            style: const TextStyle(fontWeight: FontWeight.bold),
          ),
          const SizedBox(width: 8),
          Expanded(child: Text(value)),
        ],
      ),
    );
  }

  Widget _buildMessagesList() {
    if (widget.task.messages.isEmpty) {
      return const Center(
        child: Text('Нет сообщений'),
      );
    }

    return ListView.builder(
      shrinkWrap: true,
      physics: const NeverScrollableScrollPhysics(),
      itemCount: widget.task.messages.length,
      itemBuilder: (context, index) {
        return _buildMessageBubble(widget.task.messages[index]);
      },
    );
  }

  Widget _buildMessageBubble(Message message) {
    final isMe = message.sender == 'Вы';

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
                  child: Text(message.text),
                ),
                const SizedBox(height: 4),
                Text(
                  '${message.sender}, ${DateFormat('HH:mm').format(message.time)}',
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

  Future<void> _sendMessage() async {
    if (_messageController.text.trim().isEmpty) return;

    final newMessage = Message(
      text: _messageController.text,
      sender:
          'Вы', // В реальном приложении здесь будет имя текущего пользователя
      time: DateTime.now(),
    );

    try {
      setState(() {
        _isLoading = true;
      });

      // Добавляем сообщение в базу данных
      await _taskRepository.addMessageToTask(widget.task.id!, newMessage);

      // Обновляем локальный список сообщений
      setState(() {
        widget.task.messages.add(newMessage);
        _messageController.clear();
      });

      // Отправляем уведомления другим участникам (если есть)
      // await NotificationService().sendTaskMessageNotification(...);
    } catch (e) {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text('Ошибка отправки сообщения: $e')),
      );
    } finally {
      setState(() {
        _isLoading = false;
      });
    }
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

        // В реальном приложении здесь будет сохранение файлов
        // и добавление информации о вложениях в базу данных
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(content: Text('Файлы прикреплены')),
        );
      }
    } catch (e) {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text('Ошибка при выборе файла: $e')),
      );
    }
  }

  Future<void> _removeAttachment(Attachment attachment) async {
    try {
      // Удаляем вложение из базы данных
      await _taskRepository.removeAttachmentFromTask(
          widget.task.id!, attachment.id!);

      // Обновляем локальный список вложений
      setState(() {
        widget.task.attachments.remove(attachment);
      });

      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('Файл удален')),
      );
    } catch (e) {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text('Ошибка удаления файла: $e')),
      );
    }
  }

  Future<void> _editTask() async {
    // TODO: Реализовать редактирование задачи
    ScaffoldMessenger.of(context).showSnackBar(
      const SnackBar(
          content: Text('Функция редактирования задачи в разработке')),
    );
  }

  Future<void> _deleteTask() async {
    final confirmed = await showDialog<bool>(
      context: context,
      builder: (BuildContext context) {
        return AlertDialog(
          title: const Text('Удаление задачи'),
          content: const Text('Вы уверены, что хотите удалить эту задачу?'),
          actions: [
            TextButton(
              onPressed: () => Navigator.of(context).pop(false),
              child: const Text('Отмена'),
            ),
            TextButton(
              onPressed: () => Navigator.of(context).pop(true),
              child: const Text('Удалить', style: TextStyle(color: Colors.red)),
            ),
          ],
        );
      },
    );

    if (confirmed == true) {
      try {
        await _taskRepository.deleteTask(widget.task.id!);
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(content: Text('Задача удалена')),
        );
        Navigator.of(context).pop();
      } catch (e) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(content: Text('Ошибка удаления задачи: $e')),
        );
      }
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
