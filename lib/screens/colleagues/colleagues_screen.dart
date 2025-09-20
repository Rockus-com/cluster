import 'package:flutter/material.dart';
import 'package:secretary/database/models.dart';
import 'package:secretary/repositories/repositories.dart';
import 'package:secretary/screens/tasks/task_detail_screen.dart';
import 'package:intl/intl.dart';

class ColleaguesScreen extends StatefulWidget {
  const ColleaguesScreen({super.key});

  @override
  _ColleaguesScreenState createState() => _ColleaguesScreenState();
}

class _ColleaguesScreenState extends State<ColleaguesScreen> {
  final ColleagueRepository _colleagueRepository = ColleagueRepository();
  final GroupRepository _groupRepository = GroupRepository();
  final TaskRepository _taskRepository = TaskRepository();
  
  List<Colleague> _colleagues = [];
  bool _isLoading = true;

  @override
  void initState() {
    super.initState();
    _loadColleagues();
  }

  Future<void> _loadColleagues() async {
    try {
      final colleagues = await _colleagueRepository.getColleagues();
      setState(() {
        _colleagues = colleagues;
        _isLoading = false;
      });
    } catch (e) {
      setState(() {
        _isLoading = false;
      });
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text('Ошибка загрузки данных: $e')),
      );
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Коллеги'),
        backgroundColor: Colors.blue[700],
        foregroundColor: Colors.white,
        actions: [
          IconButton(
            icon: const Icon(Icons.refresh),
            onPressed: _loadColleagues,
            tooltip: 'Обновить',
          ),
        ],
      ),
      body: _isLoading
          ? const Center(child: CircularProgressIndicator())
          : _colleagues.isEmpty
              ? const Center(child: Text('Нет данных о коллегах'))
              : ListView.builder(
                  padding: const EdgeInsets.all(16),
                  itemCount: _colleagues.length,
                  itemBuilder: (context, index) {
                    return _buildColleagueCard(_colleagues[index], context);
                  },
                ),
    );
  }

  Widget _buildColleagueCard(Colleague colleague, BuildContext context) {
    return Card(
      margin: const EdgeInsets.only(bottom: 16),
      child: InkWell(
        onTap: () => _showColleagueDetails(context, colleague),
        child: Padding(
          padding: const EdgeInsets.all(16),
          child: Row(
            children: [
              // Аватар
              CircleAvatar(
                radius: 24,
                backgroundColor: Colors.blue[100],
                child: Text(
                  colleague.fullName.split(' ').map((n) => n[0]).take(2).join(),
                  style: const TextStyle(fontWeight: FontWeight.bold),
                ),
              ),
              const SizedBox(width: 16),
              // Информация
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      colleague.fullName,
                      style: const TextStyle(
                        fontSize: 18,
                        fontWeight: FontWeight.bold,
                      ),
                    ),
                    const SizedBox(height: 4),
                    Text(
                      colleague.position,
                      style: TextStyle(
                        fontSize: 16,
                        color: Colors.grey[700],
                      ),
                    ),
                    const SizedBox(height: 4),
                    Text(
                      colleague.department,
                      style: const TextStyle(fontSize: 14, color: Colors.grey),
                    ),
                  ],
                ),
              ),
              const Icon(Icons.arrow_forward_ios, size: 16),
            ],
          ),
        ),
      ),
    );
  }

  void _showColleagueDetails(BuildContext context, Colleague colleague) {
    showModalBottomSheet(
      context: context,
      isScrollControlled: true,
      builder: (BuildContext context) {
        return ColleagueDetailBottomSheet(colleague: colleague);
      },
    );
  }
}

// Виджет деталей сотрудника
class ColleagueDetailBottomSheet extends StatefulWidget {
  final Colleague colleague;

  const ColleagueDetailBottomSheet({super.key, required this.colleague});

  @override
  _ColleagueDetailBottomSheetState createState() => _ColleagueDetailBottomSheetState();
}

class _ColleagueDetailBottomSheetState extends State<ColleagueDetailBottomSheet> {
  final ColleagueRepository _colleagueRepository = ColleagueRepository();
  final GroupRepository _groupRepository = GroupRepository();
  final TaskRepository _taskRepository = TaskRepository();
  
  List<Group> _groups = [];
  List<Task> _tasks = [];
  bool _isLoading = true;

  @override
  void initState() {
    super.initState();
    _loadColleagueData();
  }

