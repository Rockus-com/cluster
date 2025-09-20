import 'package:flutter/material.dart';
import 'package:intl/intl.dart';
import 'package:table_calendar/table_calendar.dart';
import 'package:cluster/database/models.dart';
import 'package:cluster/repositories/repositories.dart';

class ScheduleScreen extends StatefulWidget {
  const ScheduleScreen({super.key});

  @override
  _ScheduleScreenState createState() => _ScheduleScreenState();
}

class _ScheduleScreenState extends State<ScheduleScreen> {
  final ScheduleRepository _scheduleRepository = ScheduleRepository();
  CalendarFormat _calendarFormat = CalendarFormat.week;
  DateTime _focusedDay = DateTime.now();
  DateTime _selectedDay = DateTime.now();
  Map<DateTime, List<ScheduleItem>> _scheduleItems = {};
  bool _isLoading = true;

  // Получаем первый и последний день для календаря
  DateTime get _firstDay {
    final now = DateTime.now();
    return DateTime(now.year - 1, now.month, now.day);
  }

  DateTime get _lastDay {
    final now = DateTime.now();
    return DateTime(now.year + 1, now.month, now.day);
  }

  @override
  void initState() {
    super.initState();
    _loadScheduleData();
  }

  Future<void> _loadScheduleData() async {
    try {
      final scheduleItems =
          await _scheduleRepository.getScheduleForDate(_selectedDay);

      // Группируем элементы расписания по дате
      final Map<DateTime, List<ScheduleItem>> groupedItems = {};
      for (var item in scheduleItems) {
        final date = DateTime(item.date.year, item.date.month, item.date.day);
        if (groupedItems[date] == null) {
          groupedItems[date] = [];
        }
        groupedItems[date]!.add(item);
      }

      setState(() {
        _scheduleItems = groupedItems;
        _isLoading = false;
      });
    } catch (e) {
      setState(() {
        _isLoading = false;
      });
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text('Ошибка загрузки расписания: $e')),
      );
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Расписание'),
        backgroundColor: Colors.blue[700],
        foregroundColor: Colors.white,
        actions: [
          IconButton(
            icon: const Icon(Icons.today),
            onPressed: () {
              setState(() {
                _focusedDay = DateTime.now();
                _selectedDay = DateTime.now();
              });
              _loadScheduleData();
            },
            tooltip: 'Сегодня',
          ),
          IconButton(
            icon: const Icon(Icons.add),
            onPressed: _addScheduleItem,
            tooltip: 'Добавить занятие',
          ),
        ],
      ),
      body: Column(
        children: [
          // Календарь для выбора даты
          TableCalendar(
            firstDay: _firstDay,
            lastDay: _lastDay,
            focusedDay: _focusedDay,
            calendarFormat: _calendarFormat,
            selectedDayPredicate: (day) {
              return isSameDay(_selectedDay, day);
            },
            onDaySelected: (selectedDay, focusedDay) {
              setState(() {
                _selectedDay = selectedDay;
                _focusedDay = focusedDay;
              });
              _loadScheduleData();
            },
            onFormatChanged: (format) {
              setState(() {
                _calendarFormat = format;
              });
            },
            onPageChanged: (focusedDay) {
              setState(() {
                _focusedDay = focusedDay;
              });
            },
            headerStyle: const HeaderStyle(
              formatButtonVisible: true,
              titleCentered: true,
              formatButtonShowsNext: false,
            ),
            calendarStyle: CalendarStyle(
              selectedDecoration: BoxDecoration(
                color: Colors.blue,
                shape: BoxShape.circle,
              ),
              todayDecoration: BoxDecoration(
                color: Colors.blue.shade100,
                shape: BoxShape.circle,
              ),
            ),
            locale: 'ru_RU',
          ),
          const SizedBox(height: 16),

          // Заголовок с выбранной датой
          Padding(
            padding: const EdgeInsets.symmetric(horizontal: 16),
            child: Text(
              DateFormat('EEEE, d MMMM y', 'ru_RU').format(_selectedDay),
              style: const TextStyle(
                fontSize: 18,
                fontWeight: FontWeight.bold,
              ),
            ),
          ),
          const SizedBox(height: 16),

          // Список занятий
          Expanded(
            child: _isLoading
                ? const Center(child: CircularProgressIndicator())
                : _buildScheduleList(),
          ),
        ],
      ),
    );
  }

  Widget _buildScheduleList() {
    final normalizedDate =
        DateTime(_selectedDay.year, _selectedDay.month, _selectedDay.day);
    final selectedItems = _scheduleItems[normalizedDate] ?? [];

    if (selectedItems.isEmpty) {
      return const Center(
        child: Text('Нет занятий на выбранный день'),
      );
    }

    // Сортируем занятия по времени начала
    selectedItems.sort((a, b) => a.startTime.compareTo(b.startTime));

    return ListView.builder(
      padding: const EdgeInsets.symmetric(horizontal: 16),
      itemCount: selectedItems.length,
      itemBuilder: (context, index) {
        return _buildScheduleCard(selectedItems[index], context);
      },
    );
  }

  Widget _buildScheduleCard(ScheduleItem item, BuildContext context) {
    return Card(
      margin: const EdgeInsets.only(bottom: 12),
      child: InkWell(
        onTap: () => _showScheduleItemDetails(context, item),
        child: Padding(
          padding: const EdgeInsets.all(16),
          child: Row(
            children: [
              // Иконка урока или перемены
              Icon(
                item.isLesson ? Icons.school : Icons.free_breakfast,
                color: item.isLesson ? Colors.blue : Colors.grey,
                size: 30,
              ),
              const SizedBox(width: 16),

              // Информация о занятии
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      '${item.startTime} - ${item.endTime}',
                      style: const TextStyle(
                        fontWeight: FontWeight.bold,
                        fontSize: 16,
                      ),
                    ),
                    const SizedBox(height: 4),
                    Text(
                      item.subject,
                      style: TextStyle(
                        fontSize: 18,
                        fontWeight: FontWeight.w500,
                        color: item.isLesson ? Colors.black : Colors.grey,
                      ),
                    ),
                    if (item.isLesson) ...[
                      const SizedBox(height: 4),
                      Text(
                        '${item.teacher} • ${item.classroom}',
                        style: const TextStyle(
                          color: Colors.grey,
                        ),
                      ),
                    ],
                  ],
                ),
              ),
              if (item.isLesson) const Icon(Icons.arrow_forward_ios, size: 16),
            ],
          ),
        ),
      ),
    );
  }

  void _showScheduleItemDetails(BuildContext context, ScheduleItem item) {
    if (!item.isLesson) return;

    showDialog(
      context: context,
      builder: (BuildContext context) {
        return AlertDialog(
          title: Text(item.subject),
          content: SingleChildScrollView(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              mainAxisSize: MainAxisSize.min,
              children: [
                Text(
                  '${item.startTime} - ${item.endTime}',
                  style: const TextStyle(fontWeight: FontWeight.bold),
                ),
                const SizedBox(height: 8),
                Text('Преподаватель: ${item.teacher}'),
                Text('Кабинет: ${item.classroom}'),
                const SizedBox(height: 16),
                if (item.topics.isNotEmpty) ...[
                  const Text(
                    'Темы урока:',
                    style: TextStyle(fontWeight: FontWeight.bold),
                  ),
                  ...item.topics.map((topic) => Padding(
                        padding: const EdgeInsets.only(top: 4),
                        child: Text('• $topic'),
                      )),
                ],
              ],
            ),
          ),
          actions: [
            TextButton(
              onPressed: () => Navigator.of(context).pop(),
              child: const Text('Закрыть'),
            ),
            IconButton(
              icon: const Icon(Icons.edit),
              onPressed: () {
                Navigator.of(context).pop();
                _editScheduleItem(item);
              },
              tooltip: 'Редактировать',
            ),
            IconButton(
              icon: const Icon(Icons.delete, color: Colors.red),
              onPressed: () {
                Navigator.of(context).pop();
                _deleteScheduleItem(item);
              },
              tooltip: 'Удалить',
            ),
          ],
        );
      },
    );
  }

  void _addScheduleItem() {
    // TODO: Реализовать добавление нового занятия
    ScaffoldMessenger.of(context).showSnackBar(
      const SnackBar(content: Text('Функция добавления занятия в разработке')),
    );
  }

  void _editScheduleItem(ScheduleItem item) {
    // TODO: Реализовать редактирование занятия
    ScaffoldMessenger.of(context).showSnackBar(
      const SnackBar(
          content: Text('Функция редактирования занятия в разработке')),
    );
  }

  Future<void> _deleteScheduleItem(ScheduleItem item) async {
    final confirmed = await showDialog<bool>(
      context: context,
      builder: (BuildContext context) {
        return AlertDialog(
          title: const Text('Удаление занятия'),
          content: const Text('Вы уверены, что хотите удалить это занятие?'),
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
        await _scheduleRepository.deleteScheduleItem(item.id!);
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(content: Text('Занятие удалено')),
        );
        _loadScheduleData(); // Перезагружаем данные
      } catch (e) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(content: Text('Ошибка удаления занятия: $e')),
        );
      }
    }
  }
}
