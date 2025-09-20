import 'package:cluster/screens/tasks/task_detail.dart';
import 'package:flutter/material.dart';
import 'package:intl/intl.dart';
import 'package:cluster/database/models.dart';
import 'package:cluster/repositories/repositories.dart';

class TasksScreen extends StatefulWidget {
  const TasksScreen({super.key});

  @override
  _TasksScreenState createState() => _TasksScreenState();
}

class _TasksScreenState extends State<TasksScreen> {
  final TaskRepository _taskRepository = TaskRepository();
  List<Task> _tasks = [];
  List<Task> _filteredTasks = [];
  bool _isLoading = true;
  String _filterStatus = 'all';
  String _searchQuery = '';

  @override
  void initState() {
    super.initState();
    _loadTasks();
  }

  Future<void> _loadTasks() async {
    try {
      final tasks = await _taskRepository.getTasks();
      setState(() {
        _tasks = tasks;
        _filteredTasks = _filterTasks(tasks, _filterStatus, _searchQuery);
        _isLoading = false;
      });
    } catch (e) {
      setState(() {
        _isLoading = false;
      });
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text('Ошибка загрузки задач: $e')),
      );
    }
  }

  List<Task> _filterTasks(List<Task> tasks, String status, String query) {
    List<Task> filtered = tasks;

    // Фильтрация по статусу
    if (status != 'all') {
      filtered = filtered.where((task) => task.status == status).toList();
    }

    // Фильтрация по поисковому запросу
    if (query.isNotEmpty) {
      filtered = filtered.where((task) {
        return task.title.toLowerCase().contains(query.toLowerCase()) ||
            task.description.toLowerCase().contains(query.toLowerCase()) ||
            task.assignedBy.toLowerCase().contains(query.toLowerCase());
      }).toList();
    }

    // Сортировка по сроку выполнения (сначала просроченные, затем по дате)
    filtered.sort((a, b) {
      final now = DateTime.now();
      final aIsOverdue = a.status != 'completed' && a.deadline.isBefore(now);
      final bIsOverdue = b.status != 'completed' && b.deadline.isBefore(now);

      if (aIsOverdue && !bIsOverdue) return -1;
      if (!aIsOverdue && bIsOverdue) return 1;

      return a.deadline.compareTo(b.deadline);
    });

    return filtered;
  }

  void _applyFilter(String status) {
    setState(() {
      _filterStatus = status;
      _filteredTasks = _filterTasks(_tasks, status, _searchQuery);
    });
  }

  void _searchTasks(String query) {
    setState(() {
      _searchQuery = query;
      _filteredTasks = _filterTasks(_tasks, _filterStatus, query);
    });
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Задачи от руководства'),
        backgroundColor: Colors.blue[700],
        foregroundColor: Colors.white,
        actions: [
          IconButton(
            icon: const Icon(Icons.search),
            onPressed: () {
              showSearch(
                context: context,
                delegate: TaskSearchDelegate(_tasks, _searchTasks),
              );
            },
            tooltip: 'Поиск задач',
          ),
          IconButton(
            icon: const Icon(Icons.filter_list),
            onPressed: _showFilterDialog,
            tooltip: 'Фильтровать задачи',
          ),
          IconButton(
            icon: const Icon(Icons.add),
            onPressed: _addTask,
            tooltip: 'Добавить задачу',
          ),
        ],
      ),
      body: _isLoading
          ? const Center(child: CircularProgressIndicator())
          : _filteredTasks.isEmpty
              ? _buildEmptyState()
              : ListView.builder(
                  padding: const EdgeInsets.all(16),
                  itemCount: _filteredTasks.length,
                  itemBuilder: (context, index) {
                    return _buildTaskCard(_filteredTasks[index], context);
                  },
                ),
    );
  }

  Widget _buildEmptyState() {
    return Center(
      child: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          const Icon(Icons.assignment, size: 64, color: Colors.grey),
          const SizedBox(height: 16),
          Text(
            _searchQuery.isNotEmpty || _filterStatus != 'all'
                ? 'Задачи не найдены'
                : 'Нет задач',
            style: const TextStyle(fontSize: 18),
          ),
          const SizedBox(height: 8),
          Text(
            _searchQuery.isNotEmpty || _filterStatus != 'all'
                ? 'Попробуйте изменить параметры поиска или фильтра'
                : 'Нажмите + чтобы добавить новую задачу',
            textAlign: TextAlign.center,
            style: const TextStyle(color: Colors.grey),
          ),
        ],
      ),
    );
  }

  Widget _buildTaskCard(Task task, BuildContext context) {
    final isOverdue =
        task.status != 'completed' && task.deadline.isBefore(DateTime.now());

    return Card(
      margin: const EdgeInsets.only(bottom: 16),
      child: InkWell(
        onTap: () => _navigateToTaskDetail(context, task),
        child: Padding(
          padding: const EdgeInsets.all(16),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              // Заголовок и статус
              Row(
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                children: [
                  Expanded(
                    child: Text(
                      task.title,
                      style: const TextStyle(
                        fontSize: 18,
                        fontWeight: FontWeight.bold,
                      ),
                    ),
                  ),
                  _buildStatusIndicator(task.status),
                ],
              ),
              const SizedBox(height: 8),

              // Описание
              Text(
                task.description,
                maxLines: 2,
                overflow: TextOverflow.ellipsis,
                style: TextStyle(color: Colors.grey[700]),
              ),
              const SizedBox(height: 12),

              // Информация о задаче
              Row(
                children: [
                  const Icon(Icons.person, size: 16, color: Colors.grey),
                  const SizedBox(width: 4),
                  Text(
                    task.assignedBy,
                    style: const TextStyle(fontSize: 14, color: Colors.grey),
                  ),
                ],
              ),
              const SizedBox(height: 4),

              Row(
                children: [
                  const Icon(Icons.access_time, size: 16, color: Colors.grey),
                  const SizedBox(width: 4),
                  Text(
                    'Поставлена: ${DateFormat('dd.MM.yyyy HH:mm').format(task.assignedTime)}',
                    style: const TextStyle(fontSize: 14, color: Colors.grey),
                  ),
                ],
              ),
              const SizedBox(height: 4),

              Row(
                children: [
                  Icon(
                    Icons.timer,
                    size: 16,
                    color: isOverdue ? Colors.red : Colors.grey,
                  ),
                  const SizedBox(width: 4),
                  Text(
                    'Срок: ${DateFormat('dd.MM.yyyy HH:mm').format(task.deadline)}',
                    style: TextStyle(
                      fontSize: 14,
                      color: isOverdue ? Colors.red : Colors.grey,
                      fontWeight:
                          isOverdue ? FontWeight.bold : FontWeight.normal,
                    ),
                  ),
                ],
              ),
              const SizedBox(height: 8),

              // Вложения и сообщения
              Row(
                children: [
                  if (task.attachments.isNotEmpty) ...[
                    const Icon(Icons.attach_file, size: 16, color: Colors.grey),
                    const SizedBox(width: 4),
                    Text(
                      '${task.attachments.length} файл(ов)',
                      style: const TextStyle(fontSize: 14, color: Colors.grey),
                    ),
                    const SizedBox(width: 16),
                  ],
                  const Icon(Icons.chat, size: 16, color: Colors.grey),
                  const SizedBox(width: 4),
                  Text(
                    '${task.messages.length} сообщ.',
                    style: const TextStyle(fontSize: 14, color: Colors.grey),
                  ),
                ],
              ),
            ],
          ),
        ),
      ),
    );
  }

  Widget _buildStatusIndicator(String status) {
    Color color;
    String text;

    switch (status) {
      case 'pending':
        color = Colors.orange;
        text = 'Ожидает';
        break;
      case 'inProgress':
        color = Colors.blue;
        text = 'В работе';
        break;
      case 'completed':
        color = Colors.green;
        text = 'Завершена';
        break;
      default:
        color = Colors.grey;
        text = 'Неизвестно';
    }

    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
      decoration: BoxDecoration(
        color: color.withOpacity(0.2),
        borderRadius: BorderRadius.circular(12),
      ),
      child: Text(
        text,
        style: TextStyle(
          color: color,
          fontSize: 12,
          fontWeight: FontWeight.bold,
        ),
      ),
    );
  }

  void _navigateToTaskDetail(BuildContext context, Task task) {
    Navigator.push(
      context,
      MaterialPageRoute(
        builder: (context) => TaskDetailScreen(task: task),
      ),
    );
  }

  void _showFilterDialog() {
    showDialog(
      context: context,
      builder: (BuildContext context) {
        return AlertDialog(
          title: const Text('Фильтр задач'),
          content: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              RadioListTile<String>(
                title: const Text('Все задачи'),
                value: 'all',
                groupValue: _filterStatus,
                onChanged: (value) {
                  Navigator.of(context).pop();
                  _applyFilter(value!);
                },
              ),
              RadioListTile<String>(
                title: const Text('Ожидают'),
                value: 'pending',
                groupValue: _filterStatus,
                onChanged: (value) {
                  Navigator.of(context).pop();
                  _applyFilter(value!);
                },
              ),
              RadioListTile<String>(
                title: const Text('В работе'),
                value: 'inProgress',
                groupValue: _filterStatus,
                onChanged: (value) {
                  Navigator.of(context).pop();
                  _applyFilter(value!);
                },
              ),
              RadioListTile<String>(
                title: const Text('Завершены'),
                value: 'completed',
                groupValue: _filterStatus,
                onChanged: (value) {
                  Navigator.of(context).pop();
                  _applyFilter(value!);
                },
              ),
            ],
          ),
        );
      },
    );
  }

  void _addTask() {
    // TODO: Реализовать добавление новой задачи
    ScaffoldMessenger.of(context).showSnackBar(
      const SnackBar(content: Text('Функция добавления задачи в разработке')),
    );
  }
}