  Future<void> _loadColleagueData() async {
    try {
      final groups = await _groupRepository.getGroupsForColleague(widget.colleague.id);
      final tasks = await _colleagueRepository.getTasksForColleague(widget.colleague.id);
      
      setState(() {
        _groups = groups;
        _tasks = tasks;
        _isLoading = false;
      });
    } catch (e) {
      setState(() {
        _isLoading = false;
      });
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text('Ошибка загрузки данных: $e')),
      );
    }
  }

  @override
  Widget build(BuildContext context) {
    return DraggableScrollableSheet(
      expand: false,
      initialChildSize: 0.9,
      maxChildSize: 0.9,
      builder: (_, controller) {
        return Container(
          padding: const EdgeInsets.all(16),
          child: _isLoading
              ? const Center(child: CircularProgressIndicator())
              : Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Center(
                      child: Container(
                        width: 40,
                        height: 4,
                        decoration: BoxDecoration(
                          color: Colors.grey[300],
                          borderRadius: BorderRadius.circular(2),
                        ),
                      ),
                    ),
                    const SizedBox(height: 16),
                    
                    // Заголовок
                    Center(
                      child: Text(
                        widget.colleague.fullName,
                        style: const TextStyle(
                          fontSize: 20,
                          fontWeight: FontWeight.bold,
                        ),
                      ),
                    ),
                    const SizedBox(height: 8),
                    
                    // Должность и отдел
                    Center(
                      child: Text(
                        '${widget.colleague.position}, ${widget.colleague.department}',
                        style: TextStyle(
                          fontSize: 16,
                          color: Colors.grey[700],
                        ),
                      ),
                    ),
                    const SizedBox(height: 16),
                    
                    // Контакты
                    const Text(
                      'Контакты:',
                      style: TextStyle(fontWeight: FontWeight.bold),
                    ),
                    const SizedBox(height: 8),
                    _buildContactInfo(Icons.email, widget.colleague.email),
                    _buildContactInfo(Icons.phone, widget.colleague.phone),
                    const SizedBox(height: 16),
                    
                    // Группы
                    const Text(
                      'Группы:',
                      style: TextStyle(fontWeight: FontWeight.bold),
                    ),
                    const SizedBox(height: 8),
                    _groups.isEmpty
                        ? const Text('Не состоит в группах')
                        : Wrap(
                            spacing: 8,
                            children: _groups.map((group) {
                              return Chip(
                                label: Text(group.name),
                                backgroundColor: Colors.blue[50],
                              );
                            }).toList(),
                          ),
                    const SizedBox(height: 16),
                    
                    // Статистика задач
                    const Text(
                      'Задачи:',
                      style: TextStyle(fontWeight: FontWeight.bold),
                    ),
                    const SizedBox(height: 8),
                    _buildTaskStatistics(),
                    const SizedBox(height: 16),
                    
                    // Список задач
                    Expanded(
                      child: ListView.builder(
                        controller: controller,
                        itemCount: _tasks.length,
                        itemBuilder: (context, index) {
                          return _buildTaskCard(_tasks[index], context);
                        },
                      ),
                    ),
                  ],
                ),
        );
      },
    );
  }

  Widget _buildContactInfo(IconData icon, String text) {
    return Padding(
      padding: const EdgeInsets.symmetric(vertical: 4),
      child: Row(
        children: [
          Icon(icon, size: 16, color: Colors.grey),
          const SizedBox(width: 8),
          Text(text),
        ],
      ),
    );
  }

  Widget _buildTaskStatistics() {
    final totalTasks = _tasks.length;
    final completedTasks = _tasks.where((task) => task.status == 'completed').length;
    final overdueTasks = _tasks.where((task) {
      return task.status != 'completed' && task.deadline.isBefore(DateTime.now());
    }).length;
    
    return Row(
      mainAxisAlignment: MainAxisAlignment.spaceAround,
      children: [
        _buildStatisticCard('Всего', totalTasks.toString(), Colors.blue),
        _buildStatisticCard('Выполнено', completedTasks.toString(), Colors.green),
        _buildStatisticCard('Просрочено', overdueTasks.toString(), Colors.red),
      ],
    );
  }

  Widget _buildStatisticCard(String title, String value, Color color) {
    return Column(
      children: [
        Text(
          value,
          style: TextStyle(
            fontSize: 20,
            fontWeight: FontWeight.bold,
            color: color,
          ),
        ),
        const SizedBox(height: 4),
        Text(
          title,
          style: const TextStyle(fontSize: 14, color: Colors.grey),
        ),
      ],
    );
  }

  Widget _buildTaskCard(Task task, BuildContext context) {
    final isOverdue = task.status != 'completed' && task.deadline.isBefore(DateTime.now());
    
    return Card(
      margin: const EdgeInsets.only(bottom: 8),
      child: InkWell(
        onTap: () {
          Navigator.pop(context); // Закрыть bottom sheet
          Navigator.push(
            context,
            MaterialPageRoute(
              builder: (context) => TaskDetailScreen(task: task),
            ),
          );
        },
        child: Padding(
          padding: const EdgeInsets.all(12),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text(
                task.title,
                style: const TextStyle(
                  fontSize: 16,
                  fontWeight: FontWeight.bold,
                ),
              ),
              const SizedBox(height: 4),
              Text(
                task.description,
                maxLines: 2,
                overflow: TextOverflow.ellipsis,
                style: TextStyle(color: Colors.grey[700]),
              ),
              const SizedBox(height: 8),
              Row(
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                children: [
                  Text(
                    'Срок: ${DateFormat('dd.MM.yyyy').format(task.deadline)}',
                    style: TextStyle(
                      color: isOverdue ? Colors.red : Colors.grey,
                      fontWeight: isOverdue ? FontWeight.bold : FontWeight.normal,
                    ),
                  ),
                  Container(
                    padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
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
                ],
              ),
            ],
          ),
        ),
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