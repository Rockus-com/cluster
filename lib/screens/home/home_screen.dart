import 'package:flutter/material.dart';
import 'package:cluster/screens/colleagues/colleagues_screen.dart';
import 'package:cluster/screens/groups/groups_screen.dart';
import 'package:cluster/screens/schedule/schedule_screen.dart';
import 'package:cluster/screens/tasks/tasks_screen.dart';
import 'package:cluster/screens/auth/login_screen.dart';

class HomeScreen extends StatelessWidget {
  const HomeScreen({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text(
          'Секретарь',
          style: TextStyle(
            fontWeight: FontWeight.bold,
            fontSize: 20,
          ),
        ),
        backgroundColor: Colors.blue[700],
        foregroundColor: Colors.white,
        actions: [
          // Кнопка уведомлений
          IconButton(
            icon: const Icon(Icons.notifications),
            onPressed: () => _showNotifications(context),
            tooltip: 'Уведомления',
          ),
          // Кнопка звонков
          IconButton(
            icon: const Icon(Icons.phone),
            onPressed: () => _makeCall(context),
            tooltip: 'Звонки',
          ),
          // Кнопка чатов
          IconButton(
            icon: const Icon(Icons.chat),
            onPressed: () => _openChats(context),
            tooltip: 'Чаты',
          ),
          // Кнопка меню
          PopupMenuButton<String>(
            itemBuilder: (BuildContext context) => [
              const PopupMenuItem(
                value: 'profile',
                child: Text('Профиль'),
              ),
              const PopupMenuItem(
                value: 'settings',
                child: Text('Настройки'),
              ),
              const PopupMenuItem(
                value: 'logout',
                child: Text('Выйти'),
              ),
            ],
            onSelected: (String value) => _handleMenuSelection(context, value),
            icon: const Icon(Icons.more_vert),
            tooltip: 'Меню',
          ),
        ],
      ),
      body: Padding(
        padding: const EdgeInsets.all(16.0),
        child: GridView.count(
          crossAxisCount: 2,
          crossAxisSpacing: 16,
          mainAxisSpacing: 16,
          childAspectRatio: 1.2,
          children: [
            // Кнопка расписания
            _buildFeatureButton(
              context,
              'Расписание',
              Icons.calendar_today,
              Colors.blue,
              () => _navigateToSchedule(context),
            ),
            // Кнопка задач
            _buildFeatureButton(
              context,
              'Задачи от руководства',
              Icons.assignment,
              Colors.green,
              () => _navigateToTasks(context),
            ),
            // Кнопка учащихся
            _buildFeatureButton(
              context,
              'Учащиеся',
              Icons.people,
              Colors.orange,
              () => _navigateToStudents(context),
            ),
            // Кнопка преподаватели
            _buildFeatureButton(
              context,
              'Преподаватели',
              Icons.school,
              Colors.purple,
              () => _navigateToTeachers(context),
            ),
            // Кнопка новости
            _buildFeatureButton(
              context,
              'Школьные новости',
              Icons.newspaper,
              Colors.red,
              () => _navigateToNews(context),
            ),
            // Кнопка документы
            _buildFeatureButton(
              context,
              'Документы',
              Icons.folder,
              Colors.brown,
              () => _navigateToDocuments(context),
            ),
            // Кнопка коллеги
            _buildFeatureButton(
              context,
              'Коллеги',
              Icons.people_outline,
              Colors.teal,
              () => _navigateToColleagues(context),
            ),
            // Кнопка группы
            _buildFeatureButton(
              context,
              'Группы',
              Icons.group,
              Colors.indigo,
              () => _navigateToGroups(context),
            ),
          ],
        ),
      ),
    );
  }

  // Строим кнопку фичи
  Widget _buildFeatureButton(
    BuildContext context,
    String title,
    IconData icon,
    Color color,
    VoidCallback onPressed,
  ) {
    return Card(
      elevation: 4,
      shape: RoundedRectangleBorder(
        borderRadius: BorderRadius.circular(12),
      ),
      child: InkWell(
        onTap: onPressed,
        borderRadius: BorderRadius.circular(12),
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Icon(
              icon,
              size: 40,
              color: color,
            ),
            const SizedBox(height: 12),
            Text(
              title,
              textAlign: TextAlign.center,
              style: TextStyle(
                fontWeight: FontWeight.bold,
                color: Colors.grey[800],
                fontSize: 16,
              ),
            ),
          ],
        ),
      ),
    );
  }

  // Навигация к расписанию
  void _navigateToSchedule(BuildContext context) {
    Navigator.push(
      context,
      MaterialPageRoute(builder: (context) => const ScheduleScreen()),
    );
  }

  // Навигация к задачам
  void _navigateToTasks(BuildContext context) {
    Navigator.push(
      context,
      MaterialPageRoute(builder: (context) => const TasksScreen()),
    );
  }

  // Навигация к учащимся
  void _navigateToStudents(BuildContext context) {
    Navigator.push(
      context,
      MaterialPageRoute(builder: (context) => const StudentsScreen()),
    );
  }

  // Навигация к преподавателям
  void _navigateToTeachers(BuildContext context) {
    Navigator.push(
      context,
      MaterialPageRoute(builder: (context) => const TeachersScreen()),
    );
  }

  // Навигация к новостям
  void _navigateToNews(BuildContext context) {
    Navigator.push(
      context,
      MaterialPageRoute(builder: (context) => const NewsScreen()),
    );
  }

  // Навигация к документам
  void _navigateToDocuments(BuildContext context) {
    Navigator.push(
      context,
      MaterialPageRoute(builder: (context) => const DocumentsScreen()),
    );
  }

  // Навигация к коллегам
  void _navigateToColleagues(BuildContext context) {
    Navigator.push(
      context,
      MaterialPageRoute(builder: (context) => const ColleaguesScreen()),
    );
  }

  // Навигация к группам
  void _navigateToGroups(BuildContext context) {
    Navigator.push(
      context,
      MaterialPageRoute(builder: (context) => const GroupsScreen()),
    );
  }

  // Показать уведомления
  void _showNotifications(BuildContext context) {
    ScaffoldMessenger.of(context).showSnackBar(
      const SnackBar(content: Text('Раздел уведомлений в разработке')),
    );
  }

  // Совершить звонок
  void _makeCall(BuildContext context) {
    ScaffoldMessenger.of(context).showSnackBar(
      const SnackBar(content: Text('Раздел звонков в разработке')),
    );
  }

  // Открыть чаты
  void _openChats(BuildContext context) {
    ScaffoldMessenger.of(context).showSnackBar(
      const SnackBar(content: Text('Раздел чатов в разработке')),
    );
  }

  // Обработка выбора в меню
  void _handleMenuSelection(BuildContext context, String value) {
    switch (value) {
      case 'profile':
        Navigator.push(
          context,
          MaterialPageRoute(builder: (context) => const ProfileScreen()),
        );
        break;
      case 'settings':
        Navigator.push(
          context,
          MaterialPageRoute(builder: (context) => const SettingsScreen()),
        );
        break;
      case 'logout':
        _showLogoutDialog(context);
        break;
    }
  }

  // Диалог выхода
  void _showLogoutDialog(BuildContext context) {
    showDialog(
      context: context,
      builder: (BuildContext context) {
        return AlertDialog(
          title: const Text('Выход'),
          content: const Text('Вы уверены, что хотите выйти?'),
          actions: [
            TextButton(
              onPressed: () => Navigator.of(context).pop(),
              child: const Text('Отмена'),
            ),
            TextButton(
              onPressed: () {
                Navigator.of(context).pop();
                // Возврат к экрану авторизации
                Navigator.pushReplacement(
                  context,
                  MaterialPageRoute(builder: (context) => const LoginScreen()),
                );
              },
              child: const Text('Выйти'),
            ),
          ],
        );
      },
    );
  }
}

// Заглушки экранов (реализуйте их позже)
class StudentsScreen extends StatelessWidget {
  const StudentsScreen({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: const Text('Учащиеся')),
      body: const Center(child: Text('Экран учащихся')),
    );
  }
}

class TeachersScreen extends StatelessWidget {
  const TeachersScreen({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: const Text('Преподаватели')),
      body: const Center(child: Text('Экран преподавателей')),
    );
  }
}

class NewsScreen extends StatelessWidget {
  const NewsScreen({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: const Text('Школьные новости')),
      body: const Center(child: Text('Экран новостей')),
    );
  }
}

class DocumentsScreen extends StatelessWidget {
  const DocumentsScreen({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: const Text('Документы')),
      body: const Center(child: Text('Экран документов')),
    );
  }
}

class ProfileScreen extends StatelessWidget {
  const ProfileScreen({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: const Text('Профиль')),
      body: const Center(child: Text('Экран профиля')),
    );
  }
}

class SettingsScreen extends StatelessWidget {
  const SettingsScreen({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: const Text('Настройки')),
      body: const Center(child: Text('Экран настроек')),
    );
  }
}