// Делегат для поиска задач
class TaskSearchDelegate extends SearchDelegate {
  final List<Task> tasks;
  final Function(String) onSearchChanged;

  TaskSearchDelegate(this.tasks, this.onSearchChanged);

  @override
  List<Widget> buildActions(BuildContext context) {
    return [
      IconButton(
        icon: const Icon(Icons.clear),
        onPressed: () {
          query = '';
          onSearchChanged(query);
        },
      ),
    ];
  }

  @override
  Widget buildLeading(BuildContext context) {
    return IconButton(
      icon: const Icon(Icons.arrow_back),
      onPressed: () {
        close(context, null);
      },
    );
  }

  @override
  Widget buildResults(BuildContext context) {
    return _buildSearchResults();
  }

  @override
  Widget buildSuggestions(BuildContext context) {
    return _buildSearchResults();
  }

  Widget _buildSearchResults() {
    final filteredTasks = query.isEmpty
        ? tasks
        : tasks.where((task) {
            return task.title.toLowerCase().contains(query.toLowerCase()) ||
                task.description.toLowerCase().contains(query.toLowerCase()) ||
                task.assignedBy.toLowerCase().contains(query.toLowerCase());
          }).toList();

    return ListView.builder(
      itemCount: filteredTasks.length,
      itemBuilder: (context, index) {
        final task = filteredTasks[index];
        return ListTile(
          title: Text(task.title),
          subtitle: Text(task.description),
          trailing: _buildStatusIndicator(task.status),
          onTap: () {
            close(context, null);
            Navigator.push(
              context,
              MaterialPageRoute(
                builder: (context) => TaskDetailScreen(task: task),
              ),
            );
          },
        );
      },
    );
  }

  Widget _buildStatusIndicator(String status) {
    Color color;

    switch (status) {
      case 'pending':
        color = Colors.orange;
        break;
      case 'inProgress':
        color = Colors.blue;
        break;
      case 'completed':
        color = Colors.green;
        break;
      default:
        color = Colors.grey;
    }

    return Container(
      width: 12,
      height: 12,
      decoration: BoxDecoration(
        color: color,
        shape: BoxShape.circle,
      ),
    );
  }
}
