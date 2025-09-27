// lib/di/dependency_injection.dart
import 'package:cluster/data/repositories/http_repo.dart';
import 'package:cluster/data/repositories/websocket_repo.dart';
import 'package:cluster/data/repositories/cache_repo.dart';
import 'package:cluster/data/repositories/users_repo.dart';
import 'package:cluster/data/repositories/chats_repo.dart';
import 'package:cluster/data/repositories/tasks_repo.dart';
import 'package:cluster/domain/services/http_service.dart';
import 'package:cluster/domain/services/websocket_service.dart';
import 'package:cluster/domain/services/cache_service.dart';
import 'package:cluster/domain/services/users_service.dart';
import 'package:cluster/domain/services/chats_service.dart';
import 'package:cluster/domain/services/tasks_service.dart';
import 'package:cluster/domain/usecases/auth_uc.dart';
import 'package:cluster/domain/usecases/load_chats_uc.dart';
import 'package:cluster/domain/usecases/create_chat_uc.dart';
import 'package:cluster/domain/usecases/add_to_chat_uc.dart';
import 'package:cluster/domain/usecases/send_message_uc.dart';
import 'package:cluster/domain/usecases/edit_message_uc.dart';
import 'package:cluster/domain/usecases/delete_message_uc.dart';
import 'package:cluster/domain/usecases/get_messages_uc.dart';
import 'package:cluster/domain/usecases/load_tasks_uc.dart';
import 'package:cluster/domain/usecases/create_task_uc.dart';
import 'package:cluster/domain/usecases/edit_task_uc.dart';
import 'package:cluster/domain/usecases/delete_task_uc.dart';
import 'package:cluster/domain/usecases/complete_task_uc.dart';
import 'package:cluster/domain/usecases/load_users_uc.dart';
import 'package:cluster/domain/usecases/update_user_info_uc.dart';
import 'package:cluster/domain/bloc/home_cubit.dart';
import 'package:cluster/domain/bloc/auth_cubit.dart';
import 'package:cluster/domain/bloc/chats_cubit.dart';
import 'package:cluster/domain/bloc/chat_cubit.dart';
import 'package:cluster/domain/bloc/tasks_cubit.dart';
import 'package:cluster/domain/bloc/task_cubit.dart';
import 'package:cluster/domain/bloc/settings_cubit.dart';
import 'package:cluster/domain/bloc/about_cubit.dart';
import 'package:dio/dio.dart';
import 'package:flutter_secure_storage/flutter_secure_storage.dart';
import 'package:get_it/get_it.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'package:web_socket_channel/web_socket_channel.dart';

final getIt = GetIt.instance;

Future<void> initDependencies() async {
  // External
  getIt.registerSingleton<Dio>(Dio());
  getIt.registerSingleton<FlutterSecureStorage>(const FlutterSecureStorage());
  final sharedPrefs = await SharedPreferences.getInstance();
  getIt.registerSingleton<SharedPreferences>(sharedPrefs);

  // Data sources / Repos
  getIt.registerSingleton<HttpRepo>(HttpRepoImpl(getIt<Dio>(), getIt<FlutterSecureStorage>()));
  getIt.registerSingleton<WebSocketRepo>(WebSocketRepoImpl());
  getIt.registerSingleton<CacheRepo>(CacheRepoImpl(getIt<SharedPreferences>()));

  getIt.registerSingleton<UsersRepo>(UsersRepoImpl(
    getIt<HttpRepo>(),
    getIt<WebSocketRepo>(),
    getIt<CacheRepo>(),
  ));

  getIt.registerSingleton<ChatsRepo>(ChatsRepoImpl(
    getIt<HttpRepo>(),
    getIt<WebSocketRepo>(),
    getIt<CacheRepo>(),
  ));

  getIt.registerSingleton<TasksRepo>(TasksRepoImpl(
    getIt<HttpRepo>(),
    getIt<WebSocketRepo>(),
    getIt<CacheRepo>(),
  ));

  // Services
  getIt.registerSingleton<HttpService>(HttpService(getIt<UsersRepo>()));
  getIt.registerSingleton<WebSocketService>(WebSocketService(getIt<ChatsRepo>()));
  getIt.registerSingleton<CacheService>(CacheService(getIt<CacheRepo>()));

  getIt.registerSingleton<UsersService>(UsersService(getIt<UsersRepo>()));
  getIt.registerSingleton<ChatsService>(ChatsService(getIt<ChatsRepo>()));
  getIt.registerSingleton<TasksService>(TasksService(getIt<TasksRepo>()));

  // Use Cases
  getIt.registerSingleton<AuthUC>(AuthUC(getIt<UsersService>()));
  getIt.registerSingleton<LoadChatsUC>(LoadChatsUC(getIt<ChatsService>()));
  getIt.registerSingleton<CreateChatUC>(CreateChatUC(getIt<ChatsService>()));
  getIt.registerSingleton<AddToChatUC>(AddToChatUC(getIt<ChatsService>()));
  getIt.registerSingleton<SendMessageUC>(SendMessageUC(getIt<ChatsService>()));
  getIt.registerSingleton<EditMessageUC>(EditMessageUC(getIt<ChatsService>()));
  getIt.registerSingleton<DeleteMessageUC>(DeleteMessageUC(getIt<ChatsService>()));
  getIt.registerSingleton<GetMessagesUC>(GetMessagesUC(getIt<ChatsService>()));
  getIt.registerSingleton<LoadTasksUC>(LoadTasksUC(getIt<TasksService>()));
  getIt.registerSingleton<CreateTaskUC>(CreateTaskUC(getIt<TasksService>()));
  getIt.registerSingleton<EditTaskUC>(EditTaskUC(getIt<TasksService>()));
  getIt.registerSingleton<DeleteTaskUC>(DeleteTaskUC(getIt<TasksService>()));
  getIt.registerSingleton<CompleteTaskUC>(CompleteTaskUC(getIt<TasksService>()));
  getIt.registerSingleton<LoadUsersUC>(LoadUsersUC(getIt<UsersService>()));
  getIt.registerSingleton<UpdateUserInfoUC>(UpdateUserInfoUC(getIt<UsersService>()));
  
  // Cubits
  getIt.registerFactory<HomeCubit>(() => HomeCubit(getIt<LoadTasksUC>(), getIt<LoadChatsUC>()));
  getIt.registerFactory<AuthCubit>(() => AuthCubit(getIt<AuthUC>()));
  getIt.registerFactory<ChatsCubit>(() => ChatsCubit(getIt<LoadChatsUC>(), getIt<CreateChatUC>(), getIt<AddToChatUC>(), getIt<LoadUsersUC>()));
  getIt.registerFactory<ChatCubit>(() => ChatCubit(getIt<SendMessageUC>(), getIt<EditMessageUC>(), getIt<DeleteMessageUC>(), getIt<GetMessagesUC>()));
  getIt.registerFactory<TasksCubit>(() => TasksCubit(getIt<LoadTasksUC>(), getIt<CreateTaskUC>(), getIt<LoadUsersUC>()));
  getIt.registerFactory<TaskCubit>(() => TaskCubit(getIt<EditTaskUC>(), getIt<DeleteTaskUC>(), getIt<CompleteTaskUC>()));
  getIt.registerFactory<SettingsCubit>(() => SettingsCubit());
  getIt.registerFactory<AboutCubit>(() => AboutCubit(getIt<UpdateUserInfoUC>()));
}