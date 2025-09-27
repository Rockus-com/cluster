// lib/app.dart
import 'package:cluster/di/dependency_injection.dart';
import 'package:cluster/presentation/screens/home_screen.dart';
import 'package:cluster/presentation/screens/auth_screen.dart';
import 'package:cluster/presentation/screens/reg_screen.dart';
import 'package:cluster/presentation/screens/forgot_screen.dart';
import 'package:cluster/presentation/screens/chats_screen.dart';
import 'package:cluster/presentation/screens/chat_screen.dart';
import 'package:cluster/presentation/screens/create_chat_screen.dart';
import 'package:cluster/presentation/screens/tasks_screen.dart';
import 'package:cluster/presentation/screens/task_screen.dart';
import 'package:cluster/presentation/screens/create_task_screen.dart';
import 'package:cluster/presentation/screens/about_screen.dart';
import 'package:cluster/presentation/screens/edit_about_screen.dart';
import 'package:cluster/presentation/screens/settings_screen.dart';
import 'package:cluster/domain/bloc/home_cubit.dart';
import 'package:cluster/domain/bloc/auth_cubit.dart';
import 'package:cluster/domain/bloc/chats_cubit.dart';
import 'package:cluster/domain/bloc/chat_cubit.dart';
import 'package:cluster/domain/bloc/tasks_cubit.dart';
import 'package:cluster/domain/bloc/task_cubit.dart';
import 'package:cluster/domain/bloc/settings_cubit.dart';
import 'package:cluster/domain/bloc/about_cubit.dart';
import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:go_router/go_router.dart';

class MyApp extends StatelessWidget {
  const MyApp({super.key});

  @override
  Widget build(BuildContext context) {
    return MaterialApp.router(
      title: 'Cluster',
      theme: ThemeData(primarySwatch: Colors.blue),
      routerConfig: _router,
    );
  }
}

final GoRouter _router = GoRouter(
  initialLocation: '/auth',
  routes: <RouteBase>[
    GoRoute(
      path: '/home',
      builder: (context, state) => BlocProvider(
        create: (_) => getIt<HomeCubit>(),
        child: const HomeScreen(),
      ),
    ),
    GoRoute(
      path: '/settings',
      builder: (context, state) => BlocProvider(
        create: (_) => getIt<SettingsCubit>(),
        child: const SettingsScreen(),
      ),
    ),
    GoRoute(
      path: '/about',
      builder: (context, state) => BlocProvider(
        create: (_) => getIt<AboutCubit>(),
        child: const AboutScreen(),
      ),
    ),
    GoRoute(
      path: '/about/edit',
      builder: (context, state) => const EditAboutScreen(),
    ),
    GoRoute(
      path: '/auth',
      builder: (context, state) => BlocProvider(
        create: (_) => getIt<AuthCubit>(),
        child: const AuthScreen(),
      ),
      routes: [
        GoRoute(
          path: 'reg',
          builder: (context, state) => BlocProvider.value(
            value: getIt<AuthCubit>(),
            child: const RegScreen(),
          ),
        ),
        GoRoute(
          path: 'forgot',
          builder: (context, state) => BlocProvider.value(
            value: getIt<AuthCubit>(),
            child: const ForgotScreen(),
          ),
        ),
      ],
    ),
    GoRoute(
      path: '/chats',
      builder: (context, state) => BlocProvider(
        create: (_) => getIt<ChatsCubit>(),
        child: const ChatsScreen(),
      ),
      routes: [
        GoRoute(
          path: 'create',
          builder: (context, state) => const CreateChatScreen(),
        ),
        GoRoute(
          path: ':id',
          builder: (context, state) => BlocProvider(
            create: (_) => getIt<ChatCubit>(),
            child: ChatScreen(id: state.pathParameters['id']!),
          ),
        ),
      ],
    ),
    GoRoute(
      path: '/tasks',
      builder: (context, state) => BlocProvider(
        create: (_) => getIt<TasksCubit>(),
        child: const TasksScreen(),
      ),
      routes: [
        GoRoute(
          path: 'create',
          builder: (context, state) => const CreateTaskScreen(),
        ),
        GoRoute(
          path: ':id',
          builder: (context, state) => BlocProvider(
            create: (_) => getIt<TaskCubit>(),
            child: TaskScreen(id: state.pathParameters['id']!),
          ),
        ),
      ],
    ),
  ],
);