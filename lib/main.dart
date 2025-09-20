import 'package:flutter/material.dart';
import 'package:sqflite/sqflite.dart';
import 'package:path/path.dart';
import 'package:intl/date_symbol_data_local.dart';
import 'package:flutter_local_notifications/flutter_local_notifications.dart';

// Импорт экранов
import 'screens/auth/login_screen.dart';
import 'database/database_helper.dart';
import 'services/notification_service.dart';

void main() async {
  WidgetsFlutterBinding.ensureInitialized();
  
  // Инициализация данных для локализации дат (русский язык)
  await initializeDateFormatting('ru_RU', null);
  
  // Инициализация базы данных
  final dbHelper = DatabaseHelper();
  await dbHelper.database;
  
  // Инициализация уведомлений
  await NotificationService().initialize();
  
  runApp(const SecretaryApp());
}

class SecretaryApp extends StatelessWidget {
  const SecretaryApp({super.key});

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      title: 'Секретарь',
      theme: ThemeData(
        primarySwatch: Colors.blue,
        visualDensity: VisualDensity.adaptivePlatformDensity,
      ),
      home: const LoginScreen(),
      debugShowCheckedModeBanner: false,
    );
  }
}